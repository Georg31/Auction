//
//  NewLotVC.swift
//  Auction
//
//  Created by George Digmelashvili on 7/6/20.
//  Copyright © 2020 George Digmelashvili. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import AuthenticationServices
import ImagePicker

protocol reloadCollection {
    func reload()
}

class NewLotVC: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var lotNameTextField: UITextField!
    @IBOutlet var startPriceTextField: UITextField!
    @IBOutlet var bidTextField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    let locationManager = CLLocationManager()
    var del: reloadCollection?
    var service = DBService.service
    var imgURLS = [String]()
    var userID: String!
    var imgs = [UIImage]()
    let imagePicker = ImagePickerController()
    
    var st = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        checkLocationServiceEnabled()
    }
    
    
    
    @IBAction func test(_ sender: Any) {
        
        
    }
    
    
    
    @objc func SelectImages(_ sender: UITapGestureRecognizer){
        imagePicker.imageLimit = 5
        self.present(imagePicker, animated: true)
    }
    
    
    @IBAction func PostLotButton(_ sender: UIButton) {
        service.setLotWithCodable(lot: createLotObject())
        del?.reload()
        dismiss(animated: true)
    }
    
    
    func createLotObject() -> Lots{
        let s = locationManager.location!.coordinate
        let lot = Lots(name: lotNameTextField.text!, desc: descriptionTextView.text!, imgs: imgURLS, seller: userID, location: GeoPoint(latitude: s.latitude, longitude: s.longitude))
        
        return lot
    }
    
    func setUp(){
        imagePicker.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(SelectImages))
        collectionView.addGestureRecognizer(tap)
        userID = Auth.auth().currentUser?.uid
    }
    
    
    private func checkLocationServiceEnabled() {
           if CLLocationManager.locationServicesEnabled() {
               setupLocationManager()
               checkAuthorizationStatus()
           }
       }
       
       private func setupLocationManager() {
           locationManager.delegate = self
           locationManager.desiredAccuracy = kCLLocationAccuracyBest
       }
       
       private func checkAuthorizationStatus() {
           switch CLLocationManager.authorizationStatus() {
           case .authorizedWhenInUse:
               locationManager.startUpdatingLocation()
               //mapView.showsUserLocation = true
           case .authorizedAlways:
               break
           case .denied:
               break
           case .notDetermined:
               locationManager.requestWhenInUseAuthorization()
           case .restricted:
               break
           @unknown default:
            fatalError()
        }
       }
}






extension NewLotVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate, ImagePickerDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if imgs.count == 0 {return 1}
        return imgs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imgCell", for: indexPath) as! ImgCell
        if imgs.count > 0{cell.imgView.image = imgs[indexPath.row] }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width / 3
        return CGSize(width: width - 10, height: collectionView.frame.height)
    }
    
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print(#function)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imgs = images
        collectionView.reloadData()
        service.newImageUrl(imgs: imgs) { (url) in
            DispatchQueue.main.async {
                self.imgURLS.append(url!)
            }
        }
        dismiss(animated: true)
        
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        dismiss(animated: true)
    }
}


