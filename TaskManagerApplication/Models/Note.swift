//
//  Note.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 26.01.22.
//

import Foundation
import RealmSwift

class Note: Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var text: String = ""
    @objc dynamic var createdAt = NSDate()
    @objc dynamic var updatedAt = NSDate()
    @objc dynamic var revisions: Int = 0
    @objc dynamic var favourite: Bool = false
    
    convenience init(title: String, text: String, createdAt: NSDate, favourite: Bool) {
        self.init()
        self.title = title
        self.text = text
        self.createdAt = createdAt
        self.updatedAt = createdAt
        self.revisions = 1
        self.favourite = favourite
    }
}
