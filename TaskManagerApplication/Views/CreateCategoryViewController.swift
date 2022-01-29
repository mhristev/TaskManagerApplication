//
//  CreateCategoryViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 23.01.22.
//

import UIKit

protocol categoryActionDelegate {
    func didEditCategory(categories: Array<Category>)
    func didCreateCategory(category: Category)
}


class CreateCategoryViewController: UIViewController {

    var categoryDelegate: categoryActionDelegate!
    
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
            nameOfCategory.text = editCategory?.title
            buttonCreate.setTitle("Edit", for: .normal)
            for button in colorButtons {
                if (hexStringFromColor(color: button.backgroundColor!) == editCategory?.color) {
                    button.layer.borderWidth = 2
                    button.layer.borderColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1).cgColor
                    break
                }
            }
            
            for icon in iconButtons {
                if (icon.restorationIdentifier == editCategory?.icon) {
                    icon.tintColor = .blue
                    break
                }
            }
            
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func colorSelected(_ sender: UIButton) {
        colorButtons.forEach({$0.layer.borderWidth = 0})
        sender.layer.borderWidth = 2
        sender.layer.borderColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1).cgColor
        
    }
    
    @IBAction func iconSelected(_ sender: UIButton) {
        iconButtons.forEach({$0.tintColor = .white})
        sender.tintColor = .blue
    }
    
    
    @IBAction func createCategory(_ sender: UIButton) {
        var icon: String = ""
        var color: String = ""
        
        for button in iconButtons {
            if button.tintColor == .blue {
                
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
        
        
        guard let navController = presentingViewController as? UINavigationController else {
            return
        }
        
        guard let vc = navController.viewControllers.first as? HomeViewController else {
            return
        }
        
        guard let name = nameOfCategory.text else {
            return
        }
        
        if (icon == "" || name == "" || color == "") {
            dialogWindow(message: "Please fill all the fields!", title: "Error")
            return
        }
        
        if (editCategory == nil) {
            //RealmHandler.shared.createCategoryWith(title: name, color: color, icon: icon)
            //var categories = RealmHandler.shared.getAllCategories()
            var category = Category(title: name, color: color, icon: icon)
            categoryDelegate.didCreateCategory(category: category)
        } else {
            RealmHandler.shared.updateCategoryWith(ID: editCategory!.id, title: name, icon: icon, color: color)
            var categories = RealmHandler.shared.getAllCategories()
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
    
   
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CreateCategoryViewController{
    func hexStringFromColor(color: UIColor) -> String {
        let components = color.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        print(hexString)
        return hexString
     }

    
}


extension CreateCategoryViewController: categorySelectionDelegate {
    func didSelectCategoryWith(name: String, notes: Array<Note>) {
        return
    }
    
    func didEditCategory(category: Category) {
        //print(titleViewController.text)
        self.editCategory = category
        
       // nameOfCategory.text = category.title
       // titleViewController.text = "Edit Category"
       // buttonCreate.setTitle("Edit", for: .normal)
    }
}
