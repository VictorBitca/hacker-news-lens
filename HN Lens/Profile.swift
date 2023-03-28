import SwiftUI
import HackerNewsKit
import ComposableArchitecture

enum ProfileDestinations: Hashable {
    case upvotedStories
    case favoriteStories
    case upvotedComments
    case favoriteComments
}

struct Profile: ReducerProtocol, Hashable {
    enum Action: Equatable {
        case viewAppeared
        case logInTapped(String, String)
        case logOutTapped
        case logInResult(TaskResult<String>)
        case alertDismissed
    }
    
    enum ViewState: Equatable {
        case loading
        case loggedOut
        case loggedIn(username: String)
    }
    
    struct State: Equatable {
        var profileState: ViewState = .loading
        var alert: AlertState<Action>?
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .viewAppeared:
            if HackerNewsAPI.shared.isLoggedIn {
                state.profileState = .loggedIn(username: HackerNewsAPI.shared.loggedInUser ?? "undefined")
            } else {
                state.profileState = .loggedOut
            }
            return .none
        case .logInTapped(let username, let password):
            state.profileState = .loading
            return .task {
                return await onLogIn(username: username, password: password)
            }
        case .logOutTapped:
            HackerNewsAPI.shared.signOut()
            state.profileState = .loggedOut
            return .none
        case .logInResult(.success(let username)):
            state.profileState = .loggedIn(username: username)
            return .none
        case .logInResult(.failure):
            state.alert = AlertState { TextState("Failed to log in") }
            state.profileState = .loggedOut
            return .none
        case .alertDismissed:
            state.alert = nil
            return .none
        }
    }
    
    private func onLogIn(username: String, password: String) async -> Action {
        do {
            try await HackerNewsAPI.shared.singIn(username: username, password: password)
            return .logInResult(.success(username))
        } catch {
            return .logInResult(.failure(error))
        }
    }
}

struct ProfileView: View {
    let store: StoreOf<Profile>
    @EnvironmentObject var coordinator: Coordinator
    @State var upvotedStoriesStore = Store(initialState: SavedStoriesFeed.State(saveType: .upvote), reducer: SavedStoriesFeed())
    @State var favoriteStoriesStore = Store(initialState: SavedStoriesFeed.State(saveType: .favorite), reducer: SavedStoriesFeed())
    @State var upvotedCommentsStore = Store(initialState: SavedCommentsFeed.State(saveType: .upvote), reducer: SavedCommentsFeed())
    @State var favoriteCommentsStore = Store(initialState: SavedCommentsFeed.State(saveType: .favorite), reducer: SavedCommentsFeed())
    
    @State var username = ""
    @State var password = ""
    
    @ViewBuilder
    func loginView(viewStore: ViewStoreOf<Profile>) -> some View {
        VStack() {
            TextField("Username", text: $username)
                .padding()
                .background(Pallete.grayLight.color)
                .cornerRadius(5.0)
                .padding()
            
            SecureField("Password", text: $password)
                .padding()
                .background(Pallete.grayLight.color)
                .cornerRadius(5.0)
                .padding()
            
            Button(action: { viewStore.send(.logInTapped(username, password)) }) {
                Text("Sign in")
                    .font(.body)
                    .foregroundColor(Pallete.textPrimary.color)
                    .padding()
                    .frame(height: 44)
                    .background(Pallete.appleGreen.color)
                    .cornerRadius(5.0)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    func loadingView(viewStore: ViewStoreOf<Profile>) -> some View {
        ZStack() {
            loginView(viewStore: viewStore)

            Color.gray
            .opacity(0.2)
            .overlay(ProgressView())
        }
    }
    
    @ViewBuilder
    func logedInView(username: String, viewStore: ViewStoreOf<Profile>) -> some View {
        VStack() {
            List() {
                Section {
                    NavigationLink(value: ProfileDestinations.upvotedStories) {
                        Label("Upvoted Stories", systemImage: "square.text.square")
                    }
                    NavigationLink(value: ProfileDestinations.upvotedComments) {
                        Label("Upvoted Comments", systemImage: "text.bubble")
                    }
                    NavigationLink(value: ProfileDestinations.favoriteStories) {
                        Label("Favorite Stories", systemImage: "text.badge.star")
                    }
                    NavigationLink(value: ProfileDestinations.favoriteComments) {
                        Label("Favorite Comments", systemImage: "star.bubble")
                    }
                }
                
                Section {
                    Button(action: { viewStore.send(.logOutTapped) }) {
                        Text("Log out").foregroundColor(.red)
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { (viewStore: ViewStoreOf<Profile>) in
            VStack() {
                switch viewStore.state.profileState {
                case .loggedOut: loginView(viewStore: viewStore)
                case .loggedIn(let username): logedInView(username: username, viewStore: viewStore)
                case .loading: loadingView(viewStore: viewStore)
                }
            }
            .onAppear {
                viewStore.send(.viewAppeared)
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ProfileDestinations.self) { destination in
                switch destination {
                case .upvotedStories:
                    SavedPostsFeedView(store: upvotedStoriesStore)
                        .environmentObject(self.coordinator)
                case .upvotedComments:
                    SavedCommentsFeedView(store: upvotedCommentsStore)
                        .environmentObject(self.coordinator)
                case .favoriteStories:
                    SavedPostsFeedView(store: favoriteStoriesStore)
                        .environmentObject(self.coordinator)
                case .favoriteComments:
                    SavedCommentsFeedView(store: favoriteCommentsStore)
                        .environmentObject(self.coordinator)
                }
            }
        }
        .alert(
          self.store.scope(state: \.alert),
          dismiss: .alertDismissed
        )
    }
}
