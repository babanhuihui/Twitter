//
//  ViewController.swift
//  Twitter
//
//  Created by Shuhui Qu on 4/25/15.
//  Copyright (c) 2015 Shuhui Qu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func OnLogin(sender: UIButton) {
        TwitterClient.sharedInstance.loginWithCompletion(){
            (user: User?, error: NSError?) in
            if user != nil{
                // perform segue
                self.performSegueWithIdentifier("loginSegue", sender: self)
            }else{
                // handle login error
            }
        }
    }
}

