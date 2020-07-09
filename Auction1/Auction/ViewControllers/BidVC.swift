//
//  BidVC.swift
//  Auction
//
//  Created by George Digmelashvili on 7/7/20.
//  Copyright © 2020 George Digmelashvili. All rights reserved.
//

import UIKit
import Firebase

class BidVC: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var statusView: UIView!
    
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var sellerImgView: UIImageView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var currentPriceLabel: UILabel!
    var progress = Float()
    var service = DBService.service
    var lotID = String()
    var lot: Lots?
    var lotRef: DocumentReference?
    var bid: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        
    }
    
    @IBAction func bidButton(_ sender: UIButton) {
        
        bid! += 10
        service.updateLot(lot: lotRef!, bid: bid!)
        currentPriceLabel.text = "Current Price: \(bid!)"
    }
    
    
    @IBAction func BackButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    
    func setUp(){
        service.listenDocument(lotID: lotID)
        collectionView.delegate = self
        collectionView.dataSource = self
        service.del = self
        service.getLot(id: lotID) { (lot, ref) in
            DispatchQueue.main.async {
                self.lotRef = ref
                self.lot = lot
                self.progress = Float(self.lot!.startDate.distance(to: self.lot!.endDate))
                self.bid = lot?.currentPrice
                self.collectionView.reloadData()
                self.currentPriceLabel.text = "Current Price: \(self.lot!.currentPrice)"
                self.nameLabel.text = lot?.name
                //self.statusLabel.text = lot!.sold ? "": ""
                if lot!.sold || lot!.endDate < Date(){
                    self.statusView.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                    self.statusView.sparkle(color: UIColor.red)
                    self.progressView.isHidden = true
                }
 
                if lot!.endDate > Date() && lot!.startDate < Date(){
                    self.statusView.backgroundColor = #colorLiteral(red: 0.1882352941, green: 0.8196078431, blue: 0.3450980392, alpha: 1)
                    self.statusView.sparkle(color: UIColor.green)
                    let newtime = Float(Date().distance(to: lot!.endDate)).rounded()
                    let newprogress =  1 - newtime / self.progress
                    self.progressView.progress = Float(newprogress)
                    self.progress = newtime
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (t) in
                        self.progressView.setProgress(self.progress, animated: true)
                    }
                }
            }}
    }
    
}




extension BidVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, test{
    func updateBid(price: Int, id: String) {
        if id == lotID{
            bid = price
            self.currentPriceLabel.text = "Current Price: \(price)"
        }
        else{return}
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lot?.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AuctionImgCell", for: indexPath) as! AuctionImgCell
        lot?.images[indexPath.row].downloadImage(completion: { (img) in
            DispatchQueue.main.async {
                cell.imgView.image = img
            }
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        return CGSize(width: width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}


extension UIView{
    
    func sparkle(color: UIColor){
        UIView.animate(withDuration: 0.7, delay: 1.0, options: [.repeat, .autoreverse], animations: {
            self.backgroundColor = color.withAlphaComponent(0.3)
            self.layoutIfNeeded()
        },completion: nil)
    }
}
