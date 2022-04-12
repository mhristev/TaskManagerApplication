//
//  NoteViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 23.01.22.
//

import UIKit
import RealmSwift


class NoteViewController: UIViewController {
    
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
    @IBOutlet var favouriteButton: UIButton!
    @IBOutlet var toolbarView: UIView!
    @IBOutlet var textView: UITextView!
    
    var currNoteID: String?
    
    
    var noteDelegate: noteActionDelegate!
    
    @IBOutlet var metaInformation: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.delegate = self
        //textView.font = UIFont(name: "ArialMT", size: 18)
        textView.font = UIFont(name: ".AppleSystemUIFont", size: 18)
                
        if currNoteID != nil {
            guard let note = RealmHandler.getNoteWith(ID: currNoteID!, inRealmObject: realm) else {
                return
            }
            
            guard let newAttributedString = note.html2AttrString() else {
                return
            }
            
            
            textView.attributedText = newAttributedString
            textView.textColor = UIColor(named: "colorSelector")
            configureFavourite()
            
            
            
            metaInformation.text = "created at: \(note.createdAt)\nupdated at: \(note.updatedAt) \nrevisions: \(note.revisions)\n"
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
        
        guard let note = RealmHandler.getNoteWith(ID: id, inRealmObject: realm) else {
            return
        }
        
        
        if note.favourite {
            favouriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            favouriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
    
    @IBAction func goToGallery(_ sender: UIButton) {
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "GalleryViewController") as! GalleryViewController
        noteDelegate = destinationVC
        
        guard let id = currNoteID else {
            return
        }
        
        noteDelegate.didCreateNoteWith(ID: id)
        //destinationVC.title = "\(categories[categories.count - (1 + indexPath.row)])"
        
        self.navigationController?.pushViewController(destinationVC, animated: true)    }
    
    
    @IBAction func addToFavourite(_ sender: UIButton) {
        guard let uid = currNoteID else {
            return
        }
        
        RealmHandler.updateFavouriteForNote(ID: uid, inRealmObject: realm)
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
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 40.0)
            ]
            string.addAttributes(boldAttribute, range: range)
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
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 25.0)
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
            let underlineAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0)]
            
            string.addAttributes(underlineAttribute, range: textView.selectedRange)
            textView.attributedText = string
            textView.selectedRange = range
            
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        let title = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines).first ?? ""
        let text = textView.attributedText
        
        print(textView.font?.fontName)
        if currNoteID != nil {
            
            if text?.string == "" {
                RealmHandler.deleteNoteWith(ID: currNoteID!, inRealmObject: realm)
            }else {
                RealmHandler.updateNoteWith(ID: currNoteID!, title: title, attrText: text ?? NSAttributedString(""), inRealmObject: realm)
                
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


extension NoteViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //textView.typingAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]
        textView.typingAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "colorSelector"), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]
        return true
    }
}


extension NoteViewController: noteActionDelegate {
    func reloadData() {
        return
    }
    
    func didCreateReminderOn(note: Note) {
        return
    }
    
    
    
    func didCreateNoteWith(ID: String) {
        self.currNoteID = ID
    }
}

