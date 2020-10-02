//
//  MaskMojiCellCollectionViewCell.swift
//  MaskMoji
//
//  Created by Robert on 9/12/20.
//  Copyright © 2020 Robert Diamond. All rights reserved.
//

import UIKit

class MaskMojiCellCollectionViewCell: UICollectionViewCell {    
    @IBOutlet weak var maskMojiLabel: UILabel!
    
    override var isHighlighted: Bool{
        didSet {
            self.backgroundColor = isHighlighted ? UIColor.blue : UIColor.systemBackground
        }
    }
}
