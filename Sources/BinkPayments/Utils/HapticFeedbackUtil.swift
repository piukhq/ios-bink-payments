//
//  File.swift
//  
//
//  Created by Sean Williams on 20/10/2022.
//

import UIKit

enum HapticFeedbackUtil {
    static func giveFeedback(forType type: UINotificationFeedbackGenerator.FeedbackType) {
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        notificationFeedbackGenerator.notificationOccurred(type)
    }
}
