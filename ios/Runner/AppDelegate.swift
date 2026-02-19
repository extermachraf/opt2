import UIKit
import Flutter
import LocalAuthentication

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let biometricChannel = FlutterMethodChannel(name: "nutrivita/biometric",
                                              binaryMessenger: controller.binaryMessenger)
    
    biometricChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      
      switch call.method {
      case "isBiometricAvailable":
        let context = LAContext()
        var error: NSError?
        let isAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        result(isAvailable)

      case "getAvailableBiometrics":
        let context = LAContext()
        var types: [String] = []

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
          switch context.biometryType {
          case .faceID:
            types.append("face")
          case .touchID:
            types.append("touch")
          default:
            types.append("fingerprint")
          }
        }
        result(types)

      case "authenticate":
        let signInTitle = (call.arguments as? [String: Any])?["signInTitle"] as? String ?? "Autenticazione Biometrica"

        let context = LAContext()
        context.localizedFallbackTitle = "Usa Password"

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                              localizedReason: signInTitle) { success, error in
          DispatchQueue.main.async {
            if success {
              result(true)
            } else if let error = error as? LAError {
              switch error.code {
              case .userCancel:
                result(FlutterError(code: "UserCancel", message: "Autenticazione annullata", details: nil))
              case .biometryNotAvailable:
                result(FlutterError(code: "NotAvailable", message: "Biometria non disponibile", details: nil))
              case .biometryNotEnrolled:
                result(FlutterError(code: "NotEnrolled", message: "Biometria non configurata", details: nil))
              case .biometryLockout:
                result(FlutterError(code: "PermanentlyLockedOut", message: "Biometria bloccata", details: nil))
              case .passcodeNotSet:
                result(FlutterError(code: "PasscodeNotSet", message: "Codice di accesso non impostato", details: nil))
              default:
                result(FlutterError(code: "AuthenticationError", message: error.localizedDescription, details: nil))
              }
            } else {
              result(false)
            }
          }
        }
        
      default:
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}