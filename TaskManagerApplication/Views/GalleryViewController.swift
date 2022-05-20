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
import Vision

class GalleryViewController: UIViewController {

    var realm: Realm {
                do {
                    let realm = try Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
                    return realm
                } catch {
                    print("Could not access database: ", error)
                }
                return self.realm
        }
    @IBOutlet var addButton: UIButton!

    // @IBOutlet var photoCollection: UICollectionView!
    let imagePicker = UIImagePickerController()

    var currNoteID: String = ""

    var photos: [String] = []

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        addButton.menu = demoMenu
        addButton.showsMenuAsPrimaryAction = true
        imagePicker.delegate = self
        tableView.delegate = self
        tableView.dataSource = self

        if let fetchPhotos = RealmHandler.getAllPhotosInNoteWith(ID: currNoteID, inRealmObject: realm) {
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
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }

    var menuItems: [UIAction] {
        return [
            UIAction(title: "Choose Image", image: UIImage(systemName: "sun.max"), handler: { (_) in
                self.photoPicker()
            }),

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
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        if picker.sourceType == .camera {
            if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
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

        RealmHandler.addPhotoToNoteWith(ID: currNoteID, photoURL: photoURL, inRealmObject: realm)

        if let fetchPhotos = RealmHandler.getAllPhotosInNoteWith(ID: currNoteID, inRealmObject: realm) {
            photos = fetchPhotos
        } else {
            photos = []
        }

        FirestoreHandler.uploadMedia(url: photoURL,
                                     noteID: currNoteID)

        tableView.reloadData()
    }

    func recognizeTextIn(indexPath: IndexPath) {
        guard let url = URL(string: photos[photos.count - (1 + indexPath.row)]) else {
            return
        }
        var recognizedResult: String = "\n"
        guard let imageData = try? Data(contentsOf: url) else { return }
                        guard let image = UIImage(data: imageData) else {
                                return
                        }

            let request = VNRecognizeTextRequest { request, error in
                if error != nil {
                    return
                }
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    fatalError("Received invalid observations")
                }
                for observation in observations {
                    guard let bestCandidate = observation.topCandidates(1).first else {
                        print("No candidate")
                        continue
                    }
                    recognizedResult.append(bestCandidate.string + "\n")
                }
                let noteText = RealmHandler.getNoteWith(ID: self.currNoteID,
                                                        inRealmObject: self.realm)?.textHtmlString.html2AttributedString
                let title = noteText!.string.trimmingCharacters(in: .whitespacesAndNewlines)
                    .components(separatedBy: .newlines).first ?? ""
                let attributedResult = NSAttributedString(string: recognizedResult,
                                              attributes: [NSAttributedString.Key.font:
                                                            UIFont.systemFont(ofSize: 18.0)])
                guard let currText = noteText!.mutableCopy() as? NSMutableAttributedString else { return }
                guard let textInPicture = attributedResult.mutableCopy() as? NSMutableAttributedString else { return }
                currText.append(textInPicture)
                RealmHandler.updateNoteWith(ID: self.currNoteID,
                                            title: title, attrText: currText, inRealmObject: self.realm)
            }
            let requests = [request]
            request.recognitionLevel = .accurate
            DispatchQueue.global(qos: .userInitiated).async {
                guard let img = image.cgImage else {
                    fatalError("Missing image to scan")
                }

                let handler = VNImageRequestHandler(cgImage: img, options: [:])
                try? handler.perform(requests)
            }

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

        FirestoreHandler.deletePicture(inNoteID: currNoteID, imgID: stack.last ?? "")
        photos.remove(at: photos.count - (1 + indexPath.row))
        tableView.reloadData()
        print("Deleted")
    }

    func displayAndSaveImageFromCamera(image: UIImage) {
        let imageID = UUID().uuidString

        guard let documentsDirectory = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        // задава се име на снимката
        let fileName = imageID + ".jpeg"
        // създаване на destination file url където ще се запази снимката
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        if let data = image.jpegData(compressionQuality: 1.0),
           !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // записва снимката в destination url
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

extension GalleryViewController: NoteActionDelegate {
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
    // swiftlint:disable force_cast
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: PhotoTableViewCell.identifier, for: indexPath) as! PhotoTableViewCell

        if let url = URL(string: photos[photos.count - (1 + indexPath.row)]) {
            if let img = returnImageFor(url: url) {
                cell.configureWith(image: img)
            }
        }

        return cell
    }
    // swiftlint:enable force_cast
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            let deleteAction = UIAction(title: "Delete", image: nil, attributes: .destructive, handler: { (_) in
                self.deletePhoto(indexPath: indexPath) 
            })

            let recognizeAction = UIAction(title: "Recognize Text",
                                           image: nil, attributes: [], handler: { (_) in
                self.recognizeTextIn(indexPath: indexPath)
            })

            return UIMenu( image: nil, identifier: nil, options: [], children: [deleteAction, recognizeAction])
        }
        return configuration
    }

}
