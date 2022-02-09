//
//  GalleryViewController.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 22.01.22.
//

import UIKit
import AVFoundation
import RealmSwift

class GalleryViewController: UIViewController {
    @IBOutlet var addButton: UIButton!
    
    @IBOutlet var photoCollection: UICollectionView!
    let imagePicker = UIImagePickerController()
    
    var currNoteID: String = ""
    
    var photos: [String] = []
    
    let realm = try! Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButton.menu = demoMenu
        addButton.showsMenuAsPrimaryAction = true
        imagePicker.delegate = self
        photoCollection.delegate = self
        photoCollection.dataSource = self
        
        let width = (view.frame.width - 20)
        let layout = photoCollection.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width
                                 , height: width)
        
        if let fetchPhotos = RealmHandler.shared.getAllPhotosinNoteWith(ID: currNoteID, inRealmObject: realm) {
            photos = fetchPhotos
        }
        
        
        
        
        // let url = URL(string: RealmHandler.shared.giveMePhoto(ID: currNoteID, inRealmObject: realm) ?? "")
        //displayAndSaveImageWith(url: url!)
        // Do any additional setup after loading the view.
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
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

       //MARK: - Add image to Library
       @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
           if let error = error {
               // we got back an error!
               showAlertWith(title: "Save error", message: error.localizedDescription)
           } else {
               
               showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
           }
       }
        
    

       func showAlertWith(title: String, message: String){
           let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
           ac.addAction(UIAlertAction(title: "OK", style: .default))
           present(ac, animated: true)
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
        photoCollection.reloadData()
    }
    

    
    func displayAndSaveImageFromCamera(image: UIImage) {
        let imageID = UUID().uuidString

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // choose a name for your image
        let fileName = imageID + ".png"
        // create the destination file url to save your image
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        // get your UIImage jpeg data representation and check if the destination file url already exists
        if let data = image.jpegData(compressionQuality:  1.0),
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

extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photoCollection.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! PhotosCollectionViewCell
        
        
        if let url = URL(string: photos[photos.count - (1 + indexPath.row)]) {
            if let img = returnImageFor(url: url) {
                cell.configureWith(image: img)
            }
        }
        
        
        
        return cell
    }
    
    
    
    
}
