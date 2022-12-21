import HackerNewsKit
import SwiftUI
import AsyncAlgorithms

public enum AccountState: Hashable {
    case loggedOut
    case loggedIn(username: String)
    case loading
}

@MainActor
public class AccountModel: ObservableObject {
    @Published var state: AccountState = .loggedOut
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var failedAttempts: Int = 0
    
    private var g: AsyncChannel<[Int]>!
    
    lazy var upvotedStoriesModel: SavedItemsFeedModel = {
        return SavedItemsFeedModel(feedType: .stories(.upvoted))
    }()
    
    lazy var upvotedCommentsModel: SavedItemsFeedModel = {
        return SavedItemsFeedModel(feedType: .comments(.upvoted))
    }()
    
    lazy var favoriteStoriesModel: SavedItemsFeedModel = {
        return SavedItemsFeedModel(feedType: .stories(.favorite))
    }()
    
    lazy var favoriteCommentsModel: SavedItemsFeedModel = {
        return SavedItemsFeedModel(feedType: .comments(.favorite))
    }()
    
    func onAppear() {
        if HackerNewsAPI.shared.isLoggedIn {
            state = .loggedIn(username: HackerNewsAPI.shared.loggedInUser ?? "undefined")
        } else {
            state = .loggedOut
        }
    }
    
    func logIn() {
        Task {
            do {
                state = .loading
                try await HackerNewsAPI.shared.singIn(username: username, password: password)
                state = .loggedIn(username: HackerNewsAPI.shared.loggedInUser ?? "undefined")
            } catch {
                state = .loggedOut
                withAnimation {
                    failedAttempts += 1
                }
            }
        }
    }
}
