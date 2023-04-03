import SwiftUI
import HackerNewsKit
import ComposableArchitecture
import XCTestDynamicOverlay

struct HNAPI {
    var allStories: (MainFeedType) async throws -> [StoryItem]
}

extension DependencyValues {
    var hnClient: HNAPI {
        get { self[HNAPI.self] }
        set { self[HNAPI.self] = newValue }
    }
}

extension HNAPI: DependencyKey {
    static let liveValue = Self(
        allStories: { feedType in
            return try await HackerNewsAPI.shared.mainFeedItems(feedType: feedType)
        }
    )
    
    static let previewValue = Self(
        allStories: { _ in
            return RawItem.mockItems.compactMap { StoryItem(rawItem: $0) }
        }
    )
    
    static let testValue = Self(
        allStories: unimplemented("\(Self.self).allStories")
    )
}

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
