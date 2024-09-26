import UIKit

func getRootViewController() -> UIViewController? {
    // Get the first window in the application
    if let window = UIApplication.shared.windows.first {
        // Return the root view controller of the window
        return window.rootViewController
    }
    return nil
}

extension UIColor {
    convenience init(rgb: Int) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255.0,
            green: CGFloat((rgb >> 8) & 0xFF) / 255.0,
            blue: CGFloat(rgb & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
}
