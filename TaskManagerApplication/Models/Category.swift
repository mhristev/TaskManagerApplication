//
//  Category.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 24.01.22.
//

import Foundation
import RealmSwift
import FirebaseFirestoreSwift

class Category: Object, Codable {
    @objc dynamic private var _id: String = ""
    var id: String {
        get {
            return self._id
        }
        set {
            self._id = newValue
        }
    }

    @objc dynamic private var _name: String = ""
    var name: String {
        get {
            return self._name
        }
        set {
            self._name = newValue
        }
    }

    @objc dynamic private var _color: String = ""
    var color: String {
        get {
            return self._color
        }
        set {
            return self._color = newValue
        }
    }

    @objc dynamic private var _icon: String = ""
    var icon: String {
        get {
            return self._icon
        }
        set {
            return self._icon = newValue
        }
    }
    // swiftlint:disable identifier_name
    enum CodingKeys: String, CodingKey {
        case _id
        case _name
        case _color
        case _icon
    }
    // swiftlint:enable identifier_name

    convenience init(name: String, color: String, icon: String) {
        self.init()
        self.id = UUID().uuidString
        self.name = name
        self.color = color
        self.icon = icon
    }

    convenience init(id: String, name: String, color: String, icon: String) {
        self.init()
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
    }

    func getName() -> String {
        return name
    }

    func getColor() -> String {
        return color
    }

}
