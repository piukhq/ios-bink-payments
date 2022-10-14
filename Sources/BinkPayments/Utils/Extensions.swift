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
    // MARK: - Cell
    
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

extension UIView {
    func pin(to view: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

public extension UICollectionReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

public extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
