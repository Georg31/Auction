//
//  DBService.swift
//  Auction
//
//  Created by George Digmelashvili on 7/4/20.
//  Copyright © 2020 George Digmelashvili. All rights reserved.
//

import UIKit
import Firebase
import AuthenticationServices
protocol test {
    func updateBid(price: Int, id: String)
}

class DBService{
    
    var del: test?
    var db: Firestore!
    static var service = DBService()
    
    private init(){
        Firestore.firestore().settings = FirestoreSettings()
        db = Firestore.firestore()
    }
    
    
    
    func signOut(vc: UIViewController){
        do{
            try Auth.auth().signOut()
            let sceneDelegate = vc.view.window?.windowScene?.delegate as! SceneDelegate
            sceneDelegate.signOut()
        }
        catch{print(error.localizedDescription)}
    }
    
    func SignIn(email: String, password: String, vc: UIViewController) {
        Auth.auth().signIn(withEmail: email, password: password) { (AuthRes, Error) in
            if AuthRes != nil{
                let sceneDelegate = vc.view.window?.windowScene?.delegate as! SceneDelegate
                sceneDelegate.signIn()
            }
            else{ print(Error?.localizedDescription as Any)}
        }
    }
    
    
    private func setDocumentWithCodable(user: User) {
        let id = Auth.auth().currentUser!.uid
        do {
            try db.collection("users").document(id).setData(from: user)
            
        } catch let error {
            print("Error writing to Firestore: \(error)")
        }
    }
    
    func newUser(email: String, password: String, user: User, vc : UIViewController){
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if authResult != nil{
                self.setDocumentWithCodable(user: user)
                self.SignIn(email: email, password: password, vc: vc )
            }
            else{ print(error?.localizedDescription as Any)}
        }
    }
    
    private func updateUser(ref: DocumentReference) {
        // [START update_document]
        let user = db.collection("users").document(Auth.auth().currentUser!.uid)
        
        // Set the "capital" field of the city 'DC'
        user.updateData([
            "sellingLots": FieldValue.arrayUnion([ref])
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        // [END update_document]
    }
    
    func setLotWithCodable(lot: Lots) {
        
        do {
            let ref = db.collection("lots").document(lot.id)
            try ref.setData(from: lot)
            updateUser(ref: ref)
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
    }
    
    func getUserLots() {
        // [START get_document]
        let docRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                let s = dataDescription!["sellingLots"]
                print(s!)
            } else {
                print("Document does not exist")
            }
        }
        // [END get_document]
    }
    
    
    func updateLot(lot: DocumentReference, bid: Int) {
        let user = db.collection("users").document(Auth.auth().currentUser!.uid)
        lot.updateData([
            "currentPrice": bid,
            "winnerUser": user
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    
    func newImageUrl(imgs: [UIImage],completion:@escaping((String?) -> () )) {
        for img in imgs{
            let data = img.jpegData(compressionQuality: 0.5)!
            let imgName = UUID().uuidString
            let imgRef = Storage.storage().reference().child("/images").child(imgName)
            
            imgRef.putData(data, metadata: nil) { (data, error) in
                guard data != nil else {
                    return
                }
                
                imgRef.downloadURL { (url, error) in
                    guard let urlStr = url else{
                        completion(nil)
                        return
                    }
                    let urlFinal = (urlStr.absoluteString)
                    completion(urlFinal)
                }
            }
        }
    }
    
    
    func getMyLots(completion:@escaping((Lots?) -> () )) {
        let s = db.collection("lots").whereField("sellerUser", isEqualTo: String(Auth.auth().currentUser!.uid))
        s.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let result = Result {
                        try document.data(as: Lots.self)
                    }
                    switch result {
                    case .success(let lot):
                        let lot = lot
                        completion(lot)
                        
                    case .failure(let error):
                        print("Error decoding city: \(error)")
                    }
                }
            }
        }
    }
    
    func getAllLots(completion:@escaping((Lots?) -> () )) {
        db.collection("lots").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let result = Result {
                        try document.data(as: Lots.self)
                    }
                    switch result {
                    case .success(let lot):
                        let lot = lot
                        completion(lot)
                        
                    case .failure(let error):
                        print("Error decoding city: \(error)")
                    }
                }
            }
        }
    }
    
     func listenDocument(lotID: String) {
           // [START listen_document]
           db.collection("lots").document(lotID)
               .addSnapshotListener { documentSnapshot, error in
                 guard let document = documentSnapshot else {
                   print("Error fetching document: \(error!)")
                   return
                 }
                if let data = document.data() {
                    
                    self.del?.updateBid(price: data["currentPrice"] as! Int, id: document.documentID)
                }
                else {
                   print("Document data was empty.")
                   return
                 }
                 
               }
           // [END listen_document]
       }
    
    func listenDiffs() {
        // [START listen_diffs]
        db.collection("lots").whereField("sold", isEqualTo: false)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        // print("New city: \(diff.document.data())")
                    }
                    if (diff.type == .modified) {
                        let result = Result {
                            try diff.document.data(as: Lots.self)
                        }
                        switch result {
                        case .success(let price):
                            _ = price
                            //self.del?.updateBid(price: price!.currentPrice)
                            
                        case .failure(let error):
                            print("Error decoding city: \(error)")
                        }
                        
                    }
                    if (diff.type == .removed) {
                        // print("Removed city: \(diff.document.data())")
                    }
                }
        }
        // [END listen_diffs]
    }
    
    func listenMultiple() {
        db.collection("lots").whereField("sold", isEqualTo: false)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                let lots = documents.map { $0["name"]! }
                print("Current cities in CA: \(lots)")
        }
    }
    
    
    func getLot(id: String,completion:@escaping((Lots?, DocumentReference) -> () )) {
        let s = db.collection("lots").whereField("id", isEqualTo: id)
        s.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let result = Result {
                        try document.data(as: Lots.self)
                    }
                    switch result {
                    case .success(let lot):
                        let lot = lot
                        completion(lot, document.reference)
                        
                    case .failure(let error):
                        print("Error decoding city: \(error)")
                    }
                }
            }
        }
    }
    
}

