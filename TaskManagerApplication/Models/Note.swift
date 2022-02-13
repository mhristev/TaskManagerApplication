//
//  Note.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 26.01.22.
//

import Foundation
import RealmSwift

class NoteWrapper: Codable {
    var id: String = ""
    var title: String = ""
    var textHtmlString: String = ""
    var createdAt: String = ""
    var updatedAt: String = ""
    var revisions: Int = 0
    var favourite: Bool = false
    var categoryID: String = ""
    var reminderDate: String?
    var photos = List<String>()
    
    init() {}
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case textHtmlString
        case createdAt
        case updatedAt
        case revisions
        case favourite
        case categoryID
        case reminderDate
        case photos
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
        categoryID = try values.decode(String.self, forKey: .categoryID)
        reminderDate = try? values.decodeIfPresent(String.self, forKey: .reminderDate)
        photos = try values.decode(List<String>.self, forKey: .photos)
    }
    

}



class Note: Object, Codable {
    @objc dynamic private var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var textHtmlString: String = ""
    @objc dynamic var createdAt: String = ""
    @objc dynamic var updatedAt: String = ""
    @objc dynamic var revisions: Int = 0
    @objc dynamic var favourite: Bool = false
    @objc dynamic var category: Category? = nil
    @objc dynamic var reminderDate: String?
    var photos = List<String>()
    
    
    convenience init(title: String, htmlText: String, favourite: Bool, category: Category) {
        self.init()
        self.id = UUID().uuidString
        self.title = title
        self.textHtmlString = htmlText
        self.createdAt = Date().formatedToStringDate()
        self.updatedAt = createdAt
        self.revisions = 1
        self.favourite = favourite
        self.category = category
        self.reminderDate = nil
    }
    
    convenience init(id: String, title: String, htmlText: String, createdAt: String, updatedAt: String, revisions: Int, favourite: Bool, category: Category?, reminderDate: String?) {
        self.init()
        self.id = id
        self.title = title
        self.textHtmlString = htmlText
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.revisions = revisions
        self.favourite = favourite
        self.category = category
        self.reminderDate = reminderDate
    }
    
   
    
    func getID() -> String {
        return self.id
    }
    
    func set(ID: String) {
        self.id = ID
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
    
    func html2AttrString() -> NSAttributedString? {
        return self.textHtmlString.html2AttributedString
    }
    
    func toWrapper() -> NoteWrapper {
        let wrapper = NoteWrapper()
        
        wrapper.id = self.id
        wrapper.title = self.title
        wrapper.categoryID = self.category!.id
        wrapper.textHtmlString = self.textHtmlString
        wrapper.createdAt = self.createdAt
        wrapper.updatedAt = self.updatedAt
        wrapper.revisions = self.revisions
        wrapper.favourite = self.favourite
        wrapper.reminderDate = self.reminderDate
        wrapper.photos = self.photos
        
        return wrapper
    }
    
    
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

