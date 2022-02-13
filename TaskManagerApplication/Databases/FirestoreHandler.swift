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
                
                Firestore.firestore().collection("users").document(user.uid).setData(["notes": noteAsValue], merge: true)
                
            } catch {
                print(error)
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
    
    static func fetchAllCategories(completion: @escaping ([Category]) -> Void) {
        
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
    static func fetchAllNotes(completion: @escaping ([NoteWrapper]) -> Void) {
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
                
                
                let noteWrappers = try JSONDecoder().decode(Array<NoteWrapper>.self, from: data)
                completion(noteWrappers)
                
            } catch {
                print(error)
                return
            }
            
        }
    }
    
    static func uploadMedia(url: String, completion: @escaping (_ url: String?) -> Void) {

        guard let localFile = URL(string: url) else {
            return
        }
//        guard let imageData = img.pngData() else {
//            return
//        }
//
        guard let currentUser = Auth.auth().currentUser else {
            return
        }

        let userURL = "\(currentUser.uid)/\(UUID().uuidString)"

        let storageRef = Storage.storage().reference().child(userURL)
//
//
//        // Upload the file to the path "images/rivers.jpg"
//        let uploadTask = storageRef.putData(imageData, metadata: nil, completion: { metadata, error in
//            guard error == nil else {
//                print("failed to upload")
//                return
//            }
//
//            storageRef.downloadURL { url, error in
//                guard error == nil else {
//                    print("error while trying to get the download URL!")
//                    return
//                }
//                guard let downloadURL = url else {
//                    print("failed to get the downloadURL of the image!")
//                    return
//                }
//                print("----------------------------------")
//                print(downloadURL)
//
//            }
//
//        })
        

        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = storageRef.putFile(from: localFile, metadata: nil) { metadata, error in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            print(size)
            // You can also access to download URL after upload.
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }

                print("------------")
                print(downloadURL)
            }
        }
        
        
        
        
    }
    
    
    
    static func downloadMedia() {
        let url = "\(Auth.auth().currentUser!.uid)"
        let storageReference = Storage.storage().reference().child(url)
        
        storageReference.listAll { (result, error) in
          if let error = error {
            // ...
          }
          for prefix in result.prefixes {
            // The prefixes under storageReference.
            // You may call listAll(completion:) recursively on them.
          }
          for item in result.items {
            print(item)
          }
        }
       
    }
}
