import SwiftUI
import HackerNewsKit
import AttributedText

struct SavedItemsFeedView: View {
    @ObservedObject var model: SavedItemsFeedModel
    @EnvironmentObject var coordinator: Coordinator

    @ViewBuilder
    func postList(posts: [PostModel]) -> some View {
        List() {
            ForEach(posts) { post in
                PostView(post: post)
                    .onAppear {
                        post.didAppear()
                    }.onDisappear {
                        post.didDisappear()
                    }
                    .listRowSeparator(.hidden)
                    .onTapGesture {
                        coordinator.path.append(post)
                    }
            }
        }
        .listStyle(.plain)
        .refreshable { await model.fetchItemsOnAppear() }
    }
    
    @ViewBuilder
    func commentsList(comments: [SavedCommentModel]) -> some View {
        List() {
            ForEach(comments) { comment in
                SavedCommentView(model: comment)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .refreshable { await model.fetchItemsOnAppear() }
    }
    
    var body: some View {
        VStack {
            switch model.state {
            case .loading, .failed:
                ProgressView()
            case .loadedPosts(let posts):
                postList(posts: posts)
            case .loadedComments(let comments):
                commentsList(comments: comments)
            }
        }
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: PostModel.self) { post in
            CommentsView(post: post)
        }
        .task {
            await model.fetchItemsOnAppear()
        }
    }
}

@MainActor
public class SavedCommentModel: Identifiable, ObservableObject {
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
                    .font(.callout)
                    .minimumScaleFactor(0.3)
                    .foregroundColor(.primary)
                AttributedText(CommentParser.buildAttributedText(from: model.comment.text,
                                                                 textColor: Pallete.textPrimary,
                                                                 font: UIFont.preferredFont(forTextStyle: .footnote)) ?? NSAttributedString(string: ""))
//                Text(model.comment.text)
//                    .font(.body)
//                    .foregroundColor(.primary)
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


//struct SavedItemsFeedView_Previews: PreviewProvider {
//    struct Preview: View {
//        private var posts = [
//            PostModel(from: Item.sample1()),
//            PostModel(from: Item.sample2()),
//            PostModel(from: Item.sample3())
//        ]
//        
//        @StateObject private var model = AppModel.preview
//
//        var body: some View {
//            FeedView(model: model.topFeedModel).onAppear {
//                model.loadDummyData()
//            }
//        }
//    }
//
//    static var previews: some View {
//        if #available(iOS 16.0, *) {
//            NavigationStack {
//                Preview()
//            }
//        } else {
//            Preview()
//        }
//    }
//}
