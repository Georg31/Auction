//
//  MyLotsVC.swift
//  Auction
//
//  Created by George Digmelashvili on 7/6/20.
//  Copyright © 2020 George Digmelashvili. All rights reserved.
//

import UIKit

class MyLotsVC: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    let refreshControl = UIRefreshControl()
    var service = DBService.service
    var lots = [Lots]()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpVC()
    }
    
    
    @objc func refreshData() {
        //service.listenMultiple()
        lots.removeAll()
        service.getMySellingLots { (lot) in
            DispatchQueue.main.async {
                self.lots.append(lot!)
                self.lots = self.lots.sorted(by:{$0.startDate > $1.startDate})
                self.collectionView.reloadData()
            }
        }
        refreshControl.endRefreshing()
    }
    
    @IBAction func AddNewLot(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Storyboard", bundle: nil).instantiateViewController(withIdentifier: "NewLotVC") as! NewLotVC
        vc.del = self
        self.present(vc, animated: true)
    }
    
    
    func setUpVC(){
        refreshControl.addTarget(self, action: #selector(refreshData), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.white
        refreshControl.attributedTitle = NSAttributedString(string: "Refresh Auctions", attributes: .some([NSAttributedString.Key.foregroundColor : UIColor.systemOrange]))
        collectionView.refreshControl = refreshControl
        collectionView.delegate = self
        collectionView.dataSource = self
        refreshData()
    }
    
}


extension MyLotsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, reloadCollection{
    func reload() {
        refreshData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeAuctionCell", for: indexPath) as! HomeAuctionCell
        cell.setData(lot: lots[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        return CGSize(width: width - 10 - 10, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           let vc = UIStoryboard(name: "Storyboard", bundle: nil).instantiateViewController(withIdentifier: "BidVC") as! BidVC
           vc.lotID = self.lots[indexPath.row].id
           vc.hidden = true
           self.present(vc, animated: true)
       }
    
}


extension String{
    func downloadImage(completion: @escaping (UIImage?) -> ()) {
        guard let url = URL(string: self) else {return}
        URLSession.shared.dataTask(with: url) { (data, res, err) in
            guard let data = data else {return}
            completion(UIImage(data: data))
        }.resume()
    }
}
