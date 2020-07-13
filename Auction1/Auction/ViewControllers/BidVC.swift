//
//  BidVC.swift
//  Auction
//
//  Created by George Digmelashvili on 7/7/20.
//  Copyright © 2020 George Digmelashvili. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class BidVC: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var statusView: UIView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var bidButton: UIButton!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var currentPriceLabel: UILabel!
    
    let alert = UIAlertController(title: "Auction", message: "Congratulations you Won!!!", preferredStyle: .alert)
    var timer: Timer?
    var progress = Float()
    var service = DBService.service
    var lotID = String()
    var hidden = false
    var lot: Lots?
    var lotRef: DocumentReference?
    var bid: Int?
    var user: DocumentReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        user = service.db.collection("users").document(Auth.auth().currentUser!.uid)
    }
    
    @IBAction func bidButton(_ sender: UIButton) {
        Notification()
        bid! += 10
        service.updateLot(lot: lotRef!, bid: bid!)
        currentPriceLabel.text = "Current Price: \(bid!)"
    }
    
    
    @IBAction func BackButton(_ sender: UIButton) {
        timer?.invalidate()
        dismiss(animated: true)
    }
    
    
    func retreiveCityName(latitude: Double, longitude: Double, completionHandler: @escaping (String?) -> Void)
    {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude), completionHandler:
            {
                placeMarks, error in
                
                completionHandler(placeMarks?.first?.locality)
        })
    }
    
    func Notification(){
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.removeAllPendingNotificationRequests()
        let content = UNMutableNotificationContent()
        
        content.title = "Auction"
        content.body =  "Auction Finished"
        content.sound = UNNotificationSound.default
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute, .second], from: lot!.endDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(req)
        
        
    }
    
    
    
    func setUp(){
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        bidButton.isHidden = hidden
        service.listenDocument(lotID: lotID)
        self.bidButton.isEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        service.del = self
        service.getLot(id: lotID) { (lot, ref) in
            DispatchQueue.main.async {
                self.lotRef = ref
                self.lot = lot
                self.retreiveCityName(latitude: (lot?.location.latitude)!, longitude: (lot?.location.longitude)!) { (str) in
                    self.locationLabel.text = str
                }
                self.progress = Float(self.lot!.startDate.distance(to: self.lot!.endDate))
                self.bid = lot?.currentPrice
                self.descriptionLabel.text = lot?.description
                self.collectionView.reloadData()
                self.currentPriceLabel.text = "Current Price: \(self.lot!.currentPrice)"
                self.nameLabel.text = lot?.name
                self.checkStatus()
            }}
    }
    
    func checkStatus(){
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (time) in
            if self.lot!.sold || self.lot!.endDate < Date(){
                self.bidButton.isEnabled = false
                self.statusView.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                self.statusView.sparkle(color: UIColor.red)
                self.progressView.isHidden = true
                time.invalidate()
            }
            self.timer = time
            
            if self.lot!.endDate > Date() && self.lot!.startDate < Date(){
                self.timer?.invalidate()
                self.progressView.isHidden = false
                self.bidButton.isEnabled = true
                self.statusView.backgroundColor = #colorLiteral(red: 0.1882352941, green: 0.8196078431, blue: 0.3450980392, alpha: 1)
                self.statusView.sparkle(color: UIColor.green)
                let newtime = Float(Date().distance(to: self.lot!.endDate)).rounded()
                let newprogress =  1 - newtime / self.progress
                self.progressView.progress = Float(newprogress)
                self.progress = newtime
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (t) in
                    self.progressView.setProgress(self.progress, animated: true)
                    self.timer = t
                    if self.lot!.endDate < Date(){
                        self.bidButton.isEnabled = false
                        self.statusView.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                        self.statusView.sparkle(color: UIColor.red)
                        self.progressView.isHidden = true
                        t.invalidate()
                        if self.lot?.winnerUser?.documentID == self.user?.documentID{
                            self.present(self.alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
}




extension BidVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UNUserNotificationCenterDelegate, LiveBid{
    
    func updateBid(price: Int, id: String, winner: DocumentReference) {
        if id == lotID{
            lot?.winnerUser = winner
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
