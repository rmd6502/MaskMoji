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

class BluetoothDataSource: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static var serviceId = "BC0DAFB6-3EE7-4D77-9012-FAC1DA5ADE15"
    static var characteristicId = "BC0DAFB6-3EE7-4D77-9012-FAC1DA5A0001"
    var q : DispatchQueue
    public var delegate : BluetoothDataSourceDelegate? = nil
    var centralManager : CBCentralManager!
    var isPoweredOn = false
    var peripherals = [CBPeripheral]()
    var closures = [UUID : (Bool) -> Void]()
    
    override init() {
        q = DispatchQueue(label: "Bluetooth")
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: q)
    }
    
    func startScan() {
        centralManager.scanForPeripherals(withServices: [CBUUID(string: BluetoothDataSource.serviceId)], options: .none)
        //centralManager.scanForPeripherals(withServices: [CBUUID(string: BluetoothDataSource.serviceId)], options: .none)
    }
    
    func stopScan() {
        centralManager.stopScan()
    }
    
    func connectToPeripheral(_ peripheral: CBPeripheral, resultBlock: @escaping (_ success: Bool) -> Void) {
        closures[peripheral.identifier] = resultBlock
        centralManager.connect(peripheral, options: .none)
    }
    
    // MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            isPoweredOn = true
            startScan()
        case .poweredOff:
            isPoweredOn = false
            stopScan()
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripherals.append(peripheral)
        DispatchQueue.main.async {
            self.delegate?.devicesFound(self.peripherals)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: BluetoothDataSource.serviceId)])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        peripheral.discoverCharacteristics([CBUUID(string: BluetoothDataSource.characteristicId)], for: (services.first(where: { (service : CBService) -> Bool in
            service.uuid.uuidString == BluetoothDataSource.serviceId
        }))!)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let closure = closures[peripheral.identifier] else {
            return
        }
        closures[peripheral.identifier] = nil
        DispatchQueue.main.async {
            closure(error == nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        guard let closure = closures[peripheral.identifier] else {
            return
        }
        closures[peripheral.identifier] = nil
        closure(false)
    }
}
