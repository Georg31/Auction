//
//  testVC.swift
//  Auction
//
//  Created by George Digmelashvili on 7/14/20.
//  Copyright © 2020 George Digmelashvili. All rights reserved.
//

import UIKit

class testVC: UIViewController {
   
    
    @IBOutlet var testView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
       ShapeLayer()
        
    }
    
    func ShapeLayer(){
        let shapeLayer = CAShapeLayer()
        let openPath = UIBezierPath()
        openPath.addArc(withCenter: CGPoint(x: 0, y: 0), radius: 400, startAngle: 0, endAngle: 50, clockwise: true)
        shapeLayer.path = openPath.cgPath
        shapeLayer.fillColor = #colorLiteral(red: 1, green: 0.6235294118, blue: 0.03921568627, alpha: 1)
        self.testView.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.1529411765, blue: 0.1529411765, alpha: 1)
        self.testView.layer.addSublayer(shapeLayer)
    }


}
