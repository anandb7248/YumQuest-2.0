//
//  ViewController.swift
//  YumQuest
//
//  Created by Anand Batjargal on 12/13/17.
//  Copyright © 2017 AnandBatjargal. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FBSDKLoginKit

class LogInVC: UIViewController,FBSDKLoginButtonDelegate {
    
    var dict : [String : AnyObject]!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fbLoginButton = FBSDKLoginButton()
    
        fbLoginButton.frame = CGRect(x:35,y:575,width:343,height:55)
        
        view.addSubview(fbLoginButton)
        
        fbLoginButton.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logInPressed(_ sender: Any) {
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil{
            print(error)
            return
        }
        else{
            print("Logged in")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Logged out")
    }
}
