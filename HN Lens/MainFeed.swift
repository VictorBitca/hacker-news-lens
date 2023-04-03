import SwiftUI
import HackerNewsKit
import ComposableArchitecture

enum FeedState: Hashable {
    case loading
    case loaded(posts: [PostModel])
    case failed
}

struct MainFeed: ReducerProtocol {
    struct State: Equatable {
        let feedType: MainFeedType
        var feedState: FeedState = .loading
    }
    
    enum Action: Equatable {
        case didAppear
        case refresh
        case feedLoadTaskResult(TaskResult<[PostModel]>)
    }
    
    @Dependency(\.hnClient) var hnClient
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .didAppear:
                if case .loaded = state.feedState { return .none }
                state.feedState = .loading
                return mainFeedTask(type: state.feedType)
            case .refresh:
                return mainFeedTask(type: state.feedType)
            case .feedLoadTaskResult(.success(let posts)):
                state.feedState = .loaded(posts: posts)
                return .none
            case .feedLoadTaskResult(.failure):
                state.feedState = .loaded(posts: [])
                return .none
            }
        }
    }
    
    func mainFeedTask(type: MainFeedType) -> EffectTask<MainFeed.Action> {
        return .task {
            do {
                let allStories = try await hnClient.allStories(type)
                    .enumerated()
                    .map { index, item in PostModel(from: item, index: index) }
                return .feedLoadTaskResult(.success(allStories))
            } catch {
                return .feedLoadTaskResult(.failure(error))
            }
        }
    }
}

struct MainFeedView: View {
    let store: StoreOf<MainFeed>
    
    @EnvironmentObject var coordinator: Coordinator
    @Environment(\.horizontalSizeClass) var sizeClass
    
    let columns = [
        GridItem(.adaptive(minimum: 350, maximum: 600), spacing: 10),
    ]
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { (viewStore: ViewStoreOf<MainFeed>) in
            VStack {
                ZStack {
                    LinearGradient(colors: [Pallete.background.color,
                                            Pallete.background.color,
                                            Pallete.appleViolet.color.opacity(0.25)],
                                   startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                    
                    switch viewStore.state.feedState {
                    case .loading, .failed:
                        ProgressView()
                    case .loaded(let posts):
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
                            }
                            .padding(.horizontal)
                        }
                        .refreshable { viewStore.send(.refresh) }
                    }
                }
            }
            .navigationTitle("News")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: PostModel.self) { post in
                CommentsView(post: post)
            }
            .task {
                viewStore.send(.didAppear)
            }
        }
    }
}

struct MainFeedView_Previews: PreviewProvider {
    struct Preview: View {
        var body: some View {
            MainFeedView(store: Store(initialState: MainFeed.State(feedType: .top), reducer: MainFeed()))
        }
    }

    static var previews: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                Preview()
            }
        } else {
            Preview()
        }
    }
}
