//
//  ViewController.swift
//  MaskMoji
//
//  Created by Robert on 9/12/20.
//  Copyright © 2020 Robert Diamond. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, BluetoothVCDelegate {
    var peripheral : CBPeripheral? = nil
    
    static let emojis : [String] = ["😀", "🤣","😍","😎","😏","😞","😟","😕","😡","😱"];

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.blue;
        self.title = NSLocalizedString("MaskMojis", tableName: "Standard", bundle: Bundle.main, value: "MaskMoji", comment: "Maskmoji title")
        
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ViewController.emojis.count;
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MaskMojiCell", for: indexPath) as? MaskMojiCellCollectionViewCell {
            cell.maskMojiLabel.text = ViewController.emojis[indexPath.row];
            cell.maskMojiLabel.font = UIFont.systemFont(ofSize: cell.bounds.height/2)
            cell.contentView.backgroundColor = UIColor.red;
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? BluetoothTableViewController {
            dest.delegate = self
        }
    }
    
    func peripheralChosen(_ peripheral: CBPeripheral?) {
        self.peripheral = peripheral
    }
}

