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
    var realm: Realm {
            get {
                do {
                    let realm = try Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
                    return realm
                }
                catch {
                    print("Could not access database: ", error)
                }
                return self.realm
            }
        }
    
    @IBOutlet var favSegment: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        reminders = RealmHandler.getAllRemindersForThisWeek(inRealmObject: realm)
        
    }
    
    @IBAction func favouriteFilter(_ sender: UISegmentedControl) {
        
        if favSegment.selectedSegmentIndex == 0 {
            reminders = RealmHandler.getAllRemindersForThisWeek(inRealmObject: realm)
            tableView.reloadData()
        } else {
            reminders = RealmHandler.returnFavouriteReminders(inRealmObject: realm)
            tableView.reloadData()
        }
    }
    
    
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
        
        
        cell.configureWith(title: reminders[reminders.count - (1 + indexPath.row)].title, date: out)
        
        
        
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


