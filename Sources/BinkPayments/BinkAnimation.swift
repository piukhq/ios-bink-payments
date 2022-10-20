//
//  BinkAnimation.swift
//  
//
//  Created by Sean Williams on 20/10/2022.
//

import UIKit

class BinkAnimation {
    enum AnimationType: String {
        case shake
    }

    let animation: CAAnimation
    let type: AnimationType

    init(animation: CAAnimation, type: AnimationType) {
        self.animation = animation
        self.type = type
    }

    static let shake: BinkAnimation = {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.speed = 0.8
        animation.values = [0.9, 1.1, 0.9, 1.1, 0.95, 1.05, 0.98, 1.02, 1.0]
        return BinkAnimation(animation: animation, type: .shake)
    }()
}

extension CALayer {
    func addBinkAnimation(_ animation: BinkAnimation) {
        add(animation.animation, forKey: animation.type.rawValue)
    }
}
