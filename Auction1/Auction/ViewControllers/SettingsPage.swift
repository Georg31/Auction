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
    
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    
    var user: User?
    var service = DBService.service
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
        
    }
    
    
    
    
    @IBAction func SignOutButton(_ sender: UIButton) {
        print("back")
        service.signOut(vc: self)
    }
    
    func setData(){
        service.getUser { (user) in
            DispatchQueue.main.async {
                self.user = user
                self.firstNameTextField.text = user?.firstname
                self.lastNameTextField.text = user?.lastname
                self.emailTextField.text = user?.email
            }
        }
    }
    
    
}




