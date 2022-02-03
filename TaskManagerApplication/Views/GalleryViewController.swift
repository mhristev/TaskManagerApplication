//
//  GalleryViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 22.01.22.
//

import UIKit

class GalleryViewController: UIViewController {
    @IBOutlet var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButton.menu = demoMenu
        addButton.showsMenuAsPrimaryAction = true

        // Do any additional setup after loading the view.
    }
    
    var menuItems: [UIAction] {
        return [
            UIAction(title: "Choose photo", image: UIImage(systemName: "sun.max"), handler: { (_) in
            }),
            /*UIAction(title: "Disabled item", image: UIImage(systemName: "moon"), attributes: .disabled, handler: { (_) in
            }),
            UIAction(title: "Delete..", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { (_) in
            })*/
            UIAction(title: "Take a photo", image: UIImage(systemName: "sun.max"), handler: { (_) in
            })
        ]
    }

    var demoMenu: UIMenu {
        return UIMenu(title: "Menu", image: nil, identifier: nil, options: [], children: menuItems)
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
