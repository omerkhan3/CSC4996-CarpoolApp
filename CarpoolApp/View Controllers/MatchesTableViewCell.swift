//
//  MatchesTableViewCell.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 4/15/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit

class MatchesTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var matchImage: UIImageView!
    @IBOutlet weak var matchLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
