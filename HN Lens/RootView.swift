import SwiftUI
import os
import ComposableArchitecture

class Coordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    func gotoHomePage() {
        path.removeLast(path.count)
    }
}

struct Root: ReducerProtocol {
    struct State: Equatable {
        var detail = Detail.State()
    }
    
    enum Action: Equatable {
        case detail(Detail.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            return .none
        }
        
        Scope(state: \.detail, action: /Action.detail) {
            Detail()
        }
    }
}

struct RootView: View {
    let store: StoreOf<Root>
    
    // TODO: integrate coordinator and selectedTab into composable architecture
    @StateObject var coordinator = Coordinator()
    @State private var selectedTab: Panel? = Panel.top
    
    var body: some View {
        NavigationSplitView {
            Sidebar(selection: $selectedTab)
        } detail: {
            NavigationStack(path: $coordinator.path) {
                DetailView(store: store.scope(state: \.detail, action: Root.Action.detail),
                           selection: $selectedTab)
            }
            .environmentObject(coordinator)
        }
        .onOpenURL { url in
            debugPrint("onOpenURL URL", url)
        }
    }
}
