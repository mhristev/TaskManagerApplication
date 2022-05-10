//
//  CategoryActionDelegate.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 2.02.22.
//

import Foundation

protocol CategoryActionDelegate: AnyObject {
    func didEditCategory(categories: [Category])
    func didCreateCategory(category: Category)
    func didChangeCategory(currCategory: Category, currNote: Note)
    func didSelectCategoryWith(name: String, notes: [Note])
    func didEditCategory(category: Category)
}
