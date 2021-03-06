//
//  NoteActionDelegate.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 2.02.22.
//

import Foundation

protocol NoteActionDelegate: AnyObject {
    func didCreateNoteWith(ID: String)
    func didCreateReminderOn(note: Note)
    func reloadData()
}
