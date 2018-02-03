//
//  ProfileVC.swift
//  YumQuest
//
//  Created by Anand Batjargal on 12/16/17.
//  Copyright © 2017 AnandBatjargal. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FBSDKLoginKit

class ProfileVC: UIViewController,FBSDKLoginButtonDelegate{
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var name:String?
    var fbUrl:String?
    // Persist data
    var filePath: String {
        //1 - manager lets you examine contents of a files and folders in your app; creates a directory to where we are saving it
        let manager = FileManager.default
        //2 - this returns an array of urls from our documentDirectory and we take the first path
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        //3 - creates a new path component and creates a new file called "Data" which is where we will store our Data array.
        return (url!.appendingPathComponent("FB_Info").path)
    }
    // Persist data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //nameLabel.text = name
        //loadImage(urlString: fbUrl!, view: profilePicture)
        // Find a way to get the FB contents in this VC rather than performing them in the LoginVC and passing the data.
        
        // Load FBUserCache data from disk
        if let fbData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? FBUserCache {
            nameLabel.text = fbData.fbName
            loadImage(urlString: fbData.fbPicUrl, view: profilePicture)
        }
        
        // Create Facebook button
        let fbLoginButton = FBSDKLoginButton()
        fbLoginButton.frame = CGRect(x:35,y:600,width:343,height:55)
        view.addSubview(fbLoginButton)
        fbLoginButton.delegate = self
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("Login")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        // Segue to Log In
        performSegue(withIdentifier: "goToLogIn", sender: self)
    }
    
    func loadImage(urlString:String, view:UIImageView)
    {
        let profilePictureURL = URL(string: urlString)
        // Creating a session object with the default configuration.
        // You can read more about it here https://developer.apple.com/reference/foundation/urlsessionconfiguration
        let session = URLSession(configuration: .default)
        // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
        let downloadPictureTask = session.dataTask(with: profilePictureURL!) { (data,response,error) in
            // The download has finished.
            if error != nil {
                print("Error downloading Facebook picture")
            }else{
                if (response as? HTTPURLResponse) != nil{
                    if let imageData = data{
                        let image = UIImage(data:imageData)
                        
                        DispatchQueue.main.async {
                            self.profilePicture.image = image
                        }
                    }else{
                        print("Couldn't get the image")
                    }
                }else{
                    print("Couldn't get response")
                }
            }
            
        }
        downloadPictureTask.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToLogIn"{
            print("Go back to Log In")
        }
    }

}
