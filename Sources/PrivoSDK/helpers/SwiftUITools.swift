import SwiftUI

extension View {
    func cornerRadiusTop(_ radius: CGFloat, antialiased: Bool = true) -> some View {
        self.padding(.bottom, radius)
            .cornerRadius(radius, antialiased: antialiased)
            .padding(.bottom, -radius)
    }
}
