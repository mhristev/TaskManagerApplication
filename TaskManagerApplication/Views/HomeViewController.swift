//
//  HomeViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 14.12.21.
//

import UIKit
import Firebase
import FirebaseAuth
import RealmSwift

class HomeViewController: UIViewController {
    
    @IBOutlet var welcomeLabel: UILabel!
    var newNoteDelegate: noteActionDelegate!
    
    let realm = try! Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
    @IBOutlet var overviewView: UIView!
    @IBOutlet var remindersView: UIView!
    
    var overviewChildController: OverviewChildHomeController?
    var remindersChildController: RemindersChildHomeController?
    
    
    @IBOutlet var segmentRemindersOverview: UISegmentedControl!
    
    
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        switch segmentRemindersOverview.selectedSegmentIndex {
            
        case 1:
            remindersChildController?.updateReminders()
            remindersView.isHidden = false
            
            overviewView.isHidden = true
               
           
        default:
            remindersView.isHidden = true
            overviewView.isHidden = false
            
        }
        
    }
    

    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        prepareChildren()
        let myAttribute = [ NSAttributedString.Key.font: UIFont(name: "Arial-BoldMT", size: 52.0)! ]
        let myString = NSMutableAttributedString(string: "Good,\nevening!", attributes: myAttribute )
        welcomeLabel.attributedText = myString
        
        let reminders = RealmHandler.shared.getAllReminders(inRealmObject: realm)
        NotificationHelper.createPendingNotificationsIn(reminders: reminders)
        
        //let firebase = FirebaseHandler()
        //firebase.createCategoryForCurrentUser(category: Category(name: "12", color: "2", icon: "3"))
        
        
//        let docRef = Firestore.firestore()
//                    .collection("users")
//                    .document(Auth.auth().currentUser!.uid)
//                    .collection("categoryID")
//
//
//
//        docRef.getDocument { (document, error) in
//            guard let document = document, document.exists else {
//                print("Document does not exist")
//                return
//            }
//            let dataDescription = document.data()
//            //print(dataDescription?["categories"] ?? "")
//
//
//            do {
//
//            let data = try JSONSerialization.data(withJSONObject: dataDescription?["categories"], options: .prettyPrinted)
//
//
//                let category = try JSONDecoder().decode(Array<Category>.self, from: data)
//            print("----------")
//                print(category)
//            } catch {
//                print(error)
//            }
//            //print(dataDescription?["firstname"] ?? "")
//        }
//
//        docRef.getDocument { document, error in
//                    guard error == nil else {
//                        //completionHandler(FirebaseError.database(error), nil)
//                        return
//                    }
//
//                    guard let json = document?.data() else {
//                        //completionHandler(FirebaseError.unknown, nil)
//                        return
//                    }
//
//                    do {
//                        let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
//                        //print(json)
//                        //let user = try JSONDecoder().decode(User.self, from: data)
//                       // self.currentUser = user
//
//                       // self.delegatesCollection.forEach { delegate in
//                       //     delegate.databaseManagerDidUserChange(sender: self)
//                       // }
//
//                        //completionHandler(nil, user)
//                    } catch {
//                        //completionHandler(FirebaseError.database(error), nil)
//                    }
//                }
        // Do any additional setup after loading the view.
    }
    
    
    
    
    @IBAction func quickNoteAction(_ sender: Any) {
        RealmHandler.shared.createNoteWith(title: "", text: NSAttributedString(""), favourite: false, categoryName: "Quick Notes", inRealmObject: self.realm)
        
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "NoteViewController") as! NoteViewController
        newNoteDelegate = destinationVC

        guard let note = RealmHandler.shared.getNoteWith(name: "", inRealmObject: self.realm) else {
            return
       }
        //print(note.id)
        newNoteDelegate.didCreateNoteWith(ID: note.getID())
        
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    
    
    @IBAction func signOutClicked(_ sender: UIButton) {
    
        let reminders = RealmHandler.shared.getAllReminders(inRealmObject: realm)
        NotificationHelper.removeAllPendingNotificationsIn(reminders: reminders)
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
                //RealmHandler.currUserID = nil
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

extension HomeViewController {
    func prepareChildren() {
        
        if let overviewChild = storyboard?.instantiateViewController(withIdentifier: "OverviewChildHomeController") as? OverviewChildHomeController {
            overviewChildController = overviewChild
            addChild(overviewChild)
            overviewView.addSubview(overviewChild.view)
            overviewChild.view.frame = overviewView.bounds
            overviewChild.tableView.delegate = overviewChild.self
            overviewChild.tableView.dataSource = overviewChild.self
            overviewChild.didMove(toParent: self)
        }
        
        if let remindersChild = storyboard?.instantiateViewController(withIdentifier: "RemindersChildHomeController") as? RemindersChildHomeController {
            remindersChildController = remindersChild
            addChild(remindersChild)
            remindersChild.view.frame = remindersView.bounds
            remindersView.addSubview(remindersChild.view)
            remindersChild.didMove(toParent: self)
        }
        
        remindersView.isHidden = true
        overviewView.isHidden = false
    }
    /*
    func removeOverview() {
       if parent == nil {
            return
        }
        
        willMove(toParent: nil)
        overviewView.removeFromSuperview()
        removeFromParent()
    }
    */
    
}


