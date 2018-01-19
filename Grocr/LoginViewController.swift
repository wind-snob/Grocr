/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class LoginViewController: UIViewController {
  
  // MARK: Constants
  let loginToList = "LoginToList"
  
  // MARK: Outlets
  @IBOutlet weak var textFieldLoginEmail: UITextField!
  @IBOutlet weak var textFieldLoginPassword: UITextField!
  
  // MARK: Actions
  @IBAction func loginDidTouch(_ sender: AnyObject) {
    //performSegue(withIdentifier: loginToList, sender: nil)
    FIRAuth.auth()!.signIn(withEmail: textFieldLoginEmail.text!,
                           password: textFieldLoginPassword.text!)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // 1 Create an authentication observer using addStateDidChangeListener(_:).
    // The block is passed two parameters: auth and user.
    FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
      
      // 2 Test the value of user. Upon successful user authentication, user is populated with the user’s information.
      // If authentication fails, the variable is nil.
      if user != nil {
        
      // 3 On successful authentication, perform the segue. Pass nil as the sender. This may seem strange,
      // but you’ll set this up in GroceryListTableViewController.swift
        self.performSegue(withIdentifier: self.loginToList, sender: nil)
      }
    }
  }
  

  @IBAction func signUpDidTouch(_ sender: AnyObject) {
    let alert = UIAlertController(title: "Register",
                                  message: "Register",
                                  preferredStyle: .alert)
    
    let saveAction = UIAlertAction(title: "Save",
                                   style: .default) { action in
                                    
      // 1 Get the email and password as supplied by the user from the alert controller.
                                    let emailField = alert.textFields![0]
                                    let passwordField = alert.textFields![1]
                                    
      // 2 Call createUser(withEmail:password:) on the default Firebase auth object passing the email and password.
                                    FIRAuth.auth()!.createUser(withEmail: emailField.text!,
                                                               password: passwordField.text!) { user, error in
                                                                if error == nil {
    // 3 If there are no errors, the user account has been created. However, you still need to authenticate this new user,
    // so call signIn(withEmail:password:), again passing in the supplied email and password.
                                                                  FIRAuth.auth()!.signIn(withEmail: self.textFieldLoginEmail.text!,
                                                                                         password: self.textFieldLoginPassword.text!)
                                                                }
                                    }
                                    
    }
    
    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .default)
    
    alert.addTextField { textEmail in
      textEmail.placeholder = "Enter your email"
    }
    
    alert.addTextField { textPassword in
      textPassword.isSecureTextEntry = true
      textPassword.placeholder = "Enter your password"
    }
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true, completion: nil)
  }
  
}

extension LoginViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == textFieldLoginEmail {
      textFieldLoginPassword.becomeFirstResponder()
    }
    if textField == textFieldLoginPassword {
      textField.resignFirstResponder()
    }
    return true
  }
  
}
