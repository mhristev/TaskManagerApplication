//
//  CategoryActionDelegate.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 2.02.22.
//

import Foundation

protocol categoryActionDelegate {
    func didEditCategory(categories: Array<Category>)
    func didCreateCategory(category: Category)
    func didChangeCategory(currCategory: Category, currNote: Note)
    func didSelectCategoryWith(name: String, notes: Array<Note>)
    func didEditCategory(category: Category)
}
