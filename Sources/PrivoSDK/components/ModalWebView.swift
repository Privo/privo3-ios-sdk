//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 14.06.2021.
//

import SwiftUI

struct ModalWebView: View {
    @Binding
    var isPresented: Bool
    @ObservedObject
    var model = WebViewModel(permissionService: PrivoCameraPermissionService.shared)
    let config: WebviewConfig
  
    var body: some View {
      return
        LoadingView(isShowing: $model.isLoading) {
            VStack() {
              if (self.config.showCloseIcon) {
                  HStack() {
                      Spacer()
                      Button(action: {
                        isPresented = false
                        self.config.onClose?()
                      }, label: {
                        if (self.config.closeIcon != nil) {
                            self.config.closeIcon
                          } else {
                              Image(systemName: "xmark").font(.system(size: 20.0, weight: .bold)).foregroundColor(.black).padding(5)
                          }
                      })
                  }
              }
              Webview(viewModel: model, config: config)
            }
        
        }
    }
}
