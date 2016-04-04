//
//  LogInViewController.swift
//  onMyFeet
//
//  Created by Zhao Xiongbin on 2016-02-22.
//  Copyright © 2016 OnMyFeet Group. All rights reserved.
//

import UIKit
import SafariServices

class LogInViewController: UIViewController {
    let screenHeight = UIScreen.mainScreen().bounds.height
    
      //MARK: Outlets
    @IBOutlet weak var logInBtn: UIButton!
    @IBOutlet weak var appLabel: UILabel!
    
    let fitbitAPI = FitbitAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logInBtn.layer.cornerRadius = 8.0;
        logInBtn.clipsToBounds = true;
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LogInViewController.didBecomeActive), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didBecomeActive() {
        if NSUserDefaults.standardUserDefaults().objectForKey("RefreshCode") != nil {
            fitbitAPI.refreshAccessToken()
            fitbitAPI.getUserName()
            fitbitAPI.getFitbitID()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func logIn(sender: AnyObject) {
        
        if NSUserDefaults.standardUserDefaults().boolForKey("LogOutManually") == true {
            FitbitAPI.logIn(forceLogIn: true)
        } else {
            FitbitAPI.logIn(forceLogIn: false)
        }
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
}
