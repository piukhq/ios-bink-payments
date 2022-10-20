//
//  Extensions.swift
//  
//
//  Created by Ricardo Silva on 26/09/2022.
//

import UIKit

enum DateFormat: String {
    case dayMonthYear = "dd MMMM yyyy"
    case dayShortMonthYear = "dd MMM yyyy"
    case dayShortMonthYearWithSlash = "dd/MM/yyyy"
    case dayShortMonthYear24HourSecond = "dd MMM yyyy HH:mm:ss"
}

public extension Date {
    static func makeDate(year: Int, month: Int, day: Int, hr: Int, min: Int, sec: Int) -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: year, month: month, day: day, hour: hr, minute: min, second: sec)
        return calendar.date(from: components)
    }
    
    func isBefore(date: Date, toGranularity: Calendar.Component) -> Bool {
        let comparisonResult = Calendar.current.compare(self, to: date, toGranularity: toGranularity)
        
        switch comparisonResult {
        case .orderedSame:
            return false
        case .orderedDescending:
            return false
        case .orderedAscending:
            return true
        }
    }

    var monthHasNotExpired: Bool {
        return !self.isBefore(date: Date(), toGranularity: .month)
    }

    static func numberOfSecondsIn(days: Int) -> Int {
        return days * 24 * 60 * 60
    }

    static func numberOfSecondsIn(hours: Int) -> Int {
        return hours * 60 * 60
    }

    static func numberOfSecondsIn(minutes: Int) -> Int {
        return minutes * 60
    }

    static func hasElapsed(days: Int, since date: Date) -> Bool {
        let elapsed = Int(Date().timeIntervalSince(date))
        return elapsed >= Date.numberOfSecondsIn(days: days)
    }

    static func hasElapsed(hours: Int, since date: Date) -> Bool {
        let elapsed = Int(Date().timeIntervalSince(date))
        return elapsed >= Date.numberOfSecondsIn(hours: hours)
    }

    static func hasElapsed(minutes: Int, since date: Date) -> Bool {
        let elapsed = Int(Date().timeIntervalSince(date))
        return elapsed >= Date.numberOfSecondsIn(minutes: minutes)
    }
}

extension String {
    public var isBlank: Bool {
        return allSatisfy({ $0.isWhitespace })
    }
}

public extension UICollectionView {    
    func register<T: UICollectionViewCell>(_: T.Type, asNib: Bool = false) {
        if asNib {
            register(UINib(nibName: T.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: T.reuseIdentifier)
        } else {
            register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    func dequeue<T: UICollectionViewCell>(indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
}

extension UIViewController {
    static public func topMostViewController() -> UIViewController? {
        let window = UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }
        if var topController = window?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}

extension UIView {
    func pin(to view: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    static func fromNib<T: UIView>() -> T {
        guard let viewFromNib = Foundation.Bundle.module.loadNibNamed(String(describing: T.self), owner: self)?.first as? T else { fatalError("Could not load view from nib") }
        return viewFromNib
    }
}

public extension UICollectionReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UINavigationController {
    func removeViewController(_ viewController: UIViewController) {
        if let index = viewControllers.firstIndex(where: { $0 == viewController }) {
            viewControllers.remove(at: index)
        }
    }
}

public extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if hexString.hasPrefix("#") {
            scanner.currentIndex = hexString.index(hexString.startIndex, offsetBy: 1)
        }
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    // MARK: - Payment Card Gradient Colours

    static let visaGradientLeft = UIColor(hexString: "13288d")
    static let visaGradientRight = UIColor(hexString: "181c51")

    static let mastercardGradientLeft = UIColor(hexString: "f79e1b")
    static let mastercardGradientRight = UIColor(hexString: "eb001b")

    static let amexGradientLeft = UIColor(hexString: "57c4ff")
    static let amexGradientRight = UIColor(hexString: "006bcd")

    static let unknownGradientLeft = UIColor(hexString: "b46fea")
    static let unknownGradientRight = UIColor(hexString: "4371fe")

    static let visaPaymentCardGradients: [CGColor] = [UIColor.visaGradientLeft.cgColor, UIColor.visaGradientRight.cgColor]
    static let mastercardPaymentCardGradients: [CGColor] = [UIColor.mastercardGradientLeft.cgColor, UIColor.mastercardGradientRight.cgColor]
    static let amexPaymentCardGradients: [CGColor] = [UIColor.amexGradientLeft.cgColor, UIColor.amexGradientRight.cgColor]
    static let unknownPaymentCardGradients: [CGColor] = [UIColor.systemBlue.cgColor, UIColor.systemPink.cgColor]
    
    static let okGreen = UIColor(hexString: "50A7AB")
}

extension CALayer {
    func applyDefaultBinkShadow() {
        applySketchShadow(color: .black, alpha: 0.1, x: 0, y: 3, blur: 15, spread: 0)
    }

    func applySketchShadow(color: UIColor = .black, alpha: Float = 0.5, x: CGFloat = 0, y: CGFloat = 2, blur: CGFloat = 4, spread: CGFloat = 0) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0

        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}
