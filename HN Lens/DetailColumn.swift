import SwiftUI

struct DetailColumn: View {
    @Binding var selection: Panel?
    @ObservedObject var model: AppModel
    
    var body: some View {
        switch selection ?? .top {
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
        case .account:
            AccountView(model: model.accountModel)
        default:
            EmptyView()
        }
    }
    
    struct DetailColumn_Previews: PreviewProvider {
        struct Preview: View {
            @State private var selection: Panel? = .top
            @StateObject private var model = AppModel.preview
            
            var body: some View {
                DetailColumn(selection: $selection, model: model)
            }
        }
        static var previews: some View {
            Preview()
        }
    }
}
