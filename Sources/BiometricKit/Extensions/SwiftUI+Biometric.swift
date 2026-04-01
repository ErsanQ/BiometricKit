import SwiftUI

public extension View {
    
    /// A view modifier that triggers biometric authentication when a binding becomes true.
    /// - Parameters:
    ///   - isPresented: A binding to a Boolean value that determines whether to prompt for authentication.
    ///   - reason: A localized string explaining the reason for the authentication request.
    ///   - onCompletion: A closure to execute when the authentication completes.
    /// - Returns: A view that handles biometric authentication.
    @MainActor
    func onBiometricAuth(
        isPresented: Binding<Bool>,
        reason: String,
        onCompletion: @escaping (BiometricResult) -> Void
    ) -> some View {
        self.modifier(BiometricAuthModifier(isPresented: isPresented, reason: reason, onCompletion: onCompletion))
    }
}

@MainActor
private struct BiometricAuthModifier: ViewModifier {
    @Binding var isPresented: Bool
    let reason: String
    let onCompletion: (BiometricResult) -> Void
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { newValue in
                if newValue {
                    Task {
                        let result = await BiometricManager.shared.authenticate(reason: reason)
                        isPresented = false
                        onCompletion(result)
                    }
                }
            }
    }
}
