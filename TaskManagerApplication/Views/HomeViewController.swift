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
    var newNoteDelegate: NoteActionDelegate!

    var realm: Realm {
            do {
                let realm = try Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
                return realm
            } catch {
                print("Could not access database: ", error)
            }
            return self.realm
    }
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
        let myAttribute = [NSAttributedString.Key.font: UIFont(name: "Arial-BoldMT", size: 52.0)!]
        let today = Date()
        let hours = (Calendar.current.component(.hour, from: today))
        var greeting: String
        if hours >= 5 && hours < 12 {
            greeting = "Good,\nmorning!"
        } else if hours >= 12 && hours < 18 {
            greeting = "Good,\nafternoon!"
        } else {
            greeting = "Good,\nevening!"
        }

        let myString = NSMutableAttributedString(string: greeting, attributes: myAttribute)
        welcomeLabel.attributedText = myString
        let reminders = RealmHandler.getAllReminders(inRealmObject: realm)
        NotificationHelper.createPendingNotificationsIn(reminders: reminders)
    }
    @IBAction func quickNoteAction(_ sender: Any) {
        RealmHandler.createNoteWith(title: "", text: NSAttributedString(""),
                                    favourite: false, categoryName: "Quick Notes", inRealmObject: self.realm)
        guard let destinationVC = storyboard?.instantiateViewController(
            withIdentifier: "NoteViewController") as? NoteViewController else { return }
        newNoteDelegate = destinationVC
        guard let note = RealmHandler.getNoteWith(name: "", inRealmObject: self.realm) else {
            return
        }
        newNoteDelegate.didCreateNoteWith(ID: note.getID())

        self.navigationController?.pushViewController(destinationVC, animated: true)
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
                let reminders = RealmHandler.getAllReminders(inRealmObject: self.realm)
                NotificationHelper.removeAllPendingNotificationsIn(reminders: reminders)
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
}

extension HomeViewController {
    func prepareChildren() {
        if let overviewChild = storyboard?.instantiateViewController(
            withIdentifier: "OverviewChildHomeController") as? OverviewChildHomeController {
            overviewChildController = overviewChild
            addChild(overviewChild)
            overviewView.addSubview(overviewChild.view)
            overviewChild.view.frame = overviewView.bounds
            overviewChild.tableView.delegate = overviewChild.self
            overviewChild.tableView.dataSource = overviewChild.self
            overviewChild.didMove(toParent: self)
        }
        if let remindersChild = storyboard?.instantiateViewController(
            withIdentifier: "RemindersChildHomeController") as? RemindersChildHomeController {
            remindersChildController = remindersChild
            addChild(remindersChild)
            remindersChild.view.frame = remindersView.bounds
            remindersView.addSubview(remindersChild.view)
            remindersChild.didMove(toParent: self)
        }
        remindersView.isHidden = true
        overviewView.isHidden = false
    }
}
