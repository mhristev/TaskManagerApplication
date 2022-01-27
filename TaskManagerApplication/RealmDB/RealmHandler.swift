//
//  RealmHandler.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 26.01.22.
//

import Foundation
import RealmSwift

class RealmHandler {
    static let shared = RealmHandler()
    
    private let categories = try! Realm()
    private let notes = try! Realm()
    
    func createCategoryWith(title: String, color: String, icon: String) {
        print(categories.configuration.fileURL!.path)
        categories.beginWrite()
        categories.add(Category(title: title, color: color, icon: icon))
        try! categories.commitWrite()
    }
    
    func createNoteWith(title: String, text: String, favourite: Bool, categoryTitle: String?) {
        print(notes.configuration.fileURL!.path)
        
        
        if categoryTitle != nil {
            let foundCategory = categories.objects(Category.self).filter("title == %@", categoryTitle!).first
            notes.beginWrite()
            notes.add(Note(title: title, text: text, favourite: favourite, category: foundCategory))
            try! notes.commitWrite()
        } else {
            let note = Note()
            note.title = title
            note.text = text
            note.favourite = favourite
            note.category = nil
            
            notes.beginWrite()
            notes.add(note)
            try! notes.commitWrite()
        }
        
    }
    
    
    func getAllCategories() -> Array<Category> {
        return Array(categories.objects(Category.self))
    }
    
    func getAllNotesForCategory(name: String) -> Array<Note> {
        print(notes.objects(Note.self).filter("category.title == %@", name))
        return Array(notes.objects(Note.self).filter("category.title == %@", name))
    }
    
    func getCategoryWith(name: String) -> Category? {
        let cat = categories.objects(Category.self).filter("title == %@", name).first
        
        guard cat != nil else {
            return nil
        }
        
        return cat
    }
    
    func updateCategoryWith(ID: String) {
        if let category = categories.objects(Category.self).filter("id == %@", ID).first {
            categories.beginWrite()
            category.title = "PROMENENO SUM"
            try! categories.commitWrite()
        }
    }
    
    func deleteCategoryWith(ID: String) {
        if let category = categories.objects(Category.self).filter("id == %@", ID).first {
            let notesInCategory = getAllNotesForCategory(name: category.getTitle())
            
            notes.beginWrite()
            notes.delete(notesInCategory)
            try! notes.commitWrite()

            categories.beginWrite()
            categories.delete(category)
            try! categories.commitWrite()
        }
    }
    
    
    
}
