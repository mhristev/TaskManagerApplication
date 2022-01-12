//
//  WelcomeViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 14.12.21.
//

import UIKit
import Firebase
import FirebaseAuth

class WelcomeViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOutClicked(_ sender: UIButton) {
        showCreateAccount()
    }
    
    func presentLoginViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "LoginFormViewController")
        
        secondVC.modalPresentationStyle = .fullScreen
        secondVC.modalTransitionStyle = .crossDissolve
        
        self.present(secondVC, animated: true, completion: nil)
        
    }
    
    func showCreateAccount () {
    
    
        let myalert = UIAlertController(title: "Sign Out?", message: "Do you want to sign out?", preferredStyle: .alert)
        
    
        
        
        myalert.addAction(UIAlertAction(title: "Continue", style: .default,
                                      handler: {_ in
            do {
                try Auth.auth().signOut()
                self.presentLoginViewController()
                
                
            } catch {
                print("error sign out button")
            }
            
        }))
                        
        
        myalert.addAction(UIAlertAction(title: "Cancel", style: .default,
                                      handler: {_ in
        }))
        
        present(myalert, animated: true)
        
            
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
