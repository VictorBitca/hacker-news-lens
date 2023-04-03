import SwiftUI
import HackerNewsKit
import ComposableArchitecture
import XCTestDynamicOverlay

@main
struct HNLens: App {    
    init() {
        HackerNewsAPI.configureFirebase()
    }
    
    var body: some Scene {
        WindowGroup {
            if !_XCTIsTesting {
                RootView(
                    store: Store(initialState: Root.State(), reducer: Root())
                )
            }
        }
    }
}
