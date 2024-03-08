import SwiftUI

struct UpdatePasswordView: View {
    
    @ObservedObject
    private var vm: UpdatePassword
    
    @State
    private var isPresentedAnimation: Bool = false

    private let backgroundColor: Color = .white
    
    public init(_ vm: UpdatePassword) {
        self.vm = vm
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(isPresentedAnimation ? 0.4 : 0)
                .allowsHitTesting(isPresentedAnimation)
                .simultaneousGesture(
                    TapGesture().onEnded {
                        if vm.isFailedContent {
                            vm.isPresented = false
                            isPresentedAnimation = false
                            vm.onClose()
                        }
                })
                .transition(.opacity)
                .animation(.easeOut(duration: 0.3), value: isPresentedAnimation)
            
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(backgroundColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 26) // Sometimes, the background color may not be transparent, and applying a white background may not be visible. In this case, the header color will not match the background color. Let's make the header height moderate and not too narrow, so that in this case, the overall appearance of the pop-up widget does not look bad.
                        .cornerRadiusTop(8)
                    
                    ModalWebView(isPresented: $vm.isPresented, config: vm.config)
                        .background(backgroundColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 500)
                }
            }.edgesIgnoringSafeArea(.bottom)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    isPresentedAnimation = vm.isPresented
                }
            }
            //since iOS14 use onChange (for isPresented variable) to updated isPresentedAnimation back
        }
    }
}
