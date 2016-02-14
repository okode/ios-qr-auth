//
//  ViewController.swift
//  QRAuth
//
//  Created by Pedro Jorquera on 12/2/16.
//  Copyright © 2016 Okode. All rights reserved.
//

import UIKit
import MobileForms

class ViewController: UIViewController, FormDelegate {

    var form: Form!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form = Form(controller: self)
        form.delegate = self
        
        let filepath = NSBundle.mainBundle().pathForResource("contact", ofType: "json", inDirectory: "json")
        do {
            let contents = try NSString(contentsOfFile: filepath!, usedEncoding: nil) as String
            form.setForm(contents)
            form.load()
        } catch { }

    }
    
    func result(data: String) { }
    func event(eventType: FormEventType, element: String, value: String) { }
    
}

