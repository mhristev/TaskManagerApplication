//
//  Note.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 26.01.22.
//

import Foundation
import RealmSwift

class Note: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var text: String = ""
    @objc dynamic var createdAt = NSDate()
    @objc dynamic var updatedAt = NSDate()
    @objc dynamic var revisions: Int = 0
    @objc dynamic var favourite: Bool = false
    @objc dynamic var category: Category? = nil
    
    
    
    
    
    
    convenience init(title: String, text: String, favourite: Bool, category: Category?) {
        self.init()
        self.title = title
        self.text = text
        self.createdAt = NSDate()
        self.updatedAt = createdAt
        self.revisions = 1
        self.favourite = favourite
        self.category = category
    }
    
    func getID() -> String {
        return self.id
    }
    
    func getTitle() -> String{
        return self.title
    }
}
