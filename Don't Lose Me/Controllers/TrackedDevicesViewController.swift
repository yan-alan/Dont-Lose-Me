//
//  TrackedDevicesViewController.swift
//  Don't Lose Me
//
//  Created by Alan Yan on 2019-06-10.
//  Copyright © 2019 Alan Yan. All rights reserved.
//

import UIKit

class TrackedDevicesViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BluetoothName", for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        tableView.deselectRow(at: indexPath, animated: true)
        DispatchQueue.main.async(){
            self.performSegue(withIdentifier: "ToAdd", sender: self)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //let destinationVC = segue.destination as! DeviceAddLandingViewController
        
    }
    
}
