//
//  Note.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 26.01.22.
//

import Foundation
import RealmSwift

class Note: Object, Codable {
    @objc dynamic private var id = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var textHtmlString: String = ""
    @objc dynamic var createdAt: String = ""
    @objc dynamic var updatedAt: String = ""
    @objc dynamic var revisions: Int = 0
    @objc dynamic var favourite: Bool = false
    @objc dynamic var category: Category? = nil
    @objc dynamic var reminderDate: String?
    var photos = List<String>()
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case textHtmlString
        case createdAt
        case updatedAt
        case revisions
        case favourite
        case category
        case reminderDate
        case photos
    }
    
    required init() {}
    
    convenience init(title: String, htmlText: String, favourite: Bool, category: Category) {
        self.init()
        self.title = title
        self.textHtmlString = htmlText
        self.createdAt = Date().formatedToStringDate()
        self.updatedAt = createdAt
        self.revisions = 1
        self.favourite = favourite
        self.category = category
        self.reminderDate = nil
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)
        textHtmlString = try values.decode(String.self, forKey: .textHtmlString)
        createdAt = try values.decode(String.self, forKey: .createdAt)
        updatedAt = try values.decode(String.self, forKey: .updatedAt)
        revisions = try values.decode(Int.self, forKey: .revisions)
        favourite = try values.decode(Bool.self, forKey: .favourite)
        category = try? values.decodeIfPresent(Category.self, forKey: .category)
        reminderDate = try? values.decodeIfPresent(String.self, forKey: .reminderDate)
        photos = try values.decode(List<String>.self, forKey: .photos)
        
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

extension String {
    
    func toDate() -> Date? {
        let dateFormatter = DateFormatter().getDefaultDateFormatter()
        
        return dateFormatter.date(from: self)
    }
    
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


func dateFor(timeStamp: String) -> NSDate {
    let formater = DateFormatter()
    formater.dateFormat = "HH:mm:ss:SSS - MMM dd, yyyy"
    return formater.date(from: timeStamp)! as NSDate
}



