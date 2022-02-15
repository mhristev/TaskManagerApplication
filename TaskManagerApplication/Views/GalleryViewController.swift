//
//  GalleryViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 22.01.22.
//

import UIKit
import AVFoundation
import RealmSwift
import FirebaseStorage

class GalleryViewController: UIViewController {
    @IBOutlet var addButton: UIButton!
    
    //@IBOutlet var photoCollection: UICollectionView!
    let imagePicker = UIImagePickerController()
    
    
    var currNoteID: String = ""
    
    var photos: [String] = []
    
    @IBOutlet var tableView: UITableView!
    let realm = try! Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //FirestoreHandler.downloadMedia()
        addButton.menu = demoMenu
        addButton.showsMenuAsPrimaryAction = true
        imagePicker.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        if let fetchPhotos = RealmHandler.shared.getAllPhotosinNoteWith(ID: currNoteID, inRealmObject: realm) {
            photos = fetchPhotos
        }
        
        
    }
    func photoPicker() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    func openCamera() {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    var menuItems: [UIAction] {
        return [
            UIAction(title: "Choose Image", image: UIImage(systemName: "sun.max"), handler: { (_) in
                self.photoPicker()
            }),
            
            
            /*UIAction(title: "Disabled item", image: UIImage(systemName: "moon"), attributes: .disabled, handler: { (_) in
             }),
             UIAction(title: "Delete..", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { (_) in
             })*/
            UIAction(title: "Open Camera", image: UIImage(systemName: "sun.max"), handler: { (_) in
                self.openCamera()
            })
        ]
    }
    
    var demoMenu: UIMenu {
        return UIMenu(title: "Menu", image: nil, identifier: nil, options: [], children: menuItems)
    }
    

    
    
}

extension GalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if picker.sourceType == .camera {
            if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                displayAndSaveImageFromCamera(image: pickedImage)
            }
        } else if picker.sourceType == .photoLibrary {
            guard let imageUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL else {
                return
            }
            saveImageToRealm(photoURL: imageUrl.absoluteString)
        }
        
        dismiss(animated: true)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
}

extension GalleryViewController {
    
    func returnImageFor(url: URL) -> UIImage? {
        
        let data = try? Data(contentsOf: url)
        if let imageData = data {
            if let image = UIImage(data: imageData) {
                return image
            } else {
                print("image not found!")
            }
        }
        
        return nil
        
    }
    
    func saveImageToRealm(photoURL: String) {
        
        RealmHandler.shared.addPhotoToNoteWith(ID: currNoteID, photoURL: photoURL, inRealmObject: realm)
        
        if let fetchPhotos = RealmHandler.shared.getAllPhotosinNoteWith(ID: currNoteID, inRealmObject: realm) {
            photos = fetchPhotos
        } else {
            photos = []
        }
        
        
        FirestoreHandler.uploadMedia(url: photoURL,
                                     noteID: currNoteID)
        
        tableView.reloadData()
    }
    
    func deletePhoto(indexPath: IndexPath) {
        let documentsDirectory = FileManager.default
        
        guard let url = URL(string: photos[photos.count - (1 + indexPath.row)]) else {
            return
        }
        do {
            try documentsDirectory.removeItem(at: url)
        } catch {
            print(error)
        }
        
        
        

        let imgURL = photos[photos.count - (1 + indexPath.row)]
        
       
        let stack = imgURL.components(separatedBy: "/")
        
    
        FirestoreHandler.deleteMedia(inNoteID: currNoteID, imgID: stack.last ?? "")
        
        
        photos.remove(at: photos.count - (1 + indexPath.row))
        tableView.reloadData()  
        

        print("Deleted")
    }
    
    func displayAndSaveImageFromCamera(image: UIImage) {
        let imageID = UUID().uuidString
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // choose a name for your image
        let fileName = imageID + ".png"
        // create the destination file url to save your image
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        // get your UIImage jpeg data representation and check if the destination file url already exists
        if let data = image.pngData(),
           !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // writes the image data to disk
                try data.write(to: fileURL)
                print("file saved")
                saveImageToRealm(photoURL: fileURL.absoluteString)
                print(fileURL.absoluteString)
            } catch {
                print("error saving file:", error)
            }
        }
    }
}




extension GalleryViewController: noteActionDelegate {
    func didCreateNoteWith(ID: String) {
        self.currNoteID = ID
    }
    
    
    
    func didCreateReminderOn(note: Note) {
        return
    }
    
    func reloadData() {
        return
    }
    
}

extension GalleryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotoTableViewCell.identifier, for: indexPath) as! PhotoTableViewCell
        
        
        if let url = URL(string: photos[photos.count - (1 + indexPath.row)]) {
            if let img = returnImageFor(url: url) {
                cell.configureWith(image: img)
            }
        }
        
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions -> UIMenu? in
            let deleteAction = UIAction(title: "Delete", image: nil,attributes: .destructive, handler: { (_) in
                self.deletePhoto(indexPath: indexPath)   // Put button handler here
            })
            
            
            return UIMenu( image: nil, identifier: nil, options: [], children: [deleteAction])
        }
        return configuration
    }
    
}
