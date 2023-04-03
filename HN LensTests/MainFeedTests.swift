import ComposableArchitecture
import HackerNewsKit
import XCTest

@testable import HN_Lens

extension RawItem {
    static var mockItems: [RawItem] {
        let data =
        """
        [
        {
          "by" : "poeti8",
          "descendants" : 55,
          "id" : 35419771,
          "kids" : [ 35421115, 35420807, 35420560 ],
          "score" : 349,
          "time" : 1680506881,
          "title" : "Show HN: Unknown Pleasures, a tiny web experiment with WebGL",
          "type" : "story",
          "url" : "https://pouria.dev/unknown-pleasures"
        },
        {
          "by" : "AshleysBrain",
          "descendants" : 200,
          "id" : 35421554,
          "kids" : [ 35422381, 35422559, 35422217 ],
          "score" : 227,
          "time" : 1680520209,
          "title" : "Safari releases are development hell",
          "type" : "story",
          "url" : "https://www.construct.net/en/blogs/ashleys-blog-2/safari-releases-development-1616"
        },
        {
          "by" : "kungfudoi",
          "descendants" : 361,
          "id" : 35422842,
          "kids" : [ 35424381, 35423963, 35424770 ],
          "score" : 246,
          "time" : 1680527162,
          "title" : "AI won't steal your job, people leveraging AI will",
          "type" : "story",
          "url" : "https://cmte.ieee.org/futuredirections/2023/04/03/ai-wont-steal-your-job-people-leveraging-ai-will/"
        },
        {
          "by" : "whoishiring",
          "descendants" : 94,
          "id" : 35424807,
          "kids" : [ 35427524, 35427522, 35427504 ],
          "score" : 118,
          "text" : "Please state the location and include REMOTE, INTERNS...",
          "time" : 1680534122,
          "title" : "Ask HN: Who is hiring? (April 2023)",
          "type" : "story"
        }
        ]
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let rawItems = try! decoder.decode([RawItem].self, from: data)
        return rawItems
    }
}

@MainActor
final class MainFeedTests: XCTestCase {
    func testHappyPath() async {
        let expectedStory1 = StoryItem(rawItem: RawItem.mockItems[0])!
        let expectedPostModel1 = PostModel(from: expectedStory1, index: 0)
        let expectedStory2 = StoryItem(rawItem: RawItem.mockItems[1])!
        let expectedPostModel2 = PostModel(from: expectedStory2, index: 0)
        
        let store = TestStore(
            initialState: MainFeed.State(feedType: .top),
            reducer: MainFeed()
        ) {
            $0.hnClient.allStories = { _ in return [expectedStory1] }
        }
        
        await store.send(.didAppear)
        await store.receive(.feedLoadTaskResult(.success([expectedPostModel1]))) { state in
            state.feedState = .loaded(posts: [expectedPostModel1])
        }
        
        store.dependencies.hnClient.allStories = { _ in return [expectedStory2] }
        
        await store.send(.refresh)
        await store.receive(.feedLoadTaskResult(.success([expectedPostModel2]))) { state in
            state.feedState = .loaded(posts: [expectedPostModel2])
        }
    }
    
    func testUnhappyPath() async {
        let store = TestStore(
            initialState: MainFeed.State(feedType: .top),
            reducer: MainFeed()
        ) {
            $0.hnClient.allStories = { _ in throw "Not available" }
        }
        
        await store.send(.didAppear)
        
        await store.receive(.feedLoadTaskResult(.failure("Not available"))) { state in
            state.feedState = .loaded(posts: [])
        }
    }
}
