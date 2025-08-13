import Flutter
import UIKit

public class PlusNavigatorPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "plus_navigator", binaryMessenger: registrar.messenger())
        let instance = PlusNavigatorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("PlusNavigatorPlugin received method: \(call.method)")
        switch call.method {
        case "getStatusbarHeight":
            let statusBarHeight = getStatusbarHeight()
            print("getStatusbarHeight result: \(statusBarHeight)")
            result(statusBarHeight)
        case "setStatusBarBackground":
            if let args = call.arguments as? [String: Any],
               let colorString = args["color"] as? String {
                print("setStatusBarBackground called with color: \(colorString)")
                setStatusBarBackground(color: colorString)
                result(nil)
            } else {
                print("setStatusBarBackground failed: invalid arguments")
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Color is null", details: nil))
            }
        case "getStatusBarBackground":
            let color = getStatusBarBackground()
            print("getStatusBarBackground result: \(color)")
            result(color)
        case "setStatusBarStyle":
            if let args = call.arguments as? [String: Any],
               let style = args["style"] as? String {
                print("setStatusBarStyle called with style: \(style)")
                setStatusBarStyle(style: style)
                result(nil)
            } else {
                print("setStatusBarStyle failed: invalid arguments")
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Style is null", details: nil))
            }
        case "getStatusBarStyle":
            let style = getStatusBarStyle()
            print("getStatusBarStyle result: \(style)")
            result(style)
        case "isBackground":
            // 在iOS中，我们无法直接判断应用是否在后台，这里返回false作为默认值
            result(false)
        default:
            print("PlusNavigatorPlugin unknown method: \(call.method)")
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func getStatusbarHeight() -> Double {
        let statusBarHeight: Double
        if #available(iOS 13.0, *) {
            statusBarHeight = UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        return Double(statusBarHeight)
    }
    
    private var statusBarOverlay: UIView?
    
    private func setStatusBarBackground(color: String) {
        print("setStatusBarBackground called with color: \(color)")
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else { 
                print("setStatusBarBackground: No window found")
                return 
            }
            guard let uiColor = UIColor.colorFromHexString(color) else { 
                print("setStatusBarBackground: Invalid color string: \(color)")
                return 
            }
            
            print("setStatusBarBackground: Window found, color parsed successfully")
            
            // 保存当前颜色值
            self.currentStatusBarColor = color
            
            // 先移除之前的状态栏覆盖层
            if let overlay = self.statusBarOverlay {
                print("setStatusBarBackground: Removing previous overlay")
                overlay.removeFromSuperview()
            }
            
            if #available(iOS 13.0, *) {
                guard let statusBarFrame = window.windowScene?.statusBarManager?.statusBarFrame else { 
                    print("setStatusBarBackground: No status bar frame found (iOS 13+)")
                    return 
                }
                
                print("setStatusBarBackground: Creating status bar overlay for iOS 13+, frame: \(statusBarFrame)")
                let statusBar = UIView(frame: statusBarFrame)
                statusBar.backgroundColor = uiColor
                statusBar.tag = 999 // 用于识别状态栏覆盖层
                
                // 确保状态栏覆盖层在最顶层
                window.addSubview(statusBar)
                self.statusBarOverlay = statusBar
                print("setStatusBarBackground: Status bar overlay added successfully")
            } else {
                // iOS 13以下版本使用不同的方法
                let statusBarFrame = UIApplication.shared.statusBarFrame
                print("setStatusBarBackground: Creating status bar overlay for iOS <13, frame: \(statusBarFrame)")
                let statusBar = UIView(frame: statusBarFrame)
                statusBar.backgroundColor = uiColor
                statusBar.tag = 999
                
                window.addSubview(statusBar)
                self.statusBarOverlay = statusBar
                print("setStatusBarBackground: Status bar overlay added successfully")
            }
        }
    }
    
    private var currentStatusBarColor: String = "#000000"
    
    private func getStatusBarBackground() -> String {
        return currentStatusBarColor
    }
    
    private func setStatusBarStyle(style: String) {
        switch style {
        case "light":
            UIApplication.shared.statusBarStyle = .lightContent
        case "dark":
            if #available(iOS 13.0, *) {
                UIApplication.shared.statusBarStyle = .darkContent
            } else {
                UIApplication.shared.statusBarStyle = .default
            }
        default:
            UIApplication.shared.statusBarStyle = .default
        }
    }
    
    private func getStatusBarStyle() -> String {
        switch UIApplication.shared.statusBarStyle {
        case .lightContent:
            return "light"
        case .darkContent:
            return "dark"
        default:
            return "light"
        }
    }
}

// UIColor 扩展，用于解析十六进制颜色字符串
extension UIColor {
    static func colorFromHexString(_ hexString: String) -> UIColor? {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}