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
        datePickerView.overrideUserInterfaceStyle = .dark
        
        
        //myDatePicker.overrideUserInterfaceStyle = .light

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createReminder(_ sender: UIButton) {
   //     print(datePickerView.date)
       
        guard let note = currNote else {
            return
        }
        
        NotificationHelper.createNewNotificationWith(title: note.title, date: datePickerView.date, ID: note.getID())
        
        RealmHandler.shared.createReminderForNote(withID: note.getID(), andDate: datePickerView.date as NSDate, inRealmObject: realm)
        
       
        
        let myalert = UIAlertController(title: "Success", message: "You have successfuly created a reminder.", preferredStyle: .alert)
        
        myalert.addAction(UIAlertAction(title: "Dismiss", style: .default,
                                      handler: {_ in
            self.dismiss(animated: true, completion: nil)
        }))
                        
    
        self.present(myalert, animated: true)
       //    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["testID"])
        //self.dismiss(animated: true, completion: nil)
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
