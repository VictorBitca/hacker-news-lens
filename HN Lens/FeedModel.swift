import HackerNewsKit
import Foundation

public enum FeedState: Hashable {
    case loading
    case loaded(posts: [PostModel])
    case failed
}

@MainActor
public class FeedModel: ObservableObject {
    @Published public var feedType: MainFeedType
    @Published public var state: FeedState = .loading
    
    init(feedType: MainFeedType) {
        self.feedType = feedType
    }
    
    func fetchPostsOnAppear() async {
        switch state {
        case .loaded(_): return
        case .failed, .loading: await fetchPosts()
        }
    }
    
    func fetchPosts() async {
        do {
            let allStories = try await HackerNewsAPI.shared.mainFeedItems(feedType: feedType)
                .enumerated()
                .map { index, item in PostModel(from: item, index: index) }
            
            state = .loaded(posts: allStories)
        } catch {
            state = .failed
        }
    }
}
