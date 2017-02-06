//
//  ViewController.swift
//  TestMatrix
//
//  Created by Tony Lattke on 04.02.17.
//  Copyright © 2017 HSB. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let valuesA:[Float] = [10, 20, 30, 40, 50, 60, 70, 80, 90]
        let matrixA = MatrixEngineWrapper.init(3,3,valuesA)
        matrixA?.print("Matrix A")
        
        let valuesB:[Float] = [1,-2,3,4,5,6,7,8,9]
        let matrixB = MatrixEngineWrapper.init(3,3,valuesB)
        matrixB?.print("Matrix B")
        
        let result = matrixA?.add(matrixB)
        result?.print("Matrix Result")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

