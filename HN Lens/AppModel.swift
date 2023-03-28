import SwiftUI
import HackerNewsKit

@MainActor
public class AppModel: ObservableObject {    
    let topFeedModel = FeedModel(feedType: .top)
    let bestFeedModel = FeedModel(feedType: .best)
    let newFeedModel = FeedModel(feedType: .new)
    let askFeedModel = FeedModel(feedType: .ask)
    let showFeedModel = FeedModel(feedType: .show)
    let jobsFeedModel = FeedModel(feedType: .jobs)
    let searchModel = SearchModel()
}

public extension AppModel {
    static let preview = AppModel()
}
