import Foundation
import SwiftUI
import HackerNewsKit
import ComposableArchitecture

@MainActor
class SearchModel: ObservableObject {
    @Published var searchState: FeedState = .loading
    @Published var searchTerm: String = ""
    @Published var searchResults: [PostModel] = []
    
    func search(for term: String) {
        Task {
            searchResults = try await HackerNewsAPI.shared.search(query: term)
                .enumerated()
                .map { index, item in PostModel(from: item, index: index) }
        }
    }
}

struct Search: ReducerProtocol {
    struct State: Equatable {
        var isLoading = false
        var posts = [PostModel]()
    }
    
    enum Action: Equatable {
        case search(String)
        case searchTaskResult(TaskResult<[PostModel]>)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .search(let searchString):
                state.isLoading = true
                return .task {
                    let searchResults = try await HackerNewsAPI.shared.search(query: searchString)
                        .enumerated()
                        .map { index, item in PostModel(from: item, index: index) }
                    return .searchTaskResult(.success(searchResults))
                }
            case .searchTaskResult(.success(let posts)):
                state.isLoading = false
                state.posts = posts
                return .none
            case .searchTaskResult(.failure):
                state.isLoading = false
                return .none
            }
        }
    }
}

struct SearchView: View {
    let store: StoreOf<Search>
    @EnvironmentObject var coordinator: Coordinator
    @State var searchString: String = ""
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { (viewStore: ViewStoreOf<Search>) in
            ZStack {
                List(viewStore.state.posts) { post in
                    PostView(post: post)
                        .listRowSeparator(.hidden)
                        .onTapGesture {
                            coordinator.path.append(post)
                        }
                }
                .listStyle(.plain)
                .searchable(text: $searchString)
                .onSubmit(of: .search, { viewStore.send(.search(searchString)) })
                .navigationTitle("Search")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: PostModel.self) { post in
                    CommentsView(post: post)
                }
                
                if viewStore.state.isLoading {
                    ProgressView()
                }
            }
        }
    }
}
