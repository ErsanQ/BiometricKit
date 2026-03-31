import Foundation

#if canImport(LocalAuthentication)
import LocalAuthentication
#endif

/// A premium, asynchronous manager for handling biometric authentication (FaceID/TouchID).
///
/// `BiometricManager` provides a unified interface for checking biometric availability 
/// and performing authentication with native security standards.
///
/// ## Usage
/// ```swift
/// let success = await BiometricManager.shared.authenticate(reason: "Login to your account")
/// if success {
///     showPrivateContent()
/// }
/// ```
@MainActor
public final class BiometricManager: ObservableObject {
    
    /// The shared singleton instance of `BiometricManager`.
    public static let shared = BiometricManager()
    
    private init() {}
    
    /// Checks if biometric authentication is available on the current device.
    ///
    /// This property returns `true` if the device supports FaceID, TouchID, or OpticID 
    /// and the user has enrolled at least one biometric identity.
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
    /// - Returns: A boolean value indicating whether authentication was successful.
    public func authenticate(reason: String) async -> Bool {
        #if canImport(LocalAuthentication)
        let context = LAContext()
        
        // Check if biometric authentication is available
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }
        
        do {
            return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
        } catch {
            return false
        }
        #else
        return false
        #endif
    }
    
    /// The type of biometric authentication supported by the current device.
    public var biometricType: BiometricType {
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

/// The types of biometric authentication methods used in the ErsanQ ecosystem.
public enum BiometricType: Sendable {
    /// No biometric authentication is available.
    case none
    /// Apple's facial recognition technology.
    case faceID
    /// Apple's fingerprint recognition technology.
    case touchID
    /// Apple's iris recognition technology (visionOS specific).
    case opticID
}
