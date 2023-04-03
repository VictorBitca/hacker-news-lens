import SwiftUI
import ComposableArchitecture

struct Detail: ReducerProtocol {
    struct State: Equatable {
        var profile = Profile.State()
        var search = Search.State()
        var topFeed = MainFeed.State(feedType: .top)
        var bestFeed = MainFeed.State(feedType: .best)
        var newFeed = MainFeed.State(feedType: .new)
        var askFeed = MainFeed.State(feedType: .ask)
        var showFeed = MainFeed.State(feedType: .show)
        var jobsFeed = MainFeed.State(feedType: .jobs)
    }
    
    enum Action: Equatable {
        case profile(Profile.Action)
        case search(Search.Action)
        case top(MainFeed.Action)
        case best(MainFeed.Action)
        case new(MainFeed.Action)
        case ask(MainFeed.Action)
        case show(MainFeed.Action)
        case jobs(MainFeed.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            return .none
        }
        
        Scope(state: \.profile, action: /Action.profile) {
            Profile()
        }
        
        Scope(state: \.search, action: /Action.search) {
            Search()
        }
        
        Scope(state: \.topFeed, action: /Action.top) {
            MainFeed()
        }
        
        Scope(state: \.bestFeed, action: /Action.best) {
            MainFeed()
        }
        
        Scope(state: \.newFeed, action: /Action.new) {
            MainFeed()
        }
        
        Scope(state: \.askFeed, action: /Action.ask) {
            MainFeed()
        }
        
        Scope(state: \.showFeed, action: /Action.show) {
            MainFeed()
        }
        
        Scope(state: \.jobsFeed, action: /Action.jobs) {
            MainFeed()
        }
    }
}

struct DetailView: View {
    let store: StoreOf<Detail>
    
    // TODO: integrate selection into composable architecture
    @Binding var selection: Panel?
    
    var body: some View {
        switch selection ?? .top {
        case .account:
            ProfileView(store: self.store.scope(state: \.profile, action: Detail.Action.profile))
        case .search:
            SearchView(store: self.store.scope(state: \.search, action: Detail.Action.search))
        case .top:
            MainFeedView(store: self.store.scope(state: \.topFeed, action: Detail.Action.top))
        case .best:
            MainFeedView(store: self.store.scope(state: \.bestFeed, action: Detail.Action.best))
        case .new:
            MainFeedView(store: self.store.scope(state: \.newFeed, action: Detail.Action.new))
        case .ask:
            MainFeedView(store: self.store.scope(state: \.askFeed, action: Detail.Action.ask))
        case .show:
            MainFeedView(store: self.store.scope(state: \.showFeed, action: Detail.Action.show))
        case .jobs:
            MainFeedView(store: self.store.scope(state: \.jobsFeed, action: Detail.Action.jobs))
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
