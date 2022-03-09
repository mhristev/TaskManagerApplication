//
//  LoginFormViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 12.12.21.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class LoginFormViewController: UIViewController{
    
    @IBOutlet var segmentController: UISegmentedControl!
    @IBOutlet var actionButton: UIButton!
    @IBOutlet var titleForm: UILabel!
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
    
        switch segmentController.selectedSegmentIndex {
            
        case 1:
            actionButton.setTitle("Sign Up", for: .normal)
            titleForm.text = "Sign Up with your email and password"
        default:
            actionButton.setTitle("Sign In", for: .normal)
            titleForm.text = "Sign In with your email and password"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        actionButton.layer.cornerRadius = 18
        
    }
    
    
    func fieldValidation(email: String, password: String) -> Bool {
        
        if  email.trimmingCharacters(in: .whitespacesAndNewlines) == "" || password.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            self.dialogWindow(message: "Please fill all the fields", title: "Error")
            return false
        } else if isValidPassword(password: password) && isValidEmail(email: email) {
            return true
        } else {
            return false
        }
        
    }
    
    func isValidPassword(password: String) -> Bool{
        //Check if password contains one big letter, one number and and is minimum eight char long.
        let strongPassword = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[0-9])(?=.*[A-Z]).{8,}$")
        if (strongPassword.evaluate(with: password)) {
            return true
        } else {
            self.dialogWindow(message: "Please type a stronger password with at least one big letter, one number and is at least 8 characters long", title: "Error")
            return false
        }
        
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        
        if (emailPred.evaluate(with: email)) {
            return true
        } else {
            self.dialogWindow(message: "Please check your email field for spelling mistakes", title: "Error")
            return false
        }
    }
    
    
    @IBAction func signButtonTapped(_ sender: UIButton) {
        
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        
        guard let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        
        if segmentController.selectedSegmentIndex == 1 {
            
            let validation = fieldValidation(email: email, password: password);
            
            if validation == false {
                return
            }
            // Registration
            FirestoreHandler.registerUserWith(email: email, password: password, completion: { err in
                if let error = err {
                    self.dialogWindow(message: error, title: "Error")
                }
                FirestoreHandler.loginUserWith(email: email, password: password, completion: {err in
                    if let error = err {
                        self.dialogWindow(message: error, title: "Error")
                    } else {
                        self.presentWelcomeViewController()
                    }
                })
            })
            passwordTextField.text = ""
            emailTextField.text = ""
            
        } else {
            FirestoreHandler.loginUserWith(email: email, password: password, completion: { err in
                if let error = err {
                    self.dialogWindow(message: error, title: "Error")
                } else {
                    self.presentWelcomeViewController()
                }
            })
        }
    }
    
    
    func presentWelcomeViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let welcomeVC = storyboard.instantiateViewController(identifier: "NavController")
        
        welcomeVC.modalPresentationStyle = .fullScreen
        welcomeVC.modalTransitionStyle = .crossDissolve
        
        self.present(welcomeVC, animated: true, completion: nil)
        
    }
    
    
    @IBAction func googleLoginButton(_ sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
            
            if error != nil {
                guard let err = error?.localizedDescription else { return }
                self.dialogWindow(message: err, title: "Error")
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            self.googleLogin(credential: credential)
            
        }
        
        
    }
    
    func googleLogin(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { authResult, error in
            if error != nil {
                guard let err = error?.localizedDescription else { return }
                self.dialogWindow(message: err, title: "Error")
                return
            }
            
            print("User is signed in...")
            if let currentUser = Auth.auth().currentUser {
                RealmHandler.loadfirstConfiguration(andSetUserID: currentUser.uid)
                print(currentUser.uid)
                guard let user: GIDGoogleUser = GIDSignIn.sharedInstance.currentUser else {
                    return
                }
                
                let values = ["ID": currentUser.uid, "email" : user.profile?.email]
                
                Firestore.firestore().collection("users").document(currentUser.uid).setData(values as [String : Any], merge: true)
            }
            self.presentWelcomeViewController()
            
        }
    }
    
    
    func dialogWindow(message: String, title: String) {
        
        let myalert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        myalert.addAction(UIAlertAction(title: "Dismiss", style: .default,
                                        handler: {_ in
        }))
        
        
        present(myalert, animated: true)
        
    }
    
    
}


// return key on the keyboard
extension LoginFormViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
}

