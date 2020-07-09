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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    @objc func refreshData() {
        //service.listenMultiple()
        lots.removeAll()
        service.getMyLots { (lot) in
            DispatchQueue.main.async {
                self.lots.append(lot!)
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
        lots.removeAll()
        service.getMyLots { (lot) in
            DispatchQueue.main.async {
                self.lots.append(lot!)
                self.collectionView.reloadData()
            }
        }
    }
    
}


extension MyLotsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, reloadCollection{
    func reload() {
        lots.removeAll()
        service.getMyLots { (lot) in
            DispatchQueue.main.async {
                self.lots.append(lot!)
                self.collectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyLotCell", for: indexPath) as! MyLotCell
        lots[indexPath.row].images.first?.downloadImage(completion: { (img) in
            DispatchQueue.main.async {
                cell.imgView.image = img
            }
        })
        cell.currentPriceLabel.text = "Current Price: \(lots[indexPath.row].currentPrice)"
        cell.statusView.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        return CGSize(width: width - 10 - 10, height: 200)
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
