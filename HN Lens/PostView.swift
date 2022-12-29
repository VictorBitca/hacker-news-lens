import SwiftUI
import SafariServices
import HackerNewsKit
import AttributedText

struct PostView: View {
    @ObservedObject var post: PostModel
    
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
            Image("dots")
                .foregroundColor(Pallete.textSecondary.color)
                .padding(8)
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
                    .foregroundColor(Pallete.textSecondary.color)
                    .frame(maxWidth: 120)
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
                let primaryAccent = post.primaryAccentcolor.color
                let secondaryAccent = post.secondaryAccentColor.color
                Rectangle()
                    .frame(width: 120, height: 80)
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [primaryAccent, secondaryAccent]), startPoint: .topLeading, endPoint: .bottomTrailing))
                ZStack {
                    Text(post.siteSymbol)
                        .font(.title)
                        .bold()
                        .minimumScaleFactor(0.15)
                        .lineLimit(3)
                        .foregroundColor(primaryAccent)
                        .padding([.leading, .bottom, .trailing], 8)
                        .frame(maxWidth: 120)
                        .offset(x: 4, y: 4)
                    
                    Text(post.siteSymbol)
                        .font(.title)
                        .bold()
                        .minimumScaleFactor(0.15)
                        .lineLimit(3)
                        .foregroundColor(.white)
                        .padding([.leading, .bottom, .trailing], 8)
                        .frame(maxWidth: 120)
                }
            }
            
            .cornerRadius(4)
            
            if let url = post.shortURL {
                Text(url)
                    .font(.footnote)
                    .minimumScaleFactor(0.5)
                    .foregroundColor(Pallete.textSecondary.color)
                    .frame(maxWidth: 100)
                    .shadow(color: Pallete.grayDark.color,
                            radius: 1, x: 0, y: 0)
            }
            Spacer()
        }
        .padding()
        .onTapGesture {
            post.openBrowser()
        }
    }
    
    var body: some View {
        HStack() {
            if let thumbnail = post.thumbnailImage {
                imageThumbnail(thumbnail)
            } else {
                imagePlaceholder()
            }
            
            VStack(alignment: .leading) {
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
                
                Text(post.title)
                    .font(.callout)
                    .minimumScaleFactor(0.3)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(alignment: .topLeading)
                Divider()
                statsView()
                    .foregroundColor(.secondary)
            }
            .padding([.top, .trailing, .bottom], 8)
        }
        .frame(height: 160)
        .cornerRadius(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Pallete.grayLight.color)
        )
    }
}

struct DetailedPostView: View {
    @ObservedObject var post: PostModel
    
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
            Image("dots")
                .foregroundColor(Pallete.textSecondary.color)
                .padding(8)
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
                AttributedText(attributedText: { post.attributedText! })
                    .padding()
            }
        }
        .cornerRadius(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Pallete.grayLight.color)
        )
    }
}
