//
//  ViewController.swift
//  Don't Lose Me
//
//  Created by Alan Yan on 2019-05-24.
//  Copyright © 2019 Alan Yan. All rights reserved.
//

import UIKit
import CoreBluetooth

class DetailViewController: UIViewController {
    var selectedPeripheral: CBPeripheral?
    var centralManagerTwo: CBCentralManager!
    var width: CGFloat = 0
    var height: CGFloat = 0
    var perValue: CGFloat = 0
    var weightedHeightArray: [CGFloat] = []
    var count = 0
    var rssiSum = 0
    @IBOutlet weak var colorBack: UIView!
    @IBOutlet weak var RSSILabel: UILabel!
    @IBOutlet weak var heightCon: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        centralManagerTwo = CBCentralManager(delegate: self, queue: nil)
        findScale()
        if let selectedPeripheral = selectedPeripheral {
            if selectedPeripheral.name != nil {
                
                nameLabel.text = selectedPeripheral.name
            }
            else {
                nameLabel.text = "No Name"
            }
        }
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(goBack))
        
        view.addGestureRecognizer(rightSwipe)
    }
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
        
        dismiss(animated: true, completion: nil)
    }
    func findScale() {
        let bounds = UIScreen.main.bounds
        width = bounds.size.width
        height = bounds.size.height
        // - 20 = height
        // - 100 = 0
        
        perValue = height/65
        
    }
    //MARK: - VIEW WILL DISSAPEAR
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated);
        centralManagerTwo.stopScan()
    }
    //MARK: - ANIMATION METHODS
    func AnimateBackgroundHeight(rssi: NSNumber) {
        UIView.animate(withDuration: 1) {
        let weightedHeight = CGFloat(-35-Int(truncating: rssi))*self.perValue // heightCon is the IBOutlet to the constraint
        self.weightedHeightArray.append(weightedHeight)
            
        if self.weightedHeightArray.count == 3 {
            self.heightCon.constant = self.weightedHeightArray.reduce(0, +)/5
            self.weightedHeightArray = []
            switch self.heightCon.constant {
            case -4000...self.height/4:
                self.colorBack.backgroundColor = .green
            case self.height/4...self.height/2:
                self.colorBack.backgroundColor = .yellow
            case self.height/2...3*self.height/4:
                self.colorBack.backgroundColor = .red
            case 3*self.height/4...1000:
                self.colorBack.backgroundColor = .init(red: 130/255, green: 6/255, blue: 6/255, alpha: 1)
            default:
                print("wrong")
                print(self.height)
                print(self.heightCon.constant)
            }
        }
        self.view.layoutIfNeeded()
        }
    }
    
    
}

//MARK: - BLUETOOTH EXTENSION/METHODS
extension DetailViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
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
            centralManagerTwo.scanForPeripherals(withServices: nil)
        @unknown default:
            print("we screwed")
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if RSSILabel.text! == "" {
            RSSILabel.text = "Searching..."
        }
        if peripheral.identifier == selectedPeripheral!.identifier {
            //RSSILabel.text = "\(RSSI)"
            rssiSum += Int(truncating: RSSI)
            count += 1
            if count == 3 {
                rssiTextUpdate(rssi: NSNumber(value: rssiSum/3))
                count = 0
                rssiSum = 0
            }
            
            
            restartScan()
            AnimateBackgroundHeight(rssi: RSSI)
            
        }
    }
    func rssiTextUpdate(rssi: NSNumber) {
        switch Int(truncating: rssi) {
        case -100 ... -90:
            RSSILabel.text = "Very Far Away"
        case -90 ... -75:
            RSSILabel.text = "About Two Rooms Away"
        case -75 ... -65:
            RSSILabel.text = "About One Room Away"
        case -65 ...  -45:
            RSSILabel.text = "Should Be In The Room"
        case -45...50:
            RSSILabel.text = "Practically On Top"
            
        default:
            RSSILabel.text = "Searching"
        }
    }
    func restartScan() {
        centralManagerTwo.stopScan()
        centralManagerTwo.scanForPeripherals(withServices: nil)
    }
    func centralManager(central: CBCentralManager!, didConnectPeripheral
        peripheral: CBPeripheral!) {
    }
}
