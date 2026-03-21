import Flutter
import UIKit
import GoogleMaps
import FirebaseCore
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Phase 2: Configure Firebase before anything else
    FirebaseApp.configure()

    // Phase 2: Provide plugin registrant callback for flutter_local_notifications
    // so it can show notifications when the app is in the background/terminated.
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }

    // Phase 2: Set the notification centre delegate so iOS shows
    // foreground notifications as banners (alert / sound / badge).
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    // Google Maps API key
    GMSServices.provideAPIKey("AIzaSyCchive97vTtl8MS1PPXV2WtvFCxW_Dd8w")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
