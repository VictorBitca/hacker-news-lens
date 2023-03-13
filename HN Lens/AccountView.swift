import SwiftUI
import HackerNewsKit
import ComposableArchitecture

enum AccountDestinations: Hashable {
    case upvotedStories
    case favoriteStories
    case upvotedComments
    case favoriteComments
}

struct AccountView: View {
    @ObservedObject var model: AccountModel
    @EnvironmentObject var coordinator: Coordinator
    @State var upvotedStoriesStore = Store(initialState: SavedStoriesFeed.State(saveType: .upvote), reducer: SavedStoriesFeed())
    @State var favoriteStoriesStore = Store(initialState: SavedStoriesFeed.State(saveType: .favorite), reducer: SavedStoriesFeed())
    @State var upvotedCommentsStore = Store(initialState: SavedCommentsFeed.State(saveType: .upvote), reducer: SavedCommentsFeed())
    @State var favoriteCommentsStore = Store(initialState: SavedCommentsFeed.State(saveType: .favorite), reducer: SavedCommentsFeed())
    
    @ViewBuilder
    func loginView() -> some View {
        VStack() {
            TextField("Username", text: $model.username)
                .padding()
                .background(Pallete.grayLight.color)
                .cornerRadius(5.0)
                .modifier(Shake(animatableData: CGFloat(model.failedAttempts)))
                .padding()
            SecureField("Password", text: $model.password)
                .padding()
                .background(Pallete.grayLight.color)
                .cornerRadius(5.0)
                .modifier(Shake(animatableData: CGFloat(model.failedAttempts)))
                .padding()
            Button(action: { model.logIn() }) {
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
    func loadingView() -> some View {
        ZStack() {
            loginView()

            Color.gray
            .opacity(0.2)
            .overlay(ProgressView())
        }
    }
    
    @ViewBuilder
    func logedInView(username: String) -> some View {
        VStack() {
            list()
        }
    }
    
    @ViewBuilder
    func list() -> some View {
        List() {
            Section {
                NavigationLink(value: AccountDestinations.upvotedStories) {
                    Label("Upvoted Stories", systemImage: "square.text.square")
                }
                NavigationLink(value: AccountDestinations.upvotedComments) {
                    Label("Upvoted Comments", systemImage: "text.bubble")
                }
                NavigationLink(value: AccountDestinations.favoriteStories) {
                    Label("Favorite Stories", systemImage: "text.badge.star")
                }
                NavigationLink(value: AccountDestinations.favoriteComments) {
                    Label("Favorite Comments", systemImage: "star.bubble")
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    var body: some View {
        VStack() {
            switch model.state {
            case .loggedOut: loginView()
            case .loggedIn(let username): logedInView(username: username)
            case .loading: loadingView()
            }
        }
        .onAppear {
            model.onAppear()
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: AccountDestinations.self) { destination in
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
}

struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}
