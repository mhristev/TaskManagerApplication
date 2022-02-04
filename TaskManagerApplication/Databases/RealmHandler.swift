//
//  RealmHandler.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 26.01.22.
//

enum RealmError: Error {
    case existCategory
}

import Foundation
import RealmSwift
import Firebase

class RealmHandler {
    static let shared = RealmHandler()
    static var currUserID: String?
    
    
   // private let categories = try! Realm()
   // private let notes = try! Realm()
    
    
    func loadfirstConfiguration(andSetUserID: String) {
        self.setCurrentUser(ID: andSetUserID)
        
//        print(self.currUserID)
        //let categories = try! Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
        let realm = try! Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
        
        if realm.isEmpty {
            do {
                try createCategoryWith(name: "Quick Notes", color: "#1E63FF", icon: "folder.fill", inRealmObject: realm)
            } catch {
                print(error.localizedDescription)
            }
        }
        
       
    }
    
    func setCurrentUser(ID: String) {
        RealmHandler.currUserID = ID
    }
    
    static func configurationHelper() -> Realm.Configuration {
        var config = Realm.Configuration()
    
      //  if let user = Auth.auth().currentUser {
        
        guard let uid = RealmHandler.currUserID else {
            return config
        }
            
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(uid).realm")

        //}

        
        return config
    }
    

    
//    func getCurrUserID() -> String? {
//        return self.currUserID
//    }
    
    
    
    
    func doesExistCategoryWith(name: String, inRealmObject: Realm) -> Bool {
        return (inRealmObject.objects(Category.self).filter("name == %@", name).first != nil)
    }
    
    
    func createCategoryWith(name: String, color: String, icon: String, inRealmObject: Realm) throws {
        print(inRealmObject.configuration.fileURL!.path)
        
        if doesExistCategoryWith(name: name, inRealmObject: inRealmObject) {
            throw RealmError.existCategory
        }
        
        
        try! inRealmObject.write() {
            inRealmObject.add(Category(name: name, color: color, icon: icon))
        }
    }
    
    func deleteCategoryWith(ID: String, inRealmObject: Realm) {
        if let category = inRealmObject.objects(Category.self).filter("id == %@", ID).first {
            let notesInCategory = getAllNotesInCategoryWith(name: category.getName(), inRealmObject: inRealmObject)
            
            try! inRealmObject.write() {
                inRealmObject.delete(notesInCategory)
            }
           
            try! inRealmObject.write() {
                inRealmObject.delete(category)
            }
     
        }
    }
    
    func getAllCategories(inRealmObject: Realm) -> Array<Category> {
        
       // let realm = try! Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
        //print(inRealmObject.objects(Category.self))
        return Array(inRealmObject.objects(Category.self))
    }
    
    func getAllNotesInCategoryWith(name: String, inRealmObject: Realm) -> Array<Note> {
        return Array(inRealmObject.objects(Note.self).filter("category.name == %@", name))
    }
    
    func getCategoryWith(name: String, inRealmObject: Realm) -> Category? {
        return inRealmObject.objects(Category.self).filter("name == %@", name).first
    }
    
    func updateCategoryWith(ID: String, name: String, icon: String, color: String, inRealmObject: Realm) {
        if let category = inRealmObject.objects(Category.self).filter("id == %@", ID).first {
            try! inRealmObject.write() {
                category.name = name
                category.icon = icon
                category.color = color
            }
        }
    }
    

    func createNoteWith(title: String, text: NSAttributedString, favourite: Bool, categoryName: String, inRealmObject: Realm) {
        print(inRealmObject.configuration.fileURL!.path)
        
        if let foundCategory = inRealmObject.objects(Category.self).filter("name == %@", categoryName).first {
            try! inRealmObject.write() {
                inRealmObject.add(Note(title: title, attrText: text, favourite: favourite, category: foundCategory))
            }
        }
    
    }
    
    func updateNoteWith(ID: String, title: String, attrText: NSAttributedString, favourite: Bool, inRealmObject: Realm) {
        if let note = inRealmObject.objects(Note.self).filter("id == %@", ID).first {
           
            
            if (note.getTitle() != title) {
                if let date = note.reminderDate {
                    let center = UNUserNotificationCenter.current()
                    center.removePendingNotificationRequests(withIdentifiers: [ID])
                    
                    let content = UNMutableNotificationContent()
                
                    content.title = title
                    content.sound = .default
                    content.body = "You have a new reminder for \(title)"
                    
                    let targetDate = date as Date
                   // let targetDate = Date().addingTimeInterval(60)
                    
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day, .month, .year], from: targetDate), repeats: false)
                    
                    
                    
                    let request = UNNotificationRequest(identifier: ID, content: content, trigger: trigger)
                    
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                        if error != nil {
                            print("something went wrong")
                        }
                    })
                 
                }
            }
            
            try! inRealmObject.write() {
                note.attrStringData = try! note.archiveAttrString(attrString: attrText)
                note.title = title
                note.favourite = favourite
                note.updatedAt = NSDate()
                note.revisions += 1
            }
            
        }
    }
    

    
    func getNoteWith(name: String, inRealmObject: Realm) -> Note? {
        return inRealmObject.objects(Note.self).filter("title == %@", name).first
    }
    
    func getNoteWith(ID: String, inRealmObject: Realm) -> Note? {
        return inRealmObject.objects(Note.self).filter("id == %@", ID).first
    }
    
    func deleteNoteWith(ID: String, inRealmObject: Realm) {
        if let note = inRealmObject.objects(Note.self).filter("id == %@", ID).first {
            try! inRealmObject.write() {
                inRealmObject.delete(note)
            }
        }
    }
    
    func update(note: Note, inCategory: Category, inRealmObject: Realm) {
        if let note = inRealmObject.objects(Note.self).filter("id == %@", note.id).first {
            try! inRealmObject.write() {
                note.category = inCategory
            }
        }
    }
    
    func createReminderForNote(withID: String, andDate: NSDate, inRealmObject: Realm) {
        print(inRealmObject.configuration.fileURL!.path)
        if let note = inRealmObject.objects(Note.self).filter("id == %@", withID).first {
            try! inRealmObject.write() {
                note.reminderDate = andDate
            }
        }
    }
    
    func getAllReminders(inRealmObject: Realm) -> Array<Note> {
        cleanOldReminders(inRealmObject: inRealmObject)
        return Array(inRealmObject.objects(Note.self).filter("reminderDate != null"))
    }
    
    
    func cleanOldReminders(inRealmObject: Realm) {
        let today = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
            for oldReminder in inRealmObject.objects(Note.self).filter("reminderDate != null") {
                if today > (oldReminder.reminderDate! as Date) {
                    try! inRealmObject.write() {
                        oldReminder.reminderDate = nil
                    }
                }
            }
        

    }
    
    func removeReminderForNote(withID: String, inRealmObject: Realm) {
        if let note = inRealmObject.objects(Note.self).filter("id == %@", withID).first {
            try! inRealmObject.write() {
                note.reminderDate = nil
            }
            
            let center = UNUserNotificationCenter.current()
            
            center.removePendingNotificationRequests(withIdentifiers: [note.getID()])
            
        }
    }
    
}


