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
    var realm: Realm {
                do {
                    let realm = try Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
                    return realm
                } catch {
                    print("Could not access database: ", error)
                }
                return self.realm
        }
    var noteDelegate: NoteActionDelegate!

    @IBOutlet var datePickerView: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func createReminder(_ sender: UIButton) {
        guard let note = currNote else {
            return
        }

        if datePickerView.date < Date() {
            let myalert = UIAlertController(title: "Error",
                                            message: "The day has passed a long time ago", preferredStyle: .alert)

            myalert.addAction(UIAlertAction(title: "Dismiss", style: .default,
                                            handler: nil))

            self.present(myalert, animated: true)
            return
        }

        if let date = note.reminderDate?.toDate() {

            if date > Date() {

                let myalert = UIAlertController(title: "",
                                                message: """
                                                You already have a reminder for that note.
                                                Do you want to override it?
                                                """,
                                                preferredStyle: .alert)

                myalert.addAction(UIAlertAction(title: "Continue",
                                                style: UIAlertAction.Style.default, handler: { _ in
                    NotificationHelper.removeNotificationWithID(ID: note.id)
                    self.createReminder()

                }))
                myalert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { _ in
                    self.dismiss(animated: true, completion: nil)
                }))

                self.present(myalert, animated: true)
            }

        }

        self.createReminder()

    }

    func createReminder() {
        guard let note = currNote else {
            return
        }
        RealmHandler.createReminderAndNotificationForNote(withID: note.id,
                                                          andDate: datePickerView.date.formatedToStringDate(),
                                                          inRealmObject: realm)

        self.noteDelegate.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
}

extension CreateReminderViewController: NoteActionDelegate {
    func reloadData() {
        return
    }

    func didCreateNoteWith(ID: String) {
        return
    }

    func didCreateReminderOn(note: Note) {
        self.currNote = note
    }

}
