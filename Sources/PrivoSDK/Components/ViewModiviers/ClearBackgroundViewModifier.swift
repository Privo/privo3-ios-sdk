import SwiftUI

struct ClearBackgroundViewModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content.background(ClearBackgroundView())
    }
    
}
