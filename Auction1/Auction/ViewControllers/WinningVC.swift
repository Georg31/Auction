//
//  WinningVC.swift
//  Auction
//
//  Created by George Digmelashvili on 7/13/20.
//  Copyright © 2020 George Digmelashvili. All rights reserved.
//

import UIKit

class WinningVC: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    let refreshControl = UIRefreshControl()
    var service = DBService.service
    var lots = [Lots]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setUp()
    }
    
    @objc func refreshData() {
        //service.listenMultiple()
        lots.removeAll()
        service.getMyWonLots { (lots) in
            DispatchQueue.main.async {
                self.lots.append(lots!)
                self.lots = self.lots.sorted(by:{$0.startDate > $1.startDate})
                self.collectionView.reloadData()
            }
        }
        refreshControl.endRefreshing()
    }
    
    
    func setUp(){
        refreshControl.addTarget(self, action: #selector(refreshData), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.white
        refreshControl.attributedTitle = NSAttributedString(string: "Refresh Auctions", attributes: .some([NSAttributedString.Key.foregroundColor : UIColor.systemOrange]))
        
        collectionView.refreshControl = refreshControl
        collectionView.delegate = self
        collectionView.dataSource = self
        refreshData()
    }
    
}

extension WinningVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeAuctionCell", for: indexPath) as! HomeAuctionCell
        cell.setData(lot: lots[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width / 2
        return CGSize(width: width - 5, height: 200)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Storyboard", bundle: nil).instantiateViewController(withIdentifier: "BidVC") as! BidVC
        vc.lotID = self.lots[indexPath.row].id
        vc.hidden = true
        self.present(vc, animated: true)
    }
    
}
