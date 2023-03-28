import SwiftUI
import HackerNewsKit
import ComposableArchitecture

@main
struct HNLens: App {    
    init() {
        HackerNewsAPI.configureFirebase()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(
                store: Store(initialState: Root.State(), reducer: Root())
            )
        }
    }
}
