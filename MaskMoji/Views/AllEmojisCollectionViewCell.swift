//
//  AllEmojisCollectionViewCell.swift
//  MaskMoji
//
//  Created by Robert on 10/14/20.
//  Copyright © 2020 Robert Diamond. All rights reserved.
//

import UIKit

class AllEmojisCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var emojiLabel: UILabel!
    
    public override var isSelected: Bool {
        didSet {
            if (isSelected) {
                self.contentView.backgroundColor = UIColor.systemBlue
            } else {
                self.contentView.backgroundColor = UIColor.systemBackground
            }
        }
    }
}
