import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//    var flutter_native_splash = 1
    UIApplication.shared.isStatusBarHidden = false
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let supayChannel = FlutterMethodChannel(name: "supay",
                                              binaryMessenger: controller.binaryMessenger)
    supayChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      // Note: this method is invoked on the UI thread.
      guard call.method == "onSupayPay" else {
        result(FlutterMethodNotImplemented)
        return
      }
        self?.onSupayPay(supayChannel: supayChannel)
//        SPSDKPay.createPayment("aaa", paymentChannel: SPSDKPaymentChannelWX, appURLScheme: "supaysdk", universalLink: "aaa", withCompletion: { result, error in
//            if let result = result {
//                print("completion block: \(result)")
//            }
//            if error == nil && (result?["status"] as? NSNumber)?.uintValue ?? 0 == 200 {
//                print("Success")
//            } else {
//                if let get = error?.getMsg() {
//                    print(String(format: "Error: code=%lu msg=%@", UInt(error?.code ?? 0), get))
//                }
//            }
//        })

    })
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
//    private func receiveBatteryLevel(result: FlutterResult) {
//      result("aaaa")
//    }
    
    private func onSupayPay(supayChannel: FlutterMethodChannel) {
              SPSDKPay.createPayment("aaa" as NSObject, paymentChannel: SPSDKPaymentChannel.WX, appURLScheme: "aaa", withCompletion: { result, error in
                  if let result = result {
//                    flutterResult("completion block: \(result)")
                      print("completion block: \(result)")
//                      result("completion block: \(result)")
                  }
                  if error == nil && (result?["status"] as? NSNumber)?.uintValue ?? 0 == 200 {
//                    flutterResult("aaaa")
                      print("Success")
//                      result("Success")
                  } else {
//                    flutterResult("aaaa")
                    print("error")
                    self.invokeFlutterMethod(supayChannel: supayChannel, flutterMethod: "payFailure", message: "支付失败")
//                      result("error")
      //                if let get = error?.getMsg() {
      //                    print(String(format: "Error: code=%lu msg=%@", error?.code as! CVarArg, get))
      //                }
                  }
              })
              SPSDKPay.setDebugMode(true)
    }
    
    private func invokeFlutterMethod(supayChannel: FlutterMethodChannel, flutterMethod: String, message: String) {
        supayChannel.invokeMethod(flutterMethod, arguments: message)
    }
}
