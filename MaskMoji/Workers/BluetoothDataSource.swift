//
//  BluetoothDataSource.swift
//  MaskMoji
//
//  Created by Robert on 9/13/20.
//  Copyright © 2020 Robert Diamond. All rights reserved.
//

import UIKit
import Dispatch
import CoreBluetooth

protocol BluetoothDataSourceDelegate {
    /// delegates must be prepared for this to be empty!
    func devicesFound(_ devices : [CBPeripheral])
}

class BluetoothDataSource: NSObject {
    var q : DispatchQueue
    public var delegate : BluetoothDataSourceDelegate? = nil
    
    override init() {
        q = DispatchQueue(label: "Bluetooth")
        super.init()
        q.async {
            self.startScan()
        }
    }
    
    func startScan() {
        
    }
}
