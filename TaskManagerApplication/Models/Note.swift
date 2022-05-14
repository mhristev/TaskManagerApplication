//
//  Note.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 26.01.22.
//

import Foundation
import RealmSwift
import UIKit

class NoteWrapper: Codable {
    private var _id: String = ""
    var id: String {
        get {
            return self._id
        }
        set {
            self._id = newValue
        }
    }
    private var _title: String = ""
    var title: String {
        get {
            return self._title
        }
        set {
            self._title = newValue
        }
    }
    private var _textHtmlString: String = ""
    var textHtmlString: String {
        get {
            return self._textHtmlString
        }
        set {
            self._textHtmlString = newValue
        }
    }
    private var _createdAt: String = ""
    var createdAt: String {
        get {
            return self._createdAt
        }
        set {
            self._createdAt = newValue
        }
    }
    private var _updatedAt: String = ""
    var updatedAt: String {
        get {
            return self._updatedAt
        }
        set {
            self._updatedAt = newValue
        }
    }
    private var _revisions: Int = 0
    var revisions: Int {
        get {
            return self._revisions
        }
        set {
            self._revisions = newValue
        }
    }
    private var _favourite: Bool = false
    var favourite: Bool {
        get {
            return self._favourite
        }
        set {
            self._favourite = newValue
        }
    }
    private var _categoryID: String = ""
    var categoryID: String {
        get {
            return self._categoryID
        }
        set {
            self._categoryID = newValue
        }
    }
    private var _reminderDate: String?
    var reminderDate: String? {
        get {
            return self._reminderDate
        }
        set {
            self._reminderDate = newValue
        }
    }

    init() {}

    // swiftlint:disable identifier_name
    enum CodingKeys: String, CodingKey {
        case _id
        case _title
        case _textHtmlString
        case _createdAt
        case _updatedAt
        case _revisions
        case _favourite
        case _categoryID
        case _reminderDate
    }
    // swiftlint:enable identifier_name

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: ._id)
        title = try values.decode(String.self, forKey: ._title)
        textHtmlString = try values.decode(String.self, forKey: ._textHtmlString)
        createdAt = try values.decode(String.self, forKey: ._createdAt)
        updatedAt = try values.decode(String.self, forKey: ._updatedAt)
        revisions = try values.decode(Int.self, forKey: ._revisions)
        favourite = try values.decode(Bool.self, forKey: ._favourite)
        categoryID = try values.decode(String.self, forKey: ._categoryID)
        reminderDate = try? values.decodeIfPresent(String.self, forKey: ._reminderDate)
    }

}

extension NoteWrapper: Equatable {
    static func == (note1: NoteWrapper, note2: NoteWrapper) -> Bool {
        return note1.id == note2.id && note1.updatedAt == note2.updatedAt
    }
}

class Note: Object, Codable {

    @objc dynamic private var _id: String = ""
    var id: String {
        get {
            return self._id
        }
        set {
            return self._id = newValue
        }
    }
    @objc dynamic private var _title: String = ""
    var title: String {
        get {
            return self._title
        }
        set {
            return self._title = newValue
        }
    }
    @objc dynamic private var _textHtmlString: String = ""
    var textHtmlString: String {
        get {
            return self._textHtmlString
        }
        set {
            return self._textHtmlString = newValue
        }
    }
    @objc dynamic private var _createdAt: String = ""
    var createdAt: String {
        get {
            return self._createdAt
        }
        set {
            return self._createdAt = newValue
        }
    }
    @objc dynamic private var _updatedAt: String = ""
    var updatedAt: String {
        get {
            return self._updatedAt
        }
        set {
            return self._updatedAt = newValue
        }
    }
    @objc dynamic private var _revisions: Int = 0
    var revisions: Int {
        get {
            return self._revisions
        }
        set {
            return self._revisions = newValue
        }
    }
    @objc dynamic private var _favourite: Bool = false
    var favourite: Bool {
        get {
            return self._favourite
        }
        set {
            return self._favourite = newValue
        }
    }
    @objc dynamic private var _category: Category?
    var category: Category? {
        get {
            return self._category
        }
        set {
            return self._category = newValue
        }
    }
    @objc dynamic private var _reminderDate: String?
    var reminderDate: String? {
        get {
            return self._reminderDate
        }
        set {
            return self._reminderDate = newValue
        }
    }
    private var _photos = List<String>()
    var photos: List<String> {
        get {
            return self._photos
        }
        set {
            self._photos = newValue
        }
    }

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

    convenience init(id: String, title: String, htmlText: String,
                     createdAt: String, updatedAt: String, revisions: Int,
                     favourite: Bool, category: Category?, reminderDate: String?) {
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

    func html2AttrString() -> NSAttributedString? {

        return self.textHtmlString.html2AttributedString

    }

    func toWrapper() -> NoteWrapper {
        let wrapper = NoteWrapper()

        guard let category = self.category else { return wrapper }

        wrapper.id = self.id
        wrapper.title = self.title
        wrapper.categoryID = category.id
        wrapper.textHtmlString = self.textHtmlString
        wrapper.createdAt = self.createdAt
        wrapper.updatedAt = self.updatedAt
        wrapper.revisions = self.revisions
        wrapper.favourite = self.favourite
        wrapper.reminderDate = self.reminderDate

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
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html],
                                          documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
}
