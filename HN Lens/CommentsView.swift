import SwiftUI

struct CommentsView: View {
    @ObservedObject var post: PostModel
    
    @ViewBuilder
    var postView: some View {
        if post.hasText {
            DetailedPostView(post: post)
        } else {
            PostView(post: post)
        }
    }
    
    var body: some View {
        VStack {
            if let comments = post.comments {
                ScrollView {
                    postView.padding()
                    LazyVStack(spacing: 0) {
                        ForEach(comments) { comment in
                            CommentView(comment: comment)
                        }
                    }
                    .scenePadding([.leading, .trailing])
                }
                .refreshable { try? await post.loadComments() }
                .onDisappear { post.commentsDidDisappear() }
            } else {
                ProgressView()
            }
        }
        .task { try? await post.loadComments() }
        .navigationTitle("Comments")
    }
}

struct CommentsView_Previews: PreviewProvider {
    struct Preview: View {
        static func somePost() -> PostModel {
            let post = PostModel(hnID: 33684666,
                                 url: URL(string: "https://defn.io/2022/11/20/ann-franz/"),
                                 title: "Show HN: A native macOS client for Apache Kafka",
                                 author: "Bogdanp",
                                 score: "190",
                                 descendants: "37",
                                 time: "4 hours ago",
                                 kids: [33685217, 33685847, 33684981, 33685312, 33685315, 33686068, 33686319, 33685111, 33687706, 33701029, 33685809, 33686335],
                                 text: nil,
                                 index: 0)
            return post
        }

        @StateObject private var model = Preview.somePost()

        var body: some View {
            CommentsView(post: model)
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

