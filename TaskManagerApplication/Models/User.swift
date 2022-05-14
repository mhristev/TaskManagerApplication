//
//  File.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 10.02.22.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic private var _id: String = ""
    var id: String {
        get {
            return self._id
        }
        set {
            self._id = newValue
        }
    }
    @objc dynamic private var _lastSeenAt: Date?
    var lastSeenAt: Date? {
        get {
            return self._lastSeenAt
        }
        set {
            self._lastSeenAt = newValue
        }
    }

    convenience init(id: String) {
        self.init()
        self.id = id
        self.lastSeenAt = Date()
    }

    func updateLastSeen() {
        self.lastSeenAt = Date()
    }

}
