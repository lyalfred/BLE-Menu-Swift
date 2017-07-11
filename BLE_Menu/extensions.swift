//
//  extensions.swift
//  BLE_Menu
//
//  Created by Alfred Ly on 7/11/17.
//  Copyright © 2017 Wagic. All rights reserved.
//

import Foundation

protocol DataConvertible {
    init(data:Data)
    var data:Data { get }
}

extension DataConvertible {
    init(data:Data) {
        guard data.count == MemoryLayout<Self>.size else {
            fatalError("data size (\(data.count)) != type size (\(MemoryLayout<Self>.size))")
        }
        self = data.withUnsafeBytes { $0.pointee }
    }
    
    var data:Data {
        var value = self
        return Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
}

extension UInt8:DataConvertible {}
extension UInt16:DataConvertible {}
extension UInt32:DataConvertible {}
extension Int32:DataConvertible {}
extension Int64:DataConvertible {}
extension Double:DataConvertible {}
extension Float:DataConvertible {}
