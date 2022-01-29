//
//  OverviewChildWelcomeController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 17.01.22.
//

import UIKit

protocol categorySelectionDelegate {
    func didSelectCategoryWith(name: String, notes: Array<Note>)
}

class OverviewChildHomeController: UIViewController {
    
    var selectionDelegate: categorySelectionDelegate!
    
    @IBOutlet var tableView: UITableView!
    
    var categoryTitle: String?
    
  //  var nameOfCategories: [String] = ["Quick notes"]
    var categories: Array<Category> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        categories = RealmHandler.shared.getAllCategories()
        print(categories)
        
        //self.becomeFirstResponder()
        //view.addSubview(swag)
        //tableView.delegate = self
        //tableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    func createCategoryWith(name: String, color: String, icon: String) {
        RealmHandler.shared.createCategoryWith(title: name, color: color, icon: icon)
        categories = RealmHandler.shared.getAllCategories()
        print(categories)
        
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
        tableView.endUpdates()
        
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

extension OverviewChildHomeController: UITableViewDelegate {
    
  

    private func handleMoveToTrash(indexPath: IndexPath) {
        
        RealmHandler.shared.deleteCategoryWith(ID: categories[categories.count - (1 + indexPath.row)].getID())
        categories = RealmHandler.shared.getAllCategories()
        print(categories)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
        print("Moved to trash")
       
    }
    
    private func handleEdit(indexPath: IndexPath) {
        categoryTitle = categories[categories.count - (1 + indexPath.row)].getTitle()
        self.performSegue(withIdentifier: "editWindow", sender: self)
        print("Edit")
    }

  
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped \(indexPath.row)")
        //RealmHandler.shared.createNoteWith(title: "Swag Note", text: "Ne", favourite: false, category: categories[categories.count - (1 + indexPath.row)])
       // RealmHandler.shared.getAllNotesForCategory(name: categories[categories.count - (1 + indexPath.row)].getTitle())
        //let destinationVC = CategoryViewController()
//        RealmHandler.shared.createQuickNoteWith(title: "Quick note", text: "swag", favourite: false)
       // RealmHandler.shared.updateCategoryWith(ID: categories[categories.count - (1 + indexPath.row)].getID())
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "CategoryViewController") as! CategoryViewController
        selectionDelegate = destinationVC
        //destinationVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
       // destinationVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        let passTitle = categories[categories.count - (1 + indexPath.row)].getTitle()
        let notes = RealmHandler.shared.getAllNotesForCategory(name: passTitle)
        //destinationVC.title = "\(categories[categories.count - (1 + indexPath.row)])"
        selectionDelegate.didSelectCategoryWith(name: passTitle, notes: notes)
        self.navigationController?.pushViewController(destinationVC, animated: true)
       // present(destinationVC, animated: true, completion: nil)
        
        //self.performSegue(withIdentifier: "test", sender: self)
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
        
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = categories[categories.count-(1+indexPath.row)].getTitle()
       // cell.contentView.backgroundColor = stringToUIColorWith(hex: categories[categories.count - 1].getColor())
        //cell.backgroundColor = .red
        print(categories[categories.count-1].getColor())
        cell.contentView.backgroundColor = hexStringToUIColor(hex: categories[categories.count-(1+indexPath.row)].getColor())
        return cell
    }
}

extension OverviewChildHomeController {
    func hexStringToUIColor (hex:String) -> UIColor {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "test" {
            if let kid = segue.destination as? CategoryViewController {
                selectionDelegate = kid
                //kid.title = categoryTitle

            }
        } else if (segue.identifier == "editWindow") {
            if let editCategory = segue.destination as? CreateCategoryViewController {
                print(categoryTitle)
                print("heree")
                editCategory.editNameCategory = categoryTitle
                editCategory.title = "Edit Category"
                
            }
        }
    }
}


