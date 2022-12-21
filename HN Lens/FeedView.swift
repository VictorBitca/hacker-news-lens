import SwiftUI
import HackerNewsKit

struct FeedView: View {
    @ObservedObject var model: FeedModel
    @EnvironmentObject var coordinator: Coordinator
    
    var gridItemLayout = [GridItem(.adaptive(minimum: 130), alignment: .top)]

    var body: some View {
        VStack {
            switch model.state {
            case .loading, .failed:
                ProgressView()
            case .loaded(let posts):
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
                .refreshable { await model.fetchPosts() }
            }
        }
        .navigationTitle("News")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: PostModel.self) { post in
            CommentsView(post: post)
        }
        .task {
            await model.fetchPostsOnAppear()
        }
    }
}

struct NewsFeedView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var model = AppModel.preview

        var body: some View {
            FeedView(model: model.topFeedModel)
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
