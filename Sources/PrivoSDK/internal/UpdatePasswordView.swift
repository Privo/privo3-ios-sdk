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
                ModalWebView(isPresented: $vm.isPresented, config: vm.config)
                    .background(backgroundColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 520)
                    .cornerRadiusTop(8)
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
