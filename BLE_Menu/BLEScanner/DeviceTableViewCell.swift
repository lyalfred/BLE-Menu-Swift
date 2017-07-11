//
//  DeviceTableViewCell.swift
//  Blade Runner
//
//  Created by Alfred Ly on 5/18/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit
import CoreBluetooth
import os.log

protocol DeviceCellDelegate: class {
    func connectPressed(_ peripheral: CBPeripheral)
}

class DeviceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceRssiLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var deviceIDText: UILabel!
    
    var delegate: DeviceCellDelegate?
    var pairedPeripherals: [PairedDevices] = []
    
    var timer = Timer()
    
    //reference DataContainerSingleton.custom.peripheralName here & pull from tableSelection method
    
    var displayPeripheral: DisplayPeripheral? {
        didSet {
            if let deviceName = displayPeripheral!.peripheral?.name{
                deviceNameLabel.text = deviceName.isEmpty ? "No Device Name" : deviceName
            }else{
                deviceNameLabel.text = "No Device Name"
            }
            
            if let rssi = displayPeripheral!.lastRSSI {
                deviceRssiLabel.text = "\(rssi)dB"
            }
            
            if let deviceID = displayPeripheral!.peripheral?.identifier {
                var stringBufferID = String(describing: deviceID)
                let index = stringBufferID.index(stringBufferID.startIndex, offsetBy: 8)
                var concatStrBufferID = stringBufferID.substring(to: index)
                deviceIDText.text = "ID: \(concatStrBufferID)"
            }
            
            connectButton.isHidden = !(displayPeripheral?.isConnectable!)!
        }
    }
    
    @IBAction func connectButtonPressed(_ sender: AnyObject) {
        
        delegate?.connectPressed((displayPeripheral?.peripheral)!)
        if let savedDevices = loadDevices(){
            pairedPeripherals += savedDevices
        }
        //Instead, now you're going to save device info in a DCS and pass to RegisteredDevicesTableVC
        DataContainerSingleton.custom.peripheralName = deviceNameLabel.text
        DataContainerSingleton.custom.peripheralUUID = String(describing: displayPeripheral!.peripheral!.identifier)
        DataContainerSingleton.custom.bleServiceUUID = "5730cd00-dc2a-11e3-aa37-0002a5d5c51b"
        DataContainerSingleton.custom.updateRegList = true
        DataContainerSingleton.custom.removeIDBool = true
        let bufferPeripheral = PairedDevices(name: DataContainerSingleton.custom.peripheralName!, deviceUUID: DataContainerSingleton.custom.peripheralUUID!, userName: DataContainerSingleton.custom.peripheralName!)

        pairedPeripherals.append(bufferPeripheral!)
        savePairedDevices()
        pairedPeripherals.removeAll()
    }
    

    private func loadDevices() -> [PairedDevices]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: PairedDevices.ArchiveURL.path) as? [PairedDevices]
    }
    private func savePairedDevices() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(pairedPeripherals, toFile: PairedDevices.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("device list successfully saved", log: OSLog.default, type: .debug)
        } else {
            os_log("failed to save device list", log: OSLog.default, type: .error)
        }
    }
    
}
