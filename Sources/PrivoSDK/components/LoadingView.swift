//
//  Copyright (c) 2021-2024 Privacy Vaults Online, Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct LoadingView<Content>: View where Content: View {

    @Binding var isShowing: Bool
    var withBlur: Bool = false
    var content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                if (withBlur) {
                    self.content()
                        .disabled(self.isShowing)
                        .blur(radius: self.isShowing ? 3 : 0)
                    VStack {
                        ActivityIndicator(isAnimating: .constant(true), style: .large)
                    }
                    .frame(width: geometry.size.width / 2,
                           height: geometry.size.height / 5)
                    .background(Color.secondary.colorInvert())
                    .foregroundColor(Color.primary)
                    .cornerRadius(20)
                    .opacity(self.isShowing ? 1 : 0)
                } else {
                    self.content()
                        .disabled(self.isShowing)
                    VStack {
                        ActivityIndicator(isAnimating: .constant(true), style: .large)
                    }
                    .opacity(self.isShowing ? 1 : 0)
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

}
