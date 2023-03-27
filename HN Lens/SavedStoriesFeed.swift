import SwiftUI
import HackerNewsKit
import ComposableArchitecture

struct SavedStoriesFeed: ReducerProtocol, Hashable {
    enum Action: Equatable {
        case viewAppeared
        case storiesFetched([PostModel])
        case refresh
    }
    
    enum FeedState: Equatable {
        case loading
        case loaded
    }
    
    struct State: Equatable {
        let saveType: SaveType
        var feedState: FeedState = .loading
        var loadedPosts = [PostModel]()
        var title = "Stories"
    }
    
    private enum FetchRequestID {}
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .viewAppeared:
            
            switch state.saveType {
            case .upvote:
                state.title = "Upvoted Stories"
            case .favorite:
                state.title = "Favorite Stories"
            }
            
            switch state.feedState {
            case .loaded:
                return .none
            case .loading:
                return fetchAllStories(state: &state)
            }
            
        case .storiesFetched(let posts):
            state.loadedPosts += posts
            state.feedState = .loaded
            return .none
        case .refresh:
            state.loadedPosts = []
            return .merge(
                .cancel(id: FetchRequestID.self),
                fetchAllStories(state: &state)
            )
        }
    }
    
    private func fetchAllStories(state: inout State) -> EffectTask<Action> {
        let saveType = state.saveType
        
        return .run { send in
            let channel = try HackerNewsAPI.shared.savedStories(of: saveType)
                .map { savedStories in
                    savedStories.map { PostModel(from: $0, index: nil) }
                }
            
            for await stories in channel {
                await send(.storiesFetched(stories))
            }                
        }
        .cancellable(id: FetchRequestID.self)
    }
}

struct SavedPostsFeedView: View {
    let store: StoreOf<SavedStoriesFeed>
    @EnvironmentObject var coordinator: Coordinator
    let columns = [
        GridItem(.adaptive(minimum: 350, maximum: 600), spacing: 10),
    ]
    
    @ViewBuilder
    func postList(posts: [PostModel]) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(posts) { post in
                    PostView(post: post)
                        .onAppear {
                            post.didAppear()
                        }
                        .onDisappear {
                            post.didDisappear()
                        }
                        .listRowSeparator(.hidden)
                        .onTapGesture {
                            coordinator.path.append(post)
                        }
                }
            }.padding(.horizontal)
        }
    }

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { (viewStore: ViewStoreOf<SavedStoriesFeed>) in
            VStack {
                switch viewStore.feedState {
                case .loading:
                    ProgressView()
                case .loaded:
                    postList(posts: viewStore.loadedPosts)
                        .refreshable { viewStore.send(.refresh) }
                }
            }
            .navigationTitle(viewStore.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: PostModel.self) { post in
                CommentsView(post: post)
            }
            .onAppear { viewStore.send(.viewAppeared) }
        }
    }
}
