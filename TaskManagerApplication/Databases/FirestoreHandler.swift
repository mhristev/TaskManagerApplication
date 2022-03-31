//
//  FirebaseHandler.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 10.02.22.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UIKit

class FirestoreHandler {
    
    static func registerUserWith(email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            
            if err != nil {
                guard let error = err?.localizedDescription else { return }
                completion(error)
                return
            } else {
                
                guard let uid = result?.user.uid else {
                    return
                }
                
                let values = ["email" : email]
                
                Firestore.firestore().collection("users").document(uid).setData(values)
                
                self.dialogWindow(message: "Your account has been created successfully!", title: "Success")
            }
            completion(nil)
            
        }
    }
    
    static func loginUserWith(email: String, password: String, completion: @escaping(String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                guard let err = error?.localizedDescription else { return }
                //self.dialogWindow(message: err, title: "Error")
                completion(err)
                return
            }
            if let currentUser = Auth.auth().currentUser {
                RealmHandler.loadfirstConfiguration(andSetUserID: currentUser.uid)
            }
            completion(nil)
        }
    }
    
    static func upload(category: Category) {
        if let user = Auth.auth().currentUser {
            do {
                let categoryData = try JSONEncoder().encode(category)
                let json = try JSONSerialization.jsonObject(with: categoryData, options: [])
                
                guard let dictionary = json as? [String: Any] else {
                    return
                }
                
                let categoryAsValue = FieldValue.arrayUnion([dictionary])
                
                Firestore.firestore().collection("users").document(user.uid).setData(["categories": categoryAsValue], merge:true)
                
            } catch {
                print(error)
            }
        }
    }
    
    static func upload(note: Note) {
        if let user = Auth.auth().currentUser {
            let wrapper = note.toWrapper()
            do {
                
                let noteData = try JSONEncoder().encode(wrapper)
                let json = try JSONSerialization.jsonObject(with: noteData, options: [])
                
                guard let dictionary = json as? [String: Any] else {
                    return
                }
                
                let noteAsValue = FieldValue.arrayUnion([dictionary])
                
                Firestore.firestore().collection("users").document(user.uid).setData(["notes": noteAsValue], merge:true)
                
            } catch {
                print(error)
            }
        }
    }
    
    static func deletePicturesIn(note: Note) {
        if note.photos.count > 0 {
            for photo in note.photos {
                
                let stack = photo.components(separatedBy: "/")
                FirestoreHandler.deletePicture(inNoteID: note.getID(), imgID: stack[stack.count - 1])
            }
        }
    }
    
    static func delete(note: Note) {
        
        if let user = Auth.auth().currentUser {
            let wrapper = note.toWrapper()
            do {
                let noteData = try JSONEncoder().encode(wrapper)
                let json = try JSONSerialization.jsonObject(with: noteData, options: [])
                
                
                guard let dictionary = json as? [String: Any] else {
                    return
                }
                
                
                Firestore.firestore().collection("users").document(user.uid).updateData([
                    "notes": FieldValue.arrayRemove([dictionary])
                ]) { error in
                    if let error = error {
                        print("Unable to delete note: \(error.localizedDescription)")
                    }  else {
                        print("Successfully deleted note")
                    }
                }
            } catch {
                print("error")
            }
        }
    }
    
    static func delete(wrapper: NoteWrapper) {
        
        if let user = Auth.auth().currentUser {
            
            do {
                let noteData = try JSONEncoder().encode(wrapper)
                let json = try JSONSerialization.jsonObject(with: noteData, options: [])
                
                
                guard let dictionary = json as? [String: Any] else {
                    return
                }
                
                
                Firestore.firestore().collection("users").document(user.uid).updateData([
                    "notes": FieldValue.arrayRemove([dictionary])
                ]) { error in
                    if let error = error {
                        print("Unable to delete note: \(error.localizedDescription)")
                    }  else {
                        print("Successfully deleted note")
                    }
                }
            } catch {
                print("error")
            }
        }
    }
    
    static func delete(category: Category) {
        if let user = Auth.auth().currentUser {
            
            do {
                let categoryData = try JSONEncoder().encode(category)
                let json = try JSONSerialization.jsonObject(with: categoryData, options: [])
                
                guard let dictionary = json as? [String: Any] else {
                    return
                }
                
                
                
                Firestore.firestore().collection("users").document(user.uid).updateData([
                    "categories": FieldValue.arrayRemove([dictionary])
                ]) { error in
                    if let error = error {
                        print("Unable to delete comment: \(error.localizedDescription)")
                    }  else {
                        print("Successfully deleted comment")
                    }
                }
            } catch {
                print("error")
            }
        }
    }
    
    static func fetchCategories(completion: @escaping ([Category]) -> Void) {
        
        let db = Firestore.firestore()
        
        let docRef = db
            .collection("users")
            .document(Auth.auth().currentUser!.uid)
        
        
        
        docRef.getDocument { (document, error) in
            
            guard let document = document, document.exists else {
                print("Document does not exist")
                return
            }
            let dataDescription = document.data()
            
            if dataDescription?["categories"] == nil {
                let noCategories: [Category] = []
                completion(noCategories)
                return
            }
            
            do {
                
                let data = try JSONSerialization.data(withJSONObject: dataDescription?["categories"] as Any, options: .prettyPrinted)
                let categories = try JSONDecoder().decode(Array<Category>.self, from: data)
                
                completion(categories)
                
            } catch {
                print(error)
                
            }
            
        }
        
    }
    static func fetchNotes(completion: @escaping ([NoteWrapper]) -> Void) {
        let docRef = Firestore.firestore()
            .collection("users")
            .document(Auth.auth().currentUser!.uid)
        
        
        // https://firebase.google.com/docs/firestore/query-data/queries
        docRef.getDocument { (document, error) in
            
            guard let document = document, document.exists else {
                print("Document does not exist")
                return
            }
            let dataDescription = document.data()
            
            if dataDescription?["notes"] == nil {
                let noNotes: [NoteWrapper] = []
                completion(noNotes)
                return
            }
            
            do {
                
                let data = try JSONSerialization.data(withJSONObject: dataDescription?["notes"] as Any, options: .prettyPrinted)
                
                
                var noteWrappers = try JSONDecoder().decode(Array<NoteWrapper>.self, from: data)
                
                var i = 0
                var k = 0
                
                var toRemove: [Int] = []
                
                for note in noteWrappers {
                    if (toRemove.contains(i) == false) {
                        k = 0
                        for sameIDnote in noteWrappers {
                            if note.id == sameIDnote.id && k != i && toRemove.contains(k) == false {
                                if note.revisions > sameIDnote.revisions {
                                    toRemove.append(k)
                                    FirestoreHandler.delete(wrapper: sameIDnote)
                                } else {
                                    toRemove.append(i)
                                    FirestoreHandler.delete(wrapper: note)
                                }
                            }
                            k += 1
                        }
                    }
                    i += 1
                }
                
                toRemove = toRemove.sorted {$0 > $1}
                for t in toRemove {
                    noteWrappers.remove(at: t)
                }
                
                completion(noteWrappers)
                
            } catch {
                print(error)
                return
            }
            
        }
    }
    
    static func deletePicture(inNoteID: String, imgID: String) {
        
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let url = "\(currentUser.uid)/\(inNoteID)/\(imgID)"
        
        let ref = Storage.storage().reference().child(url)
        
        // Delete the file
        ref.delete { error in
            if error != nil {
                print("error while deleting")
            } else {
                print("deleted")
            }
        }
    }
    
    
    static func uploadMedia(url: String, noteID: String) {
        
        guard let localFile = URL(string: url) else {
            return
        }
        
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let components = url.components(separatedBy: "/")
        
        let cloudURL = "\(currentUser.uid)/\(noteID)/\(components[components.count - 1])"
        
        let storageRef = Storage.storage().reference().child(cloudURL)
        
        let taskProgress =  storageRef.putFile(from: localFile, metadata: nil) { _, error in
            
            guard error == nil else {
                return
            }
        }
        
        
        taskProgress.observe(.failure) { snapshot in
            self.dialogWindow(message: "We couldn't upload the image to the cloud", title: "Error")
        }
        
    }
    
    
    
    static func fetchPictures() {
        let url = "\(Auth.auth().currentUser!.uid)"
        let storageReference = Storage.storage().reference().child(url)
        
        storageReference.listAll { (result, error) in
            if let error = error {
                // ...
                print(error.localizedDescription)
            }
            for prefix in result.prefixes {
                // The prefixes under storageReference.
                print(prefix)
                prefix.listAll { result, error in
                    guard error == nil else {
                        return
                    }
                    
                    for pngID in result.items {
                        RealmHandler.checkIfImageExistsLocally(firestoreURL: pngID.fullPath)
                        
                    }
                    
                }
                
            }
            
            FirestoreHandler.checkForNotUploadedMedia()
        }
        
    }
    
    
    static func downloadPicture(pathToImgInFirestore: String, localURL: URL, completion: @escaping (String) -> Void) {
        
        let storageRef = Storage.storage().reference().child(pathToImgInFirestore)
        
        storageRef.write(toFile: localURL) { url, error in
            if error != nil {
                print("error while downloading picture")
            } else {
                guard let url = url else {
                    return
                }
                completion(url.absoluteString)
            }
        }
    }
    
    
    
    static func dialogWindow(message: String, title: String) {
        
        let myalert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        myalert.addAction(UIAlertAction(title: "Dismiss", style: .default,
                                        handler: {_ in
        }))
        
        UIApplication.shared.keyWindow?.rootViewController?.present(myalert, animated: true)
        
    }
    
    static func checkForNotUploadedMedia() {
        
        var cloudPhotoIDs: [String] = []
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let url = "\(currentUser.uid)"
        let storageReference = Storage.storage().reference().child(url)
        
        storageReference.listAll { (result, error) in
            if  error != nil {
                print("error while trying to access storage")
            }
            for prefix in result.prefixes {
                // go deap
                prefix.listAll { result, error in
                    guard error == nil else {
                        return
                    }
                    
                    for pngID in result.items {
                        let components = pngID.fullPath.components(separatedBy: "/")
                        cloudPhotoIDs.append(components[components.count - 1])
                    }
                    
                }
                // You may call listAll(completion:) recursively on them.
            }
            
            let localPhotoIDs = RealmHandler.getAllPhotosIDs()
            // returns categories that are in the local but not in the cloud storage
            let pushToCloud = Array(Set(localPhotoIDs).subtracting(Set(cloudPhotoIDs)))
            
            let urls = RealmHandler.getAllPhotosURLs()
            
            
            for img in pushToCloud {
                for url in urls {
                    if url.contains(img) {
                        guard let noteID = RealmHandler.getNoteIDforImageURL(url: url) else {
                            return
                        }
                        FirestoreHandler.uploadMedia(url: url, noteID: noteID)
                    }
                }
            }
            
        }
    }
    
}
