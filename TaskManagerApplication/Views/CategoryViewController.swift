//
//  CategoryListViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 15.01.22.
//

import UIKit
import RealmSwift
import UserNotifications

class CategoryViewController: UIViewController {

    @IBOutlet var searchBar: UISearchBar!
    var newNoteDelegate: NoteActionDelegate!
    var categoryDelegate: CategoryActionDelegate!
    @IBOutlet var favSegmentControl: UISegmentedControl!
    var notes: [Note] = []
    var filteredNotes: [Note] = []
    var realm: Realm {
                do {
                    let realm = try Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
                    return realm
                } catch {
                    print("Could not access database: ", error)
                }
                return self.realm
        }
    @IBOutlet var notesInCategoryTableView: UITableView!
    @IBOutlet var titleCategory: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        notesInCategoryTableView.delegate = self
        notesInCategoryTableView.dataSource = self
        searchBar.delegate = self
        self.notesInCategoryTableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "noteCell")
        // dismiss the keyboard tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    @objc func dismissKeyboard() {
        // Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    @IBAction func filterFavourites(_ sender: UISegmentedControl) {
        reloadTableBasedOnSegment()
    }
    @IBAction func createNote(_ sender: Any) {
        guard let catName = self.title else { return }
        RealmHandler.createNoteWith(title: "", text: NSAttributedString(""), favourite: false,
                                    categoryName: catName, inRealmObject: realm)
        guard let destinationVC = storyboard?.instantiateViewController(
            withIdentifier: "NoteViewController") as? NoteViewController else { return }
        newNoteDelegate = destinationVC
        guard let note = RealmHandler.getNoteWith(name: "", inRealmObject: realm) else {
            return
        }
        newNoteDelegate.didCreateNoteWith(ID: note.id)
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    func updateDataInTableViewAll() {
        notes = RealmHandler.getAllNotesInCategoryWith(name: self.title!, inRealmObject: realm)
        for note in notes where note.title.isEmpty {
            RealmHandler.deleteNoteWith(ID: note.id, inRealmObject: realm)
        }
        notes = RealmHandler.getAllNotesInCategoryWith(name: self.title!, inRealmObject: realm)
        notesInCategoryTableView.reloadData()
    }
    func updateDataInTableViewFavourite() {
        notes = RealmHandler.returnFavouriteNotesInCategory(name: self.title!, inRealmObject: realm)
        notesInCategoryTableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        reloadTableBasedOnSegment()
    }
    func reloadTableBasedOnSegment() {
        if favSegmentControl.selectedSegmentIndex == 0 {
            updateDataInTableViewAll()
        } else {
            updateDataInTableViewFavourite()
        }
    }
}

extension CategoryViewController: UITableViewDelegate {
    private func handleMarkAsFavourite(indexPath: IndexPath) {
        RealmHandler.updateFavouriteForNote(ID: notes[notes.count - (1 + indexPath.row)].id, inRealmObject: realm)
        print("Marked as favourite")
    }
    private func handleChangeCategory(indexPath: IndexPath) {
        guard let destinationVC = storyboard?.instantiateViewController(
            withIdentifier: "AddToCategoryViewController") as? AddToCategoryViewController else { return }
        categoryDelegate = destinationVC
        guard let category = RealmHandler.getCategoryWith(name: self.title!, inRealmObject: realm) else {
            return
        }
        guard let note = RealmHandler.getNoteWith(
            ID: notes[notes.count - (1 + indexPath.row)].id, inRealmObject: realm) else {
            return
        }
        categoryDelegate.didChangeCategory(currCategory: category, currNote: note)
        destinationVC.noteDelegate = self
        present(destinationVC, animated: true, completion: nil)
    }

    private func dialogWindow(message: String, title: String, indexPath: IndexPath) {

        let myalert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        myalert.addAction(UIAlertAction(title: "Delete", style: .default,
                                        handler: {_ in
            RealmHandler.deleteNoteWith(ID: self.notes[self.notes.count - (1 + indexPath.row)].id, inRealmObject: self.realm)
            self.notes = RealmHandler.getAllNotesInCategoryWith(name: self.title!, inRealmObject: self.realm)
            self.notesInCategoryTableView.beginUpdates()
            self.notesInCategoryTableView.deleteRows(at: [indexPath], with: .fade)
            self.notesInCategoryTableView.endUpdates()
            print("Moved to trash")
        }))

        myalert.addAction(UIAlertAction(title: "Cancel", style: .default,
                                        handler: {_ in
        }))

        present(myalert, animated: true)

    }
    private func handleCreateReminder(indexPath: IndexPath) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound],
                                                                completionHandler: {_, error in
            if error != nil {
                print("error while requesting permission for notifications")
                return
            }
        })
        guard let destinationVC = storyboard?.instantiateViewController(
            withIdentifier: "CreateReminderViewController") as? CreateReminderViewController else { return }
        self.newNoteDelegate = destinationVC
        destinationVC.noteDelegate = self
        guard let note = RealmHandler.getNoteWith(
            ID: notes[notes.count - (1 + indexPath.row)].id, inRealmObject: self.realm) else {
            return
        }
        newNoteDelegate.didCreateReminderOn(note: note)
        present(destinationVC, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal,
                                        title: "Favourite") { [weak self] (_, _, completionHandler) in
            self?.handleMarkAsFavourite(indexPath: indexPath)
            completionHandler(true)
        }
        action.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [action])
    }
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Reminder action
        let reminder = UIContextualAction(style: .normal,
                                          title: "Reminder") { [weak self] (_, _, completionHandler) in
            self?.handleCreateReminder(indexPath: indexPath)
            completionHandler(true)
        }
        reminder.backgroundColor = .systemGreen
        // Trash action
        let trash = UIContextualAction(style: .destructive,
                                       title: "Delete") { [weak self] (_, _, completionHandler) in
            self?.self.dialogWindow(message:
                                        "Are you sure you want to delete this note?", title: "Attention!",
                                    indexPath: indexPath)
            completionHandler(true)
        }
        trash.backgroundColor = .systemRed
        // Add To Folder action
        let folder = UIContextualAction(style: .normal,
                                        title: "Change Category") { [weak self] (_, _, completionHandler) in
            self?.handleChangeCategory(indexPath: indexPath)
            completionHandler(true)
        }
        folder.backgroundColor = .systemOrange
        let configuration = UISwipeActionsConfiguration(actions: [trash, reminder, folder])
        return configuration
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped \(indexPath.row)")
        guard let destinationVC = storyboard?.instantiateViewController(
            withIdentifier: "NoteViewController") as? NoteViewController else { return }
        newNoteDelegate = destinationVC
        guard let note = RealmHandler.getNoteWith(
            ID: notes[notes.count - (1 + indexPath.row)].id, inRealmObject: realm) else {
            return
        }
        newNoteDelegate.didCreateNoteWith(ID: note.id)
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = notesInCategoryTableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)
        print(notes)
        if let reminder = notes[notes.count - (1+indexPath.row)].reminderDate {
            if let date = reminder.toDate() {
                if Date() < date {
                    cell.detailTextLabel?.text = "Reminder for \(reminder)"
                    cell.textLabel?.text = notes[notes.count - (1 + indexPath.row)].title
                    return cell
                }
            }
        }
        cell.detailTextLabel?.text = nil
        cell.textLabel?.text = "\(notes[notes.count - (1 + indexPath.row)].title)"
        return cell
    }
}

extension CategoryViewController: CategoryActionDelegate {
    func didEditCategory(categories: [Category]) { return }
    func didCreateCategory(category: Category) { return }
    func didChangeCategory(currCategory: Category, currNote: Note) { return }
    func didEditCategory(category: Category) { return }
    func didSelectCategoryWith(name: String, notes: [Note]) {
        self.notes = notes
        self.title = name
    }
}

extension CategoryViewController: NoteActionDelegate {
    func reloadData() {
        reloadTableBasedOnSegment()
    }
    func didCreateReminderOn(note: Note) { return }
    func didCreateNoteWith(ID: String) { return }
}

extension CategoryViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredNotes = []
        if searchText == "" {
            notes = RealmHandler.getAllNotesInCategoryWith(
                name: self.title!, inRealmObject: realm)
            notesInCategoryTableView.reloadData()
            return
        }
        for note in notes {
            if note.title.uppercased().contains(searchText.uppercased()) {
                filteredNotes.append(note)
            }
        }
        notes = filteredNotes
        self.notesInCategoryTableView.reloadData()
    }
}

class SubtitleTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
