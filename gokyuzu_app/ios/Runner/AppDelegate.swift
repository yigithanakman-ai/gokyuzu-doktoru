import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "CosmicNotifications") {
      let channel = FlutterMethodChannel(
        name: "com.gokyuzudoktoru.gokyuzu_app/notifications",
        binaryMessenger: registrar.messenger()
      )
      channel.setMethodCallHandler { call, result in
        let center = UNUserNotificationCenter.current()
        switch call.method {
        case "requestPermission":
          center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
              result(granted)
            }
          }
        case "areNotificationsEnabled":
          center.getNotificationSettings { settings in
            let enabled = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
            DispatchQueue.main.async {
              result(enabled)
            }
          }
        case "showInstantNotification":
          let args = call.arguments as? [String: Any]
          let id = args?["id"] as? Int ?? 999
          let title = args?["title"] as? String ?? "Gökyüzü Doktoru 🌌"
          let body = args?["body"] as? String ?? "Günlük kozmik bildirimleriniz aktif edildi."
          let content = UNMutableNotificationContent()
          content.title = title
          content.body = body
          content.sound = .default
          let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
          let req = UNNotificationRequest(identifier: "instant_\(id)", content: content, trigger: trigger)
          center.add(req) { _ in
            DispatchQueue.main.async {
              result(true)
            }
          }
        case "scheduleDailyNotifications":
          let args = call.arguments as? [String: Any]
          let items = args?["items"] as? [[String: Any]] ?? []
          center.removeAllPendingNotificationRequests()
          for item in items {
            let id = item["id"] as? Int ?? 101
            let hour = item["hour"] as? Int ?? 9
            let minute = item["minute"] as? Int ?? 30
            let title = item["title"] as? String ?? "Gökyüzü Doktoru 🌌"
            let body = item["body"] as? String ?? "Günün kozmik enerjilerini inceleyin."
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let req = UNNotificationRequest(identifier: "daily_\(id)", content: content, trigger: trigger)
            center.add(req, withCompletionHandler: nil)
          }
          result(true)
        case "cancelAllNotifications":
          center.removeAllPendingNotificationRequests()
          result(true)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
  }
}
