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
    static var emojiCharacteristicId = "BC0DAFB6-3EE7-4D77-9012-FAC1DA5A0001"
    static var imageCharacteristicId = "BC0DAFB6-3EE7-4D77-9012-FAC1DA5A0002"
    static var durationCharacteristicId = "BC0DAFB6-3EE7-4D77-9012-FAC1DA5A0003"
    var q : DispatchQueue
    public var delegate : BluetoothDataSourceDelegate? = nil
    var centralManager : CBCentralManager!
    var isPoweredOn = false
    var peripherals = [CBPeripheral]()
    var closures = [UUID : (Bool, CBPeripheral) -> Void]()
    
    override init() {
        q = DispatchQueue(label: "Bluetooth")
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: q)
    }
    
    func startScan() {
        centralManager.scanForPeripherals(withServices: [CBUUID(string: BluetoothDataSource.serviceId)], options: .none)
    }
    
    func stopScan() {
        centralManager.stopScan()
    }
    
    func reconnectPeripheral(_ byUUID: String, resultBlock: @escaping (_ success: Bool, _ peripheral: CBPeripheral) -> Void) {
        guard let uuid = UUID(uuidString: byUUID) else {return}
        let known = centralManager.retrievePeripherals(withIdentifiers: [uuid])
        if known.count > 0 {
            connectToPeripheral(known.first!, resultBlock: resultBlock)
        } else {
            closures[uuid] = resultBlock
        }
    }
    
    func connectToPeripheral(_ peripheral: CBPeripheral, resultBlock: @escaping (_ success: Bool, _ peripheral: CBPeripheral) -> Void) {
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
        if !peripherals.contains(where: { (periph) -> Bool in
            return periph.name == peripheral.name
        }) {
            peripherals.append(peripheral)
            DispatchQueue.main.async {
                self.delegate?.devicesFound(self.peripherals)
            }
            if closures[peripheral.identifier] != nil {
                centralManager.connect(peripheral, options: .none)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: BluetoothDataSource.serviceId)])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        peripheral.discoverCharacteristics([], for: (services.first(where: { (service : CBService) -> Bool in
            service.uuid.uuidString == BluetoothDataSource.serviceId
        }))!)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let closure = closures[peripheral.identifier] else {
            return
        }
        closures[peripheral.identifier] = nil
        DispatchQueue.main.async {
            closure(error == nil, peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to ",peripheral.name ?? "unknown"," with error ", error?.localizedDescription ?? "unknown error")
        guard let closure = closures[peripheral.identifier] else {
            return
        }
        closures[peripheral.identifier] = nil
        closure(false, peripheral)
    }
}
