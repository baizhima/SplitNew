//
//  DishTableCell.swift
//  SplitMe
//
//  Created by Sean Hu on 11/1/15.
//  Copyright © 2015 Shan Lu. All rights reserved.
//


import UIKit


class DishTableCell: UITableViewCell {
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}
