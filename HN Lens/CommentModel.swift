import UIKit
import HackerNewsKit

struct Indentation: Identifiable {
    let id = UUID()
    let level: Int
    let color: UIColor
}

@MainActor
class CommentModel: Identifiable, ObservableObject {
    let id = UUID()
    let hnID: Int
    let author: String
    let text: NSAttributedString
    let time: String
    let level: Int
    let isDowngraded: Bool
    var kids: [CommentModel]
    let indentations: [Indentation]
    
    lazy var attributedString: AttributedString = {
        let result = try? AttributedString(text, including: \.uiKit)
        return result ?? AttributedString(stringLiteral: "")
    }()
    
    init(id: Int = 0,
         author: String = "",
         text: NSAttributedString = NSAttributedString(string: ""),
         time: String = "",
         level: Int = 0,
         isDowngraded: Bool = false,
         kids: [CommentModel] = []) {
        self.hnID = id
        self.author = author
        self.text = text
        self.time = time
        self.level = level
        self.isDowngraded = isDowngraded
        self.kids = kids
        self.indentations = (0...level).map { Indentation(level: $0, color: Pallete.rainbowColors(at: $0)) }
    }
    
    func upvote() {
        Task {
            try? await HackerNewsAPI.shared.vote(id: hnID, actionType: .upvote)
        }
    }
    
    func favorite() {
        Task {
            try? await HackerNewsAPI.shared.favorite(id: hnID, actionType: .add)
        }
    }
}

extension CommentModel: Equatable {
    static func == (lhs: CommentModel, rhs: CommentModel) -> Bool {
        lhs.id == rhs.id
    }
}
