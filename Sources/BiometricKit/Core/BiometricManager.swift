import Foundation

#if canImport(LocalAuthentication)
import LocalAuthentication
#endif

/// A premium, asynchronous manager for handling biometric authentication (FaceID/TouchID/OpticID).
///
/// `BiometricManager` provides a unified interface for checking biometric availability 
/// and performing authentication with native security standards.
///
/// ## Usage
/// ```swift
/// let result = await BiometricManager.shared.authenticate(reason: "Login to your account")
/// switch result {
/// case .success: print("Access Granted")
/// case .failure(let error): print("Access Denied: \(error.localizedDescription)")
/// }
/// ```
@MainActor
public final class BiometricManager: ObservableObject {
    
    /// The shared singleton instance of `BiometricManager`.
    public static let shared = BiometricManager()
    
    private init() {}
    
    /// Checks if biometric authentication is available on the current device.
    public var isAvailable: Bool {
        #if canImport(LocalAuthentication)
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        #else
        return false
        #endif
    }
    
    /// Performs biometric authentication.
    ///
    /// - Parameter reason: The localized string displayed to the user explaining why authentication is needed.
    /// - Returns: A `BiometricResult` indicating success or the specific `BiometricError`.
    public func authenticate(reason: String) async -> BiometricResult {
        #if canImport(LocalAuthentication)
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .failure(.notAvailable)
        }
        
        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            return success ? .success : .failure(.canceled)
        } catch let laError as LAError {
            return .failure(BiometricError(from: laError))
        } catch {
            return .failure(.unknown)
        }
        #else
        return .failure(.notAvailable)
        #endif
    }
    
    /// The type of biometric authentication supported by the current device.
    public var type: BiometricType {
        #if canImport(LocalAuthentication)
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        
        switch context.biometryType {
        case .faceID: return .faceID
        case .touchID: return .touchID
        case .none: return .none
        #if os(visionOS)
        case .opticID: return .opticID
        #endif
        @unknown default: return .none
        }
        #else
        return .none
        #endif
    }
}

/// The result of a biometric authentication attempt.
public enum BiometricResult: Sendable {
    /// Authentication was successful.
    case success
    /// Authentication failed with a specific error.
    case failure(BiometricError)
}

/// Specific errors that can occur during biometric authentication.
public enum BiometricError: Error, Sendable, LocalizedError {
    case notAvailable
    case canceled
    case lockedOut
    case notEnrolled
    case unknown
    
    #if canImport(LocalAuthentication)
    init(from laError: LAError) {
        switch laError.code {
        case .userCancel, .appCancel, .systemCancel: self = .canceled
        case .biometryNotAvailable: self = .notAvailable
        case .biometryLockout: self = .lockedOut
        case .biometryNotEnrolled: self = .notEnrolled
        default: self = .unknown
        }
    }
    #endif
    
    public var errorDescription: String? {
        switch self {
        case .notAvailable: return "Biometrics not available."
        case .canceled: return "Authentication was canceled."
        case .lockedOut: return "Locked out. Too many failed attempts."
        case .notEnrolled: return "No biometrics enrolled."
        case .unknown: return "An unknown error occurred."
        }
    }
}

/// The types of biometric authentication methods used in the ErsanQ ecosystem.
public enum BiometricType: String, Sendable {
    case none = "None"
    case faceID = "FaceID"
    case touchID = "TouchID"
    case opticID = "OpticID"
}
