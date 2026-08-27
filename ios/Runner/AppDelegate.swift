import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Dart tomondagi `DeviceInfoService` shu nom bilan murojaat qiladi.
  private let deviceChannelName = "colloborator_v3/device"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerDeviceChannel(with: engineBridge.pluginRegistry)
  }

  /// Qurilma ma'lumoti kanalini ro'yxatga oladi.
  /// Nega bu yerda: yangi Flutter shablonida FlutterViewController AppDelegate'da
  /// turmaydi, binaryMessenger faqat plugin registrar orqali olinadi.
  private func registerDeviceChannel(with registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "DeviceInfoChannel") else { return }

    let channel = FlutterMethodChannel(
      name: deviceChannelName,
      binaryMessenger: registrar.messenger()
    )

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "getDeviceInfo":
        result(Self.deviceInfo())
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  /// Android tomondagi map bilan bir xil kalitlarni qaytaradi.
  ///
  /// `identifierForVendor` — ANDROID_ID ning iOS dagi eng yaqin muqobili:
  /// bitta ishlab chiquvchining ilovalari uchun barqaror, ilova o'chirilsa yangilanadi.
  private static func deviceInfo() -> [String: String] {
    let device = UIDevice.current

    return [
      "uniqueId": device.identifierForVendor?.uuidString ?? "",
      "name": device.name,
      "brand": "Apple",
      "osVersion": "iOS \(device.systemVersion)",
    ]
  }
}
