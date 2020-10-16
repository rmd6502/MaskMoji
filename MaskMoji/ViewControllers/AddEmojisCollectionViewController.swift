//
//  AddEmojisCollectionViewController.swift
//  MaskMoji
//
//  Created by Robert on 10/10/20.
//  Copyright © 2020 Robert Diamond. All rights reserved.
//

import UIKit

protocol AddEmojisCollectionDelegate {
    func addEmoji(_ emoji : String)
    func removeEmoji(_ emoji : String)
}

private let reuseIdentifier = "AllEmojiCell"

class AddEmojisCollectionViewController: UICollectionViewController {
    let emojiDataSource = EmojiDataSource()
    let emojiSize = CGFloat(35)
    var delegate : AddEmojisCollectionDelegate?
    public var emojiList : [String]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.collectionView.allowsMultipleSelection = true
        
        self.title = NSLocalizedString("AllEmoji", tableName: nil, bundle: Bundle.main, value: "All Emojis", comment: "Title for All Emojis pane")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojiDataSource.emojiCount()
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        if let realCell = cell as? AllEmojisCollectionViewCell {
            let text = emojiDataSource.emojiForIndexPath(indexPath)
            realCell.emojiLabel.text = text
            realCell.emojiLabel.font = UIFont.systemFont(ofSize: emojiSize)
            realCell.layer.borderColor = UIColor.darkGray.cgColor
            realCell.layer.borderWidth = 1
            realCell.layer.cornerRadius = 4
            let selected = text != nil && self.emojiList?.contains(text!) ?? false
            if selected {
                realCell.isSelected = true
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected allmoji at ",indexPath)
        if let text = emojiDataSource.emojiForIndexPath(indexPath) {
            delegate?.addEmoji(text)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("deselected allmoji at ",indexPath)
        if let text = emojiDataSource.emojiForIndexPath(indexPath) {
            delegate?.removeEmoji(text)
        }
    }

}
