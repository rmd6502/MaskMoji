//
//  BluetoothTableViewController.swift
//  MaskMoji
//
//  Created by Robert on 9/13/20.
//  Copyright © 2020 Robert Diamond. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol BluetoothVCDelegate {
    func peripheralChosen(_ peripheral: CBPeripheral?)
}
class BluetoothTableViewController: UITableViewController, BluetoothDataSourceDelegate {
    func devicesFound(_ devices: [CBPeripheral]) {
        tableView.reloadData()
    }
    

    var bluetoothDataSource : BluetoothDataSource? = nil
    var delegate : BluetoothVCDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bluetoothDataSource = BluetoothDataSource()
        bluetoothDataSource?.delegate = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bluetoothDataSource?.peripherals.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BluetoothPeripheral", for: indexPath)
        cell.textLabel?.text = bluetoothDataSource?.peripherals[indexPath.row].identifier.uuidString

        return cell
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = bluetoothDataSource?.peripherals[indexPath.row]
        bluetoothDataSource?.connectToPeripheral(peripheral!, resultBlock: { (success : Bool) in
            self.delegate?.peripheralChosen(peripheral)
            self.dismiss(animated: true, completion: nil)
        })
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    //}

}
