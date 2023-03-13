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
