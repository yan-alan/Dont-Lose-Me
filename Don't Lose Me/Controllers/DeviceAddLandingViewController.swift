//
//  deviceAddLandingViewController.swift
//  Don't Lose Me
//
//  Created by Alan Yan on 2019-06-10.
//  Copyright © 2019 Alan Yan. All rights reserved.
//

import UIKit

class DeviceAddLandingViewController: UIViewController {
    @IBAction func nextPressed(_ sender: Any) {
        DispatchQueue.main.async(){
            self.performSegue(withIdentifier: "ToScan", sender: self)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //let destinationVC = segue.destination as! DeviceScanViewController
        
    }

}
