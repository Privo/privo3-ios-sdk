//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 01.06.2021.
//

import SwiftUI

let authRedirectUrl = URL(string: "https://auth-dev.privo.com/api/v1.0/privo/authorize?client_id=ama")!

struct ModalAuthView: View {
  @Binding var isPresented: Bool
  
  var body: some View {
    VStack(spacing: 10) {
      Button(action: {
        isPresented = false
      }, label: {
        Text("Close")
      })
      Webview(url: authRedirectUrl)
    }
  }
}

public struct PrivoAuthView<Label> : View where Label : View {
    @State var presentingAuth = false
    let label: Label
    let onFinish: (() -> Void)?
    public init(@ViewBuilder label: () -> Label, onFinish: (() -> Void)? = nil ) {
        self.label = label()
        self.onFinish = onFinish
    }
    public var body: some View {
        Button {
            presentingAuth = true
        } label: {
            label
        }.sheet(isPresented: $presentingAuth) {
            ModalAuthView(isPresented: self.$presentingAuth)
        }
    }
}

public class PrivoAuth {
    public init() {}
}
