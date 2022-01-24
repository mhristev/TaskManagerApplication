//
//  CreateCategoryViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 23.01.22.
//

import UIKit

class CreateCategoryViewController: UIViewController {

    @IBOutlet var createCategoryButton: UIButton!
    
    @IBOutlet var nameOfCategory: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createCategory(_ sender: UIButton) {
        guard let navController = presentingViewController as? UINavigationController else {
            return
        }
        
        guard let vc = navController.viewControllers.first as? HomeViewController else {
            return
        }
        
        guard let name = nameOfCategory.text else {
            return
        }
        
        guard ((vc.overviewChildController?.createCategory(withName: name)) != nil) else {
            return
        }
        
        self.dismiss(animated: true, completion: nil)
        
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
