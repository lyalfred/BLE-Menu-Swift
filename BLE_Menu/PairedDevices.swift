//
//  PairedDevices.swift
//  Body Vibes Singleton - Import
//
//  Created by Alfred Ly on 4/14/17.
//  Copyright © 2017 Wagic. All rights reserved.
//

import UIKit
import os.log

class PairedDevices: NSObject, NSCoding {
    
    //Mark: Properties
    var name: String
    var deviceUUID: String
    var userName: String
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("devices")
    
    //MARK: Types
    struct PropertyKey {
        static let name = "name"
        static let deviceUUID = "deviceUUID"
        static let userName = "userName"
    }
    
    //MARK: Initialization
    init?(name: String, deviceUUID: String, userName: String) {
        //Initialize stored properties.
        self.name = name
        self.deviceUUID = deviceUUID
        self.userName = userName
    }
    
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(deviceUUID, forKey: PropertyKey.deviceUUID)
        aCoder.encode(userName, forKey: PropertyKey.userName)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String
        let deviceUUID = aDecoder.decodeObject(forKey: PropertyKey.deviceUUID) as? String
        let userName = aDecoder.decodeObject(forKey: PropertyKey.userName) as? String
        
        self.init(name: name!, deviceUUID: deviceUUID!, userName: userName!)
    }
    
}

