//
//  PeripheralTableViewController.swift
//  Blade Runner
//
//  Created by Alfred Ly on 5/18/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import CoreBluetooth
import UIKit
import os.log

struct DisplayPeripheral{
    var peripheral: CBPeripheral?
    var lastRSSI: NSNumber?
    var isConnectable: Bool?
}

class PeripheralViewController: UIViewController,UITableViewDataSource {
    
    /* Services & Characteristics UUIDs */
    let BLEServiceUUID = CBUUID(string: "5730cd00-dc2a-11e3-aa37-0002a5d5c51b")
    //5730cd00-dc2a-11e3-aa37-0002a5d5c51b
    let PositionCharUUID = CBUUID(string: "98d240e0-dc2a-11e3-bbff-0002a5d5c51b")
    //writechar: 98d240e0-dc2a-11e3-bbff-0002a5d5c51b
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var bluetoothIcon: UIImageView!
    
    var centralManager: CBCentralManager?
    var peripherals: [DisplayPeripheral] = []
    var pairedPeripherals: [PairedDevices] = []
    var viewReloadTimer = Timer()
    var expTimer = Timer()
    var scanTimer = Timer()
    var selectedPeripheral: CBPeripheral?
    @IBOutlet weak var tableView: UITableView!
    
    //need to have some implementation for registered list.
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //Initialise CoreBluetooth Central Manager
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        viewReloadTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PeripheralViewController.refreshScanView), userInfo: nil, repeats: true)
        if let savedDevices = loadDevices() {
            pairedPeripherals = savedDevices
        }
        
        expTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: "updateTable", userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        expTimer.invalidate()
        viewReloadTimer.invalidate()
        scanTimer.invalidate()
        pairedPeripherals.removeAll()
        peripherals.removeAll()
    }
    
    func updateViewForScanning(){
        statusLabel.text = "Scanning BLE Devices..."
        bluetoothIcon.pulseAnimation()
        bluetoothIcon.isHidden = false
   //     scanningButton.buttonColorScheme(true)
    }
    
    func updateViewForStopScanning(){
        let plural = peripherals.count == 1 ? "" : "s"
        statusLabel.text = "\(peripherals.count) Device\(plural) Found"
        bluetoothIcon.layer.removeAllAnimations()
        bluetoothIcon.isHidden = true
     //   scanningButton.buttonColorScheme(false)
    }
    
    @IBAction func scanningButtonPressed(_ sender: AnyObject){
        if centralManager!.isScanning{
            centralManager?.stopScan()
            updateViewForStopScanning()
            scanTimer.invalidate()
        }else{
            startScanning()
            tableView.reloadData()
        }
    }
    
    func startScanning(){
        peripherals = []
        self.centralManager?.scanForPeripherals(withServices: [BLEServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        updateViewForScanning()
        let triggerTime = (Int64(NSEC_PER_SEC) * 1000)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
            if self.centralManager!.isScanning{
                self.centralManager?.stopScan()
                self.updateViewForStopScanning()
            }
        })
    }
 
    func refreshScanView()
    {
        if peripherals.count > 1 && centralManager!.isScanning{
            tableView.reloadData()
        }
    }
    
    func updateTable() {
        //to constantly refresh paired Instruments list
        if let savedDevices = loadDevices() {
            pairedPeripherals = savedDevices
        }
        tableView.reloadData()
        
        if(DataContainerSingleton.custom.removeIDBool!){
            print("made it inside 126")
            for i in peripherals.indices {
                print(peripherals.count)
                print(DataContainerSingleton.custom.peripheralUUID!)
                print(String(describing: peripherals[i].peripheral!.identifier))
                
                if DataContainerSingleton.custom.peripheralUUID == String(describing: peripherals[i].peripheral!.identifier) {
                    print("removing a peripheral at PVC line 128")
                    print("printing index: \(i)")
                    peripherals.remove(at: i)
                    DataContainerSingleton.custom.removeIDBool = false
                    tableView.reloadData()
                    break
                }
            }
        }
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as! DeviceTableViewCell
        //do one last check to make sure it's not also in pairedPeripherals list
        //iterate through list of paired peripherals
        var buffer = 0
        for i in pairedPeripherals.indices {
            if(String(describing: peripherals[indexPath.row].peripheral!.identifier) == pairedPeripherals[i].deviceUUID) {
                buffer += 1
            }
        }
        //if there are no collisions, then you're fine.
        if buffer == 0 {
            cell.displayPeripheral = peripherals[indexPath.row]
        }
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: cell.frame.size.height - width, width:  500, height: cell.frame.size.height)
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return peripherals.count
    }
    
    
    
}

extension PeripheralViewController: CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        if (central.state == .poweredOn){
            startScanning()
        }else{
            // do something like alert the user that ble is not on
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
      //  peripherals = []
        
        
        for (index, foundPeripheral) in peripherals.enumerated(){
            if foundPeripheral.peripheral?.identifier == peripheral.identifier{
                peripherals[index].lastRSSI = RSSI
                return
            }
        }
        
        
        let isConnectable = advertisementData["kCBAdvDataIsConnectable"] as! Bool
        let displayPeripheral = DisplayPeripheral(peripheral: peripheral, lastRSSI: RSSI, isConnectable: isConnectable)
        
        if displayPeripheral.peripheral!.name == "BTLC1000" {
            //initiate connection & disconnect to clear BTLC name
            btDiscoverySharedInstance.btlcConnect()
            if DataContainerSingleton.custom.bleConnect!{
                btDiscoverySharedInstance.clearDevices()
            }
            tableView.reloadData()
        }
        
        //iterate through list of paired peripherals
        var buffer = 0
        for i in pairedPeripherals.indices {
            if(String(describing: displayPeripheral.peripheral!.identifier) == pairedPeripherals[i].deviceUUID) {
                buffer += 1
            }
        }
        //if there are no collisions, then you're fine.
        if buffer == 0 {
            peripherals.append(displayPeripheral)
            tableView.reloadData()
            
        }
    }
    
    
}
