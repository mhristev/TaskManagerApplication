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
            
                guard var dictionary = json as? [String: Any] else {
                    assertionFailure("Couldn't cast json to dictionary.")
                    return
                }
                
                let categoryAsValue = FieldValue.arrayUnion([dictionary])
                
                Firestore.firestore().collection("users").document(user.uid).updateData(["categories": categoryAsValue])
                
//                dictionary["color"] = "mishka"
//                
//                Firestore.firestore().collection("users").document(user.uid).updateData(["categories[0]": categoryAsValue])
            
            } catch {
                print(error)
            }
        }
    }
    
    static func upload(note: Note) {
        if let user = Auth.auth().currentUser {
            do {
                
                //var cat = note.category?.getID()
                
                let categoryData = try JSONEncoder().encode(note)
                let json = try JSONSerialization.jsonObject(with: categoryData, options: [])
            
                guard var dictionary = json as? [String: Any] else {
                    assertionFailure("Couldn't cast json to dictionary.")
                    return
                }
               // dictionary["category"] = cat
                
                let categoryAsValue = FieldValue.arrayUnion([dictionary])
                
                Firestore.firestore().collection("users").document(user.uid).setData(["notes": categoryAsValue], merge: true)
            
            } catch {
                print(error)
            }
        }
    }
    
    static func delete(note: Note) {
        if let user = Auth.auth().currentUser {
            do {
                let noteData = try JSONEncoder().encode(note)
                let json = try JSONSerialization.jsonObject(with: noteData, options: [])
                
                
                guard var dictionary = json as? [String: Any] else {
                    assertionFailure("Couldn't cast json to dictionary.")
                    return
                }
                //let cat = note.category?.getID()
                //dictionary["category"] = cat
                
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
            //
        }
    }
    
    static func delete(category: Category) {
        if let user = Auth.auth().currentUser {
            
            do {
                let categoryData = try JSONEncoder().encode(category)
                let json = try JSONSerialization.jsonObject(with: categoryData, options: [])
                
                //            let categoryData: [String: Any] = [
                //                        "id" : category.id,
                //                        "name" : category.name,
                //                        "icon" : category.icon,
                //                        "color" : category.color
                //            ]
                
                guard let dictionary = json as? [String: Any] else {
                    assertionFailure("Couldn't cast json to dictionary.")
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
    
    static func fetchAllCategories() {
        // raboti
        let docRef = Firestore.firestore()
                    .collection("users")
                    .document(Auth.auth().currentUser!.uid)



        docRef.getDocument { (document, error) in
            
            guard let document = document, document.exists else {
                print("Document does not exist")
                return
            }
            let dataDescription = document.data()
            //print(dataDescription?["categories"] ?? "")


            do {

            let data = try JSONSerialization.data(withJSONObject: dataDescription?["categories"], options: .prettyPrinted)


                let category = try JSONDecoder().decode(Array<Category>.self, from: data)
            print("----------")
                print(category)
            } catch {
                print(error)
            }
            //print(dataDescription?["firstname"] ?? "")
        }
    }
    static func fetchAllNotes() {
        // raboti
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
            //print(dataDescription?["categories"] ?? "")


            do {

            let data = try JSONSerialization.data(withJSONObject: dataDescription?["notes"], options: .prettyPrinted)


                let category = try JSONDecoder().decode(Array<Note>.self, from: data)
            print("----------")
                print(category)
            } catch {
                print(error)
            }
            //print(dataDescription?["firstname"] ?? "")
        }
    }
}
