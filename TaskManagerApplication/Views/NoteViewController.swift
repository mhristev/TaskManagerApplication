//
//  NoteViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 23.01.22.
//

import UIKit

/*protocol updateNoteDelegate {
    func didUpdateNote(notes: Array<Note>)
}*/

class NoteViewController: UIViewController {

    @IBOutlet var toolbarView: UIView!
    @IBOutlet var textView: UITextView!
    
    var currNoteID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(self.parentVie)
        
       
        
        //emailTextField.delegate = self
        //passwordTextField.delegate = self
        textView.delegate = self
        if currNoteID != nil {
            let note = RealmHandler.shared.getNoteWith(ID: currNoteID!)
            textView.text = note?.text
        }
        
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
    
    

    
    
    override func willMove(toParent parent: UIViewController?) {
        
        
        super.willMove(toParent: parent)
      
        
        if (parent == nil) {
            
            
            let title = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines).first ?? ""
            let text = textView.text ?? ""
            
            if currNoteID != nil {
                if text == "" {
                    RealmHandler.shared.deleteNoteWith(ID: currNoteID!)
                }else {
                    RealmHandler.shared.updateNoteWith(ID: currNoteID!, title: title, text: text, favourite: false)
                }
            }
            
            
            print("Note to category view")
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
}


extension NoteViewController: createNoteDelegate {
    func didCreateNoteWith(ID: String) {
        self.currNoteID = ID
        print(ID)
    }
}
