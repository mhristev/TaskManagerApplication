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
    @objc dynamic var title: String = ""
    @objc dynamic var color: String = ""
    @objc dynamic var icon: String = ""
    
    convenience init(title: String, color: String, icon: String) {
        self.init()
        self.title = title
        self.color = color
        self.icon = icon
    }
    
 
    
    
    func getTitle() -> String {
        return title
    }
    
    func getColor() -> String {
        return color
    }
    
    func getID() -> String {
        return id
    }
    
}
