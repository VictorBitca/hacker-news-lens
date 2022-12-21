import Foundation
import SwiftUI

struct SearchView: View {
    @ObservedObject var model: SearchModel
    @EnvironmentObject var coordinator: Coordinator
        
    var body: some View {
        List(model.searchResults) { post in
            PostView(post: post)
                .listRowSeparator(.hidden)
                .onTapGesture {
                    coordinator.path.append(post)
                }
        }
        .listStyle(.plain)
        .searchable(text: $model.searchTerm)
        .onSubmit(of: .search, { search() })
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: PostModel.self) { post in
            CommentsView(post: post)
        }
    }
    
    func search() {
        model.search(for: model.searchTerm)
    }
}
