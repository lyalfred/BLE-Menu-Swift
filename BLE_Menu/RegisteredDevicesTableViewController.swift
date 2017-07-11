//
//  RegisteredDevicesTableViewController.swift
//  Blade Runner
//
//  Created by Alfred Ly on 5/18/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit
import os.log


class RegisteredDevicesTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    var regDevices = [PairedDevices]()
    var expTimer = Timer()
    var bufferText: UITextField?
    @IBOutlet weak var regTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let savedDevices = loadDevices(){
            regDevices += savedDevices
            print("inside registeredDevicesTableViewController with count: \(regDevices.count)")
            print(regDevices)
        }
        expTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: "updateRegList", userInfo: nil, repeats: true)
        regTable.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        expTimer.invalidate()
        regDevices.removeAll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return regDevices.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "pairedListCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RegisteredDeviceTableViewCell else {
            fatalError("The dequeued cell is not an instance of RegisteredDeviceTableViewCell")
        }
    
        let pairedDeviceBuffer = regDevices[indexPath.row]
        
        cell.deviceName.text = pairedDeviceBuffer.userName
        var stringBufferID = String(describing: pairedDeviceBuffer.deviceUUID)
        let index = stringBufferID.index(stringBufferID.startIndex, offsetBy: 8)
        var concatStrBufferID = stringBufferID.substring(to: index)
        cell.deviceID.text = "ID: \(concatStrBufferID)"
        cell.editPressed.isHidden = false
        cell.editPressed.isEnabled = true
        

        // Configure the cell, setting custom cell frame.
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: cell.frame.size.height - width, width:  1000, height: cell.frame.size.height)
        
        //get screen heigh for border.frame if iPadPro
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        if(screenHeight > 736) {
            border.frame = CGRect(x: 0, y: cell.frame.size.height - width, width: 1250, height: cell.frame.size.height)
        }
        
        border.borderWidth = width
        cell.layer.addSublayer(border)
        cell.layer.masksToBounds = true
        return cell
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //Enables user to swipe right on a cell to delete.
        if editingStyle == .delete {
            // Delete the row from the data source
            regDevices.remove(at: indexPath.row)
            savePairedDevices()
            regTable.reloadData()
            //do some sort of deletion here as well.
        }
    }

    
    func updateRegList(){
        if(DataContainerSingleton.custom.updateRegList!){
            //Refresh the Registered Devices List since a change has been made in DeviceTableViewCell
            regDevices.removeAll()
            if let savedDevices = loadDevices(){
                regDevices += savedDevices
            }
            DataContainerSingleton.custom.updateRegList = false
            regTable.reloadData()
            print("made it in updateRegList")
        }
        
        //Fetches the appropriate pairedDevice for the data source layout.
        //Use for loop to iterate as done in PVC line 127
        
        for i in regDevices.indices {
            //NOTE: removeID is just the first 9 integers of UUID
            let stringBufferID = regDevices[i].deviceUUID
            let index = stringBufferID.index(stringBufferID.startIndex, offsetBy: 8)
            //add "ID: " to conform to removeID format. 
            //again, if confusion on why we're using removeID, refer to line 32 of RegDevTBCell
            var concatStrBufferID = "ID: " + stringBufferID.substring(to: index)
            
            if concatStrBufferID == DataContainerSingleton.custom.removeID! {
                
                if(DataContainerSingleton.custom.editPressed!){
                    //Bring up the prompt to edit blade name
                    let alert = UIAlertController(title: "Edit Mode", message: "Change the Blade Name", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        self.regDevices[i].userName = self.bufferText!.text!
                        self.savePairedDevices()
                        self.regTable.reloadData()
                    }))
                    
                    alert.addTextField(configurationHandler: {(textField: UITextField!) in
                        textField.placeholder = self.regDevices[i].userName
                        self.bufferText = textField
                    })
                    self.present(alert, animated: true, completion: nil)
                    DataContainerSingleton.custom.editPressed = false
                    break
                }
            }
        }
        
    }
    
    
    private func loadDevices() -> [PairedDevices]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: PairedDevices.ArchiveURL.path) as? [PairedDevices]
    }
    private func savePairedDevices() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(regDevices, toFile: PairedDevices.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("device list successfully saved", log: OSLog.default, type: .debug)
        } else {
            os_log("failed to save device list", log: OSLog.default, type: .error)
        }
    }

} // end class bracket

