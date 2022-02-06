//
//  Note.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 26.01.22.
//

import Foundation
import RealmSwift

class Note: Object {
    @objc dynamic private var id = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var textHtmlString: String = ""
    @objc dynamic var createdAt = NSDate()
    @objc dynamic var updatedAt = NSDate()
    @objc dynamic var revisions: Int = 0
    @objc dynamic var favourite: Bool = false
    @objc dynamic var category: Category? = nil
    @objc dynamic var reminderDate: NSDate?
    
    
    convenience init(title: String, htmlText: String, favourite: Bool, category: Category) {
        self.init()
        self.title = title
        self.textHtmlString = htmlText
        self.createdAt = NSDate()
        self.updatedAt = createdAt
        self.revisions = 1
        self.favourite = favourite
        self.category = category
        self.reminderDate = nil
    }
    
    
    func getID() -> String {
        return self.id
    }
    
//    func getTitle() -> String {
//        return self.title
//    }
//
//    func getCreatedAt() -> NSDate {
//        return self.createdAt
//    }
//
//    func getUpdatedAt() -> NSDate {
//        return self.updatedAt
//    }
//
//    func getRevisions() -> Int {
//        return self.revisions
//    }
//    
//    func getFavourite() -> Bool {
//        return self.favourite
//    }
//
//    func getCategory() -> Category {
//        return self.category
//    }
//
//    func getAttrStringData() -> Data? {
//        return self.attrStringData
//    }
//    func getReminderDate() -> NSDate? {
//        return self.reminderDate
//    }

    /*
    func archiveAttrString(attrString: NSAttributedString) throws -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: attrString, requiringSecureCoding: false)
    }
    */
    func html2AttrString() -> NSAttributedString? {
        return self.textHtmlString.html2AttributedString
    }
    /*
    func returnAttrDataAsString() -> String {
            if self.attrStringData != nil {
                let a = try? self.unarchiveAttrString()
                return a?.string ?? ""
            }
        return ""
        
    }*/
    
    
   
}

extension StringProtocol {
    var html2AttributedString: NSAttributedString? {
        Data(utf8).html2AttributedString
    }
}


extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
}
