//
//  BTService.swift
//  Body Vibes Singleton - Import
//
//  Created by Alfred Ly on 1/9/17.
//  Copyright © 2017 Wagic. All rights reserved.
//

import UIKit
import Foundation
import CoreBluetooth
import UserNotifications
import os.log


var btDiscoverySharedInstance = BTDiscovery()

struct CollectPeripheral{
    var peripheral: CBPeripheral?
    var lastRSSI: NSNumber?
    var isConnectable: Bool?
}
var collectedPeripherals: [CollectPeripheral] = []

class BTDiscovery: NSObject, CBCentralManagerDelegate, UNUserNotificationCenterDelegate {
    
    fileprivate var centralManager: CBCentralManager?
    fileprivate var peripheralBLE: CBPeripheral?
    var devices = [PairedDevices]()

    
    override init() {
        super.init()
        
        let centralQueue = DispatchQueue(label: "com.raywenderlich", attributes: [])
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
    deinit{
        
    }
    
    func getPeripName() -> String {
        return peripheralBLE!.name!
    }
    
    //you can call this in BladeSelection instead of running a perpetual loop
    func perpetScanning(){
        collectedPeripherals = []
        DataContainerSingleton.custom.bleServiceUUID = "5730cd00-dc2a-11e3-aa37-0002a5d5c51b"
        var BLEServiceUUID = CBUUID(string: DataContainerSingleton.custom.bleServiceUUID!)
        self.centralManager?.scanForPeripherals(withServices: [BLEServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        let triggerTime = (Int64(NSEC_PER_SEC) * 10000)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
            if self.centralManager!.isScanning{
                self.centralManager?.stopScan()
            }
        })
    }
    
    //scans for new devices
    func startScanning() {
        collectedPeripherals = []
        var BLEServiceUUID = CBUUID(string: DataContainerSingleton.custom.bleServiceUUID!)
        
        repeat {
            self.centralManager?.scanForPeripherals(withServices: [BLEServiceUUID], options: nil)
        } while BLEServiceUUID.uuidString == "57000000-0000-0000-0000-0002a5d5c51b"
        
    }
 
    //mutable variable that holds BLE service
    var bleService: BTService? {
        didSet {
            if let service = self.bleService {
                service.startDiscoveringServices()
            }
        }
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let isConnectable = advertisementData["kCBAdvDataIsConnectable"] as! Bool
        let displayPeripheral = CollectPeripheral(peripheral: peripheral, lastRSSI: RSSI, isConnectable: isConnectable)
        collectedPeripherals.append(displayPeripheral)
        print("printing discovered peripherals: \(collectedPeripherals)")
        
    }
    
    func btlcConnect() {
        //look for any devices that have the BTLCname
        for i in collectedPeripherals.indices {
            print("made it in btlcConnect()")
            if collectedPeripherals[i].peripheral!.name! == "BTLC1000"{
                print("found names associated with BTLC1000")
                self.peripheralBLE = collectedPeripherals[i].peripheral!
                self.bleService = nil
                self.centralManager?.connect(collectedPeripherals[i].peripheral!, options: nil)
            }
        }
    }
    
    func connectSequence() {
        print("inside connectSequence")
        //First, check to see how many devices are on that list
        //If there is only one device, check to see if you've connected to it before.
        //If you have, then connect to it.
        //If you haven't, then do nothing.
        //If there is more than one device, check to see if lastConnected() is one of them
        //If it is, then connect to it.
        //If it isn't, then connect to the next available device that you've connected to before.
        //If none above is true, then do nothing.
        
        //special case for 'BTLC1000' names
        switch(collectedPeripherals.count) {
        case 0: print("case 0 reached")
        case 1: // only one device
            
            if(DataContainerSingleton.custom.firstTime!){
                if let savedDevices = loadDevices() {
                    devices += savedDevices
                }
                DataContainerSingleton.custom.firstTime = false
            }
            print("inside case 1 for real")
            //  var arrayBufferUUID = [UUID]()
            let uuidBUFFER = collectedPeripherals[0].peripheral?.identifier
            //make sure to clear array after search
            var arrayBufferUUID = [uuidBUFFER!]
            
            var searchPeripheralResults = centralManager?.retrievePeripherals(withIdentifiers: arrayBufferUUID)
            if(searchPeripheralResults!.count != 0) {
                //check to see if searchPeripheralResults is actually finding stuff.
                print("printing searchPeripheralResults: \(searchPeripheralResults)")
                //retain the peripheral before trying to connect
                self.peripheralBLE = collectedPeripherals[0].peripheral!
                self.bleService = nil
                self.centralManager?.connect(collectedPeripherals[0].peripheral!, options: nil)
                arrayBufferUUID.removeAll()
                break
            } else {
                return
            }
           
        default: //multiple devices
            print("got defaulted")
            //check to see if lastConnected()
            var arrayBufferUUID = [UUID]()
            var extendedArrayBufferUUID = [UUID]()
            if(DataContainerSingleton.custom.firstTime!){
                if let savedDevices = loadDevices() {
                    devices += savedDevices
                }
                DataContainerSingleton.custom.firstTime = false
            }

            for i in collectedPeripherals.indices {
                if (String(describing: collectedPeripherals[i].peripheral!.identifier) == DataContainerSingleton.custom.pickerUUID){
                    self.peripheralBLE = collectedPeripherals[i].peripheral!
                    self.bleService = nil
                    self.centralManager?.connect(collectedPeripherals[i].peripheral!, options: nil)
                }
            }
        }
    }
    
    
    //test connection status of the peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        // Create new service class
        if (peripheral == self.peripheralBLE) {
            self.bleService = BTService(initWithPeripheral: peripheral)
        }
        print("made it inside didConnect")
        // Stop scanning for new devices
        central.stopScan()
        DataContainerSingleton.custom.ranOnce = false
        DataContainerSingleton.custom.bleConnect = true
        switch(peripheral.state){
        case .disconnected:
            NSLog("disconnected")
            break
        case .connecting:
            NSLog("connecting")
            break
        case .connected:
            NSLog("connected")
            break
        case .disconnecting:
            NSLog("disconnecting")
            break
        }
        DataContainerSingleton.custom.peripheralName = peripheral.name
        print("connected to: \(peripheral.name)")
        print("with ID: \(peripheral.identifier)")
        //Set the content of the notification
        let content = UNMutableNotificationContent()
        content.title = "Connected to Blade"
        content.subtitle = ""
        content.body = "Re-Connection to Blade"
        
        //Set the trigger of the notification -- here a timer.
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false)
        
        //Set the request for the notification from the above
        let request = UNNotificationRequest(
            identifier: "10.second.message",
            content: content,
            trigger: trigger
        )
        //Add the notification to the currnet notification center
        UNUserNotificationCenter.current().add(
            request, withCompletionHandler: nil)
    }
    
    //test connection status of the peripheral
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Inside didDisconnectPeripiheral - line 245")
        // See if it was our peripheral that disconnected
        if (peripheral == self.peripheralBLE) {
            self.bleService = nil;
            self.peripheralBLE = nil;
            DataContainerSingleton.custom.bleConnect = false
            DataContainerSingleton.custom.ranOnce = false
        }
        
        // Start scanning for new devices
        self.startScanning()
        
        switch(peripheral.state){
        case .disconnected:
            NSLog("disconnected")
            break
        case .connecting:
            NSLog("connecting")
            break
        case .connected:
            NSLog("connected")
            break
        case .disconnecting:
            NSLog("disconnecting")
            break
        }
        
        //Set the content of the notification
        let content = UNMutableNotificationContent()
        content.title = "Disconnected from Blade"
        content.subtitle = ""
        content.body = "Lost Connection to Blade"
        
        //Set the trigger of the notification -- here a timer.
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false)
        
        //Set the request for the notification from the above
        let request = UNNotificationRequest(
            identifier: "10.second.message",
            content: content,
            trigger: trigger
        )
        //Add the notification to the currnet notification center
        UNUserNotificationCenter.current().add(
            request, withCompletionHandler: nil)
        
    }
    
    // MARK: - Private
    
    func clearDevices() {
        DataContainerSingleton.custom.bleConnect = false
        self.centralManager?.cancelPeripheralConnection(self.peripheralBLE!)
        self.bleService = nil
        self.peripheralBLE = nil
        print("clearing buffer")
        DataContainerSingleton.custom.bleServiceUUID = "57000000-0000-0000-0000-0002a5d5c51b"
    }
    
    //handler cases
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch (central.state) {
        case .poweredOff:
            NSLog("peripheral powered off")

        case .unauthorized:
            // Indicate to user that the iOS device does not support BLE.
            DataContainerSingleton.custom.bleTurnedOn = false
            NSLog("unauthorised connection")
            break

        case .unknown:
            // Wait for another event
            DataContainerSingleton.custom.bleTurnedOn = false
            NSLog("unknown error")
            break
    
        case .poweredOn:
            NSLog("device powering on")
            DataContainerSingleton.custom.bleTurnedOn = true
            self.startScanning()
            break
            
        case .resetting:
            NSLog("device resetting")
            DataContainerSingleton.custom.bleTurnedOn = false
            self.clearDevices()
            break
            
        case .unsupported:
            NSLog("device unsupported")
            DataContainerSingleton.custom.bleTurnedOn = false
            break
        }
    }
    
    private func loadDevices() -> [PairedDevices]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: PairedDevices.ArchiveURL.path) as? [PairedDevices]
    }
    private func savePairedDevices() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(devices, toFile: PairedDevices.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("device list successfully saved", log: OSLog.default, type: .debug)
        } else {
            os_log("failed to save device list", log: OSLog.default, type: .error)
        }
    }
    
}
