import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  private let CHANNEL = "screen_security"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { (call, result) in
        switch call.method {
        case "enable":
            // iOS no permite bloquear screenshots
            result(nil)
        case "disable":
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenCaptured),
      name: UIScreen.capturedDidChangeNotification,
      object: nil
    )

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  var blackView: UIView?
  @objc func screenCaptured() {
    if UIScreen.main.isCaptured {
      if blackView == nil {
        blackView = UIView(frame: window!.frame)
        blackView!.backgroundColor = UIColor.black
        window?.addSubview(blackView!)
      }
    } else {
      blackView?.removeFromSuperview()
      blackView = nil
    }
  }
}