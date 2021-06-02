//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 01.06.2021.
//

import SwiftUI

struct AuthView: View {
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

public class PrivoAuth {
    public init() {}
    @State var presentingAuth = false
    public func show(rootView: AnyView) {
        print("Show Auth")
        _ = rootView.sheet(isPresented: $presentingAuth) {
            AuthView(isPresented: self.$presentingAuth)
        }
        presentingAuth = true;
    }
}
