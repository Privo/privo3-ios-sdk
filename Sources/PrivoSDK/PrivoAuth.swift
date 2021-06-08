//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 01.06.2021.
//

import SwiftUI

struct ModalAuthView: View {
  @Binding var isPresented: Bool
  var closeIcon: Image?
  let onPrivoEvent: ([String : AnyObject]?) -> Void;
  
  var body: some View {
    // let serviceIdentifier = PrivoInternal.shared.settings.serviceIdentifier; // Uncomment it later when Alex fix a backend
    let url = PrivoInternal.shared.configuration.authUrl
    // url.appendQueryParam(name: "service_identifier", value: serviceIdentifier) // Uncomment it later when Alex fix a backend
    return VStack() {
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
        Webview(url: url, onPrivoEvent: {data in
            self.onPrivoEvent(data)
            isPresented = false
        })
    }
  }
}

public struct PrivoAuthView<Label> : View where Label : View {
    @State var presentingAuth = false
    let label: Label
    var closeIcon: Image?
    let onFinish: ((String?) -> Void)?
    public init(@ViewBuilder label: () -> Label, onFinish: ((String?) -> Void)? = nil, closeIcon: Image? = nil ) {
        self.label = label()
        self.onFinish = onFinish
        self.closeIcon = closeIcon
    }
    public var body: some View {
        Button {
            presentingAuth = true
        } label: {
            label
        }.sheet(isPresented: $presentingAuth) {
            ModalAuthView(isPresented: self.$presentingAuth, onPrivoEvent: { event in
                if let accessId = event?["accessId"] as? String {
                    PrivoInternal.shared.rest.getValueFromTMPStorage(key: accessId) { resp in
                        let token = resp?.data
                        self.onFinish?(token)
                    }
                } else {
                    self.onFinish?(nil)
                }
            })
        }
    }
}

public class PrivoAuth {
    public init() {}
}
