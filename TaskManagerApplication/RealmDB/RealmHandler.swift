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
    
    func createNoteWith(title: String, text: String, createdAt: NSDate, favourite: Bool) {
        print(notes.configuration.fileURL!.path)
        notes.beginWrite()
        notes.add(Note(title: title, text: text, createdAt: createdAt, favourite: favourite))
        try! notes.commitWrite()
    }
    
}
