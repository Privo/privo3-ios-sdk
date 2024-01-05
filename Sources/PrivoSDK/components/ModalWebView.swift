//
//  Copyright (c) 2021 Privo Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import SwiftUI

struct ModalWebView: View {
    @Binding
    var isPresented: Bool
    
    private let permissionService = PrivoCameraPermissionService.shared
    
    @State
    private var isLoading: Bool = true
    
    let config: WebviewConfig
  
    var body: some View {
      return
        LoadingView(isShowing: $isLoading) {
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
              Webview(isLoading: $isLoading, permissionService: permissionService, config: config)
            }
        
        }
    }
}
