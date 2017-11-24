//
//  ISSTableViewCell.swift
//  ISSPass
//
//  Created by TAPAN BISWAS on 11/22/17.
//  Copyright © 2017 TAPAN BISWAS. All rights reserved.
//

import UIKit

class ISSTableViewCell: UITableViewCell {

    @IBOutlet weak var lblRiseDateTime: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
