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

protocol LiveBid: AnyObject{
    func updateBid(price: Int, id: String, winner: DocumentReference)
}

class DBService{
    
    weak var del: LiveBid?
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
    

    
    func getUser(completion:@escaping((User?) -> () )){
        let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        userRef.getDocument { (doc, err) in
            let result = Result {
                try doc?.data(as: User.self)
            }
            switch result {
            case .success(let user):
                if let user = user{
                    completion(user)
                }
                else{print("erro")}
            case.failure(let error):
                print(error)
            }
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
    
    
    
    func updateLot(lot: DocumentReference, bid: Int) {
        let user = db.collection("users").document(Auth.auth().currentUser!.uid)
        lot.updateData([
            "sold": true,
            "currentPrice": bid,
            "winnerUser": user
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {}
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
    
    func getMyWonLots(completion:@escaping((Lots?) -> () )) {
        let user = db.collection("users").document(Auth.auth().currentUser!.uid)
        let s = db.collection("lots").whereField("winnerUser", isEqualTo: user)
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
                        print("Error decoding: \(error)")
                    }
                }
            }
        }
    }
    
    
    func getMySellingLots(completion:@escaping((Lots?) -> () )) {
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
                    
                    self.del?.updateBid(price: data["currentPrice"] as! Int, id: document.documentID, winner: data["winnerUser"] as? DocumentReference ?? self.db.collection("users").document(Auth.auth().currentUser!.uid) )
                }
                else {
                    print("Document data was empty.")
                    return
                }
                
        }
        // [END listen_document]
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

