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
    var fbName:String?
    var fbPicUrl:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the textfields delegate to self in order to use textFieldShouldReturn properly
        self.usernameTF.delegate = self
        self.passwordTF.delegate = self
        
        // Create Facebook button
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

    @IBAction func logInPressed(_ sender: Any) {
    }
    
    // Facebook login button
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil{
            print(error)
            return
        }
        else{
            FBSDKGraphRequest(graphPath: "/me", parameters: ["fields":"id,name,first_name,last_name, email,picture.width(256).height(256)"]).start {
                (connection, result, err) in
                
                if err != nil{
                    print("Failed to start graph request:",err!)
                }
                
                // Obtain Facebook users full name and picture.
                if let data = result as? [String: Any]{
                    self.fbName = data["name"] as? String
                    
                    if let picture = data["picture"] as? [String:Any]{
                        if let data = picture["data"] as? [String:Any]{
                            if let url = data["url"] as? String{
                                self.fbPicUrl = url
                            }
                        }
                    }
                }
                
                let accessToken = FBSDKAccessToken.current()
                guard let accessTokenString = accessToken?.tokenString else { return }
                let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
                Auth.auth().signIn(with: credentials, completion: { (user,error) in
                    if error != nil {
                        print("Something went wrong",error!)
                    }
                    //
                    print("Successfully logged in")
                    
                    // Segue to Profile screen
                    self.performSegue(withIdentifier: "segueToProfile", sender: nil)
                })
            }
        }
    }
    
    // When logout is pressed on Facebook the following function is called
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
    
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "segueToProfile"){
            let tabController = segue.destination as! UITabBarController
            let destVC = tabController.viewControllers![0] as! ProfileVC
            destVC.name = fbName
            destVC.fbUrl  = fbPicUrl
        }
     }
    
    @IBAction func unwindToLogIn(segue:UIStoryboardSegue) { }
    
}
