//
//  CreateCategoryViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 23.01.22.
//

import UIKit
import RealmSwift



class CreateCategoryViewController: UIViewController {
    
    var categoryDelegate: categoryActionDelegate!
    var realm: Realm {
            get {
                do {
                    let realm = try Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
                    return realm
                }
                catch {
                    print("Could not access database: ", error)
                }
                return self.realm
            }
        }
    var editCategory: Category? = nil
    
    @IBOutlet var createCategoryButton: UIButton!
    
    @IBOutlet var titleViewController: UILabel!
    @IBOutlet var buttonCreate: UIButton!
    
    
    @IBOutlet var colorButtons: [UIButton]!
    
    @IBOutlet var iconButtons: [UIButton]!
    
    @IBOutlet var nameOfCategory: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (editCategory != nil) {
            titleViewController.text = "Edit Category"
            nameOfCategory.text = editCategory?.getName()
            buttonCreate.setTitle("Edit", for: .normal)
            for button in colorButtons {
                if (hexStringFromColor(color: button.backgroundColor!) == editCategory?.color) {
                    button.layer.borderWidth = 2
                    button.layer.borderColor = UIColor(named: "colorSelector")?.cgColor
                    break
                }
            }
            
            for icon in iconButtons {
                if (icon.restorationIdentifier == editCategory?.icon) {
                    icon.tintColor = .blue
                    icon.layer.borderColor = UIColor(named: "iconSelectorColor")?.cgColor
                    icon.layer.borderWidth = 2
                    break
                }
            }
            
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func colorSelected(_ sender: UIButton) {
        colorButtons.forEach({$0.layer.borderWidth = 0})
        sender.layer.borderWidth = 2
        sender.layer.borderColor = UIColor(named: "colorSelector")?.cgColor
        
    }
    
    @IBAction func iconSelected(_ sender: UIButton) {
        
        
        for button in iconButtons {
            button.tintColor = UIColor.label
            button.layer.borderWidth = 0
        }
        
        
        sender.tintColor = .blue
        sender.layer.borderColor = UIColor(named: "iconSelectorColor")?.cgColor
        sender.layer.borderWidth = 2
        
    }
    
    
    @IBAction func createCategory(_ sender: UIButton) {
        var icon: String = ""
        var color: String = ""
        
        for button in iconButtons {
            
            if button.layer.borderWidth == 2 {
                
                guard let name = button.restorationIdentifier else {
                    return
                }
                
                icon = name
                
            }
        }
        
        for button in colorButtons {
            if button.layer.borderWidth == 2 {
                
                guard let buttonColor = button.backgroundColor else {
                    return
                }
                color = hexStringFromColor(color: buttonColor)
            }
        }
        
        guard let name = nameOfCategory.text else {
            return
        }
        
        if (icon == "" || name == "" || color == "") {
            dialogWindow(message: "Please fill all the fields!", title: "Error")
            return
        }
        
        if (editCategory == nil) {
            let category = Category(name: name, color: color, icon: icon)
            categoryDelegate.didCreateCategory(category: category)
        } else {
            guard let editCategory = editCategory else { return }
            RealmHandler.updateCategoryWith(ID: editCategory.id, name: name, icon: icon, color: color, inRealmObject: realm)
            let categories = RealmHandler.getAllCategories(inRealmObject: realm)
            categoryDelegate.didEditCategory(categories: categories)
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func dialogWindow(message: String, title: String) {
        
        let myalert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        myalert.addAction(UIAlertAction(title: "Dismiss", style: .default,
                                        handler: {_ in
        }))
        
        
        present(myalert, animated: true)
        
    }
    
    
}

extension CreateCategoryViewController{
    func hexStringFromColor(color: UIColor) -> String {
        let components = color.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        
        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        return hexString
    }
    
    
}

extension UIColor {
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
}


extension CreateCategoryViewController: categoryActionDelegate {
    func didEditCategory(categories: Array<Category>) {
        return
    }
    
    func didCreateCategory(category: Category) {
        return
    }
    
    func didChangeCategory(currCategory: Category, currNote: Note) {
        return
    }
    
    func didSelectCategoryWith(name: String, notes: Array<Note>) {
        return
    }
    
    func didEditCategory(category: Category) {
        self.editCategory = category
    }
}
