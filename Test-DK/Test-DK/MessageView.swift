//
//  InfoAlertView.swift
//  binkapp
//
//  Created by Sean Williams on 20/10/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

enum ResponseCodeVisualizer {
    case success
    case warning
    case failure
    case info
}

protocol MessageViewTestable {
    func getType() -> MessageType
    func getMessageButton() -> MessageButton?
}

class MessageView: UIView, UIGestureRecognizerDelegate {
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.font = .systemFont(ofSize: 11)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.widthAnchor.constraint(equalToConstant: MessageViewConstants.buttonWidth).isActive = true
        button.addTarget(self, action: #selector(performAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackview: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [textLabel])
        stackview.frame = CGRect(x: self.bounds.origin.x + MessageViewConstants.stackviewPadding, y: self.bounds.origin.y, width: self.bounds.width - (MessageViewConstants.stackviewPadding * 2), height: self.bounds.height)
        stackview.axis = .horizontal
        stackview.distribution = .fill
        stackview.spacing = MessageViewConstants.stackviewSpacing
        return stackview
    }()
    
    private var timer: Timer?
    private let message: String
    private let type: MessageType
    private let messageButton: MessageButton?
    
    init(message: String, type: MessageType, window: UIWindow, button: MessageButton? = nil) {
        self.message = message
        self.type = type
        self.messageButton = button

        var originFrame: CGRect
        switch type {
        case .snackbar:
            originFrame = CGRect(x: MessageViewConstants.xPosition, y: window.bounds.height, width: window.bounds.width - (MessageViewConstants.xPosition * 2), height: MessageViewConstants.height)
        case .responseCodeVisualizer:
            originFrame = CGRect(x: MessageViewConstants.xPosition, y: 0, width: window.bounds.width - (MessageViewConstants.xPosition * 2), height: MessageViewConstants.height)
        }
        
        super.init(frame: originFrame)
        
        if let button = button {
            self.button.setTitle(button.title.capitalized, for: .normal)
            self.button.setTitleColor(button.textColor, for: .normal)
            stackview.addArrangedSubview(self.button)
        }

        self.textLabel.text = message
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static func shouldShowMessage(_ type: MessageType) -> Bool {
        switch type {
        case .responseCodeVisualizer:
            return true
        case .snackbar:
            return true
        }
    }
    
    private func configureUI() {
        layer.cornerRadius = MessageViewConstants.cornerRadius
        layer.cornerCurve = .continuous
        addSubview(stackview)
        
        switch type {
        case .responseCodeVisualizer(let infoType):
            switch infoType {
            case .success:
                self.backgroundColor = .systemGreen
            case .warning:
                self.backgroundColor = .systemOrange
            case .failure:
                self.backgroundColor = .systemRed
            default:
                self.backgroundColor = .gray
            }
        case .snackbar:
            self.backgroundColor = .lightGray
        }
        
        configureGestureRecognizer(direction: .up)
        configureGestureRecognizer(direction: .left)
        configureGestureRecognizer(direction: .right)
    }
    
    @objc func performAction () {
        messageButton?.action()
    }
    
    static func show(_ message: String, type: MessageType, button: MessageButton? = nil) {
        guard shouldShowMessage(type) else { return }
        if let window = UIApplication.shared.connectedScenes.flatMap({ ($0 as? UIWindowScene)?.windows ?? [] }).first(where: { $0.isKeyWindow }) {
            if let messageView = window.subviews.first(where: { $0.isKind(of: MessageView.self) }) as? MessageView {
                messageView.hideSideways(direction: .left) {
                    configureMessageView(message, type: type, window: window, button: button)
                }
            } else {
                configureMessageView(message, type: type, window: window, button: button)
            }
        } else {
            fatalError("Couldn't get window")
        }
    }
    
    static private func configureMessageView(_ message: String, type: MessageType, window: UIWindow, button: MessageButton? = nil) {
        let view = MessageView(message: message, type: type, window: window, button: button)
        window.addSubview(view)
        DispatchQueue.main.async {
            view.show()
        }
    }
    
    private func show() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: type.timeInterval, repeats: false) { _ in
            self.hide()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.frame = CGRect(x: self.frame.origin.x, y: self.type.showOffset, width: self.frame.width, height: self.frame.height)
        }
    }
    
    private func hide() {
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect(x: self.frame.origin.x, y: self.type.hideOffset, width: self.frame.width, height: self.frame.height)
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    private func hideSideways(direction: UISwipeGestureRecognizer.Direction, completion: (() -> Void)? = nil) {
        let xOffset: CGFloat = direction == .left ? MessageViewConstants.hideLeftOffset : MessageViewConstants.hideRightOffset
        UIView.animate(withDuration: 0.2, animations: {
            self.frame = CGRect(x: xOffset, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
        }) { _ in
            self.removeFromSuperview()
            completion?()
        }
    }
    
    private func configureGestureRecognizer(direction: UISwipeGestureRecognizer.Direction) {
        let gestureRecognizer = UISwipeGestureRecognizer(target: self, action: .handleSwipe)
        gestureRecognizer.delegate = self
        gestureRecognizer.direction = direction
        self.addGestureRecognizer(gestureRecognizer)
    }

    @objc func handleSwipe(gesture: UISwipeGestureRecognizer) {
        timer?.invalidate()

        switch gesture.direction {
        case .up:
            hide()
        case .left, .right:
            hideSideways(direction: gesture.direction)
        default:
            break
        }
    }
}

//extension MessageView: MessageViewTestable {
//    func getMessageButton() -> MessageButton? {
//        return messageButton
//    }
//
//    func getType() -> MessageType {
//        return type
//    }
//}

struct MessageButton {
    enum ButtonType {
        case success
        case error
    }
    
    let title: String
    let type: ButtonType
    let action: () -> Void
    
    var textColor: UIColor {
        switch type {
        case .success:
            return .systemGreen
        case .error:
            return .systemRed
        }
    }
}

enum MessageType: Equatable {
    enum Length {
        case short
        case long
    }
    
    case snackbar(Length)
    case responseCodeVisualizer(ResponseCodeVisualizer)

    var showOffset: CGFloat {
        switch self {
        case .snackbar:
            return MessageViewConstants.Snackbar.showOffset
        case .responseCodeVisualizer:
            return MessageViewConstants.ResponseCodeVisualizer.showOffset
        }
    }
    
    var hideOffset: CGFloat {
        switch self {
        case .snackbar:
            return MessageViewConstants.Snackbar.hideOffset
        case .responseCodeVisualizer:
            return MessageViewConstants.ResponseCodeVisualizer.hideOffset
        }
    }
    
    var timeInterval: Double {
        switch self {
        case .snackbar(let snackbarType):
            switch snackbarType {
            case .short:
                return MessageViewConstants.timeIntervalShort
            case .long:
                return MessageViewConstants.timeIntervalLong
            }
        case .responseCodeVisualizer:
            return MessageViewConstants.timeIntervalLong
        }
    }
}

private enum MessageViewConstants {
    enum Snackbar {
        static let showOffset: CGFloat = UIScreen.main.bounds.height - 100
        static let hideOffset: CGFloat = UIScreen.main.bounds.height + 100
    }
    
    enum ResponseCodeVisualizer {
        static let showOffset: CGFloat = 50
        static let hideOffset: CGFloat = -50
    }

    static let timeIntervalShort: CGFloat = 1.5
    static let timeIntervalLong: CGFloat = 2.75
    static let buttonWidth: CGFloat = 60
    static let stackviewSpacing: CGFloat = 15
    static let stackviewPadding: CGFloat = 20
    static let xPosition: CGFloat = 25
    static let height: CGFloat = 70
    static let cornerRadius: CGFloat = 15
    static let hideLeftOffset: CGFloat = -500
    static let hideRightOffset: CGFloat = 500
}

private extension Selector {
    static let handleSwipe = #selector(MessageView.handleSwipe(gesture:))
}
