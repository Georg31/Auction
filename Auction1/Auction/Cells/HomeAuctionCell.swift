//
//  HomeAuctionCell.swift
//  Auction
//
//  Created by George Digmelashvili on 7/6/20.
//  Copyright © 2020 George Digmelashvili. All rights reserved.
//

import UIKit

class HomeAuctionCell: UICollectionViewCell {
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var startTimeLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var statusView: UIView!
    
    
    func setData(lot: Lots){
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        lot.images.first?.downloadImage(completion: { (img) in
            DispatchQueue.main.async {
                self.imgView.image = img
            }
        })
        nameLabel.text = lot.name
        if lot.endDate < Date() && lot.sold{
            startTimeLabel.text = "Sold"
            statusView.backgroundColor = #colorLiteral(red: 1, green: 0.2016660048, blue: 0.1306692334, alpha: 1)
        }
        else if lot.endDate < Date(){
            startTimeLabel.text = "Finished"
            statusView.backgroundColor = #colorLiteral(red: 1, green: 0.2016660048, blue: 0.1306692334, alpha: 1)
        }
        else
        {startTimeLabel.text = formatter.string(from: lot.startDate)
            statusView.backgroundColor = #colorLiteral(red: 0.1882352941, green: 0.8196078431, blue: 0.3450980392, alpha: 1)
        }
        priceLabel.text = "Price: \(lot.currentPrice)"
    }
}
