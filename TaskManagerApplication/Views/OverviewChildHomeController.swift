//
//  OverviewChildWelcomeController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 17.01.22.
//

import UIKit

class OverviewChildHomeController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var nameOfCategories: [String] = ["Quick notes"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.becomeFirstResponder()
        //view.addSubview(swag)
        //tableView.delegate = self
        //tableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    func createCategory(withName: String) {
        nameOfCategories.append(withName)
        print(nameOfCategories)
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath.init(row: 1, section: 0)], with: .automatic)
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
        
        if indexPath.row == 0 {
            return
        }
        tableView.beginUpdates()
        nameOfCategories.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
        print("Moved to trash")
       
    }
    
    private func handleEdit(indexPath: IndexPath) {
        print("Edit")
    }

  
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped \(indexPath.row)")
        
        self.performSegue(withIdentifier: "test", sender: self)
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
        return nameOfCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = nameOfCategories[nameOfCategories.count - 1]
        return cell
    }
}
