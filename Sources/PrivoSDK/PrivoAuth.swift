//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 01.06.2021.
//

import SwiftUI

// client_id === mobile; data key_id =

let authRedirectUrl = URL(string: "https://auth-dev.privo.com/api/v1.0/privo/authorize?client_id=mobile&redirect_uri=")!


struct ModalAuthView: View {
  @Binding var isPresented: Bool
  
  var body: some View {
    VStack() {
        HStack() {
            Spacer()
            Button(action: {
              isPresented = false
            }, label: {
                Image(systemName: "xmark").font(.system(size: 20.0, weight: .bold)).foregroundColor(.black).padding(5)
            })
        }
        Webview(url: authRedirectUrl, onPrivoEvent: {data in print(data)})
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
