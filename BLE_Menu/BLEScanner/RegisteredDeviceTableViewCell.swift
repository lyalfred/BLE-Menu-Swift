//
//  DeviceTableViewCell.swift
//  Blade Runner
//
//  Created by Alfred Ly on 5/18/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit


class RegisteredDeviceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var deviceID: UILabel!
    @IBOutlet weak var editPressed: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func editPressed(_ sender: Any) {
        DataContainerSingleton.custom.editPressed = true
        DataContainerSingleton.custom.updateRegList = true
        DataContainerSingleton.custom.removeID = deviceID.text

    }
    
    
    
    
}

     
