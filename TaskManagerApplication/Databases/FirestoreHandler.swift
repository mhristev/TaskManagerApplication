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
    
    
    
    
}
