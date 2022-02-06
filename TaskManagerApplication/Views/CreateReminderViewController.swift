//
//  CreateReminderViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 1.02.22.
//

import UIKit
import SwiftUI
import RealmSwift

class CreateReminderViewController: UIViewController {
    
    var currNote: Note?
    let realm = try! Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
    
    @IBOutlet var datePickerView: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //datePickerView.overrideUserInterfaceStyle = .dark
        
        
        //myDatePicker.overrideUserInterfaceStyle = .light

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createReminder(_ sender: UIButton) {
   //     print(datePickerView.date)
       
        guard let note = currNote else {
            return
        }
        
        
        if datePickerView.date < Date() {
            let myalert = UIAlertController(title: "Error", message: "The day has passed a long time ago, my friend", preferredStyle: .alert)
            
            myalert.addAction(UIAlertAction(title: "Dismiss", style: .default,
                                          handler: nil))
                            
            self.present(myalert, animated: true)
            return
        }
        
        
        if note.reminderDate != nil {
            print("bbbbbbb")
            let myalert = UIAlertController(title: "", message: "You already have a reminder for that note. Do you want to override it?", preferredStyle: .alert)
            
            myalert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: { _ in
                NotificationHelper.removeNotificationWithID(ID: note.getID())
                self.createReminder()
                
            }))
            myalert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            
            self.present(myalert, animated: true)
        } else {
            print("AAAAAAAA")
            self.createReminder()
        }
        
        
        
        
       //    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["testID"])
        //self.dismiss(animated: true, completion: nil)
    }
    

    func createReminder() {
        guard let note = currNote else {
            return
        }
        RealmHandler.shared.createReminderAndNotificationForNote(withID: note.getID(), andDate: datePickerView.date, inRealmObject: realm)
        
        
        let myalert = UIAlertController(title: "Success", message: "You have successfuly created a reminder.", preferredStyle: .alert)
        
        myalert.addAction(UIAlertAction(title: "Dismiss", style: .default,
                                      handler: {_ in
            self.dismiss(animated: true, completion: nil)
        }))
                        
    
        self.present(myalert, animated: true)
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

extension CreateReminderViewController: noteActionDelegate {
    func didCreateNoteWith(ID: String) {
        return
    }
    
    func didUpdateNoteCategory(notes: Array<Note>) {
        return
    }
    
    func didCreateReminderOn(note: Note) {
        self.currNote = note
    }
    
    
}
