//
//  CheckboxView.swift
//  
//
//  Created by Sean Williams on 14/12/2022.
//

import UIKit

class CheckboxViewBroken: CustomView {

    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var checkbox: UIButton!
    
//    private lazy var addButton: UIButton = {
//        let button = UIButton(type: .roundedRect)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.backgroundColor = .systemPink
//        button.setTitle("CHECKBOX", for: .normal)
////        button.layer.cornerRadius = Constants.buttonCornerRadius
//        button.layer.cornerCurve = .continuous
//        button.tintColor = .label
//        button.isEnabled = true
//        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
//        view.addSubview(button)
//        return button
//    }()
    
    private var checkedState = false
    private var text: String?
    
    init(checked: Bool) {
        super.init(frame: .zero)
        checkedState = checked
        configureCheckboxButton(forState: checkedState, animated: false)
    }
    
    func configureCheckboxButton(forState: Bool, animated: Bool) {
        
    }
//    init(checkedState: Bool, text: String?) {
//        self.checkedState = checkedState
//        self.text = text
//        super.init(frame: .zero)
////        xibSetup()
//
////        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
////        checkboxButton.addGestureRecognizer(tapGesture)
////
////        NSLayoutConstraint.activate([
////            view.centerXAnchor.constraint(equalTo: addButton.centerXAnchor),
////            view.centerYAnchor.constraint(equalTo: addButton.centerYAnchor)
////            ])
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func xibSetup() {
//        view = loadViewFromNib()
//        view.frame = bounds
//        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        addSubview(view)
//    }
//
    @objc func buttonTapped() {
        print("YO")
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Foundation.Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as? UIView
        guard let viewFromNib = view else { fatalError("Cannot create view from nib") }
        return viewFromNib
    }
    

    @IBAction func bap(_ sender: Any) {
        print("Boop")
    }
    
//    @IBAction func checkboxTapped(_ sender: Any) {
//        print("Checkbox tapped")
//    }
//
    
}
