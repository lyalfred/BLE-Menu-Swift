//
//  DataContainerSingleton.swift
//  Blade Runner
//
//  Created by Alfred Ly on 3/10/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import Foundation
import UIKit

/*
 This struct defines the keys used to save the data container singleton's properties to NSUserDefaults.
 This is the "Swift way" to define string constants.
 */
struct DefaultsKeys
{

    static let profName = "profName"
    static let frequency = "frequency"
    static let intensity = "intensity"
    static let onTime = "onTime"
    static let offTime = "offTime"
    
    static let dataPacket1 = "dataPacket1"
    static let dataPacket2 = "dataPacket2"
    static let dataPacket3 = "dataPacket3"
    
    //Temp offload of BLE tasks
    static let bleServiceUUID = "bleServiceUUID"
    static let bleConnect = "bleConnect"
    static let peripheralName = "peripheralName"
    static let peripheralUUID = "peripheralUUID"
    static let disconnectYNFlag = "disconnectYNFlag"
    static let ranOnce = "ranOnce"                  //For notification system
    static let addDevice = "addDevice"              //DEPRECIATED
    static let fromDTVC = "fromDTVC"                //DEPRECIATED
    static let batteryStatusChange = "batteryStatusChange"
    static let firstTime = "firstTime"              //used to check if deviceList has been loaded or not
    static let numDevice = "numDevice"
    static let bleTurnedOn = "bleTurnedOn"
    static let updateRegList = "updateRegList"      //used to update registerList from DeviceCell to RegisterListDC
    static let pickerUUID = "pickerUUID"            //Buffer to hold user selection
    static let editPressed = "editPressed"          //Used to denote when user has pressed 'edit' to change blade name
    static let removeID = "removeID"                //UUID to be removed from PeripheralVC
    static let removeIDBool = "removeIDBool"        //flag to trigger removal
}

/**
 :Class:   DataContainerSingleton
 This class is used to save app state data and share it between classes.
 It observes the system UIApplicationDidEnterBackgroundNotification and saves its properties to NSUserDefaults before
 entering the background.
 
 Use the syntax `DataContainerSingleton.sharedDataContainer` to reference the shared data container singleton
 */

class DataContainerSingleton
{
    
    static let alaP1A = DataContainerSingleton()
    static let alaP2A = DataContainerSingleton()
    static let alaP3A = DataContainerSingleton()
    static let alaP4A = DataContainerSingleton()
    static let alaP1B = DataContainerSingleton()
    static let alaP2B = DataContainerSingleton()
    static let alaP3B = DataContainerSingleton()
    static let alaP4B = DataContainerSingleton()
    
    static let garraP1A = DataContainerSingleton()
    static let garraP2A = DataContainerSingleton()
    static let garraP3A = DataContainerSingleton()
    static let garraP4A = DataContainerSingleton()
    static let garraP1B = DataContainerSingleton()
    static let garraP2B = DataContainerSingleton()
    static let garraP3B = DataContainerSingleton()
    static let garraP4B = DataContainerSingleton()

    static let picoP1A = DataContainerSingleton()
    static let picoP2A = DataContainerSingleton()
    static let picoP3A = DataContainerSingleton()
    static let picoP4A = DataContainerSingleton()
    static let picoP1B = DataContainerSingleton()
    static let picoP2B = DataContainerSingleton()
    static let picoP3B = DataContainerSingleton()
    static let picoP4B = DataContainerSingleton()
    
    //Temp offload of BLE tasks
    static let custom = DataContainerSingleton()
    static let ala = DataContainerSingleton()
    static let garra = DataContainerSingleton()
    static let pico = DataContainerSingleton()
    //------------------------------------------------------------
    //Add properties here that you want to share accross your app
    var profName: String?
    var frequency: Int?
    var intensity: Int?
    var onTime: Int?
    var offTime: Int?
    
    //Temp offload of BLE tasks
    var bleServiceUUID: String?
    var bleConnect: Bool?
    var peripheralName: String?
    var peripheralUUID: String?
    var disconnectYNFlag: Bool?
    var ranOnce: Bool?
    var addDevice: Bool?
    var fromDTVC: Bool?
    var batteryStatusChange: Bool?
    var firstTime: Bool?
    var numDevice: Int?
    var bleTurnedOn: Bool?
    var updateRegList: Bool?
    var pickerUUID: String?
    var editPressed: Bool?
    var removeID: String?
    var removeIDBool: Bool?
    //------------------------------------------------------------
    
    var goToBackgroundObserver: AnyObject?
    
    private init()
    {
        let defaults = UserDefaults.standard
        //-----------------------------------------------------------------------------
        //This code reads the singleton's properties from NSUserDefaults.
        //edit this code to load your custom properties
        profName = " "
        frequency = 3250
        intensity = 50
        onTime = 30
        offTime = 30
        
        //Temp offload of BLE tasks
        bleServiceUUID = ""
        bleConnect = false
        peripheralName = ""
        peripheralUUID = ""
        disconnectYNFlag = false
        ranOnce = false
        addDevice = false
        fromDTVC = false
        batteryStatusChange = false
        firstTime = false
        numDevice = 0
        bleTurnedOn = true
        updateRegList = false
        pickerUUID = ""
        editPressed = false
        removeID = ""
        removeIDBool = false
        //-----------------------------------------------------------------------------
        
        //Add an obsever for the UIApplicationDidEnterBackgroundNotification.
        //When the app goes to the background, the code block saves our properties to NSUserDefaults.
        goToBackgroundObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIApplicationDidEnterBackground,
            object: nil,
            queue: nil)
        {_ in
            //       (note: Notification!) -> Void in
            let defaults = UserDefaults.standard
            //-----------------------------------------------------------------------------
            //This code saves the singleton's properties to NSUserDefaults.
            //edit this code to save your custom properties
            
            defaults.set( self.profName, forKey: DefaultsKeys.profName)
            defaults.set( self.frequency, forKey: DefaultsKeys.frequency)
            defaults.set( self.intensity, forKey: DefaultsKeys.intensity)
            defaults.set(self.onTime, forKey: DefaultsKeys.onTime)
            defaults.set(self.offTime, forKey: DefaultsKeys.offTime)
            
            //Temp offload of BLE tasks
            defaults.set(self.bleServiceUUID, forKey: DefaultsKeys.bleServiceUUID)
            defaults.set(self.bleConnect, forKey: DefaultsKeys.bleConnect)
            defaults.set(self.peripheralName, forKey: DefaultsKeys.peripheralName)
            defaults.set(self.peripheralUUID, forKey: DefaultsKeys.peripheralUUID)
            defaults.set(self.disconnectYNFlag, forKey: DefaultsKeys.disconnectYNFlag)
            defaults.set(self.ranOnce, forKey: DefaultsKeys.ranOnce)
            defaults.set(self.addDevice, forKey: DefaultsKeys.addDevice)
            defaults.set(self.fromDTVC, forKey: DefaultsKeys.fromDTVC)
            defaults.set(self.batteryStatusChange, forKey: DefaultsKeys.batteryStatusChange)
            defaults.set(self.firstTime, forKey: DefaultsKeys.firstTime)
            defaults.set(self.numDevice, forKey: DefaultsKeys.numDevice)
            defaults.set(self.bleTurnedOn, forKey: DefaultsKeys.bleTurnedOn)
            defaults.set(self.updateRegList, forKey: DefaultsKeys.updateRegList)
            defaults.set(self.pickerUUID, forKey: DefaultsKeys.pickerUUID)
            defaults.set(self.editPressed, forKey: DefaultsKeys.editPressed)
            defaults.set(self.removeID, forKey: DefaultsKeys.removeID)
            defaults.set(self.removeIDBool, forKey: DefaultsKeys.removeIDBool)
            //-----------------------------------------------------------------------------
            
            //Tell NSUserDefaults to save to disk now.
            defaults.synchronize()
        }
    }
}
