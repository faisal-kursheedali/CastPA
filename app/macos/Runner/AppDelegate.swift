import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var bookmarkChannel: FlutterMethodChannel?

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)
    NSApp.activate(ignoringOtherApps: true)

    guard let controller = mainFlutterWindow?.contentViewController as? FlutterViewController else { return }
    bookmarkChannel = FlutterMethodChannel(
      name: "castpa/bookmark",
      binaryMessenger: controller.engine.binaryMessenger
    )
    bookmarkChannel?.setMethodCallHandler(handleBookmark)
  }

  private func handleBookmark(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "saveBookmark":
      guard let path = call.arguments as? String else {
        result(FlutterError(code: "INVALID_ARG", message: "path required", details: nil))
        return
      }
      do {
        let url = URL(fileURLWithPath: path)
        let data = try url.bookmarkData(
          options: .withSecurityScope,
          includingResourceValuesForKeys: nil,
          relativeTo: nil
        )
        result(FlutterStandardTypedData(bytes: data))
      } catch {
        result(FlutterError(code: "BOOKMARK_FAILED", message: error.localizedDescription, details: nil))
      }

    case "resolveBookmark":
      guard let args = call.arguments as? FlutterStandardTypedData else {
        result(FlutterError(code: "INVALID_ARG", message: "bookmark data required", details: nil))
        return
      }
      do {
        var isStale = false
        let url = try URL(
          resolvingBookmarkData: args.data,
          options: .withSecurityScope,
          relativeTo: nil,
          bookmarkDataIsStale: &isStale
        )
        guard url.startAccessingSecurityScopedResource() else {
          result(FlutterError(code: "ACCESS_DENIED", message: "startAccessingSecurityScopedResource failed", details: nil))
          return
        }
        result(["path": url.path, "isStale": isStale])
      } catch {
        result(FlutterError(code: "RESOLVE_FAILED", message: error.localizedDescription, details: nil))
      }

    case "stopAccessing":
      guard let path = call.arguments as? String else {
        result(nil)
        return
      }
      URL(fileURLWithPath: path).stopAccessingSecurityScopedResource()
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
