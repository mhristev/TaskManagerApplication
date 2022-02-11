//
//  NotificationCenter.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 5.02.22.
//

import Foundation
import UserNotifications


class NotificationHelper {
    
    static func removeAllPendingNotificationsIn(reminders: Array<Note>) {
        for reminder in reminders {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.getID()])
        }
    }
    
    static func createPendingNotificationsIn(reminders: Array<Note>) {
        for reminder in reminders {
            
            guard let date = reminder.reminderDate  else {
                return
            }
            
            NotificationHelper.createNewNotificationWith(title: reminder.title, date: date, ID: reminder.getID())
            
        }
    }
    
    static func createNewNotificationWith(title: String, date: String, ID: String) {
        
        let content = UNMutableNotificationContent()
    
        content.title = title
        content.sound = .default
        content.body = "You have a new reminder for \(title)"
        
        guard let targetDate = date.toDate() else {
            return
        }
    
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: targetDate), repeats: false)
        
        
        
        let request = UNNotificationRequest(identifier: ID, content: content, trigger: trigger)
        
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if error != nil {
                print("something went wrong")
            }
        })
    }
    
    static func removeNotificationWithID(ID: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [ID])
    }
    
}
