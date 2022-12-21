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
    
    @State private var selection: Panel? = Panel.top

    var body: some View {
        NavigationSplitView {
            Sidebar(selection: $selection)
        } detail: {
            NavigationStack(path: $coordinator.path) {
                DetailColumn(selection: $selection, model: model)
            }
            .environmentObject(coordinator)
        }
        .onChange(of: selection) { _ in
            coordinator.path.removeLast(coordinator.path.count)
        }
        .onOpenURL { url in
            debugPrint("onOpenURL URL", url)
        }
    }
}
