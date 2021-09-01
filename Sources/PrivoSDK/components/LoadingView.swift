//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 31.08.2021.
//

//
//  File.swift
//  SDKDemoApp (iOS)
//
//  Created by alex slobodeniuk on 10.06.2021.
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
