//
//  SignUpVC.swift
//  YumQuest
//
//  Created by Anand Batjargal on 12/14/17.
//  Copyright © 2017 AnandBatjargal. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firstNameTF.delegate = self
        self.lastNameTF.delegate = self
        self.emailTF.delegate = self
        self.passwordTF.delegate = self
        self.confirmPasswordTF.delegate = self

        self.navigationController?.isNavigationBarHidden = false
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField: confirmPasswordTF, moveDistance: -200, up: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
                moveTextField(textField: confirmPasswordTF, moveDistance: -200, up: false)
    }
    
    
    // Move view up when textfield is pressed
    func moveTextField(textField: UITextField, moveDistance: Int, up: Bool){
        // Time it takes to move the textfield out of the way
        let moveDuration = 0.3
        // If up is true, set movement to moveDistance
        // If up is false, set movement to -moveDistance
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy:movement)
        UIView.commitAnimations()
    }
    
    @IBAction func logInPressed(_ sender: Any) {
    }
    
    // MARK: - Navigation

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        }
    }
    */
    


}
