import SwiftUI
import SafariServices
import HackerNewsKit
import SwiftUIKitView
import UIKit

class CircleGridView: UIView {
    private let gridSize = Int.random(in: 4...10)
    private let circleCount = 100
    private var circleLayers: [CALayer] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: 100).isActive = true
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        backgroundColor = .black
        createCircleLayers()
    }

    private func createCircleLayers() {
        for _ in 0..<circleCount {
            let circleLayer = CALayer()
            circleLayers.append(circleLayer)
            layer.addSublayer(circleLayer)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateAppearance()
    }
    
    private func updateAppearance() {
        let cellSize = bounds.width / CGFloat(gridSize)
        let margin = cellSize * 0.1
        let coeficients = ThumbnailGenerator.noiseMatrix(size: gridSize).flatMap({ $0 }).map({ CGFloat($0).remap(form: 0...254, to: 0...1) })
        
        let color = Pallete.randomAccent
        for y in 0..<gridSize {
            for x in 0..<gridSize {
                let index = y * gridSize + x
                let circleLayer = circleLayers[index]
                let cellOrigin = CGPoint(x: CGFloat(x) * cellSize, y: CGFloat(y) * cellSize)
                let circleSize = cellSize - 2 * margin

                let perlinValue = coeficients[index]
                let diameter = circleSize * perlinValue
                let circleFrame = CGRect(x: cellOrigin.x + margin, y: cellOrigin.y + margin, width: diameter, height: diameter)

                circleLayer.frame = circleFrame
                circleLayer.cornerRadius = diameter * 0.5
                circleLayer.backgroundColor = color.cgColor
            }
        }
    }
}


struct PostView: View {
    @ObservedObject var post: PostModel
    @State private var showActionSheet = false
    
    @ViewBuilder
    fileprivate func statsView() -> some View {
        HStack(spacing: 2) {
            Image(systemName: "smallcircle.circle")
                .font(.caption)
                .foregroundColor(Pallete.textSecondary.color)
            Text(post.score)
                .font(.caption)
                .foregroundColor(Pallete.textSecondary.color)
                .padding(.trailing)
            Image(systemName: "text.bubble")
                .font(.caption)
                .foregroundColor(Pallete.textSecondary.color)
            Text(post.descendants)
                .font(.caption)
                .foregroundColor(Pallete.textSecondary.color)
            
            Spacer()
            
            Button(action: {
                showActionSheet.toggle()
            }, label: {
                Image("dots")
                    .foregroundColor(Pallete.textSecondary.color)
                    .padding(8)
            })
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(
                    title: Text("Actions"),
                    buttons: [
                        .default(Text("Upvote"), action: { post.upvote() }),
                        .default(Text("Favorite"), action: { post.favorite() }),
                        .cancel()
                    ]
                )
            }
        }
    }
    
    @ViewBuilder
    fileprivate func imageThumbnail(_ thumbnail: UIImage) -> some View {
        VStack() {
            Spacer().layoutPriority(1)
            Image(uiImage: thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: 120, maxHeight: 120)
                .cornerRadius(4)
            
            if let url = post.shortURL {
                Text(url)
                    .font(.footnote)
                    .minimumScaleFactor(0.5)
                    .foregroundColor(Pallete.textSecondary.color)
                    .frame(maxWidth: 120)
                    .frame(minHeight: 20)
            }
            Spacer().layoutPriority(1)
        }
        .padding()
        .onTapGesture {
            post.openBrowser()
        }
    }
    
    @ViewBuilder
    fileprivate func imagePlaceholder() -> some View {
        VStack {
            Spacer()
            ZStack(alignment: .center) {
                let primaryAccent = post.primaryAccentColor.color
                let secondaryAccent = post.secondaryAccentColor.color
                let titleBackground = post.titleShadowColor.color
                
                Rectangle()
                    .frame(width: 120, height: 80)
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [primaryAccent, secondaryAccent]), startPoint: .bottom, endPoint: .top))
                
                Text(post.siteSymbol)
                    .font(.title)
                    .bold()
                    .minimumScaleFactor(0.5)
                    .lineLimit(3)
                    .foregroundColor(titleBackground)
                    .padding([.leading, .bottom, .trailing], 8)
                    .frame(maxWidth: 120)
                
                Text(post.siteSymbol)
                    .font(.title)
                    .bold()
                    .minimumScaleFactor(0.5)
                    .lineLimit(3)
                    .foregroundColor(.white)
                    .padding([.leading, .bottom, .trailing], 8)
                    .frame(maxWidth: 120)
                    .offset(x: -3, y: -3)
            }
            .cornerRadius(4)
            
            if let url = post.shortURL {
                Text(url)
                    .font(.footnote)
                    .minimumScaleFactor(0.5)
                    .foregroundColor(Pallete.textSecondary.color)
                    .frame(maxWidth: 120)
                    .frame(minHeight: 20)
            }
            
            Spacer()
        }
        .padding()
        .onTapGesture {
            post.openBrowser()
        }
    }
    @ViewBuilder
    fileprivate func experimentalThumbnail() -> some View {
        ZStack {
            UIViewContainer(CircleGridView(),
                            layout: .intrinsic)
            .set(\.backgroundColor, to: UIColor(.clear))
            .fixedSize()
            
            Text(post.siteSymbol)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.teal, .indigo],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .font(.title)
                .bold()
                .minimumScaleFactor(0.5)
                .lineLimit(3)
                .foregroundColor(.white)
                .padding([.leading, .bottom, .trailing], 8)
                .frame(maxWidth: 120)
        }.padding([.leading])
    }
    
    var body: some View {
        HStack(spacing: 8) {
            if let thumbnail = post.thumbnailImage {
                imageThumbnail(thumbnail)
            } else {
                imagePlaceholder()
            }
            
            Divider()
                .padding([.top, .bottom])
            
            VStack(alignment: .leading) {
                Text(post.title)
                    .font(.callout)
                    .minimumScaleFactor(0.3)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(alignment: .topLeading)
                
                statsView()
                    .foregroundColor(.secondary)
                
                HStack(alignment: .center) {
                    Text(post.author)
                        .font(.caption2)
                        .foregroundColor(Pallete.textSecondary.color)
                    Circle().frame(width: 4, height: 4)
                        .foregroundColor(Pallete.textSecondary.color)
                    Text(post.time)
                        .font(.caption2)
                        .foregroundColor(Pallete.textSecondary.color)
                }
            }
            .padding([.top, .trailing, .bottom], 8)
        }
        .frame(height: 160)
        .background(.thinMaterial)
        .cornerRadius(8)
    }
}

struct DetailedPostView: View {
    @ObservedObject var post: PostModel
    @State private var showActionSheet = false
    
    @ViewBuilder
    fileprivate func statsView() -> some View {
        HStack(spacing: 2) {
            Image(systemName: "smallcircle.circle")
                .font(.caption)
                .foregroundColor(Pallete.textSecondary.color)
            Text(post.score)
                .font(.caption)
                .foregroundColor(Pallete.textSecondary.color)
                .padding(.trailing)
            Image(systemName: "text.bubble")
                .font(.caption)
                .foregroundColor(Pallete.textSecondary.color)
            Text(post.descendants)
                .font(.caption)
                .foregroundColor(Pallete.textSecondary.color)
            Spacer()
            
            Button(action: {
                showActionSheet.toggle()
            }, label: {
                Image("dots")
                    .foregroundColor(Pallete.textSecondary.color)
                    .padding(8)
            })
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(
                    title: Text("Actions"),
                    buttons: [
                        .default(Text("Upvote"), action: { post.upvote() }),
                        .default(Text("Favorite"), action: { post.favorite() }),
                        .cancel()
                    ]
                )
            }
        }
    }
    
    var body: some View {
        HStack() {
            VStack(alignment: .leading) {
                Text(post.title)
                    .font(.callout)
                    .minimumScaleFactor(0.3)
                    .foregroundColor(.primary)
                    .padding()
                
                Divider()
                
                statsView()
                    .foregroundColor(.secondary)
                    .padding()
                
                Divider()
                
                if let attributedText = post.attributedText,
                    let text = try? AttributedString(attributedText, including: \.uiKit) {
                    Text(text)
                        .padding()
                }
            }
        }
        .cornerRadius(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Pallete.grayLight.color)
        )
    }
}
