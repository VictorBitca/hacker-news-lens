import SwiftUI
import HackerNewsKit

@main
struct HNLens: App {
    @StateObject private var model = AppModel()
    
    init() {
        HackerNewsAPI.configureFirebase()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(model: model)
        }
    }
}
