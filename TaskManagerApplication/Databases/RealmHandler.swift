//
//  RealmHandler.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 26.01.22.
//

import UIKit
import Foundation
import RealmSwift

class RealmHandler {
    static let shared = RealmHandler()
    static var currUserID: String?
    
    
    init() {}
    
    
    func registerUserWith(id: String) {
        let userTable = try! Realm()
        
        if let user = userTable.objects(User.self).filter("id == %@", id).first {
            if userTable.objects(User.self).count < 4 {
                try! userTable.write() {
                    user.updateLastSeen()
                }
            }
        } else {
            if userTable.objects(User.self).count > 2 {
                if let oldUser = userTable.objects(User.self).sorted(byKeyPath: "lastSeenAt").first {
                    self.deleteConfigurationForUser(id: oldUser.getID())
                    try! userTable.write() {
                        userTable.delete(oldUser)
                        
                    }
                    
                }
            }
            try! userTable.write() {
                userTable.add(User(id: id))
            }
        }
    }
    
    func deleteConfigurationForUser(id: String) {
        var config = Realm.Configuration()
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(id).realm")
        do {
            try FileManager.default.removeItem(at: config.fileURL!)
        } catch {
            print("help")
        }
    }
    
    func loadfirstConfiguration(andSetUserID: String) {
        self.setCurrentUser(ID: andSetUserID)
        self.registerUserWith(id: andSetUserID)
        
        
        let realm = try! Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
        
        
        if realm.isEmpty {
            self.createCategoryWith(name: "Quick Notes", color: "#1E63FF", icon: "folder.fill", inRealmObject: realm)
        }
        
        
    }
    
    func setCurrentUser(ID: String) {
        RealmHandler.currUserID = ID
    }
    
    static func configurationHelper() -> Realm.Configuration {
        var config = Realm.Configuration()
        
        
        guard let uid = RealmHandler.currUserID else {
            return config
        }
        
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(uid).realm")
        
        return config
    }
    
    
    func doesExistCategoryWith(name: String, inRealmObject: Realm) -> Bool {
        return (inRealmObject.objects(Category.self).filter("name == %@", name).first != nil)
    }
    
    func getCategoryWith(ID: String, inRealmObject: Realm) -> Category? {
        if let category = inRealmObject.objects(Category.self).filter("id == %@", ID).first {
            return category
        }
        
        return nil
    }
    
    func createCategoryWith(name: String, color: String, icon: String, inRealmObject: Realm) {
        print(inRealmObject.configuration.fileURL!.path)
        
        if doesExistCategoryWith(name: name, inRealmObject: inRealmObject) {
            print("this category exist")
            return
        }
        
        let category = Category(name: name, color: color, icon: icon)
        
        if name != "Quick Notes" {
            FirestoreHandler.upload(category: category)
        }
        
        try! inRealmObject.write() {
            inRealmObject.add(category)
        }
        
    }
    
    func deleteCategoryWith(ID: String, inRealmObject: Realm) {
        if let category = inRealmObject.objects(Category.self).filter("id == %@", ID).first {
            let notesInCategory = getAllNotesInCategoryWith(name: category.getName(), inRealmObject: inRealmObject)
            
            for note in notesInCategory {
                if note.reminderDate != nil {
                    NotificationHelper.removeNotificationWithID(ID: note.getID())
                }
            }
            
            try! inRealmObject.write() {
                inRealmObject.delete(notesInCategory)
            }
            
            FirestoreHandler.delete(category: category)
            
            try! inRealmObject.write() {
                inRealmObject.delete(category)
            }
        }
    }
    
    func getAllCategories(inRealmObject: Realm) -> Array<Category> {
        return Array(inRealmObject.objects(Category.self))
    }
    
    func getAllNotesInCategoryWith(name: String, inRealmObject: Realm) -> Array<Note> {
        self.clearEmtyNotes(inRealmObject: inRealmObject)
        return Array(inRealmObject.objects(Note.self).filter("category.name == %@", name)).sortedByUpdatedAt()
    }
    
    func clearEmtyNotes(inRealmObject: Realm) {
        // TO DO
        // convert htmlString to string and compare to empty string
        //        let emtyNotes = inRealmObject.objects(Note.self).filter("textHtmlString == %@", "")
        //        for note in emtyNotes {
        //            try! inRealmObject.write() {
        //                inRealmObject.delete(note)
        //            }
        //        }
    }
    
    func getCategoryWith(name: String, inRealmObject: Realm) -> Category? {
        return inRealmObject.objects(Category.self).filter("name == %@", name).first
    }
    
    func updateCategoryWith(ID: String, name: String, icon: String, color: String, inRealmObject: Realm) {
        if let category = inRealmObject.objects(Category.self).filter("id == %@", ID).first {
            
            FirestoreHandler.delete(category: category)
            
            
            try! inRealmObject.write() {
                category.name = name
                category.icon = icon
                category.color = color
            }
            
            FirestoreHandler.upload(category: category)
        }
    }
    
    
    func createNoteWith(title: String, text: NSAttributedString, favourite: Bool, categoryName: String, inRealmObject: Realm) {
        print(inRealmObject.configuration.fileURL!.path)
        
        if let foundCategory = inRealmObject.objects(Category.self).filter("name == %@", categoryName).first {
            
            guard let htmlString = text.toHtmlString() else {
                return
            }
            
            try! inRealmObject.write() {
                inRealmObject.add(Note(title: title, htmlText: htmlString, favourite: favourite, category: foundCategory))
            }
        }
        
    }
    
    func updateNoteWith(ID: String, title: String, attrText: NSAttributedString, inRealmObject: Realm) {
        if let note = inRealmObject.objects(Note.self).filter("id == %@", ID).first {
            
            
            if (note.title != title) {
                if let date = note.reminderDate {
                    NotificationHelper.removeNotificationWithID(ID: ID)
                    NotificationHelper.createNewNotificationWith(title: title, date: date, ID: ID)
                }
            }
            
            guard let htmlString = attrText.toHtmlString() else {
                return
            }
            
            try! inRealmObject.write() {
                note.textHtmlString = htmlString
                note.title = title
                note.updatedAt = Date().formatedToStringDate()
                note.revisions += 1
            }
            
            
            FirestoreHandler.upload(note: note)
            
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
            
            
            if note.reminderDate != nil {
                NotificationHelper.removeNotificationWithID(ID: note.getID())
            }
            
            FirestoreHandler.delete(note: note)
            
            try! inRealmObject.write() {
                inRealmObject.delete(note)
            }
        }
    }
    
    func update(note: Note, inCategory: Category, inRealmObject: Realm) {
        if let note = inRealmObject.objects(Note.self).filter("id == %@", note.getID()).first {
            try! inRealmObject.write() {
                note.category = inCategory
            }
        }
    }
    
    func createReminderAndNotificationForNote(withID: String, andDate: String, inRealmObject: Realm) {
        print(inRealmObject.configuration.fileURL!.path)
        if let note = inRealmObject.objects(Note.self).filter("id == %@", withID).first {
            try! inRealmObject.write() {
                note.reminderDate = andDate
            }
            NotificationHelper.createNewNotificationWith(title: note.title, date: andDate, ID: note.getID())
        }
    }
    
    func getAllReminders(inRealmObject: Realm) -> Array<Note> {
        cleanOldReminders(inRealmObject: inRealmObject)
        return Array(inRealmObject.objects(Note.self).filter("reminderDate != null")).returnDatesAfterToday()
    }
    
    func getAllRemindersForThisWeek(inRealmObject: Realm) -> [Note] {
        cleanOldReminders(inRealmObject: inRealmObject)
        return Array(inRealmObject.objects(Note.self).filter("reminderDate != null")).onlyThisWeek()
    }
    
    func returnFavouriteReminders(inRealmObject: Realm) -> Array<Note> {
        return Array(inRealmObject.objects(Note.self).filter("reminderDate != null && favourite = 1")).sortedByRemindersDate()//.sortedByRemindersDate()
    }
    
    
    
    
    func cleanOldReminders(inRealmObject: Realm) {
        
        let today = Date()
        
        for oldReminder in inRealmObject.objects(Note.self)
                                        .filter("reminderDate != null") {
            
            guard let day = oldReminder.reminderDate else {
                return
            }
            
            guard let convertDate = day.toDate() else {
                return
            }
            
            if today > convertDate {
                if isInCurrentWeek(date: convertDate) == false {
                    try! inRealmObject.write() {
                        oldReminder.reminderDate = nil
                    }
                }
            }
            
        }
        
        
    }
    
    func removeReminderAndNotificationForNote(withID: String, inRealmObject: Realm) {
        if let note = inRealmObject.objects(Note.self)
                                   .filter("id == %@", withID)
                                   .first {
            try! inRealmObject.write() {
                note.reminderDate = nil
            }
            NotificationHelper.removeNotificationWithID(ID: withID)
        }
    }
    
    func updateFavouriteForNote(ID: String, inRealmObject: Realm) {
        if let note = inRealmObject.objects(Note.self)
                                   .filter("id == %@", ID)
                                   .first {
            if note.favourite {
                try! inRealmObject.write() {
                    note.favourite = false
                }
            } else {
                try! inRealmObject.write() {
                    note.favourite = true
                }
            }
            
        }
    }
    
    
    
    func returnFavouriteNotesInCategory(name: String, inRealmObject: Realm) -> Array<Note> {
        let results: Results<Note> = inRealmObject.objects(Note.self)
                                                  .filter("category.name == %@", name)
                                                  .filter("favourite == 1")
        
        return Array(results).sortedByUpdatedAt()
    }
    
    func addPhotoToNoteWith(ID: String, photoURL: String, inRealmObject: Realm) {
        let note = inRealmObject.objects(Note.self)
                                .filter("id == %@", ID)
                                .first
        
        try! inRealmObject.write() {
            note?.photos.append(photoURL)
        }
    }
    
    func getAllPhotosinNoteWith(ID: String, inRealmObject: Realm) -> [String]? {
        if let note = inRealmObject.objects(Note.self).filter("id == %@", ID).first {
            clearOldImagesIn(note: note, inRealmObject: inRealmObject)
            return Array(note.photos)
        }
        return nil
    }
    
    func clearOldImagesIn(note: Note, inRealmObject: Realm) {
        var i = 0
        for photo in note.photos {
            if let url = URL(string: photo) {
                if returnImageFor(url: url) == nil {
                    try! inRealmObject.write() {
                        note.photos.remove(at: i)
                    }
                    i -= 1
                }
            }
            i += 1
        }
    }
    
    
    func createLocalFromCloud(categories: [Category], inRealmObject: Realm ) {
        for category in categories {
            let cat = Category(id: category.id, name: category.name, color: category.color, icon: category.icon)
            try! inRealmObject.write() {
                inRealmObject.add(cat)
            }
        }
    }
    
    func handleFetchedCategories(cloudCategories: [Category]) {
        
        let realm = try! Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
        
        let localCategories = RealmHandler.shared.getAllCategories(inRealmObject: realm)
        
        // returns categories that are in the cloud but not in the local storage
        let differenceFromLocal = Array(Set(cloudCategories).subtracting(Set(localCategories)))
        
        var toCreateLocally: [Category] = []
        
        
        var flag = false
        
        for cloudCat in differenceFromLocal {
            for localcat in localCategories {
                if localcat.id == cloudCat.id {
                    flag = true
                    // ASK user if he wants the local or the cloud settings for the given category
                    try! realm.write() {
                        localcat.name = cloudCat.name
                        localcat.color = cloudCat.color
                        localcat.icon = cloudCat.icon
                    }
                    break
                }
                if localcat.name == "Quick Notes" && cloudCat.name == "Quick Notes" {
                    flag = true
                    try! realm.write() {
                        localcat.id = cloudCat.id
                        localcat.name = cloudCat.name
                        localcat.color = cloudCat.color
                        localcat.icon = cloudCat.icon
                    }
                    break
                }
            }
            if flag {
                flag = false
            } else {
                toCreateLocally.append(cloudCat)
            }
        }
        self.createLocalFromCloud(categories: toCreateLocally, inRealmObject: realm)
        
        let toPushToCloud = Array(Set(localCategories).subtracting(Set(cloudCategories)))
        
        for category in toPushToCloud {
            //FirestoreHandler.upload(category: category)
        }
        
        
    }
    
    
}


func returnImageFor(url: URL) -> UIImage? {
    
    let data = try? Data(contentsOf: url)
    if let imageData = data {
        if let image = UIImage(data: imageData) {
            return image
        } else {
            print("image not found!")
        }
    }
    
    return nil
    
}


func isInCurrentWeek(date: Date) -> Bool {
    var startDate = Date()
    var interval : TimeInterval = 0.0
    let calendar = Calendar.current
    // calendar.firstWeekday = 1 set the index of the first weekday if necessary
    calendar.dateInterval(of: .weekOfYear, start: &startDate, interval: &interval, for: Date())
    let endDate = calendar.date(byAdding:.second, value: Int(interval), to: startDate)!
    return date >= startDate && date < endDate
    
}


extension DateFormatter {
    func getDefaultDateFormatter() -> DateFormatter {
        self.dateFormat = "dd MMM yyyy, HH:mm:ss"
        return self
    }
}

extension Date {
    func formatedToStringDate() -> String {
        let dateFormatter = DateFormatter().getDefaultDateFormatter()
        return dateFormatter.string(from: self)
    }
}


extension Array where Element : NoteWrapper {
    func toNotes() -> [Note] {
        var result: [Note] = []
        
        let realm = try! Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
        
        for res in self {
            let note = Note()
            note.set(ID: res.id)
            note.title = res.title
            note.category = RealmHandler.shared.getCategoryWith(ID: res.categoryID, inRealmObject: realm)
            note.textHtmlString = res.textHtmlString
            note.createdAt = res.createdAt
            note.updatedAt = res.updatedAt
            note.revisions = res.revisions
            note.favourite = res.favourite
            note.reminderDate = res.reminderDate
            note.photos = res.photos
            
            result.append(note)
        }
        
        return result
    }
}



extension Array where Element: Note {
    
    
    func toNoteWrapper() -> [NoteWrapper] {
        var result: [NoteWrapper] = []
        
        self.forEach {
            let wrapper = $0.toWrapper()
            result.append(wrapper)
        }
        
        return result
    }
    
    
    func onlyThisWeek() -> [Note] {
        var result: [Note] = []
        
        self.forEach {
            guard let date = $0.reminderDate?.toDate() else {
                return
            }
            if isInCurrentWeek(date: date) {
                result.append($0)
            }
        }
        return result
    }
    
    
    func sortedByUpdatedAt() -> [Note] {
        return self.sorted {
            $0.updatedAt.toDate()! < $1.updatedAt.toDate()!
        }
    }
    
    func sortedByRemindersDate() -> [Note] {
        return self.sorted {
            $0.reminderDate!.toDate()! < $1.reminderDate!.toDate()!
        }
    }
    
    func returnDatesAfterToday() -> [Note] {
        var result: [Note] = []
        
        self.forEach {
            guard let date = $0.reminderDate?.toDate() else {
                return
            }
            
            if date > Date() {
                result.append($0)
            }
        }
        return result
    }
    
}
