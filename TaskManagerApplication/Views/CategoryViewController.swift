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
    var newNoteDelegate: noteActionDelegate!
    
    var categoryDelegate: categoryActionDelegate!
    
    
    @IBOutlet var favSegmentControl: UISegmentedControl!
    
    var notes: Array<Note> = []
    var filteredNotes: [Note] = []
    
    let realm = try! Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
    
    
    @IBOutlet var NotesInCategoryTableView: UITableView!
    @IBOutlet var titleCategory: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotesInCategoryTableView.delegate = self
        NotesInCategoryTableView.dataSource = self
        
        searchBar.delegate = self
        self.NotesInCategoryTableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "noteCell")
        
        // dismiss the keyboard tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func filterFavourites(_ sender: UISegmentedControl) {
        reloadTableBasedOnSegment()
    }
    
    @IBAction func createNote(_ sender: Any) {
        
        RealmHandler.shared.createNoteWith(title: "", text: NSAttributedString(""), favourite: false, categoryName: self.title!, inRealmObject: realm)
        
        reloadTableBasedOnSegment()
        
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "NoteViewController") as! NoteViewController
        newNoteDelegate = destinationVC
        
        guard let note = RealmHandler.shared.getNoteWith(name: "", inRealmObject: realm) else {
            return
        }
        
        newNoteDelegate.didCreateNoteWith(ID: note.getID())
        
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    func updateDataInTableViewAll() {
        notes = RealmHandler.shared.getAllNotesInCategoryWith(name: self.title!, inRealmObject: realm)
        NotesInCategoryTableView.reloadData()
    }
    func updateDataInTableViewFavourite() {
        notes = RealmHandler.shared.returnFavouriteNotesInCategory(name: self.title!, inRealmObject: realm)
        NotesInCategoryTableView.reloadData()
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
        RealmHandler.shared.updateFavouriteForNote(ID: notes[notes.count - (1 + indexPath.row)].getID(), inRealmObject: realm)
        print("Marked as favourite")
    }
    
    private func handleChangeCategory(indexPath: IndexPath) {
        
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "AddToCategoryViewController") as! AddToCategoryViewController
        
        categoryDelegate = destinationVC
        
        guard let category = RealmHandler.shared.getCategoryWith(name: self.title!, inRealmObject: realm) else {
            return
        }
        
        guard let note = RealmHandler.shared.getNoteWith(ID: notes[notes.count - (1 + indexPath.row)].getID(), inRealmObject: realm) else {
            return
        }
        
        categoryDelegate.didChangeCategory(currCategory: category, currNote: note)
        
        destinationVC.noteDelegate = self
        
        present(destinationVC, animated: true, completion: nil)
    }
    
    private func handleMoveToTrash(indexPath: IndexPath) {
        
        RealmHandler.shared.deleteNoteWith(ID: notes[notes.count - (1 + indexPath.row)].getID(), inRealmObject: realm)
        
        notes = RealmHandler.shared.getAllNotesInCategoryWith(name: self.title!, inRealmObject: realm)
        
        NotesInCategoryTableView.beginUpdates()
        NotesInCategoryTableView.deleteRows(at: [indexPath], with: .fade)
        NotesInCategoryTableView.endUpdates()
        
        print("Moved to trash")
        
    }
    
    private func handleCreateReminder(indexPath: IndexPath) {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {success, error in
            if let err = error {
                print("error while requesting permission for notifications")
                return
            }
        })
        
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "CreateReminderViewController") as! CreateReminderViewController
        
        self.newNoteDelegate = destinationVC
        destinationVC.noteDelegate = self
        
        guard let note = RealmHandler.shared.getNoteWith(ID: notes[notes.count - (1 + indexPath.row)].getID(), inRealmObject: self.realm) else {
            return
        }

        newNoteDelegate.didCreateReminderOn(note: note)
        
        present(destinationVC, animated: true, completion: nil)
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal,
                                        title: "Favourite") { [weak self] (action, view, completionHandler) in
            self?.handleMarkAsFavourite(indexPath: indexPath)
            completionHandler(true)
        }
        action.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Reminder action
        let reminder = UIContextualAction(style: .normal,
                                          title: "Reminder") { [weak self] (action, view, completionHandler) in
            self?.handleCreateReminder(indexPath: indexPath)
            completionHandler(true)
        }
        reminder.backgroundColor = .systemGreen
        
        // Trash action
        let trash = UIContextualAction(style: .destructive,
                                       title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.handleMoveToTrash(indexPath: indexPath)
            completionHandler(true)
        }
        trash.backgroundColor = .systemRed
        
        // Add To Folder action
        let folder = UIContextualAction(style: .normal,
                                        title: "Change Category") { [weak self] (action, view, completionHandler) in
            self?.handleChangeCategory(indexPath: indexPath)
            completionHandler(true)
        }
        folder.backgroundColor = .systemOrange
        
        let configuration = UISwipeActionsConfiguration(actions: [trash, reminder, folder])
        
        return configuration
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped \(indexPath.row)")
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "NoteViewController") as! NoteViewController
        newNoteDelegate = destinationVC
        
        guard let note = RealmHandler.shared.getNoteWith(ID: notes[notes.count - (1 + indexPath.row)].getID(), inRealmObject: realm) else {
            return
        }
        newNoteDelegate.didCreateNoteWith(ID: note.getID())
        
        self.navigationController?.pushViewController(destinationVC, animated: true)
        
    }
    
}


extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = NotesInCategoryTableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)
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
        cell.textLabel?.text = "\(notes[notes.count - (1 + indexPath.row)].title) - \(notes[notes.count - (1 + indexPath.row)].getID())"
        
        return cell
    }
    
    
}

extension CategoryViewController: categoryActionDelegate {
    func didEditCategory(categories: Array<Category>) {
        return
    }
    
    func didCreateCategory(category: Category) {
        return
    }
    
    func didChangeCategory(currCategory: Category, currNote: Note) {
        return
    }
    
    func didEditCategory(category: Category) {
        return
    }
    
    func didSelectCategoryWith(name: String, notes: Array<Note>) {
        self.notes = notes
        self.title = name
    }
}


extension CategoryViewController: noteActionDelegate {
    func reloadData() {
        reloadTableBasedOnSegment()
    }
    
    func didCreateReminderOn(note: Note) {
        return
    }
    
    
    
    func didCreateNoteWith(ID: String) {
        return
    }
    
    
}


extension CategoryViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredNotes = []
        
        if searchText == "" {
            notes = RealmHandler.shared.getAllNotesInCategoryWith(name: self.title!, inRealmObject: realm)//.testSortByUpdatedAt()//.sortedByUpdatedAt()
            NotesInCategoryTableView.reloadData()
            return
        }
        
        for note in notes {
            if note.title.uppercased().contains(searchText.uppercased()) {
                filteredNotes.append(note)
            }
        }
        
        notes = filteredNotes
        self.NotesInCategoryTableView.reloadData()
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
