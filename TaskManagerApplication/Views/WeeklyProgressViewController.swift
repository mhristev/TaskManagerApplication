//
//  WeeklyProgressViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 7.02.22.
//

import UIKit
import RealmSwift

class WeeklyProgressViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    var reminders: [Note] = []
    let realm = try! Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
    
    @IBOutlet var favSegment: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        FirestoreHandler.fetchAllNotes()
        tableView.dataSource = self
       tableView.delegate = self
        reminders = RealmHandler.shared.getAllRemindersForThisWeek(inRealmObject: realm)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func favouriteFilter(_ sender: UISegmentedControl) {
        
        if favSegment.selectedSegmentIndex == 0 {
            reminders = RealmHandler.shared.getAllRemindersForThisWeek(inRealmObject: realm)
            tableView.reloadData()
        } else {
            reminders = RealmHandler.shared.returnFavouriteReminders(inRealmObject: realm)
            tableView.reloadData()
        }
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

extension WeeklyProgressViewController: UITableViewDelegate {
    
}

extension WeeklyProgressViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReminderTableViewCell.identifier, for: indexPath) as! ReminderTableViewCell
        
        
        var out = reminders[reminders.count - (1+indexPath.row)].reminderDate!
        
        if let categoryName = reminders[reminders.count - (1+indexPath.row)].category?.name  {
            out = "\(out) (\(categoryName))"
        }
        
        
        cell.configureWith(title: reminders[reminders.count - (1 + indexPath.row)].title, imageName: "", date: out)
        
     
        
        guard let convertedDate = reminders[reminders.count - (1+indexPath.row)].reminderDate!.toDate() else {
            return cell
        }
        
        
        if Date() > (convertedDate) {
            cell.isUserInteractionEnabled = false
            cell.titleLabel.isEnabled = false
            cell.dateLabel.isEnabled = false
            cell.checkBox.tintColor = .gray
        }
        
        
        return cell
    }
    
    
}


