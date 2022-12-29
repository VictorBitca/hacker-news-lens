import SwiftUI
import os

class Coordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    func gotoHomePage() {
        path.removeLast(path.count)
    }
}

struct RootView: View {
    @ObservedObject var model: AppModel
    @StateObject var coordinator = Coordinator()
    
    @State private var selectedTab: Panel? = Panel.top
    

    var body: some View {
        NavigationSplitView {
            Sidebar(selection: $selectedTab)
        } detail: {
            NavigationStack(path: $coordinator.path) {
                DetailColumn(selection: $selectedTab, model: model)
            }
            .environmentObject(coordinator)
        }
        .onOpenURL { url in
            debugPrint("onOpenURL URL", url)
        }
    }
}
