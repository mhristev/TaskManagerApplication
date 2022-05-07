//
//  CurrentUserDelegate.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 3.02.22.
//

import Foundation

protocol currentUserDelegate: AnyObject {
    func setCurrentUserID(uuid: String)
}
