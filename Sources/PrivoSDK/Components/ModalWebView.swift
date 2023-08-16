import SwiftUI

struct ModalWebView: View {
    
    //MARK: - Internal properties
    
    @Binding
    var isPresented: Bool
    @ObservedObject
    var model = WebViewModel(permissionService: PrivoCameraPermissionService.shared)
    let config: WebviewConfig
  
    //MARK: - Body builder
    
    var body: some View {
      return
        LoadingView(isShowing: $model.isLoading) {
            VStack() {
              if config.showCloseIcon {
                  HStack() {
                      Spacer()
                      Button(action: {
                        isPresented = false
                        config.onClose?()
                      }, label: {
                        if config.closeIcon != nil {
                            config.closeIcon
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
