//
//  NotificationTableViewCell.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 4/14/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import SideMenu

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var notificationLbl: UILabel!
    @IBOutlet weak var notificationDateLbl: UILabel!
    @IBOutlet weak var notificationBell: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
