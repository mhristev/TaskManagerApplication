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
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    @objc dynamic var icon: String = ""
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case color
        case icon
    }
    
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
    
    func getID() -> String {
        return id
    }
    
    
    
}
