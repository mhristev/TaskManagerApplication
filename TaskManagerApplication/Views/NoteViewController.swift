//
//  NoteViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 23.01.22.
//

import UIKit

class NoteViewController: UIViewController {

    @IBOutlet var toolbarView: UIView!
    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //emailTextField.delegate = self
        //passwordTextField.delegate = self
        textView.delegate = self
        
        
        textView.inputAccessoryView = toolbarView
        textView.keyboardDismissMode = .onDrag
        
        
        // https://www.hackingwithswift.com/example-code/uikit/how-to-adjust-a-uiscrollview-to-fit-the-keyboard
        let not = NotificationCenter.default
        
        not.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        not.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
        

        // Do any additional setup after loading the view.
    }
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        textView.scrollIndicatorInsets = textView.contentInset

        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
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



extension NoteViewController: UITextViewDelegate {
    func textViewShouldReturn(_ textField: UITextView) -> Bool {
        //emailTextField.resignFirstResponder()
        //passwordTextField.resignFirstResponder()
        print("ddasd")
        textField.resignFirstResponder()
        guard let title = textField.text else {
            return false
        }
       // RealmHandler.shared.createNoteWith(title: title, text: "", favourite: false, category: Category())
        
        
        
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("hhhehehh")
        textView.resignFirstResponder()
        guard let title = textView.text else {
            return false
        }
        
        return true
    }
}
