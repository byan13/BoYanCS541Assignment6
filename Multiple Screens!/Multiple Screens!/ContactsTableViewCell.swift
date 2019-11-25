//
//  ContactsTableViewCell.swift
//  Multiple Screens!
//
//  Created by Bo Yan on 11/3/19.
//  Copyright © 2019 Bo Yan. All rights reserved.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
