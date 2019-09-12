//
//  DeviceScanViewController.swift
//  Don't Lose Me
//
//  Created by Alan Yan on 2019-06-10.
//  Copyright © 2019 Alan Yan. All rights reserved.
//

import UIKit
import CoreBluetooth
import UserNotifications

class DeviceScanViewController: UITableViewController {
    
    
    var centralManager: CBCentralManager!
    var bluetoothArray: [CBPeripheral] = []
    var bluetoothIdentifiers: [UUID] = []
    var bluetoothBackgrounds: [UIImage] = []
    var imageArray = [ "Back-1","Back-2", "Back-3", "Back-4", "Back-5"]
    let generator = UINotificationFeedbackGenerator()
    var counter = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey:
            "myCentralManagerIdentifier"])
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        self.performSegue(withIdentifier: "ToAssist", sender: self)

    }
    
    //MARK: - TABLEVIEW SETUP
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bluetoothArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BluetoothName", for: indexPath) as! BluetoothConnectingCustomCell
        
        let device = bluetoothArray[indexPath.row]
        cell.backImage?.image = bluetoothBackgrounds[0]
        if device.name != nil {
            cell.nameLabel?.text = device.name
        }
        else{
            cell.nameLabel?.text = "No Name"
        }
        cell.secondaryLabel?.text = "UUID: \(device.identifier.uuidString)"
        
        return cell
    }
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Make the first row larger to accommodate a custom cell.
        
        
        // Use the default size for all other rows.
        return 100
    }
    //MARK: -TABLEVIEW ANIMATION
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Add animations here
        cell.alpha = 0
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.02 * Double(indexPath.row),
            animations: {
                cell.alpha = 1
        })
    }
    
    //MARK: - TABLEVIEW INTERACTION
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        tableView.deselectRow(at: indexPath, animated: true)
        //performSegue(withIdentifier: "ToConnecting", sender: self)
        print("Connecting")
        centralManager.stopScan()
        centralManager.connect(bluetoothArray[indexPath.row], options: nil)
    }
    func restartScan() {
        centralManager.stopScan()
        centralManager.scanForPeripherals(withServices: nil)
    }
    func scanForDevices() {
        counter = 0
        bluetoothArray = []
        bluetoothIdentifiers = []
        tableView.reloadData()
        centralManager.scanForPeripherals(withServices: nil)
        self.navigationItem.title = "Searching..."
        //self.title = "Searching..."
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.centralManager.stopScan()
            if self.bluetoothArray.count > 0 {
                self.generator.notificationOccurred(.success)
                self.tableView.reloadData()
                self.navigationItem.title = "Devices Found"
            }
            else {
                self.generator.notificationOccurred(.error)
                self.tableView.reloadData()
                self.navigationItem.title = "No Devices Found"
            }
            
        }
    }
}



//MARK: - BLUETOOTH EXTENSION/METHODS
extension DeviceScanViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            scanForDevices()
        @unknown default:
            print("we screwed")
            
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
        if !bluetoothIdentifiers.contains(peripheral.identifier) {
            bluetoothArray.append(peripheral)
            bluetoothBackgrounds.append(UIImage(named: imageArray[counter])!)
            counter += 1
            if counter == 5{
                counter = 0
            }
            bluetoothIdentifiers.append(peripheral.identifier)
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("we did it! Connected to: \(String(describing: peripheral))")
    
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected \(String(describing: peripheral.name))")
        scheduleNotification(peripheral: peripheral)
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("failed")
    }
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("Yo")
        let center = UNUserNotificationCenter.current()
        var newName: String = "No Name"
        let content = UNMutableNotificationContent()
        content.title = "STOP!"
        content.body = "state restored!!!"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func scheduleNotification(peripheral: CBPeripheral) {
        let center = UNUserNotificationCenter.current()
        var newName: String = "No Name"
        if peripheral.name != nil {
            newName = peripheral.name!
        }
        let content = UNMutableNotificationContent()
        content.title = "STOP!"
            content.body = "Don't leave \(newName) behind!!!"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
}




