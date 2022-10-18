//
//  AddPaymentCardViewController.swift
//  
//
//  Created by Sean Williams on 14/10/2022.
//

import Combine
import UIKit

class AddPaymentCardViewController: UIViewController {
    // MARK: - Helpers
    
    private enum Constants {
        static let normalCellHeight: CGFloat = 84.0
        static let horizontalInset: CGFloat = 10
        static let bottomInset: CGFloat = 150.0
        static let postCollectionViewPadding: CGFloat = 25.0
        static let preCollectionViewPadding: CGFloat = 10.0
        static let offsetPadding: CGFloat = 30.0
        static let cardHeight: CGFloat = 120.0
    }
    
    // MARK: - Properties
    
    lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: [collectionView], adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.margin = UIEdgeInsets(top: 0, left: Constants.horizontalInset, bottom: 0, right: Constants.horizontalInset)
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.backgroundColor = .systemBackground
        stackView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.bottomInset, right: 0)
        stackView.customPadding(Constants.postCollectionViewPadding, after: collectionView)
        stackView.customPadding(Constants.preCollectionViewPadding, before: collectionView)
        view.addSubview(stackView)
        return stackView
    }()
    
    lazy var collectionView: NestedCollectionView = {
        let collectionView = NestedCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.register(FormCollectionViewCell.self)
        return collectionView
    }()
    
    private lazy var card: PaymentCardCollectionViewCell = {
        let cell: PaymentCardCollectionViewCell = .fromNib()
        return cell
    }()
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return layout
    }()
    
    private var cancellable: AnyCancellable?
    private var hasSetupCell = false
    public var viewModel: AddPaymentCardViewModel
    
    public init(viewModel: AddPaymentCardViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        
        cancellable = viewModel.$paymentCard
            .sink() { [weak self] in
                self?.card.configureWithAddViewModel($0)
            }
    }

    private func configureLayout() {
        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        
        stackScrollView.insert(arrangedSubview: card, atIndex: 0, customSpacing: 20)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: Constants.cardHeight),
            card.widthAnchor.constraint(equalTo: collectionView.widthAnchor)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // This is due to strange layout issues on first appearance
        if collectionView.contentSize.width > 0.0 {
            hasSetupCell = true
            card.configureWithAddViewModel(viewModel.paymentCard)
        }
    }
}

extension AddPaymentCardViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? FormCollectionViewCell else { return }
        cell.setWidth(collectionView.frame.size.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.fields.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FormCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
        let field = viewModel.fields[indexPath.item]
        cell.configure(with: field, delegate: self)
        return cell
    }
}

extension AddPaymentCardViewController: FormCollectionViewCellDelegate {
    func formCollectionViewCell(_ cell: FormCollectionViewCell, didSelectField: UITextField) {
        
    }
    
    func formCollectionViewCell(_ cell: FormCollectionViewCell, shouldResignTextField textField: UITextField) {
        
    }
}
