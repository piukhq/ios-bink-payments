//
//  StackScrollView.swift
//  binkapp
//
//  Created by Max Woodhams on 15/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

public protocol StackScrollViewDelegate: AnyObject {
    func contentSizeWillUpdate(to size: CGSize)
}

open class StackScrollView: UIScrollView {
    // MARK: - Helpers
    
    private enum Constants {
        static let minimumGuideSizeWidth: CGFloat = 30.0
    }
    
    // MARK: - Properties
    
    private let stackView: UIStackView
    private var stackViewTopConstraint = NSLayoutConstraint()
    private var lastContentInset: UIEdgeInsets?
    
    public var arrangedSubviews: [UIView] {
        return stackView.arrangedSubviews
    }
    
    public var padding: CGFloat {
        get {
            return stackView.spacing
        }
        set {
            stackView.spacing = newValue
        }
    }
    
    public var margin: UIEdgeInsets {
        get {
            return stackView.layoutMargins
        } set {
            stackView.layoutMargins = newValue
        }
    }
    
    public var alignment: UIStackView.Alignment {
        get {
            return stackView.alignment
        } set {
            stackView.alignment = newValue
        }
    }
    
    public var distribution: UIStackView.Distribution {
        get {
            return stackView.distribution
        } set {
            stackView.distribution = newValue
        }
    }
    
    open override var contentSize: CGSize {
        willSet {
            stackScrollDelegate?.contentSizeWillUpdate(to: newValue)
        }
    }
    
    public weak var stackScrollDelegate: StackScrollViewDelegate?
    private lazy var preferredContentSizeWidthConstraint = stackView.widthAnchor.constraint(equalTo: widthAnchor)
    private lazy var minimumContentWidthGuidingConstraint = stackView.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.minimumGuideSizeWidth)
    
    // MARK: - Initialisation
    
    public init(axis: NSLayoutConstraint.Axis, arrangedSubviews: [UIView]? = nil, adjustForKeyboard: Bool = true) {
        if let subviews = arrangedSubviews, !subviews.isEmpty {
            stackView = UIStackView(arrangedSubviews: subviews)
        } else {
            stackView = UIStackView(frame: .zero)
        }
        
        super.init(frame: .zero)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = axis
        stackView.isLayoutMarginsRelativeArrangement = true
        addSubview(stackView)
        
        if axis == .vertical {
            alwaysBounceVertical = true
            
            stackViewTopConstraint = stackView.topAnchor.constraint(equalTo: topAnchor)
            
            NSLayoutConstraint.activate([
                stackViewTopConstraint,
                stackView.widthAnchor.constraint(equalTo: widthAnchor),
                stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            
            if adjustForKeyboard {
                NotificationCenter.default.addObserver(self, selector: .keyboardShow, name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: .keyboardHide, name: UIResponder.keyboardWillHideNotification, object: nil)
            }
        } else {
            /*
            HACK: We need just under the highest priority to ensure these two constraints are honoured.
            The preferredContentSizeWidthConstraint is required to make the stackScrollview try to be as large as it
            can be before scrolling.
            The minimumContentWidthGuidingConstraint is required to ensure that the scrollView attemps to grow causing
            the necessary layout pass required to start drawing it's content.
            */
            preferredContentSizeWidthConstraint.priority = UILayoutPriority(rawValue: 999)
            minimumContentWidthGuidingConstraint.priority = UILayoutPriority(rawValue: 999)
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                stackView.heightAnchor.constraint(equalTo: heightAnchor),
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
                preferredContentSizeWidthConstraint,
                minimumContentWidthGuidingConstraint
            ])
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("This view controller has no related XIB or Storyboard")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - View Lifecycle
    
    override open func layoutIfNeeded() {
        super.layoutIfNeeded()
        stackView.layoutIfNeeded()
    }
    
    // MARK: - Configuration
    
    public func add(arrangedSubview: UIView) {
        stackView.addArrangedSubview(arrangedSubview)
    }
    
    public func add(arrangedSubviews: [UIView]) {
        for view in arrangedSubviews {
            add(arrangedSubview: view)
        }
    }
    
    public func insert(arrangedSubview: UIView, atIndex: Int, customSpacing: CGFloat? = nil) {
        stackView.insertArrangedSubview(arrangedSubview, at: atIndex)
        
        if let customSpacing = customSpacing {
            stackView.setCustomSpacing(customSpacing, after: arrangedSubview)
        }
    }
    
    public func remove(arrangedSubview: UIView) {
        arrangedSubview.removeFromSuperview()
    }
    
    // MARK: - Other
    
    open override func touchesShouldCancel(in view: UIView) -> Bool {
        return true
    }
    
    public func scrollTo(frame: CGRect) {
        setContentOffset(CGPoint(x: 0, y: min(frame.origin.y, contentSize.height - frame.size.height)), animated: true)
    }
    
    public func customPadding(_ padding: CGFloat, after: UIView) {
        stackView.setCustomSpacing(padding, after: after)
    }
    
    /// A method to leverage the customPaddingAfter method by finding the view before the subview in question, and adding padding after it
    /// - Parameter padding: The desired padding
    /// - Parameter before: The view which the padding should be applied before
    public func customPadding(_ padding: CGFloat, before: UIView) {
        var index = 0
        stackView.subviews.forEach {
            if $0 == before {
                guard index != 0 else { return }
                let view = stackView.subviews[index - 1]
                customPadding(padding, after: view)
                return
            }
            index += 1
        }
    }
    
    public func setHeaderHeight(_ height: CGFloat) {
        stackViewTopConstraint.constant = height
    }
    
    public func requiresScrolling() -> Bool {
        switch self.stackView.axis {
        case .vertical:
            return self.contentSize.height > self.frame.size.height
        default:
            return self.contentSize.width > self.frame.size.width
        }
    }
    
    // MARK: - Keyboard Avoidance
    
    @objc fileprivate func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo
        
        guard let frameValue = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return // Do not continue if we cannot get the frame
        }
        
        var keyboardFrame: CGRect = frameValue.cgRectValue
        keyboardFrame = convert(keyboardFrame, from: nil)
        
        var inset: UIEdgeInsets = contentInset
        if inset.bottom != keyboardFrame.size.height { lastContentInset = inset }
        inset.bottom = keyboardFrame.size.height
        contentInset = inset
    }
    
    @objc fileprivate func keyboardWillHide(notification: NSNotification) {
        if let lastInset = lastContentInset {
            contentInset = lastInset
            lastContentInset = nil
        } else {
            contentInset = .zero
        }
    }
}

private extension Selector {
    static let keyboardShow = #selector(StackScrollView.keyboardWillShow(notification:))
    static let keyboardHide = #selector(StackScrollView.keyboardWillHide(notification:))
}
