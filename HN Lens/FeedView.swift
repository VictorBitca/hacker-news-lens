import SwiftUI
import HackerNewsKit

struct ContentView: View {
   @State var frame: CGSize = .zero
    
    var body: some View {
        HStack {
            GeometryReader { (geometry) in
                self.makeView(geometry)
            }
        }
    }
    
    func makeView(_ geometry: GeometryProxy) -> some View {
        print(geometry.size.width, geometry.size.height)

        DispatchQueue.main.async { self.frame = geometry.size }

        return Text("Test")
                .frame(width: geometry.size.width)
                .overlay(Color(.red))
    }
}

struct FeedView: View {
    @ObservedObject var model: FeedModel
    @EnvironmentObject var coordinator: Coordinator
    @Environment(\.horizontalSizeClass) var sizeClass
    
    let columns = [
        GridItem(.adaptive(minimum: 350, maximum: 600), spacing: 10),
    ]

    var body: some View {
        VStack {
            switch model.state {
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
