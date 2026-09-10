import Flutter
import UIKit
import YandexMapsMobile

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Kalit Info.plist orqali keladi, u esa Secrets.xcconfig dan.
    // Fayl bo'lmasa xarita ishlamaydi, lekin ilova ishga tushaveradi.
    if let key = Bundle.main.object(forInfoDictionaryKey: "MapKitApiKey") as? String,
       !key.isEmpty, !key.hasPrefix("$(") {
      YMKMapKit.setApiKey(key)
      YMKMapKit.setLocale("uz_UZ")
    } else {
      NSLog("MapKit kaliti topilmadi — ios/Flutter/Secrets.xcconfig ni tekshiring")
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
