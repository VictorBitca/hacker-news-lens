import Foundation
import LinkPresentation
import HackerNewsKit
import Combine

@MainActor
public class PostModel: Identifiable, ObservableObject {
    public let id = UUID()
    let hnID: Int
    let url: URL?
    let title: String
    let author: String
    let score: String
    let descendants: String
    let time: String
    let text: String?
    let index: Int?
    let primaryAccentColor = Pallete.randomAccent
    lazy var secondaryAccentColor: UIColor = {
        primaryAccentColor.lighter()
    }()
    private var isDisplayingComments = false
    private var isVisible = false
    
    @Published var thumbnailImage: UIImage? = nil
    @Published var icon: UIImage? = nil
    @Published var imageURL: String? = nil
    @Published var comments: [CommentModel] = []
    
    var hasText: Bool {
        text != nil
    }
    
    lazy var shortURL: String? = {
        let components = url?.host?
            .lowercased()
            .components(separatedBy: ".")
            .filter { !$0.starts(with: "www") }
            .joined(separator: ".")
        return components
    }()
    
    lazy var hostIsHN: Bool = {
        if url == nil { return true }
        return url?.host == "news.ycombinator.com"
    }()
    
    lazy var siteSymbol: String = {
        enum HNPostType: String {
            case askHN = "Ask HN:"
            case showHN = "Show HN:"
            case tellHN = "Tell HN:"
            case launchHN = "Launch HN:"
        }
        
        if hostIsHN {
            if title.contains(HNPostType.askHN.rawValue) {
                return HNPostType.askHN.rawValue
            } else if title.contains(HNPostType.showHN.rawValue) {
                return HNPostType.showHN.rawValue
            } else if title.contains(HNPostType.tellHN.rawValue) {
                return HNPostType.tellHN.rawValue
            } else if title.contains(HNPostType.launchHN.rawValue) {
                return HNPostType.launchHN.rawValue
            }
            return "HN"
        }
        
        return placeholderName
    }()
    
    lazy var placeholderName: String = {
        if hostIsHN {
            return siteSymbol
        }
        
        let host = url?.host ?? "news.ycombinator.com"
        
        let name = host
            .lowercased()
            .components(separatedBy: ".")
            .filter { !$0.starts(with: "www") }
            .first
        
        return String(name ?? "").lowercased()
    }()
    
    lazy var hnURL: URL? = {
        return URL(string: "https://news.ycombinator.com/item?id=\(hnID)")
    }()
    
    lazy var attributedText: NSAttributedString? = {
        guard let text else { return nil }
        
        let font = UIFont.preferredFont(forTextStyle: .callout)
        return CommentParser.buildAttributedText(from: text, textColor: Pallete.textPrimary, font: font)
    }()
    
    private let kids: [Int]
    private var metadataFetched = false
    private var imageTask: Task<Void, Never>? = nil
    
    nonisolated init(from story: StoryItem, index: Int?) {
        hnID = story.id
        url = story.url
        title = story.title
        author = story.author
        score = String(story.score)
        descendants = String(story.commentsCount)
        time = story.time
        kids = story.kids
        text = story.text
        self.index = index
    }
    
    nonisolated init(hnID: Int,
                     url: URL?,
                     title: String,
                     author: String,
                     score: String,
                     descendants: String,
                     time: String,
                     kids: [Int],
                     text: String?,
                     index: Int?) {
        self.hnID = hnID
        self.url = url
        self.title = title
        self.author = author
        self.score = score
        self.descendants = descendants
        self.time = time
        self.kids = kids
        self.text = text
        self.index = index
    }
    
    func didAppear() {
        isVisible = true
        if metadataFetched { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.3...0.6)) {
            if self.isVisible {
                self.fetchImageMetadata()
            }
        }
    }
    
    func didDisappear() {
        isVisible = false
        imageTask?.cancel()
        imageTask = nil
    }
    
    func commentsDidDisappear() {
        isDisplayingComments = false
    }
    
    func loadComments() async throws {
        isDisplayingComments = true
        let commentItemToCommentModel: (CommentItem) -> CommentModel = { comment in
            let font = UIFont.preferredFont(forTextStyle: .callout)
            let attributedCommentString = CommentParser.buildAttributedText(from: comment.text, textColor: Pallete.textPrimary, font: font) ?? NSAttributedString(string: "")
            return CommentModel(id: comment.id, author: comment.author, text: attributedCommentString, time: comment.time, level: comment.index)
        }
        
        let stream = HackerNewsAPI.shared.comments(with: kids)
            .compactMap { CommentItem(rawItem: $0) }
            .map { commentItemToCommentModel($0) }
        
        for await comment in stream {
            guard isDisplayingComments else { return }
            comments.append(comment)
        }
    }
    
    func openBrowser() {
        guard let url = url ?? hnURL else {
            return
        }
        
        UIApplication.shared.open(url)
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
    
    private func fetchImageMetadata() {
        guard let url else { return }
        
        imageTask = Task {
            guard let image = await LinkPreviewProvider.shared.previewImage(for: url) else {
                self.imageTask = nil
                return
            }
            self.metadataFetched = true
            self.thumbnailImage = image
            self.imageTask = nil
        }
    }
}

extension PostModel: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    public static func == (lhs: PostModel, rhs: PostModel) -> Bool {
        return lhs.id == rhs.id
    }
}
