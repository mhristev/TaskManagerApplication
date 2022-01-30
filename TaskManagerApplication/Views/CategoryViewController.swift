//
//  CategoryListViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 15.01.22.
//

import UIKit


protocol createNoteDelegate {
    func didCreateNoteWith(ID: String)
    func didUpdateNoteCategory(notes: Array<Note>)
}

/*protocol categoriesDelegate {
    func addToCategory()
}*/

class CategoryViewController: UIViewController {
    
    var newNoteDelegate: createNoteDelegate!
    
    var categoryDelegate: categoryActionDelegate!

    var notes: Array<Note> = []
   // var categoryName: String = ""
    
    @IBOutlet var NotesInCategoryTableView: UITableView!
    @IBOutlet var titleCategory: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // notes = RealmHandler.shared.getAllNotesForCategory(name: self.title ?? "")
        //NotesInCategoryTableView.beginUpdates()
        //NotesInCategoryTableView.endUpdates()

        
       // guard self.title != nil else {
         //   return
       // }
       // self.categoryName = self.title!
        
       // notes = RealmHandler.shared.getAllNotesForCategory(name: self.title!)
        NotesInCategoryTableView.delegate = self
        NotesInCategoryTableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    

    @IBAction func createNote(_ sender: Any) {
        
        //notes.append("New note")
       
       // NotesInCategoryTableView.beginUpdates()
        RealmHandler.shared.createNoteWith(title: "", text: "", favourite: false, categoryTitle: self.title)
        notes = RealmHandler.shared.getAllNotesForCategory(name: self.title!)
        NotesInCategoryTableView.reloadData()
        //NotesInCategoryTableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
        //NotesInCategoryTableView.endUpdates()
        
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "NoteViewController") as! NoteViewController
        newNoteDelegate = destinationVC

        guard let note = RealmHandler.shared.getNoteWith(name: "") else {
            return
        }

        newNoteDelegate.didCreateNoteWith(ID: note.id)
        
        self.navigationController?.pushViewController(destinationVC, animated: true)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.notes = RealmHandler.shared.getAllNotesForCategory(name: self.title!)
        NotesInCategoryTableView.reloadData()
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




extension CategoryViewController: UITableViewDelegate {
    private func handleMarkAsFavourite() {
        print("Marked as favourite")
    }

    private func handleAddToFolder(indexPath: IndexPath) {
        
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "AddToCategoryViewController") as! AddToCategoryViewController
        
        //selectionDelegate = destinationVC
        categoryDelegate = destinationVC
        
        guard let category = RealmHandler.shared.getCategoryWith(name: self.title ?? "") else {
            return
        }
        
        guard let note = RealmHandler.shared.getNoteWith(ID: notes[notes.count - (1 + indexPath.row)].getID()) else {
            return
        }
        
        categoryDelegate.didChangeCategory(currCategory: category, currNote: note)
        
        destinationVC.noteDelegate = self
      
        present(destinationVC, animated: true, completion: nil)
        
        
        
        //self.performSegue(withIdentifier: "addToFolder", sender: self)
       // print("Perform add to folder")
    }

    private func handleMoveToTrash(indexPath: IndexPath) {
        //NotesInCategoryTableView.beginUpdates()
        RealmHandler.shared.deleteNoteWith(ID: notes[notes.count - (1 + indexPath.row)].getID())
        notes = RealmHandler.shared.getAllNotesForCategory(name: self.title!)
        NotesInCategoryTableView.beginUpdates()
        NotesInCategoryTableView.deleteRows(at: [indexPath], with: .fade)
        NotesInCategoryTableView.endUpdates()
        
        print("Moved to trash")
       
    }

    private func handleCreateReminder() {
        self.performSegue(withIdentifier: "showCreateReminder", sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal,
                                        title: "Favourite") { [weak self] (action, view, completionHandler) in
                                            self?.handleMarkAsFavourite()
                                            completionHandler(true)
        }
        action.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Reminder action
        let reminder = UIContextualAction(style: .normal,
                                         title: "Reminder") { [weak self] (action, view, completionHandler) in
                                            self?.handleCreateReminder()
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
                                       title: "Add to folder") { [weak self] (action, view, completionHandler) in
                                        self?.handleAddToFolder(indexPath: indexPath)
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
        
        guard let note = RealmHandler.shared.getNoteWith(name: notes[notes.count - (1 + indexPath.row)].getTitle()) else {
            return
        }
        //print(note.id)
        newNoteDelegate.didCreateNoteWith(ID: note.id)
        
        self.navigationController?.pushViewController(destinationVC, animated: true)
        //self.performSegue(withIdentifier: "clickNoteToView", sender: self)
    }
    
    
}


extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = NotesInCategoryTableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)
        print(notes)
        
        cell.textLabel?.text = notes[notes.count - (1 + indexPath.row)].getTitle() 
        return cell
    }
    
    
}

extension CategoryViewController: categorySelectionDelegate {
    func didEditCategory(category: Category) {
        return
    }
    
    func didSelectCategoryWith(name: String, notes: Array<Note>) {
       // self.navigationItem.title = "hjhhhj"
        self.notes = notes
        self.title = name
    }
}


extension CategoryViewController: createNoteDelegate {
    func didUpdateNoteCategory(notes: Array<Note>) {
        print("PROTOCOL")
        self.notes = notes
        self.NotesInCategoryTableView.reloadData()
    }
    
    func didCreateNoteWith(ID: String) {
        return
    }
    
    
}