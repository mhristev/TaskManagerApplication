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

class RealmHandler {
    static let shared = RealmHandler()
    static var currUserID: String?
    
   // private let categories = try! Realm()
   // private let notes = try! Realm()
    
    
    func loadfirstConfiguration() {
        guard let uuid = RealmHandler.currUserID else {
            return
        }
        print(RealmHandler.currUserID)
        //let categories = try! Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
        let realm = try! Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
        
        if realm.objects(Category.self).isEmpty {
            do {
                try createCategoryWith(name: "Quick Notes", color: "#1E63FF", icon: "folder.fill", inRealmObject: realm)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    static func configurationHelper() -> Realm.Configuration {
        var config = Realm.Configuration()
        if let uuid = RealmHandler.shared.getCurrUserID() {
            config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(uuid).realm")
        }
        
        return config
    }
    

    
    func getCurrUserID() -> String? {
        return RealmHandler.currUserID
    }
    
    
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
        
            //let realm = try! Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
        print(inRealmObject.objects(Category.self))
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
    
}


