//
//  ViewController.swift
//  MaskMoji
//
//  Created by Robert on 9/12/20.
//  Copyright © 2020 Robert Diamond. All rights reserved.
//

import UIKit
import CoreBluetooth

class MaskMojiButtonCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, BluetoothVCDelegate, CBPeripheralDelegate {
    var peripheral : CBPeripheral? = nil
    var subtitleLabel : UILabel? = nil
    let emojiSize = CGFloat(65)
    
    static let emojis : [String] = ["😀", "🤣","😍","😎","😏","😞","😟","😕","💩","😡","😱", "😂","🤣","🙃","🥰","😘","😛","😜","🤪","🤓","😎","🥳","😒","🙁","😢","😭","😤","🤯","maskmoji"];

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.blue;
        self.title = NSLocalizedString("MaskMojis", tableName: "Standard", bundle: Bundle.main, value: "MaskMoji", comment: "Maskmoji title")
        
        let title = self.title
        let subtitle = NSLocalizedString("Not Connected", tableName: "Standard", bundle: Bundle.main, value: "Not Connected", comment: "Connection status")
        self.navigationItem.titleView = setTitle(title: title!, subtitle: subtitle)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MaskMojiButtonCollectionViewController.emojis.count;
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MaskMojiCell", for: indexPath) as? MaskMojiCellCollectionViewCell {
            cell.maskMojiLabel.text = MaskMojiButtonCollectionViewController.emojis[indexPath.row];
            if cell.maskMojiLabel.text?.count == 1 {
                cell.maskMojiLabel.font = UIFont.systemFont(ofSize: emojiSize)
            } else {
                cell.maskMojiLabel.font = UIFont.systemFont(ofSize: UIFont.buttonFontSize)
            }
            cell.layer.borderColor = UIColor.darkGray.cgColor
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 4
            
            return cell;
        }
        return UICollectionViewCell();
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 160);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected item at \(indexPath)");
        guard let peripheral = self.peripheral else { return }
        if (peripheral.state != .connected) {
            if (peripheral.state != .connecting) {
                self.peripheral = nil;
                subtitleLabel?.text = NSLocalizedString("Not Connected", tableName: "Standard", bundle: Bundle.main, value: "Not Connected", comment: "Connection status")
            }
            return
        }
        if MaskMojiButtonCollectionViewController.emojis.count <= indexPath.item { return }
        let emoji = MaskMojiButtonCollectionViewController.emojis[indexPath.item]
        var fn : String
        if emoji.count == 1 {
            let s = MaskMojiButtonCollectionViewController.emojis[indexPath.item].unicodeScalars.first
            fn = String(format: "%lx", s!.value)
        } else {
            fn = emoji
        }
        peripheral.writeValue(fn.data(using: .utf8)!, for: (peripheral.services?.first?.characteristics?.first)!, type: .withResponse)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? BluetoothTableViewController {
            dest.delegate = self
        }
    }
    
    func peripheralChosen(_ peripheral: CBPeripheral?) {
        self.peripheral = peripheral
        peripheral?.delegate = self
        subtitleLabel?.text = peripheral?.name ?? peripheral?.identifier.uuidString ?? NSLocalizedString("Not Connected", tableName: "Standard", bundle: Bundle.main, value: "Not Connected", comment: "Connection status")
    }
    
    func setTitle(title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))

        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.gray
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.text = title
        titleLabel.sizeToFit()

        subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel?.backgroundColor = UIColor.clear
        subtitleLabel?.textColor = UIColor.lightText
        subtitleLabel?.font = UIFont.systemFont(ofSize: 10)
        subtitleLabel?.text = subtitle
        subtitleLabel?.sizeToFit()

        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, (subtitleLabel?.frame.size.width)!), height: 30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel!)

        let widthDiff = subtitleLabel!.frame.size.width - titleLabel.frame.size.width

        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel!.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }

        return titleView
    }
}

