//
//  MainPageVC.swift
//  Auction
//
//  Created by George Digmelashvili on 7/1/20.
//  Copyright © 2020 George Digmelashvili. All rights reserved.
//

import UIKit
import Firebase
import ImagePicker

class SettingsPage: UIViewController{
    
   
    @IBOutlet var collectioView: UICollectionView!
    
    var service = DBService.service
    var imgs = [UIImage]()
    let imagePicker = ImagePickerController()
    var ref: DocumentReference?
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        collectioView.delegate = self
        collectioView.dataSource = self
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
        
    }
    
    @IBAction func upload(_ sender: Any) {
        imagePicker.imageLimit = 3
        self.present(imagePicker, animated: true)
    }
    
    
    @IBAction func imgButton(_ sender: Any) {
        
        let data = imgs.first!.jpegData(compressionQuality: 0.5)!
        let imgName = UUID().uuidString
        let imgRef = Storage.storage().reference().child("/images").child(Auth.auth().currentUser!.uid).child(imgName)
        imgRef.putData(data, metadata: nil) { (Metadata, err) in
            if let err = err{
                print(err.localizedDescription)
                return
            }
            imgRef.downloadURL { (url, err) in
                if let err = err{
                    print(err.localizedDescription)
                    return
                }
                guard let url = url else{ return}
                let dataRef = self.db.collection("images").document()
                let docID = dataRef.documentID
                let urlStr = url.absoluteString
                let data = ["uID":docID, "urlID":urlStr]
                
                dataRef.setData(data) { (err) in
                    if let err = err{
                        print(err.localizedDescription)
                        return
                    }
                }
            }
        }
    }
    
    private func updateLot() {
           // [START update_document]
           let user = db.collection("lots").document(Auth.auth().currentUser!.uid)
           
           // Set the "capital" field of the city 'DC'
           user.updateData([
               "images": FieldValue.arrayUnion([ref!])
           ]) { err in
               if let err = err {
                   print("Error updating document: \(err)")
               } else {
                   print("Document successfully updated")
               }
           }
           // [END update_document]
       }
    
    @IBAction func back(_ sender: Any) {
        print("back")
        service.signOut(vc: self)
    }
    @IBAction func somedata(_ sender: UIButton) {
        //customClassGetDocument()
        //getDocument()
        setLotWithCodable()
    }
    
    private func getDocument() {
        // [START get_document]
        let docRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
        // [END get_document]
    }
    
    
    
    
    private func getCollection() {
        // [START get_collection]
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
        // [END get_collection]
        
    }
    
    private func updateDocument() {
        // [START update_document]
        let user = db.collection("users").document(Auth.auth().currentUser!.uid)
        
        // Set the "capital" field of the city 'DC'
        user.updateData([
            "sellingLots": FieldValue.arrayUnion([ref!])
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        // [END update_document]
    }
    
    private func setLotWithCodable() {
        // [START set_document_codable]
        let user = User(firstname: "", lastname: "", email: "", phone: "", isVerified: true, watchingLots: [], sellingLots: [], wonLots: [])
        
        
        do {
            try ref = db.collection("lots").addDocument(from: user)
            print(ref!)
            updateDocument()
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
        // [END set_document_codable]
    }
    
    private func customClassGetDocument() {
        // [START custom_type]
        let docRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        
        docRef.getDocument { (document, error) in
            
            let result = Result {
                try document?.data(as: User.self)
            }
            switch result {
            case .success(let city):
                let city = city
                print("City: \(city)")
                
            case .failure(let error):
                // A `City` value could not be initialized from the DocumentSnapshot.
                print("Error decoding city: \(error)")
            }
            
        }
        // [END custom_type]
    }
}


extension SettingsPage: ImagePickerDelegate, UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imgCell", for: indexPath) as! ImgCell
        cell.imgView.image = imgs[indexPath.row]
        return cell
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print(#function)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imgs = images
        collectioView.reloadData()
        dismiss(animated: true)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        print(#function)
    }
    
    
   
}
