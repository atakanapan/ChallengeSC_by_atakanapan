//
//  Extensions.swift
//  Challenge
//
//  Created by Taras Nikulin on 15/10/2025.
//

import UIKit

extension UIView {
    
    /// Add a subtle shadow to the view
    func addShadow(color: UIColor = .black, opacity: Float = 0.1, offset: CGSize = CGSize(width: 0, height: 2), radius: CGFloat = 4) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
    
    /// Add a border to the view
    func addBorder(color: UIColor, width: CGFloat) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    
    /// Make the view circular (assuming it's a square)
    func makeCircular() {
        layer.cornerRadius = frame.width / 2
        clipsToBounds = true
    }
}

extension UIViewController {
    
    /// Show a simple alert with title and message
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    /// Show an alert with custom actions
    func showActionSheet(title: String?, message: String?, actions: [UIAlertAction], sourceView: UIView? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        actions.forEach { alert.addAction($0) }
        
        // For iPad compatibility
        if let popover = alert.popoverPresentationController {
            if let sourceView = sourceView {
                popover.sourceView = sourceView
                popover.sourceRect = sourceView.bounds
            } else {
                popover.sourceView = view
                popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            }
        }
        
        present(alert, animated: true)
    }
}

extension String {
    
    /// Validate if string is a valid email
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
    
    /// Validate if string is a valid phone number (basic validation)
    var isValidPhoneNumber: Bool {
        let phoneRegex = "^[+]?[0-9\\s\\-\\(\\)]{10,}$"
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: self)
    }
    
    /// Capitalize first letter of each word
    var titleCased: String {
        return self.capitalized
    }
}

extension UIImage {
    
    /// Create a placeholder image with initials
    static func placeholder(initials: String, size: CGSize = CGSize(width: 100, height: 100), backgroundColor: UIColor = .systemBlue, textColor: UIColor = .white) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: textColor,
                .font: UIFont.systemFont(ofSize: size.width * 0.4, weight: .semibold)
            ]
            
            let attributedString = NSAttributedString(string: initials.uppercased(), attributes: attributes)
            let stringSize = attributedString.size()
            let stringRect = CGRect(
                x: (size.width - stringSize.width) / 2,
                y: (size.height - stringSize.height) / 2,
                width: stringSize.width,
                height: stringSize.height
            )
            
            attributedString.draw(in: stringRect)
        }
    }
}
