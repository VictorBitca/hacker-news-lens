import Foundation
import HackerNewsKit

@MainActor
public class SearchModel: ObservableObject {
    @Published public var searchState: FeedState = .loading
    @Published public var searchTerm: String = ""
    @Published public var searchResults: [PostModel] = []
    
    func search(for term: String) {
        Task {
            searchResults = try await HackerNewsAPI.shared.search(query: term)
                .enumerated()
                .map { index, item in PostModel(from: item, index: index) }
        }
    }
}
