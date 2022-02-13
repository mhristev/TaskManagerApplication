//
//  OverviewChildWelcomeController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 17.01.22.
//

import UIKit
import RealmSwift


protocol categorySelectionDelegate {
    func didSelectCategoryWith(name: String, notes: Array<Note>)
    func didEditCategory(category: Category)
}

class OverviewChildHomeController: UIViewController {
    
    let realm = try! Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
    
    var selectionDelegate: categoryActionDelegate!
    
    @IBOutlet var tableView: UITableView!
    
    var categoryTitle: String?
    let refreshControl = UIRefreshControl()
    
    var categories: Array<Category> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirestoreHandler.fetchAllCategories { categories in
            if categories.count > 0 {
                RealmHandler.shared.handleFetchedCategories(cloudCategories: categories)
                self.categories = RealmHandler.shared.getAllCategories(inRealmObject: self.realm)
                self.tableView.reloadData()
            } else {
                let localCategories = RealmHandler.shared.getAllCategories(inRealmObject: self.realm)
                for category in localCategories {
                    FirestoreHandler.upload(category: category)
                }
            }
            
            FirestoreHandler.fetchAllNotes { noteWrappers in
                if noteWrappers.count > 0 {
                    RealmHandler.shared.handleFetchedNotes(wrappers: noteWrappers)
                }
            }
            
        }
        
        
        categories = RealmHandler.shared.getAllCategories(inRealmObject: realm)
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
    }
    
    
    @objc func refresh(_ sender: AnyObject) {
        FirestoreHandler.fetchAllCategories { categories in
            RealmHandler.shared.handleFetchedCategories(cloudCategories: categories)

            FirestoreHandler.fetchAllNotes { noteWrappers in
                RealmHandler.shared.handleFetchedNotes(wrappers: noteWrappers)
                
                self.categories = RealmHandler.shared.getAllCategories(inRealmObject: self.realm)
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    @IBAction func createCategory(_ sender: UIButton) {
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "CreateCategoryViewController") as! CreateCategoryViewController
        
        destinationVC.categoryDelegate = self
        present(destinationVC, animated: true, completion: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.refreshControl.endRefreshing()
    }
    
    
}

extension OverviewChildHomeController: UITableViewDelegate {
    
    
    
    private func handleMoveToTrash(indexPath: IndexPath) {
        
        RealmHandler.shared.deleteCategoryWith(ID: categories[categories.count - (1 + indexPath.row)].getID(), inRealmObject: realm)
        categories = RealmHandler.shared.getAllCategories(inRealmObject: realm)
        
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
        print("Moved to trash")
    }
    
    private func handleEdit(indexPath: IndexPath) {
        
        
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "CreateCategoryViewController") as! CreateCategoryViewController
        
        selectionDelegate = destinationVC
        
        guard let category = RealmHandler.shared.getCategoryWith(name: categories[categories.count - (1 + indexPath.row)].getName(), inRealmObject: realm) else {
            return
        }
        
        
        selectionDelegate.didEditCategory(category: category)
        
        destinationVC.categoryDelegate = self
        present(destinationVC, animated: true, completion: nil)
        print("Edit")
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped \(indexPath.row)")
        
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "CategoryViewController") as! CategoryViewController
        selectionDelegate = destinationVC
        
        
        let passTitle = categories[categories.count - (1 + indexPath.row)].getName()
        
        let notes = RealmHandler.shared.getAllNotesInCategoryWith(name: passTitle, inRealmObject: realm)
        selectionDelegate.didSelectCategoryWith(name: passTitle, notes: notes)
        
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let trash = UIContextualAction(style: .destructive,
                                       title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.handleMoveToTrash(indexPath: indexPath)
            completionHandler(true)
        }
        trash.backgroundColor = .systemRed
        
        let edit = UIContextualAction(style: .normal,
                                      title: "Edit") { [weak self] (action, view, completionHandler) in
            self?.handleEdit(indexPath: indexPath)
            completionHandler(true)
        }
        edit.backgroundColor = .brown
        
        
        let configuration = UISwipeActionsConfiguration(actions: [trash, edit])
        
        return configuration
    }
}


extension OverviewChildHomeController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.identifier, for: indexPath) as! CategoryTableViewCell
        cell.configureWith(title: "\(categories[categories.count - (1+indexPath.row)].getName()) - \(categories[categories.count - (1+indexPath.row)].getID())",
                           imageName: categories[categories.count-(1+indexPath.row)].icon,
                           color: OverviewChildHomeController.hexStringToUIColor(hex: categories[categories.count-(1+indexPath.row)].getColor()))
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.identifier) as! CategoryTableViewCell
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        cell.configureWith(title: "\(categories[0].getName()) - \(categories[0].getID())", imageName: categories[0].icon, color: OverviewChildHomeController.hexStringToUIColor(hex: categories[0].getColor()))
        
        cell.addGestureRecognizer(tapRecognizer)
        return cell
        
    }
    
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer) {
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "CategoryViewController") as! CategoryViewController
        selectionDelegate = destinationVC
        
        
        let passTitle = categories[0].getName()
        
        let notes = RealmHandler.shared.getAllNotesInCategoryWith(name: passTitle, inRealmObject: realm)
        
        selectionDelegate.didSelectCategoryWith(name: passTitle, notes: notes)
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
}

extension OverviewChildHomeController {
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
}


extension OverviewChildHomeController: categoryActionDelegate {
    func didSelectCategoryWith(name: String, notes: Array<Note>) {
        return
    }
    
    func didEditCategory(category: Category) {
        return
    }
    
    func didChangeCategory(currCategory: Category, currNote: Note) {
        return
    }
    
    
    func didCreateCategory(category: Category) {
        do {
            try RealmHandler.shared.createCategoryWith(name: category.name, color: category.color, icon: category.icon, inRealmObject: realm)
            
        } catch {
            print("creating didcreatecategory error")
        }
        
        self.categories = RealmHandler.shared.getAllCategories(inRealmObject: realm)
        tableView.reloadData()
    }
    
    func didEditCategory(categories: Array<Category>) {
        self.categories = categories
        tableView.reloadData()
    }
}
