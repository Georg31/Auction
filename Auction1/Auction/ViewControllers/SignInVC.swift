//
//  SignInVC.swift
//  Auction
//
//  Created by George Digmelashvili on 7/1/20.
//  Copyright © 2020 George Digmelashvili. All rights reserved.
//

import UIKit
import Firebase

class SignInVC: UIViewController {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var service = DBService.service
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func SignInButton(_ sender: UIButton) {
        activityIndicator.startAnimating()
        service.SignIn(email: emailTextField.text!, password: passwordTextField.text!, vc: self)
        
    }
    
    
}



