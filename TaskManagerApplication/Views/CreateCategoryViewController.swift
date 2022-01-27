//
//  CreateCategoryViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 23.01.22.
//

import UIKit

class CreateCategoryViewController: UIViewController {

    @IBOutlet var createCategoryButton: UIButton!
    
 
    @IBOutlet var colorButtons: [UIButton]!
    
    @IBOutlet var iconButtons: [UIButton]!
    
    @IBOutlet var nameOfCategory: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
     
        
        
        guard ((vc.overviewChildController?.createCategoryWith(name: name, color: color, icon: icon)) != nil) else {
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

    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
