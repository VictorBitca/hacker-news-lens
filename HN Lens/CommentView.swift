import SwiftUI
import HackerNewsKit

struct CommentView: View {
    @ObservedObject var comment: CommentModel
    @State var safariURL: URL? = nil
    @State var presentingSafariView = false
    @State private var showActionSheet = false
    
    var body: some View {
        let commentIndentation = 8 * CGFloat(comment.level)
        let indentationColor: Color = Pallete.rainbowColors(at: comment.level).color
        
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 1)
                .foregroundColor(indentationColor)
                .frame(maxWidth: 3)
                .padding(.init(
                    top:2 ,
                    leading: commentIndentation,
                    bottom: 2,
                    trailing: 0)
                )
            
            HStack {
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        Text(comment.author)
                            .font(.caption2)
                            .foregroundColor(Pallete.textSecondary.color)
                        Circle().frame(width: 4, height: 4)
                            .foregroundColor(Pallete.textSecondary.color)
                        Text(comment.time)
                            .font(.caption2)
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
                                    .default(Text("Upvote"), action: { comment.upvote() }),
                                    .default(Text("Favorite"), action: { comment.favorite() }),
                                    .cancel()
                                ]
                            )
                        }
                    }
                    .padding(.init(top: 8, leading: 8, bottom: 0, trailing: 0))
                    
                    Text(comment.attributedString)
                        .textSelection(.enabled)
                        .padding(.init(top: 0, leading: 8, bottom: 8, trailing: 8))
                }
                Spacer()
            }
            .cornerRadius(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Pallete.grayLight.color)
            )
            .padding(.init(top: 2,
                           leading: 4,
                           bottom: 2,
                           trailing: 0))
        }
    }
}
