//
//  RemindersChildWelcomeViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 17.01.22.
//

import UIKit
import RealmSwift


class RemindersChildHomeController: UIViewController {
    
    let realm = try! Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
    
    var reminders: Array<Note> = []
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        reminders = RealmHandler.shared.getAllReminders(inRealmObject: realm)
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
    
    override func viewDidAppear(_ animated: Bool) {
        print("MINAVAM OT TUK")
        reminders = RealmHandler.shared.getAllReminders(inRealmObject: realm)
        tableView.reloadData()
    }
    
    func test() {
        reminders = RealmHandler.shared.getAllReminders(inRealmObject: realm)
        tableView.reloadData()
    }

}

extension RemindersChildHomeController: UITableViewDelegate {
    
  

    private func handleMoveToTrash(indexPath: IndexPath) {
        
//        RealmHandler.shared.deleteCategoryWith(ID: categories[categories.count - (1 + indexPath.row)].getID(), inRealmObject: realm)
//        categories = RealmHandler.shared.getAllCategories(inRealmObject: realm)
//        print(categories)
//        tableView.beginUpdates()
//        tableView.deleteRows(at: [indexPath], with: .fade)
//        tableView.endUpdates()
        print("Moved to trash")
       
    }
    
    private func handleEdit(indexPath: IndexPath) {
//        //categoryTitle = categories[categories.count - (1 + indexPath.row)].getTitle()
//      // self.performSegue(withIdentifier: "editWindow", sender: self)
//
//        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "CreateCategoryViewController") as! CreateCategoryViewController
//
//            //self.selectionDelegate = destinationVC
//       // destinationVC.viewDidLoad()
//        selectionDelegate = destinationVC
//
//        guard let category = RealmHandler.shared.getCategoryWith(name: categories[categories.count - (1 + indexPath.row)].getName(), inRealmObject: realm) else {
//            return
//        }
//
//
//        selectionDelegate.didEditCategory(category: category)
//        //destinationVC.vc = self
//
//        destinationVC.categoryDelegate = self
//       // self.navigationController?.pushViewController(destinationVC, animated: true)
//        present(destinationVC, animated: true, completion: nil)
        print("Edit")
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


extension RemindersChildHomeController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return reminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReminderTableViewCell.identifier, for: indexPath) as! ReminderTableViewCell
        
        
        let f = DateFormatter()
        f.dateFormat = "dd, MMM, YYYY"
        
        let p = f.string(from: reminders[reminders.count - (1+indexPath.row)].reminderDate! as Date)
        
        cell.configureWith(title: reminders[reminders.count - (1 + indexPath.row)].getTitle(), imageName: "", date: p)
        
        
        return cell
    }
    
}



