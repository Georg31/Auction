//
//  HomeVC.swift
//  Auction
//
//  Created by George Digmelashvili on 7/6/20.
//  Copyright © 2020 George Digmelashvili. All rights reserved.
//

import UIKit
import Firebase

class HomeVC: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var collectionView: UICollectionView!
    
    var formatter = DateFormatter()
    var service = DBService.service
    var lots = [Lots]()
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        
    }
    
    @objc func refreshData() {
        //service.listenMultiple()
        lots.removeAll()
        service.getAllLots(completion: { (lot) in
            DispatchQueue.main.async {
                if lot?.sellerUser != Auth.auth().currentUser?.uid{
                    self.lots.append(lot!)
                    self.lots = self.lots.sorted(by:{$0.startDate > $1.startDate})
                    self.collectionView.reloadData()
                }
            }
        })
        refreshControl.endRefreshing()
    }
    
    
    func setUp(){
        service.listenDiffs()
        refreshControl.addTarget(self, action: #selector(refreshData), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.white
        refreshControl.attributedTitle = NSAttributedString(string: "Refresh Auctions", attributes: .some([NSAttributedString.Key.foregroundColor : UIColor.systemOrange]))
        collectionView.refreshControl = refreshControl
        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        formatter.dateFormat = "HH:mm"
        service.getAllLots(completion: { (lot) in
            DispatchQueue.main.async {
                if lot?.sellerUser != Auth.auth().currentUser?.uid{
                    self.lots.append(lot!)
                    self.lots = self.lots.sorted(by:{$0.startDate > $1.startDate})
                    self.collectionView.reloadData()
                }
            }
        })
        
    }
    
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeAuctionCell", for: indexPath) as! HomeAuctionCell
        lots[indexPath.row].images.first?.downloadImage(completion: { (img) in
            DispatchQueue.main.async {
                cell.imgView.image = img
            }
        })
        cell.nameLabel.text = lots[indexPath.row].name
        if lots[indexPath.row].endDate < Date() && lots[indexPath.row].sold{
            cell.startTimeLabel.text = "Sold"
        }
        else if lots[indexPath.row].endDate < Date(){
            cell.startTimeLabel.text = "Finished"
        }
        else
        {cell.startTimeLabel.text = formatter.string(from: lots[indexPath.row].startDate)}
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width / 2
        return CGSize(width: width - 5, height: 200)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Storyboard", bundle: nil).instantiateViewController(withIdentifier: "BidVC") as! BidVC
        vc.lotID = self.lots[indexPath.row].id
        self.present(vc, animated: true)
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print(lots)
    }
}
