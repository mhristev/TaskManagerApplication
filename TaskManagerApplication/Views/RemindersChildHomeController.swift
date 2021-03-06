//
//  RemindersChildWelcomeViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 17.01.22.
//

import UIKit
import RealmSwift

class RemindersChildHomeController: UIViewController {

    var realm: Realm {

                do {
                    let realm = try Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
                    return realm
                } catch {
                    print("Could not access database: ", error)
                }
                return self.realm
        }

    @IBOutlet var searchBar: UISearchBar!

    var reminders: [Note] = []
    var filteredReminders: [Note] = []

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        reminders = RealmHandler.getAllReminders(inRealmObject: realm)
        searchBar.delegate = self

        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        // Do any additional setup after loading the view.
    }
    @objc func dismissKeyboard() {
        // Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func viewDidAppear(_ animated: Bool) {
        self.updateReminders()
    }

    func updateReminders() {
        reminders = RealmHandler.getAllReminders(inRealmObject: realm)
        tableView.reloadData()
    }

}

extension RemindersChildHomeController: UITableViewDelegate {

    private func handleMoveToTrash(indexPath: IndexPath) {

        RealmHandler.removeReminderAndNotificationForNote(withID:
                                                            reminders[reminders.count - (1+indexPath.row)].id,
                                                            inRealmObject: realm)

        self.updateReminders()

        print("Moved to trash")

    }

    private func handleEdit(indexPath: IndexPath) {
        print("Edit")
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let trash = UIContextualAction(style: .destructive,
                                       title: "Remove Reminder") { [weak self] (_, _, completionHandler) in
            self?.handleMoveToTrash(indexPath: indexPath)
            completionHandler(true)
        }
        trash.backgroundColor = .systemRed

        let configuration = UISwipeActionsConfiguration(actions: [trash])

        return configuration
    }
}

extension RemindersChildHomeController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return reminders.count
    }
    // swiftlint:disable force_cast
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ReminderTableViewCell.identifier, for: indexPath) as! ReminderTableViewCell

        var out = reminders[reminders.count - (1+indexPath.row)].reminderDate!

        if let categoryName = reminders[reminders.count - (1+indexPath.row)].category?.name {
            out = "\(out) (\(categoryName))"
        }

        cell.configureWith(title: reminders[reminders.count - (1 + indexPath.row)].title, date: out)

        return cell
    }
    // swiftlint:enable force_cast
}

extension RemindersChildHomeController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredReminders = []

        if searchText == "" {
            reminders = RealmHandler.getAllReminders(inRealmObject: realm)
            tableView.reloadData()
            return
        }

        for reminder in reminders {
            if reminder.title.uppercased().contains(searchText.uppercased()) {
                filteredReminders.append(reminder)
            }
        }

        reminders = filteredReminders
        self.tableView.reloadData()
    }
}
