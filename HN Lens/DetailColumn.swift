import SwiftUI
import ComposableArchitecture

struct Detail: ReducerProtocol {
    struct State: Equatable {
        var profile = Profile.State()
    }
    
    enum Action: Equatable {
        case profile(Profile.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            return .none
//            switch action {
//            case .onAppear:
//                state = .init()
//                return .none
//
//            default:
//                return .none
//            }
        }
        
        Scope(state: \.profile, action: /Action.profile) {
            Profile()
        }
    }
}

struct DetailView: View {
    let store: StoreOf<Detail>
    
    // TODO: integrate legacy model and selection into composable architecture
    @Binding var selection: Panel?
    @ObservedObject var model: AppModel
    
    var body: some View {
        switch selection ?? .top {
        case .account:
            ProfileView(store: self.store.scope(state: \.profile, action: Detail.Action.profile))
        case .top:
            FeedView(model: model.topFeedModel)
        case .best:
            FeedView(model: model.bestFeedModel)
        case .new:
            FeedView(model: model.newFeedModel)
        case .ask:
            FeedView(model: model.askFeedModel)
        case .show:
            FeedView(model: model.showFeedModel)
        case .jobs:
            FeedView(model: model.jobsFeedModel)
        case .search:
            SearchView(model: model.searchModel)
        default:
            EmptyView()
        }
    }
    
//    struct DetailColumn_Previews: PreviewProvider {
//        struct Preview: View {
//            @State private var selection: Panel? = .top
//            @StateObject private var model = AppModel.preview
//
//            var body: some View {
//                DetailView(selection: $selection, model: model)
//            }
//        }
//        static var previews: some View {
//            Preview()
//        }
//    }
}
