import SwiftUI
import HackerNewsKit
import ComposableArchitecture

struct SavedCommentsFeed: ReducerProtocol {
    enum Action: Equatable {
        case viewAppeared
        case commentsFetched([SavedCommentModel])
        case refresh
    }
    
    enum FeedState: Equatable {
        case loading
        case loaded
    }
    
    struct State: Equatable {
        let saveType: SaveType
        var feedState: FeedState = .loading
        var loadedComments = [SavedCommentModel]()
        var title = "Comments"
    }
    
    private enum FetchRequestID {}
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .viewAppeared:
            switch state.saveType {
            case .upvote:
                state.title = "Upvoted Comments"
            case .favorite:
                state.title = "Favorite Comments"
            }
            
            switch state.feedState {
            case .loaded:
                return .none
            case .loading:
                return fetchAllComments(state: &state)
            }
        case .commentsFetched(let comments):
            state.loadedComments += comments
            state.feedState = .loaded
            return .none
        case .refresh:
            state.loadedComments = []
            return .merge(
                .cancel(id: FetchRequestID.self),
                fetchAllComments(state: &state)
            )
        }
    }
    
    private func fetchAllComments(state: inout State) -> EffectTask<Action> {
        let saveType = state.saveType
        
        return .run { send in
            let stream = try HackerNewsAPI.shared.savedComments(of: saveType).map { parentsAndComments in
                parentsAndComments.map { SavedCommentModel(parentPost: $0.parentStory, comment: $0.comment) }
            }
            
            for await comments in stream {
                await send(.commentsFetched(comments))
            }
        }
        .cancellable(id: FetchRequestID.self)
    }
}

struct SavedCommentsFeedView: View {
    let store: StoreOf<SavedCommentsFeed>
    @EnvironmentObject var coordinator: Coordinator
    
    @ViewBuilder
    func commentsList(comments: [SavedCommentModel]) -> some View {
        ScrollView {
            ForEach(comments) { comment in
                SavedCommentView(model: comment)
                    .listRowSeparator(.hidden)
            }
            .padding(.horizontal)
        }
    }

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { (viewStore: ViewStoreOf<SavedCommentsFeed>) in
            VStack {
                switch viewStore.feedState {
                case .loading:
                    ProgressView()
                case .loaded:
                    commentsList(comments: viewStore.loadedComments)
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

@MainActor
public class SavedCommentModel: Equatable, Identifiable, ObservableObject {
    nonisolated public static func == (lhs: SavedCommentModel, rhs: SavedCommentModel) -> Bool {
        return lhs.parentPost == rhs.parentPost && lhs.comment == rhs.comment
    }
    
    let parentPost: StoryItem
    let comment: CommentItem
    
    nonisolated init(parentPost: StoryItem, comment: CommentItem) {
        self.parentPost = parentPost
        self.comment = comment
    }
}

struct SavedCommentView: View {
    @ObservedObject var model: SavedCommentModel
    
    var body: some View {
        HStack() {
            VStack(alignment: .leading) {
                Text(model.parentPost.title)
                    .font(.body)
                    .bold()
                    .minimumScaleFactor(0.3)
                    .foregroundColor(.primary)

                if let attributedText = CommentParser.buildAttributedText(from: model.comment.text,
                                                                          textColor: Pallete.textPrimary,
                                                                          font: UIFont.preferredFont(forTextStyle: .callout)),
                    let text = try? AttributedString(attributedText, including: \.uiKit) {
                    Text(text)
                        .padding()
                }
            }
            .padding()
        }
        .cornerRadius(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Pallete.grayLight.color)
        )
    }
}
