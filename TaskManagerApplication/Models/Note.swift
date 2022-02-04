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
    @objc dynamic var createdAt = NSDate()
    @objc dynamic var updatedAt = NSDate()
    @objc dynamic var revisions: Int = 0
    @objc dynamic var favourite: Bool = false
    @objc dynamic var category: Category? = nil
    @objc dynamic var attrStringData: Data?
    @objc dynamic var reminderDate: NSDate?
    
    
    convenience init(title: String, attrText: NSAttributedString, favourite: Bool, category: Category?) {
        self.init()
        self.title = title
        self.attrStringData = try? archiveAttrString(attrString: attrText)
        self.createdAt = NSDate()
        self.updatedAt = createdAt
        self.revisions = 1
        self.favourite = favourite
        self.category = category
        self.reminderDate = nil
    }
    
    func archiveAttrString(attrString: NSAttributedString) throws -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: attrString, requiringSecureCoding: false)
    }
    
    func unarchiveAttrString() throws -> NSAttributedString? {
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: self.attrStringData!)
    }
    
    func returnAttrDataAsString() -> String {
            if self.attrStringData != nil {
                let a = try? self.unarchiveAttrString()
                return a?.string ?? ""
            }
        return ""
        
    }
    
    
    func getID() -> String {
        return self.id
    }
    
    func getTitle() -> String{
        return self.title
    }
}
