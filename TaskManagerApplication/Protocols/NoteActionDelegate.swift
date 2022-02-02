//
//  NoteActionDelegate.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 2.02.22.
//

import Foundation

protocol noteActionDelegate {
    func didCreateNoteWith(ID: String)
    func didUpdateNoteCategory(notes: Array<Note>)
}
