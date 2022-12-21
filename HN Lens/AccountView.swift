import SwiftUI
import HackerNewsKit

struct AccountView: View {
    @ObservedObject var model: AccountModel
    @EnvironmentObject var coordinator: Coordinator
    
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
                NavigationLink(value: model.upvotedStoriesModel) {
                    Label("Upvoted Stories", systemImage: "square.text.square")
                }
                NavigationLink(value: model.upvotedCommentsModel) {
                    Label("Upvoted Comments", systemImage: "text.bubble")
                }
                NavigationLink(value: model.favoriteStoriesModel) {
                    Label("Favorite Stories", systemImage: "text.badge.star")
                }
                NavigationLink(value: model.favoriteCommentsModel) {
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
        .navigationDestination(for: SavedItemsFeedModel.self) { model in
            // TODO: investigate why the SavedItemsFeedModel cant automatically access the EnvironmentObject
            SavedItemsFeedView(model: model).environmentObject(self.coordinator)
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
