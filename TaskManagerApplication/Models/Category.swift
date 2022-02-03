//
//  Category.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 24.01.22.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    @objc dynamic var icon: String = ""
    
    convenience init(name: String, color: String, icon: String) {
        self.init()
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
    
    func getID() -> String {
        return id
    }
    
}
