//
//  ViewController.swift
//  Rechner
//
//  Created by Tony Lattke on 31.01.17.
//  Copyright © 2017 HSB. All rights reserved.
//

import UIKit
import MathEngine

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let a = MatrixME(a: 1,b: 3)
        
        print(a)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

