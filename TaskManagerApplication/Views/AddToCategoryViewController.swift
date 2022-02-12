//
//  AddToCategoryViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 30.01.22.
//

import UIKit
import RealmSwift

class AddToCategoryViewController: UIViewController {
    let realm = try! Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
    var categories: Array<Category> = []
    var currCategory: Category!
    var currNote: Note!
    
    var noteDelegate: noteActionDelegate!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    
}

extension AddToCategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.identifier, for: indexPath) as! CategoryTableViewCell
        cell.configureWith(title: categories[categories.count - (1+indexPath.row)].getName(),
                           imageName: categories[categories.count-(1+indexPath.row)].icon,
                           color: OverviewChildHomeController.hexStringToUIColor(hex: categories[categories.count-(1+indexPath.row)].getColor()))
        
        if cell.titleLabel.text == currCategory.getName() {
            cell.isUserInteractionEnabled = false
            cell.titleLabel.isEnabled = false
        }
        
        
        
        return cell
    }
}


extension AddToCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped \(indexPath.row)")
        if let newCategory = RealmHandler.shared.getCategoryWith(name: categories[categories.count - (1+indexPath.row)].getName(), inRealmObject: realm) {
            RealmHandler.shared.update(note: currNote, inCategory: newCategory, inRealmObject: realm)
        }
        
        noteDelegate.reloadData()
        
        dismiss(animated: true, completion: nil)
    }
}


extension AddToCategoryViewController: categoryActionDelegate {
    func didSelectCategoryWith(name: String, notes: Array<Note>) {
        return
    }
    
    func didEditCategory(category: Category) {
        return
    }
    
    func didEditCategory(categories: Array<Category>) {
        return
    }
    
    func didCreateCategory(category: Category) {
        return
    }
    
    func didChangeCategory(currCategory: Category, currNote: Note) {
        self.currCategory = currCategory
        self.currNote = currNote
        self.categories = RealmHandler.shared.getAllCategories(inRealmObject: realm)
    }
    
    
}
