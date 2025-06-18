import SwiftUI
import MarkdownUI

struct MarkdownEnhancedView: View {
    let content: String
    
    var body: some View {
        Markdown(content)
            .markdownTheme(.gitHub)
            .textSelection(.enabled)
    }
}
