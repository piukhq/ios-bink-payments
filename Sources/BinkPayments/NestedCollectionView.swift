//
//  NestedCollectionView.swift
//  
//
//  Created by Sean Williams on 14/10/2022.
//

import UIKit

class NestedCollectionView: UICollectionView {
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        return collectionViewLayout.collectionViewContentSize
    }
}
