//
//  File.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 10.02.22.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic private var id: String = ""
    @objc dynamic private var lastSeenAt: Date?

    convenience init(id: String) {
        self.init()
        self.id = id
        self.lastSeenAt = Date()
    }
    
    func updateLastSeen() {
        self.lastSeenAt = Date()
    }
    
    func getID() -> String {
        return self.id
    }
    
}
