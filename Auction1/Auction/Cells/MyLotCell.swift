//
//  MyLotCell.swift
//  Auction
//
//  Created by George Digmelashvili on 7/7/20.
//  Copyright © 2020 George Digmelashvili. All rights reserved.
//

import UIKit

class MyLotCell: UICollectionViewCell {
    
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var statusView: UIView!{
        didSet{
            UIView.animate(withDuration: 0.7, delay: 1.0, options: [.repeat, .autoreverse], animations: {
                self.statusView.backgroundColor = UIColor.green.withAlphaComponent(0.3)
                self.statusView.layoutIfNeeded()
            },completion: nil)
        }
    }
    @IBOutlet var currentPriceLabel: UILabel!
    
    
}
