import Foundation
import LocalAuthentication

/// The type of biometric authentication available on the device.
public enum BiometricType: String, Sendable {
    case faceID = "Face ID"
    case touchID = "Touch ID"
    case opticID = "Optic ID"
    case none = "None"
}

/// The result of a biometric authentication attempt.
public enum BiometricResult: Sendable {
    case success
    case failure(LAError)
}

/// A manager responsible for handling biometric authentication.
@MainActor
public final class BiometricManager: ObservableObject {
    
    /// The shared instance of `BiometricManager`.
    public static let shared = BiometricManager()
    
    private init() {}
    
    /// Returns the type of biometric authentication available on the current device.
    public var type: BiometricType {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .faceID: return .faceID
        case .touchID: return .touchID
        case .opticID: return .opticID
        case .none: return .none
        @unknown default: return .none
        }
    }
    
    /// A boolean value indicating whether biometric authentication is available on the device.
    public var isAvailable: Bool {
        return type != .none
    }
    
    /// Requests biometric authentication from the user.
    /// - Parameter reason: The reason for requesting authentication, shown to the user.
    /// - Returns: A `BiometricResult` indicating success or failure.
    public func authenticate(reason: String) async -> BiometricResult {
        let context = LAContext()
        var error: NSError?
        
        // Use .deviceOwnerAuthentication if you want a fallback to passcode,
        // but normally BiometricKit implies biometric-only.
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let laError = error as? LAError {
                return .failure(laError)
            }
            return .failure(LAError(.biometryNotAvailable))
        }
        
        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            return success ? .success : .failure(LAError(.authenticationFailed))
        } catch {
            if let laError = error as? LAError {
                return .failure(laError)
            }
            return .failure(LAError(.authenticationFailed))
        }
    }
}
