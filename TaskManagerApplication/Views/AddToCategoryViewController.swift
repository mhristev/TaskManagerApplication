//
//  AddToCategoryViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 30.01.22.
//

import UIKit

class AddToCategoryViewController: UIViewController {
    
    var categories: Array<Category> = []
    var currCategory: Category!
    var currNote: Note!
    
    var noteDelegate: createNoteDelegate!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        // Do any additional setup after loading the view.
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

extension AddToCategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.identifier, for: indexPath) as! CategoryTableViewCell
        cell.configureWith(title: categories[categories.count - (1+indexPath.row)].getTitle(),
                           imageName: categories[categories.count-(1+indexPath.row)].icon,
                           color: OverviewChildHomeController.hexStringToUIColor(hex: categories[categories.count-(1+indexPath.row)].getColor()))
        
        if cell.titleLabel.text == currCategory.getTitle() {
            cell.isUserInteractionEnabled = false
            cell.titleLabel.isEnabled = false
        }
        

        
        return cell
    }
}


extension AddToCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped \(indexPath.row)")
        if let newCategory = RealmHandler.shared.getCategoryWith(name: categories[categories.count - (1+indexPath.row)].getTitle()) {
            RealmHandler.shared.updateNoteCategory(note: currNote, category: newCategory)
        }
        
        noteDelegate.didUpdateNoteCategory(notes: RealmHandler.shared.getAllNotesForCategory(name: currCategory.getTitle()))
        
        dismiss(animated: true, completion: nil)
    }
}


extension AddToCategoryViewController: categoryActionDelegate {
    func didEditCategory(categories: Array<Category>) {
        return
    }
    
    func didCreateCategory(category: Category) {
        return
    }
    
    func didChangeCategory(currCategory: Category, currNote: Note) {
        self.currCategory = currCategory
        self.currNote = currNote
        self.categories = RealmHandler.shared.getAllCategories()
    }
    
    
}