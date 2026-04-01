#if canImport(SwiftUI)
import SwiftUI

struct BiometricExampleView: View {
    @State private var showAuth = false
    @State private var isAuthenticated = false
    @State private var lastError: String?
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: biometricIcon)
                .font(.system(size: 80))
                .foregroundColor(isAuthenticated ? .green : .blue)
            
            VStack(spacing: 12) {
                Text(isAuthenticated ? "Authenticated Successfully" : "Auth Required")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Device supports: \(BiometricManager.shared.type.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Button {
                showAuth = true
            } label: {
                Text(isAuthenticated ? "Logout" : "Authenticate Now")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(isAuthenticated ? Color.red : Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
            }
            .onBiometricAuth(isPresented: $showAuth, reason: "Verify your identity to unlock content") { result in
                switch result {
                case .success:
                    isAuthenticated = true
                    lastError = nil
                case .failure(let error):
                    lastError = error.localizedDescription
                    isAuthenticated = false
                }
            }
            
            if let error = lastError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var biometricIcon: String {
        switch BiometricManager.shared.type {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "opticid"
        default: return "lock.shield"
        }
    }
}

#Preview {
    BiometricExampleView()
}
#endif
