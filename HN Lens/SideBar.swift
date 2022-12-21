import SwiftUI

enum Panel: Hashable {
    case top
    case best
    case new
    case ask
    case show
    case jobs
    case comments
    case search
    case account
}

struct Sidebar: View {
    @Binding var selection: Panel?
    
    var body: some View {
        List(selection: $selection) {
            Section {
                NavigationLink(value: Panel.account) {
                    Label("Account", systemImage: "person")
                }
            }
            
            Section {
                NavigationLink(value: Panel.search) {
                    Label("Search", systemImage: "magnifyingglass")
                }
            }
            
            Section {
                NavigationLink(value: Panel.top) {
                    Label("Top", systemImage: "flame")
                }
                NavigationLink(value: Panel.best) {
                    Label("Best", systemImage: "sparkles")
                }
                NavigationLink(value: Panel.new) {
                    Label("New", systemImage: "clock")
                }
                NavigationLink(value: Panel.ask) {
                    Label("Ask", systemImage: "questionmark")
                }
                NavigationLink(value: Panel.show) {
                    Label("Show", systemImage: "eye")
                }
                NavigationLink(value: Panel.jobs) {
                    Label("Jobs", systemImage: "brain.head.profile")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("HN Lens")
    }
}

struct Sidebar_Previews: PreviewProvider {
    struct Preview: View {
        @State private var selection: Panel? = Panel.top
        var body: some View {
            Sidebar(selection: $selection)
        }
    }
    
    static var previews: some View {
        NavigationSplitView {
            Preview()
        } detail: {
           Text("Detail!")
        }
    }
}

