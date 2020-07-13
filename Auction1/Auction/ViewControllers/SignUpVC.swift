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
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var layerView: UIView!
    var service = DBService.service
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ShapeLayer()
        self.navigationController?.navigationBar.isHidden = true
       
    }

    @IBAction func BackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func SignUpButton(_ sender: UIButton) {
        if passwordTextField.text!.count < 6 || emailTextField.text!.isEmpty{ return}
        activityIndicator.startAnimating() 
        let user = User(firstname: fNameTextField.text!, lastname: lNameTextField.text!, email: emailTextField.text!, phone: "",sellingLots: [])
        service.newUser(email: emailTextField.text!, password: passwordTextField.text!, user: user, vc: self)
    }
    
     func ShapeLayer(){
            let shapeLayer = CAShapeLayer()
            let openPath = UIBezierPath()
            openPath.addArc(withCenter: CGPoint(x: 100, y: 0), radius: 350, startAngle: 0, endAngle: 50, clockwise: true)
            shapeLayer.path = openPath.cgPath
            shapeLayer.fillColor = #colorLiteral(red: 1, green: 0.6235294118, blue: 0.03921568627, alpha: 1)
            self.layerView.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.1529411765, blue: 0.1529411765, alpha: 1)
            self.layerView.layer.addSublayer(shapeLayer)
        }
    
   
}

