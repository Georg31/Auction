//
//  ViewController.swift
//  Auction
//
//  Created by George Digmelashvili on 7/1/20.
//  Copyright © 2020 George Digmelashvili. All rights reserved.
//

import UIKit
import Firebase
import AuthenticationServices
import FirebaseFirestoreSwift

class SignUpVC: UIViewController {
    @IBOutlet var fNameTextField: UITextField!
    @IBOutlet var lNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var rePasswordTextField: UITextField!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var service = DBService.service
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
    }


    @IBAction func SignUpButton(_ sender: UIButton) {
        activityIndicator.startAnimating() 
        let user = User(firstname: fNameTextField.text!, lastname: lNameTextField.text!, email: emailTextField.text!, phone: "2", isVerified: true, watchingLots: [], sellingLots: [], wonLots: [])
        service.newUser(email: emailTextField.text!, password: passwordTextField.text!, user: user, vc: self)
    }
    
     
    
   
}

