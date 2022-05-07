//
//  CategoryListViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 15.01.22.
//

import UIKit

class CategoryListViewController: UIViewController {
    // swiftlint:disable identifier_name
    @IBOutlet var NotesInCategoryTableView: UITableView!
    // swiftlint:enable identifier_name
    override func viewDidLoad() {
        super.viewDidLoad()
        NotesInCategoryTableView.delegate = self
        NotesInCategoryTableView.dataSource = self
    }
}

extension CategoryListViewController: UITableViewDelegate {
    private func handleMarkAsFavourite() {
        print("Marked as favourite")
    }

    private func handleAddToFolder() {
        self.performSegue(withIdentifier: "addToFolder", sender: self)
        print("Perform add to folder")
    }

    private func handleMoveToTrash() {
        print("Moved to trash")
    }

    private func handleCreateReminder() {
        self.performSegue(withIdentifier: "showCreateReminder", sender: self)

    }

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal,
                                        title: "Favourite") { [weak self] (_, _, completionHandler) in
                                            self?.handleMarkAsFavourite()
                                            completionHandler(true)
        }
        action.backgroundColor = .systemBlue

        return UISwipeActionsConfiguration(actions: [action])
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Archive action
        let archive = UIContextualAction(style: .normal,
                                         title: "Reminder") { [weak self] (_, _, completionHandler) in
                                            self?.handleCreateReminder()
                                            completionHandler(true)
        }
        archive.backgroundColor = .systemGreen

        // Trash action
        let trash = UIContextualAction(style: .destructive,
                                       title: "Delete") { [weak self] (_, _, completionHandler) in
                                        self?.handleMoveToTrash()
                                        completionHandler(true)
        }
        trash.backgroundColor = .systemRed

        // Unread action
        let unread = UIContextualAction(style: .normal,
                                       title: "Add to folder") { [weak self] (_, _, completionHandler) in
                                        self?.handleAddToFolder()
                                        completionHandler(true)
        }
        unread.backgroundColor = .systemOrange

        let configuration = UISwipeActionsConfiguration(actions: [trash, archive, unread])

        return configuration
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped \(indexPath.row)")

        self.performSegue(withIdentifier: "clickNoteToView", sender: self)
    }
}

extension CategoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = NotesInCategoryTableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)

        cell.textLabel?.text = "My first Note"
        return cell
    }
}
