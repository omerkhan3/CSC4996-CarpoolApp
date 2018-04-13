//
//  ScheduledRideTableViewCell.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 4/11/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit

class ScheduledRideTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var drivingLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var rideIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
