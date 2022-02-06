//
//  NoteViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 23.01.22.
//

import UIKit
import RealmSwift


class NoteViewController: UIViewController {
    
    let fontSize = 20.0
    let realm = try! Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
    @IBOutlet var favouriteButton: UIButton!
    @IBOutlet var toolbarView: UIView!
    @IBOutlet var textView: UITextView!
    
    var currNoteID: String?
    //let notes = try! Realm()
    
    @IBOutlet var metaInformation: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
       // textView.allowsEditingTextAttributes = true
      //  textView.delegate = self

        
        if currNoteID != nil {
            guard let note = RealmHandler.shared.getNoteWith(ID: currNoteID!, inRealmObject: realm) else {
                return
            }
            
          //  let attr = [NSAttributedString.Key.font: UIFont(name: "Chalkduster", size: 18.0)!]
    
            guard let newAttributedString = note.html2AttrString() else {
                return
            }
            
            
            textView.attributedText = newAttributedString
            textView.textColor = UIColor(named: "colorSelector")
            configureFavourite()
            
            
            let f = DateFormatter()
            f.dateFormat = "yyy-MM-dd HH:mm:ss"
            
            metaInformation.text = "created at: \(f.string(from: note.createdAt as Date))\nupdated at: \(f.string(from: note.updatedAt as Date)) \nrevisions: \(note.revisions)\n"
//            self.textView.font = UIFont(name: self.textView.font!.fontName, size: self.fontSize)
        }
        
        textView.inputAccessoryView = toolbarView
        textView.keyboardDismissMode = .onDrag
        
        
        // https://www.hackingwithswift.com/example-code/uikit/how-to-adjust-a-uiscrollview-to-fit-the-keyboard
        let not = NotificationCenter.default
        
        not.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        not.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
        

        // Do any additional setup after loading the view.
    }
    
    func configureFavourite() {
        
        guard let id = currNoteID else {
            return
        }
        
        guard let note = RealmHandler.shared.getNoteWith(ID: id, inRealmObject: realm) else {
            return
        }
        
        
        if note.favourite {
            favouriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            favouriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
    
    
    
    @IBAction func addToFavourite(_ sender: UIButton) {
        guard let uid = currNoteID else {
            return
        }
        
        RealmHandler.shared.updateFavouriteForNote(ID: uid, inRealmObject: realm)
        //self.loadView()
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
        self.configureFavourite()
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
    
    
    // title = 34
    // heading =
    @IBAction func boldButton(_ sender: UIButton) {
        
        if let text = textView {
                    let range = text.selectedRange
                            let string = NSMutableAttributedString(attributedString:
                             textView.attributedText)
                            let boldAttribute = [
                                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: self.fontSize)
                             ]
                              string.addAttributes(boldAttribute, range: textView.selectedRange)
                            textView.attributedText = string
                              textView.selectedRange = range
                           
        }
    }
    
    @IBAction func italicButton(_ sender: UIButton) {
        
        if let text = textView {
                    let range = text.selectedRange

                            let string = NSMutableAttributedString(attributedString:
                             textView.attributedText)
            
                            let italicAttribute = [
                                NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: self.fontSize)
                             ]
                              string.addAttributes(italicAttribute, range: textView.selectedRange)
                            textView.attributedText = string
                              textView.selectedRange = range
                           
        }
            
    }
    
    @IBAction func underlineButton(_ sender: UIButton) {
        
        if let text = textView {
                    let range = text.selectedRange
                            let string = NSMutableAttributedString(attributedString:
                             textView.attributedText)
                    let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
                             
                              string.addAttributes(underlineAttribute, range: textView.selectedRange)
                            textView.attributedText = string
                              textView.selectedRange = range
                           
        }
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        let title = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines).first ?? ""
        let text = textView.attributedText
        
        
        if currNoteID != nil {
            
            if text?.string == "" {
                RealmHandler.shared.deleteNoteWith(ID: currNoteID!, inRealmObject: realm)
            }else {
                RealmHandler.shared.updateNoteWith(ID: currNoteID!, title: title, attrText: text ?? NSAttributedString(""), inRealmObject: realm)
              
            }
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



extension NoteViewController: noteActionDelegate {
    func didCreateReminderOn(note: Note) {
        return
    }
    
    func didUpdateNoteCategory(notes: Array<Note>) {
        return
    }
    
    func didCreateNoteWith(ID: String) {
        self.currNoteID = ID
    }
}

/*
extension NoteViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
      
        if (text == "\n") {
            
           // self.textView.font = UIFont(name: self.textView.font!.fontName, size: 18)
            return false
        }
        return true
    }
}
*/
