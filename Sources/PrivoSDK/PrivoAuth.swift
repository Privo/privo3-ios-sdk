//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 01.06.2021.
//

import SwiftUI

struct ModalAuthView: View {
  @Binding var isPresented: Bool
  
  var body: some View {
    VStack(spacing: 50) {
      Text("Information view.")
        .font(.largeTitle)
      
      Button(action: {
        isPresented = false
      }, label: {
        Text("Close")
      })
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
    @State var presentingAuth = false
}
