//
//  AssetCell.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 1.12.22.
//

import UIKit

class AssetCell: UITableViewCell {

    @IBOutlet weak var logoImaeView: UIImageView!
    @IBOutlet weak var circleImageView: UIImageView!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
