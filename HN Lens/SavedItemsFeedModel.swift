import HackerNewsKit
import Foundation
import AsyncAlgorithms

@MainActor
public class SavedItemsFeedModel: ObservableObject {
    enum FeedType: Hashable {
        public enum SaveType: Hashable {
            case upvoted
            case favorite
        }
        
        case stories(SaveType)
        case comments(SaveType)
    }
    
    enum FeedState {
        case loading
        case loadedPosts(posts: [PostModel])
        case loadedComments(comments: [SavedCommentModel])
        case failed
    }
    
    @Published var feedType: FeedType
    @Published var state: FeedState = .loading
    
    lazy var title: String = {
        switch feedType {
        case .stories(.upvoted): return "Upvoted Stories"
        case .comments(.upvoted): return "Upvoted Comments"
        case .stories(.favorite): return "Favorite Stories"
        case .comments(.favorite): return "Favorite Comments"
        }
    }()
    
    init(feedType: FeedType) {
        self.feedType = feedType
    }
    
    func fetchItemsOnAppear() async {
        switch state {
        case .loadedPosts(_), .loadedComments(_): return
        case .failed, .loading:
            switch feedType {
            case .stories(_): await loadSavedStories()
            case .comments(_): await loadSavedComments()
            }
        }
    }
    
    func loadSavedStories() async {
        do {
            state = .loading
            
            let channel = try savedStoriesIDs()
                .map { savedStories in
                    savedStories.map { PostModel(from: $0) }
                }
            
            for await nextBatch in channel {
                var previousPosts = [PostModel]()
                if case let .loadedPosts(posts) = state {
                    previousPosts = posts
                }
                state = .loadedPosts(posts: previousPosts + nextBatch)
            }
        } catch {
            state = .failed
        }
    }
    
    func loadSavedComments() async {
        do {
            state = .loading
            
            let stream = try savedCommentsIDs().map { comment in
                comment.map { SavedCommentModel(parentPost: $0.parentStory, comment: $0.comment) }
            }
            
            for try await nextBatch in stream {
                var previousItems = [SavedCommentModel]()
                if case let .loadedComments(comments) = state {
                    previousItems = comments
                }
                state = .loadedComments(comments: previousItems + nextBatch)
            }
        } catch {
            state = .failed
        }
    }
    
    private func savedStoriesIDs() throws -> AsyncChannel<[StoryItem]> {
        switch feedType {
        case .stories(.upvoted): return try HackerNewsAPI.shared.savedStories(of: .upvote)
        case .stories(.favorite): return try HackerNewsAPI.shared.savedStories(of: .favorite)
        default: throw "This is not possible"
        }
    }
    
    private func savedCommentsIDs() throws -> AsyncChannel<[(parentStory: StoryItem, comment: CommentItem)]> {
        switch feedType {
        case .comments(.upvoted): return try HackerNewsAPI.shared.savedComments(of: .upvote)
        case .comments(.favorite): return try HackerNewsAPI.shared.savedComments(of: .favorite)
        default: throw "This is not possible"
        }
    }
}

extension SavedItemsFeedModel: Hashable {
    public static func == (lhs: SavedItemsFeedModel, rhs: SavedItemsFeedModel) -> Bool {
        return lhs.feedType == rhs.feedType
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(feedType)
    }
}
