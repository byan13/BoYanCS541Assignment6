//
//  Contacts.swift
//  Multiple Screens!
//
//  Created by Bo Yan on 11/3/19.
//  Copyright © 2019 Bo Yan. All rights reserved.
//

import UIKit
import os.log

class Contacts: NSObject, NSCoding {
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("contactss")
    
    struct SavedContacts {
        static let name = "name"
        static let phoneNumber = "phoneNumber"
        static let photo = "photo"
    }
    
    var name: String
    var phoneNumber: String
    var photo: UIImage?
    
    init?(name: String, phoneNumber: String, photo: UIImage?) {
        if(name.isEmpty || phoneNumber.isEmpty){
            return nil
        }
        self.name = name
        self.phoneNumber = phoneNumber
        self.photo = photo
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: SavedContacts.name)
        coder.encode(phoneNumber, forKey: SavedContacts.phoneNumber)
        coder.encode(photo, forKey: SavedContacts.photo)
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let name = decoder.decodeObject(forKey: SavedContacts.name) as? String else {
            os_log("Unable to decode the name for a Contacts object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let phoneNumber = decoder.decodeObject(forKey: SavedContacts.phoneNumber) as? String else {
            os_log("Unable to decode the phoneNumber for a Contacts object.", log: OSLog.default, type: .debug)
            return nil
        }
        let photo = decoder.decodeObject(forKey: SavedContacts.photo) as? UIImage
        self.init(name: name, phoneNumber: phoneNumber, photo: photo)
    }
}
