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
    
    private let categories = try! Realm()
    private let notes = try! Realm()
    
    private init() {
        if categories.objects(Category.self).isEmpty {
            do {
                try createCategoryWith(name: "Quick Notes", color: "#1E63FF", icon: "folder.fill")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func doesExistCategoryWith(name: String) -> Bool {
        return (categories.objects(Category.self).filter("name == %@", name).first != nil)
    }
    
    
    func createCategoryWith(name: String, color: String, icon: String) throws {
        print(categories.configuration.fileURL!.path)
        
        if doesExistCategoryWith(name: name) {
            throw RealmError.existCategory
        }
        
        
        try! categories.write() {
            categories.add(Category(name: name, color: color, icon: icon))
        }
    }
    
    func deleteCategoryWith(ID: String) {
        if let category = categories.objects(Category.self).filter("id == %@", ID).first {
            let notesInCategory = getAllNotesInCategoryWith(name: category.getName())
            
            try! notes.write() {
                notes.delete(notesInCategory)
            }
           
            try! categories.write() {
                categories.delete(category)
            }
     
        }
    }
    
    func getAllCategories() -> Array<Category> {
        return Array(categories.objects(Category.self))
    }
    
    func getAllNotesInCategoryWith(name: String) -> Array<Note> {
        //print(notes.objects(Note.self).filter("category.title == %@", name))
        return Array(notes.objects(Note.self).filter("category.name == %@", name))
    }
    
    func getCategoryWith(name: String) -> Category? {
        return categories.objects(Category.self).filter("name == %@", name).first
    }
    
    func updateCategoryWith(ID: String, name: String, icon: String, color: String) {
        if let category = categories.objects(Category.self).filter("id == %@", ID).first {
            try! categories.write() {
                //categories.beginWrite()
                category.name = name
                category.icon = icon
                category.color = color
               // try! categories.commitWrite()
            }
        }
    }
    

    func createNoteWith(title: String, text: NSAttributedString, favourite: Bool, categoryTitle: String) {
        print(notes.configuration.fileURL!.path)
        
        if let foundCategory = categories.objects(Category.self).filter("name == %@", categoryTitle).first {
            try! notes.write() {
                notes.add(Note(title: title, attrText: text, favourite: favourite, category: foundCategory))
            }
        }
    
    }
    
    func updateNoteWith(ID: String, title: String, attrText: NSAttributedString, favourite: Bool) {
        if let note = notes.objects(Note.self).filter("id == %@", ID).first {
            
            try! notes.write() {
                note.attrStringData = try! note.archiveAttrString(attrString: attrText)
                note.title = title
                note.favourite = favourite
                note.updatedAt = NSDate()
                note.revisions += 1
            }
            
           
        }
    }
    

    
    func getNoteWith(name: String) -> Note? {
        return notes.objects(Note.self).filter("title == %@", name).first
    }
    
    func getNoteWith(ID: String) -> Note? {
        return notes.objects(Note.self).filter("id == %@", ID).first
    }
    
    func deleteNoteWith(ID: String) {
        if let note = categories.objects(Note.self).filter("id == %@", ID).first {
            try! notes.write() {
                notes.delete(note)
            }
        }
    }
    
    func updateNotesCategory(note: Note, category: Category) {
        if let note = categories.objects(Note.self).filter("id == %@", note.id).first {
            try! categories.write() {
                note.category = category
            }
        }
    }
    
}



