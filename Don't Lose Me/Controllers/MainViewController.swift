//
//  File.swift
//  Don't Lose Me
//
//  Created by Alan Yan on 2019-05-24.
//  Copyright © 2019 Alan Yan. All rights reserved.
//

import UIKit
import CoreBluetooth


class BluetoothConnectingCustomCell: UITableViewCell {
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var shadowImage: UIImageView!
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shadowImage?.layer.masksToBounds = false
        shadowImage?.layer.shadowColor = UIColor.black.cgColor
        shadowImage?.layer.shadowRadius = 6
        
        shadowImage?.layer.shadowPath = UIBezierPath(roundedRect: backImage!.bounds, cornerRadius: 20.0).cgPath
        shadowImage?.layer.shadowOpacity = 0.5
        shadowImage?.layer.shadowOffset = .zero
        
        backImage?.layer.cornerRadius = 20.0
        backImage?.layer.masksToBounds = true
    }
    
    
    
}


class MainViewController: UITableViewController {
    
    
    var centralManager: CBCentralManager!
    var bluetoothArray: [CBPeripheral] = []
    var bluetoothIdentifiers: [UUID] = []
    var bluetoothBackgrounds: [UIImage] = []
    var imageArray = [ "Back-1","Back-2", "Back-3", "Back-4", "Back-5"]
    let generator = UINotificationFeedbackGenerator()
    var counter = 0
    @IBAction func privacy(_ sender: Any) {
        if let url = NSURL(string: "http://yan-alan.github.io/apps/Dont%20Lose%20Me/privacy.html"){
            UIApplication.shared.openURL(url as URL)
        }
    }
    @IBAction func refreshButton(_ sender: UIBarButtonItem) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        scanForDevices()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        centralManager = CBCentralManager(delegate: self, queue: nil)
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
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
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! DetailViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedPeripheral = bluetoothArray[indexPath.row]
        }
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
extension MainViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
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
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral
        peripheral: CBPeripheral!) {
        print("we did it! Connected to: \(String(describing: peripheral))")
    }

}

