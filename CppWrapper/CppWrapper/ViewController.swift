//
//  ViewController.swift
//  CppWrapper
//
//  Created by Student on 08.01.17.
//  Copyright © 2017 Tony Lattke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let wrapperItem = TestCppClassWrapper(title: "Init test text for cpp item wrapper class")
        print("Title: \(wrapperItem?.getTitle())")
        wrapperItem?.setTitle("Just yet another test text setted after cpp item wrapper class init")
        print("Title: \(wrapperItem?.getTitle())")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

