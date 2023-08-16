import SwiftUI
import Combine

extension View {
    func KeyboardAwarePadding() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAwareModifier())
    }
    
    func clearModalBackground() -> some View {
        modifier(ClearBackgroundViewModifier())
    }
    
}
