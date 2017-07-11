//
//  BTService.swift
//  Body Vibes Singleton - Import
//
//  Created by Alfred Ly on 1/9/17.
//  Copyright © 2017 Wagic. All rights reserved.
//

import Foundation
import CoreBluetooth
import UserNotifications

/* Services & Characteristics UUIDs */
//let BLEServiceUUID = CBUUID(string: "5730cd00-dc2a-11e3-aa37-0002a5d5c51b")

//5730cd00-dc2a-11e3-aa37-0002a5d5c51b
let PositionCharUUID = CBUUID(string: "98d240e0-dc2a-11e3-bbff-0002a5d5c51b")
//writechar: 98d240e0-dc2a-11e3-bbff-0002a5d5c51b
let ReadCharUUID = CBUUID(string: "8e20d3a0-dc2a-11e3-8e3b-0002a5d5c51b")
//read-notify: 8e20d3a0-dc2a-11e3-8e3b-0002a5d5c51b
let BLEServiceChangedStatusNotification = "kBLEServiceChangedStatusNotification"

class BTService: NSObject, CBPeripheralDelegate, UNUserNotificationCenterDelegate {
    var peripheral: CBPeripheral?
    var positionCharacteristic: CBCharacteristic?
    var readCharacteristic: CBCharacteristic?
    
    
    init(initWithPeripheral peripheral: CBPeripheral) {
        super.init()
        
        self.peripheral = peripheral
        self.peripheral?.delegate = self
    }
    
    deinit {
        self.reset()
    }
    
    func startDiscoveringServices() {
        var BLEServiceUUID = CBUUID(string: DataContainerSingleton.custom.bleServiceUUID!)
        self.peripheral?.discoverServices([BLEServiceUUID])
    }
    
    func reset() {
        if peripheral != nil {
            peripheral = nil
            NSLog("didDisconnect")
        }
        
        // Deallocating therefore send notification
        self.sendBTServiceNotificationWithIsBluetoothConnected(false)
    }
    
    // Mark: - CBPeripheralDelegate
    
    //discovers services of the device
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        var BLEServiceUUID = CBUUID(string: DataContainerSingleton.custom.bleServiceUUID!)
        let uuidsForBTService: [CBUUID] = [PositionCharUUID, ReadCharUUID]
        if (peripheral != self.peripheral) {
            // Wrong Peripheral
            return
        }
        
        if (error != nil) {
            return
        }
        
        if ((peripheral.services == nil) || (peripheral.services!.count == 0)) {
            // No Services
            return
        }
        
        for service in peripheral.services! {
            
            if service.uuid == BLEServiceUUID {
                peripheral.discoverCharacteristics(uuidsForBTService, for: service)
            }
        }
    }
    
    
    
    //discovers characteristics for the service
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if (peripheral != self.peripheral) {
            // Wrong Peripheral
            return
        }
        
        
        if (error != nil) {
            return
        }
        // Start to check service characteristics
        
        //scan the characteristics array
        for characteristic in service.characteristics! {
            
            switch(characteristic.uuid){
            case PositionCharUUID:
                self.positionCharacteristic = (characteristic)
                peripheral.setNotifyValue(true, for: self.positionCharacteristic!)
                print("received positionCharacteristic")
                print(self.positionCharacteristic!)
            case ReadCharUUID:
                self.readCharacteristic = (characteristic)
                peripheral.setNotifyValue(true, for: self.readCharacteristic!)
                print("received readCharacteristic")
                print(self.readCharacteristic!)
            default:
                break
            }
            
        }
        // Send notification that Bluetooth is connected and all required characteristics are discovered
        self.sendBTServiceNotificationWithIsBluetoothConnected(true)
    }
    
    // Mark: - Private
    
    
    //function that handles writing packet to BLE
    func writePosition(_ position: [UInt8]) {
        // See if characteristic has been discovered before writing to it
        //    NSLog("insideWritePosition")
        if let positionCharacteristic = self.positionCharacteristic {
            //      NSLog("made it inside")
            let data = Data(bytes: position)
            //the actual api-level ble call
            self.peripheral?.writeValue(data, for: positionCharacteristic, type: CBCharacteristicWriteType.withResponse)
            //    NSLog(data)
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //retrived a characteristic value
        
        NSLog("Received value from peripheral")
        print(characteristic.value!)
        guard let data = characteristic.value else { return }
        print("value is \(UInt8(data:data))")
        
        if(UInt8(data:data) == 1) {
            print("low battery warning")
            DataContainerSingleton.custom.batteryStatusChange = true
            
            //Set the content of the notification
            let content = UNMutableNotificationContent()
            content.title = "Low Power Warning"
            content.subtitle = ""
            content.body = "Charge your Blades soon"
            
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
        
    }
    
    func readPosition() {
        self.peripheral!.readValue(for: self.readCharacteristic!)
    }
    
    //The peripheral will trigger this method after every successful write
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        //data is in characteristic.value
        NSLog("Sent Packet Successfully: Should NSLog 4 times, for 4 packets")
    }
    
    
    func sendBTServiceNotificationWithIsBluetoothConnected(_ isBluetoothConnected: Bool) {
        let connectionDetails = ["isConnected": isBluetoothConnected]
        NotificationCenter.default.post(name: Notification.Name(rawValue: BLEServiceChangedStatusNotification), object: self, userInfo: connectionDetails)
    }
    
    
    
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        NSLog("in here finally")
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
    }
    
    
}
