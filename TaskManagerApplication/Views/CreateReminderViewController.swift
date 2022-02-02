//
//  CreateReminderViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 1.02.22.
//

import UIKit

class CreateReminderViewController: UIViewController {

    @IBOutlet var dateSwitch: UISwitch!
    
    @IBOutlet var datePickerView: UIDatePicker!
    
    @IBOutlet var dateView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        datePickerView.overrideUserInterfaceStyle = .dark
        //myDatePicker.overrideUserInterfaceStyle = .light

        // Do any additional setup after loading the view.
    }
    

    @IBAction func showDatePicker(_ sender: UISwitch) {
        if (dateSwitch.isOn) {
            
            datePickerView.isHidden = false
        } else {
            
            datePickerView.isHidden = true
            
        }
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
