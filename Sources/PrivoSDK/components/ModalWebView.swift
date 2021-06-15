//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 14.06.2021.
//

import SwiftUI

struct ModalWebView: View {
  @Binding var isPresented: Bool
  let config: WebviewConfig
  var closeIcon: Image?
  
    var body: some View {
      return
          VStack() {
              HStack() {
                  Spacer()
                  Button(action: {
                    isPresented = false
                  }, label: {
                      if (self.closeIcon != nil) {
                          self.closeIcon
                      } else {
                          Image(systemName: "xmark").font(.system(size: 20.0, weight: .bold)).foregroundColor(.black).padding(5)
                      }
                  })
              }
              Webview(config: config)
          }
    }
  }
