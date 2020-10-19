//
//  ViewController.swift
//  MaskMoji
//
//  Created by Robert on 9/12/20.
//  Copyright © 2020 Robert Diamond. All rights reserved.
//

import Accelerate
import CoreBluetooth
import Foundation
import UIKit

class MaskMojiButtonCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, BluetoothVCDelegate, CBPeripheralDelegate, UICollectionViewDragDelegate, UICollectionViewDropDelegate, AddEmojisCollectionDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var peripheral : CBPeripheral? = nil
    var subtitleLabel : UILabel? = nil
    let emojiSize = CGFloat(65)
    let kLastConnectedDeviceNameKey = "kLastConnectedDeviceName"
    let kEmojiCollectionKey = "kEmojiCollectionKey"
    var bluetoothDataSource : BluetoothDataSource? = nil
    lazy var resizeFilter = CIFilter(name: "CILanczosScaleTransform")
    var jpegDataToSend : Data?
    
    // Initial set of emojis. Can be overridden by kEmojiCollectionKey in UserDefaults.standard.
    static var emojis : [String] = ["➕","😀", "🤣","😍","😎","😏","😞","😟","😕","💩","🤮","😡","😱", "😂","🤣","🙃","🥰","😘","😛","😜","🤪","🤓","😎","🥳","😒","🙁","😢","😭","😤","🤯","😴","🧐","😳","😬","🙄","🤫","maskmoji","byedon"];

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let defaults = UserDefaults.standard
        if let savedEmojis = defaults.array(forKey: kEmojiCollectionKey) as? [String] {
            MaskMojiButtonCollectionViewController.emojis = savedEmojis
        }
        bluetoothDataSource = BluetoothDataSource()
        if let lastConnected = defaults.string(forKey: kLastConnectedDeviceNameKey) {
            bluetoothDataSource?.reconnectPeripheral(lastConnected, resultBlock: { [self] (success: Bool, peripheral: CBPeripheral) in
                if success {
                    peripheralChosen(peripheral)
                }
            })
        }
        self.view.backgroundColor = UIColor.blue;
        self.title = NSLocalizedString("MaskMojis", tableName: "Standard", bundle: Bundle.main, value: "MaskMoji", comment: "Maskmoji title")
        
        let title = self.title
        let subtitle = NSLocalizedString("Not Connected", tableName: "Standard", bundle: Bundle.main, value: "Not Connected", comment: "Connection status")
        self.navigationItem.titleView = setTitle(title: title!, subtitle: subtitle)
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
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
        if indexPath.item == 0 {
            handleAddEmoji()
            return
        }
        guard let peripheral = self.peripheral else {
            subtitleLabel?.text = NSLocalizedString("Not Connected", tableName: "Standard", bundle: Bundle.main, value: "Not Connected", comment: "Connection status")
            return
        }
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
    
    func handleAddEmoji() {
        performSegue(withIdentifier: "AddEmojis", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? BluetoothTableViewController {
            dest.delegate = self
            dest.bluetoothDataSource = bluetoothDataSource
        } else if let dest = segue.destination as? AddEmojisCollectionViewController {
            dest.delegate = self
            dest.emojiList = MaskMojiButtonCollectionViewController.emojis
        }
    }
    
    func peripheralChosen(_ peripheral: CBPeripheral?) {
        self.peripheral = peripheral
        guard let peripheral = peripheral else {return}
        peripheral.delegate = self
        subtitleLabel?.text = peripheral.name ?? peripheral.identifier.uuidString
        UserDefaults.standard.set(peripheral.identifier.uuidString, forKey: kLastConnectedDeviceNameKey)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Failed to write to characteristic: ", error.localizedDescription)
            return
        }
    }

    func setTitle(title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))

        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textAlignment = .center
        titleLabel.text = title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.sizeToFit()

        subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel?.backgroundColor = UIColor.clear
        subtitleLabel?.textColor = UIColor.secondaryLabel
        subtitleLabel?.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel?.textAlignment = .center
        subtitleLabel?.text = subtitle
        subtitleLabel?.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel?.sizeToFit()

        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel!.frame.size.width), height: 30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel!)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel!.topAnchor),
            subtitleLabel!.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            subtitleLabel!.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            subtitleLabel!.bottomAnchor.constraint(equalTo: titleView.bottomAnchor)
        ])

        return titleView
    }
    
    // MARK: - UICollectionViewDragDelegate
    // TODO: We need to make it obvious you can drag the emojis around.
    
    func collectionView(_ collectionView: UICollectionView,
      itemsForBeginning session: UIDragSession,
      at indexPath: IndexPath) -> [UIDragItem] {
        if indexPath.item == 0 { return [] }
        let emoji = MaskMojiButtonCollectionViewController.emojis[indexPath.item]
        let provider = NSItemProvider(object: emoji as NSItemProviderWriting)
        let dragItem = UIDragItem(itemProvider: provider)
        return [ dragItem ]
    }
    
    // MARK: - UICollectionViewDropDelegate
    
    func collectionView(_ collectionView: UICollectionView,
                        performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else {
            return
        }
        if destinationIndexPath.item == 0 { return }
        coordinator.items.forEach { (dropItem) in
            guard let dropIndexPath = dropItem.sourceIndexPath else { return }
            let emoji = MaskMojiButtonCollectionViewController.emojis[dropIndexPath.item]
            collectionView.performBatchUpdates {
                MaskMojiButtonCollectionViewController.emojis.remove(at: dropIndexPath.item)
                MaskMojiButtonCollectionViewController.emojis.insert(emoji, at: destinationIndexPath.item)
                collectionView.deleteItems(at: [dropIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            } completion: { (_) in
                coordinator.drop(dropItem.dragItem, toItemAt: destinationIndexPath)
            }
        }
        UserDefaults.standard.set(MaskMojiButtonCollectionViewController.emojis, forKey: kEmojiCollectionKey)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        canHandle session: UIDropSession) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move)
    }
    
    // MARK: - AddEmojisCollectionDelegate
    
    func addEmoji(_ emoji: String) {
        MaskMojiButtonCollectionViewController.emojis.insert(emoji, at: 1)
        UserDefaults.standard.set(MaskMojiButtonCollectionViewController.emojis, forKey: kEmojiCollectionKey)
        self.collectionView.reloadData()
    }
    
    func removeEmoji(_ emoji: String) {
        if let index = MaskMojiButtonCollectionViewController.emojis.firstIndex(of: emoji) {
            MaskMojiButtonCollectionViewController.emojis.remove(at: index)
            UserDefaults.standard.set(MaskMojiButtonCollectionViewController.emojis, forKey: kEmojiCollectionKey)
            self.collectionView.reloadData()
        }
    }
    @IBAction func selectImage(_ sender: Any) {
        print("select images...")
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) { return }
        let imagePicker = UIImagePickerController()
        guard let mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) else { return }
        imagePicker.mediaTypes = mediaTypes
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("info ",info)
        guard var image = info[.originalImage] as? UIImage else { return }
        if image.size.width > image.size.height {
            image = UIImage(cgImage: image.cgImage!, scale: 1, orientation: .right)
        }
        guard let cg = image.cgImage else { return }
        let ci = CIImage(cgImage: cg)
        resizeFilter?.setValue(ci, forKey: kCIInputImageKey)
        resizeFilter?.setValue(min(CGFloat(240)/image.size.height, CGFloat(135)/image.size.width), forKey: kCIInputScaleKey)
        resizeFilter?.setValue(CGFloat(1), forKey: kCIInputAspectRatioKey)
        guard let result = resizeFilter?.value(forKey: kCIOutputImageKey) as? CIImage else { return }
        let outputImage = UIImage(ciImage: result)
        jpegDataToSend = outputImage.jpegData(compressionQuality: 75)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("changed my mind about choosing a picture")
    }
}

