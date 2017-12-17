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
import FirebaseAuth
import Firebase

class LogInVC: UIViewController,FBSDKLoginButtonDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameTF.delegate = self
        self.passwordTF.delegate = self
        
        let fbLoginButton = FBSDKLoginButton()
        fbLoginButton.frame = CGRect(x:35,y:575,width:343,height:55)
        view.addSubview(fbLoginButton)
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = ["email", "public_profile"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // Hide keyboard when tap outside of keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    // Hide keyboard when return is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    //
    @IBAction func logInPressed(_ sender: Any) {
    }
    
    // Facebook login button
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil{
            print(error)
            return
        }
        else{
            FBSDKGraphRequest(graphPath: "/me", parameters: ["fields":"id, name, email"]).start {
                (connection, result, err) in
                
                if err != nil{
                    print("Failed to start graph request:",err!)
                }
                
                print(result!)
                //
                let accessToken = FBSDKAccessToken.current()
                guard let accessTokenString = accessToken?.tokenString else { return }
                let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
                Auth.auth().signIn(with: credentials, completion: { (user,error) in
                    if error != nil {
                        print("Something went wrong",error!)
                    }
                    //
                    print("Successfully logged in")
                })
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Logged out")
    }
    
    // The following two functions are used to hide the navigation bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
