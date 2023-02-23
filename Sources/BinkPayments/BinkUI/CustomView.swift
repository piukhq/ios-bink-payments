//
//  CustomView.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

open class CustomView: UIView {
    public var view: UIView!
    
    var reuseableId: String {
        return String(describing: type(of: self))
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        configureUI()
        addSubview(view)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        view.frame = bounds
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Foundation.Bundle.module
        let nib = UINib(nibName: self.reuseableId, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as? UIView
        guard let viewFromNib = view else { fatalError("Cannot create view from nib") }
        return viewFromNib
    }
    
    open func configureUI() {}
}
