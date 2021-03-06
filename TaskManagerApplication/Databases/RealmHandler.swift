//
//  RealmHandler.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 26.01.22.
//

import UIKit
import Foundation
import RealmSwift

class RealmHandler {
    static var currUserID: String = ""
    static func registerUserWith(id: String) {
        guard let userTable = try? Realm() else { return }
        if let user = userTable.objects(User.self).filter("_id == %@", id).first {
            if userTable.objects(User.self).count < 4 {
                    try? userTable.write {
                        user.updateLastSeen()
                    }
            }
        } else {
            if userTable.objects(User.self).count > 2 {
                if let oldUser = userTable.objects(User.self).sorted(byKeyPath: "_lastSeenAt").first {
                    self.deleteConfigurationForUser(id: oldUser.id)
                    try? userTable.write {
                        userTable.delete(oldUser)
                    }
                }
            }
            try? userTable.write {
                userTable.add(User(id: id))
            }
        }
    }

    static func deleteConfigurationForUser(id: String) {
        var config = Realm.Configuration()
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(id).realm")
        do {
            try FileManager.default.removeItem(at: config.fileURL!)
        } catch {
            print("deleting db failed")
        }
    }

    static func loadfirstConfiguration(andSetUserID: String) {
        self.setCurrentUser(ID: andSetUserID)
        self.registerUserWith(id: andSetUserID)

        do {
            let realm = try Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
            if realm.isEmpty {
                self.createCategoryWith(name: "Quick Notes", color: "#1E63FF",
                                        icon: "folder.fill", inRealmObject: realm)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }

    }

    static func setCurrentUser(ID: String) {
        RealmHandler.currUserID = ID
    }

    static func configurationHelper() -> Realm.Configuration {
        var config = Realm.Configuration()
        let uid = RealmHandler.currUserID
        guard let URL = config.fileURL else { return config }

        config.fileURL = URL.deletingLastPathComponent().appendingPathComponent("\(uid).realm")

        return config
    }
    static func doesExistCategoryWith(name: String, inRealmObject: Realm) -> Bool {
        return (inRealmObject.objects(Category.self).filter("_name == %@", name).first != nil)
    }

    static func getCategoryWith(ID: String, inRealmObject: Realm) -> Category? {
        if let category = inRealmObject.objects(Category.self).filter("_id == %@", ID).first {
            return category
        }
        return nil
    }
    static func createCategoryWith(name: String, color: String, icon: String, inRealmObject: Realm) {
        print(inRealmObject.configuration.fileURL!.path)
        if doesExistCategoryWith(name: name, inRealmObject: inRealmObject) {
            print("this category exist")
            return
        }
        let category = Category(name: name, color: color, icon: icon)
        if name != "Quick Notes" {
            FirestoreHandler.upload(category: category)
        }
        try? inRealmObject.write {
            inRealmObject.add(category)
        }
    }
    static func deleteCategoryWith(ID: String, inRealmObject: Realm) {
        if let category = inRealmObject.objects(Category.self).filter("_id == %@", ID).first {
            let notesInCategory = getAllNotesInCategoryWith(name: category.getName(), inRealmObject: inRealmObject)
            for note in notesInCategory {
                if note.reminderDate != nil {
                    NotificationHelper.removeNotificationWithID(ID: note.id)
                }
                FirestoreHandler.delete(note: note)
            }
            try? inRealmObject.write {
                inRealmObject.delete(notesInCategory)
            }
            FirestoreHandler.delete(category: category)
            try? inRealmObject.write {
                inRealmObject.delete(category)
            }
        }
    }
    static func getAllCategories(inRealmObject: Realm) -> [Category] {
        return Array(inRealmObject.objects(Category.self))
    }
    static func getAllNotesInCategoryWith(name: String, inRealmObject: Realm) -> [Note] {
        return Array(inRealmObject.objects(Note.self).filter("_category._name == %@", name)).sortedByUpdatedAt()
    }
    static func getAllNotes(inRealmObject: Realm) -> [Note] {
        return Array(inRealmObject.objects(Note.self))
    }
    static func clearEmtyNotes(inRealmObject: Realm) {
        let emtyNotes = inRealmObject.objects(Note.self).filter("_title == %@", "")
        for note in emtyNotes {
            try? inRealmObject.write {
                inRealmObject.delete(note)
            }
        }
    }

    static func getCategoryWith(name: String, inRealmObject: Realm) -> Category? {
        return inRealmObject.objects(Category.self).filter("_name == %@", name).first
    }

    static func updateCategoryWith(ID: String, name: String, icon: String, color: String, inRealmObject: Realm) {
        if let category = inRealmObject.objects(Category.self).filter("_id == %@", ID).first {

            FirestoreHandler.delete(category: category)

            try? inRealmObject.write {
                category.name = name
                category.icon = icon
                category.color = color
            }

            FirestoreHandler.upload(category: category)
        }
    }

    static func createNoteWith(title: String,
                               text: NSAttributedString, favourite: Bool, categoryName: String, inRealmObject: Realm) {
        print(inRealmObject.configuration.fileURL!.path)

        if let foundCategory = inRealmObject.objects(Category.self).filter("_name == %@", categoryName).first {

            guard let htmlString = text.toHtmlString() else {
                return
            }
            let note = Note(title: title, htmlText: htmlString, favourite: favourite, category: foundCategory)

            FirestoreHandler.upload(note: note)

            try? inRealmObject.write {
                inRealmObject.add(note)
            }
        }

    }

    static func updateNoteWith(ID: String, title: String, attrText: NSAttributedString, inRealmObject: Realm) {
        if let note = inRealmObject.objects(Note.self).filter("_id == %@", ID).first {

            if let text = note.textHtmlString.html2AttributedString {
                if text.string == attrText.string {
                    return
                }
            }
            if note.title != title {
                if let date = note.reminderDate {
                    NotificationHelper.removeNotificationWithID(ID: ID)
                    NotificationHelper.createNewNotificationWith(title: title, date: date, ID: ID)
                }
            }

            guard let htmlString = attrText.toHtmlString() else {
                return
            }
            FirestoreHandler.delete(note: note)
            try? inRealmObject.write {
                note.textHtmlString = htmlString
                note.title = title
                note.updatedAt = Date().formatedToStringDate()
                note.revisions += 1
            }
            FirestoreHandler.upload(note: note)
        }

    }

    static func getNoteWith(name: String, inRealmObject: Realm) -> Note? {
        return inRealmObject.objects(Note.self).filter("_title == %@", name).first
    }

    static func getNoteWith(ID: String, inRealmObject: Realm) -> Note? {
        return inRealmObject.objects(Note.self).filter("_id == %@", ID).first
    }

    static func deleteNoteWith(ID: String, inRealmObject: Realm) {
        if let note = inRealmObject.objects(Note.self).filter("_id == %@", ID).first {

            if note.reminderDate != nil {
                NotificationHelper.removeNotificationWithID(ID: note.id)
            }

            FirestoreHandler.deletePicturesIn(note: note)
            FirestoreHandler.delete(note: note)

            try? inRealmObject.write {
                inRealmObject.delete(note)
            }
        }
    }

    static func update(note: Note, inCategory: Category, inRealmObject: Realm) {
        if let note = inRealmObject.objects(Note.self).filter("_id == %@", note.id).first {
            FirestoreHandler.delete(note: note)
            try? inRealmObject.write {
                note.category = inCategory
            }
            FirestoreHandler.upload(note: note)
        }
    }

    static func createReminderAndNotificationForNote(withID: String, andDate: String, inRealmObject: Realm) {
        if let note = inRealmObject.objects(Note.self).filter("_id == %@", withID).first {
            FirestoreHandler.delete(note: note)

            try? inRealmObject.write {
                note.reminderDate = andDate
            }
            NotificationHelper.createNewNotificationWith(title: note.title, date: andDate, ID: note.id)

            FirestoreHandler.upload(note: note)
        }
    }

    static func getAllReminders(inRealmObject: Realm) -> [Note] {
        cleanOldReminders(inRealmObject: inRealmObject)
        return Array(inRealmObject.objects(Note.self).filter("_reminderDate != null")).returnDatesAfterToday()
    }

    static func getAllRemindersForThisWeek(inRealmObject: Realm) -> [Note] {
        cleanOldReminders(inRealmObject: inRealmObject)
        return Array(inRealmObject.objects(Note.self).filter("_reminderDate != null")).onlyThisWeek()
    }

    static func returnFavouriteReminders(inRealmObject: Realm) -> [Note] {
        return Array(inRealmObject.objects(Note.self)
                        .filter("_reminderDate != null && _favourite = 1"))
                        .sortedByRemindersDate()
    }

    static func cleanOldReminders(inRealmObject: Realm) {

        let today = Date()

        for oldReminder in inRealmObject.objects(Note.self)
                .filter("_reminderDate != null") {

            guard let day = oldReminder.reminderDate else {
                return
            }

            guard let convertDate = day.toDate() else {
                return
            }

            if today > convertDate {
                if isInCurrentWeek(date: convertDate) == false {
                    try? inRealmObject.write {
                        oldReminder.reminderDate = nil
                    }
                }
            }

        }

    }

    static func removeReminderAndNotificationForNote(withID: String, inRealmObject: Realm) {
        if let note = inRealmObject.objects(Note.self)
            .filter("_id == %@", withID)
            .first {
            try? inRealmObject.write {
                note.reminderDate = nil
            }
            NotificationHelper.removeNotificationWithID(ID: withID)
        }
    }

    static func updateFavouriteForNote(ID: String, inRealmObject: Realm) {
        if let note = inRealmObject.objects(Note.self)
            .filter("_id == %@", ID)
            .first {
            FirestoreHandler.delete(note: note)
            if note.favourite {
                try? inRealmObject.write {
                    note.favourite = false
                }
            } else {
                try? inRealmObject.write {
                    note.favourite = true
                }
            }
            FirestoreHandler.upload(note: note)

        }
    }

    static func returnFavouriteNotesInCategory(name: String, inRealmObject: Realm) -> [Note] {
        let results: Results<Note> = inRealmObject.objects(Note.self)
            .filter("_category._name == %@", name)
            .filter("_favourite == 1")

        return Array(results).sortedByUpdatedAt()
    }

    static func addPhotoToNoteWith(ID: String, photoURL: String, inRealmObject: Realm) {
        let note = inRealmObject.objects(Note.self)
            .filter("_id == %@", ID)
            .first

        try? inRealmObject.write {
            note?.photos.append(photoURL)
        }
    }

    static func getQuickNotesCategory(inRealmObject: Realm) -> Category? {
        return inRealmObject.objects(Category.self).filter("_name == %@", "Quick Notes").first
    }

    static func getAllPhotosInNoteWith(ID: String, inRealmObject: Realm) -> [String]? {
        if let note = inRealmObject.objects(Note.self).filter("_id == %@", ID).first {
            clearFakeImagesIn(note: note, inRealmObject: inRealmObject)
            return Array(note.photos)
        }
        return nil
    }

    static func clearFakeImagesIn(note: Note, inRealmObject: Realm) {
        var index = 0
        for photo in note.photos {
            if let url = URL(string: photo) {
                if returnImageFor(url: url) == nil {
                    try? inRealmObject.write {
                        note.photos.remove(at: index)
                    }
                    index -= 1
                }
            }
            index += 1
        }
    }

    static func createLocalCopiesOf(categories: [Category], inRealmObject: Realm ) {
        for category in categories {
            let cat = Category(id: category.id, name: category.name, color: category.color, icon: category.icon)
            try? inRealmObject.write {
                inRealmObject.add(cat)
            }
        }
    }

    static func handleFetchedCategories(cloudCategories: [Category]) {

        do {
            let realm = try Realm(configuration: RealmHandler.configurationHelper(), queue: nil)

            let localCategories = RealmHandler.getAllCategories(inRealmObject: realm)

            var f = false
            for localCategory in localCategories {
                for cloudCategory in cloudCategories
                where localCategory.id == cloudCategory.id {
                    f = true
                }
                if f { f = false } else {
                    self.deleteCategoryWith(ID: localCategory.id, inRealmObject: realm)
                }
            }

            var toCreateLocally: [Category] = []

            var flag = false

            for cloudCat in cloudCategories {
                for localcat in localCategories {
                    if localcat.id == cloudCat.id {
                        flag = true
                        // ASK user if he wants the local or the cloud settings for the given category
                        try? realm.write {
                            localcat.name = cloudCat.name
                            localcat.color = cloudCat.color
                            localcat.icon = cloudCat.icon
                        }
                        break
                    }
                    if localcat.name == "Quick Notes" && cloudCat.name == "Quick Notes" {
                        flag = true
                        try? realm.write {
                            localcat.id = cloudCat.id
                            localcat.name = cloudCat.name
                            localcat.color = cloudCat.color
                            localcat.icon = cloudCat.icon
                        }
                        break
                    }
                }
                if flag {
                    flag = false
                } else {
                    toCreateLocally.append(cloudCat)
                }
            }
            self.createLocalCopiesOf(categories: toCreateLocally, inRealmObject: realm)

        } catch let error as NSError {
            print(error.localizedDescription)
        }

    }

    static func checkIfNoteExists(noteID: String, inRealmObject: Realm) -> Bool {
        let notes = inRealmObject.objects(Note.self)
        for note in notes where note.id == noteID {
            return true
        }
        return false
    }

    static func createLocalCopiesOf(notes: [Note], inRealmObject: Realm ) {
        for note in notes {
            if !self.checkIfNoteExists(noteID: note.id, inRealmObject: inRealmObject) {
                let localNote = Note(id: note.id, title: note.title,
                                     htmlText: note.textHtmlString, createdAt: note.createdAt,
                                     updatedAt: note.updatedAt, revisions: note.revisions, favourite: note.favourite,
                                     category: note.category, reminderDate: note.reminderDate)

                try? inRealmObject.write {
                    inRealmObject.add(localNote)
                }
                if let reminder = localNote.reminderDate {
                    NotificationHelper.createNewNotificationWith(
                        title: localNote.title, date: reminder, ID: localNote.id)
                }
            }
        }
    }
    static func handleFetchedNotes(wrappers: [NoteWrapper]) {
        do {
            let realm = try Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
            let cloudNotes = wrappers.toNotes()
            var localNotes = RealmHandler.getAllNotes(inRealmObject: realm)

            var f = false
            for localNote in localNotes {
                for cloudNote in cloudNotes where localNote.id == cloudNote.id {
                    f = true
                }
                if f { f = false }
                    else {
                        self.deleteNoteWith(ID: localNote.id, inRealmObject: realm)
                    }
            }
            localNotes = RealmHandler.getAllNotes(inRealmObject: realm)
            var toCreateLocally: [Note] = []

            var flag = false
            if let quickNotes = RealmHandler.getQuickNotesCategory(inRealmObject: realm) {
                for cloudNote in cloudNotes {
                    for localNote in localNotes {
                        if localNote.id == cloudNote.id {
                            flag = true
                            // ASK user if he wants the local or the cloud settings for the given category
                            try? realm.write {
                                localNote.title = cloudNote.title
                                localNote.textHtmlString = cloudNote.textHtmlString
                                localNote.createdAt = cloudNote.createdAt
                                localNote.updatedAt = cloudNote.updatedAt
                                localNote.revisions = cloudNote.revisions
                                localNote.favourite = cloudNote.favourite
                                if let localCategoryID = localNote.category?.id,
                                    let cloudCategoryID = cloudNote.category?.id {
                                    if localCategoryID != cloudCategoryID {
                                        localNote.category = cloudNote.category
                                    }
                                } else {
                                    localNote.category = quickNotes
                                }

                                localNote.reminderDate = cloudNote.reminderDate
                                if let reminder = localNote.reminderDate {
                                    NotificationHelper.removeNotificationWithID(ID: cloudNote.id)
                                    NotificationHelper.createNewNotificationWith(title: cloudNote.title,
                                                                                 date: reminder, ID: cloudNote.id)
                                }
                            }
                            break
                        }

                        if localNote.category == nil {
                            try? realm.write {
                                localNote.category = quickNotes
                            }
                        }

                    }
                    if flag {
                        flag = false
                    } else {
                        toCreateLocally.append(cloudNote)
                    }
                }
            }
            self.createLocalCopiesOf(notes: toCreateLocally, inRealmObject: realm)
        } catch let error as NSError {
            print(error.localizedDescription)
        }

    }

    static func checkIfImageExistsLocally(firestoreURL: String) {

        let components = firestoreURL.components(separatedBy: "/")

        let imageID = components[components.count - 1]
        let noteID = components[components.count - 2]

        do {
            let realm = try Realm(configuration: RealmHandler.configurationHelper(), queue: nil)

            if let note = RealmHandler.getNoteWith(ID: noteID, inRealmObject: realm) {
                guard let documentsDirectory = FileManager.default
                        .urls(for: .documentDirectory, in: .userDomainMask).first else { return }

                let fileName = imageID

                let fileURL = documentsDirectory.appendingPathComponent(fileName)

                for img in note.photos {
                    let path = img.components(separatedBy: "/")
                    if path[path.count - 1] == imageID {
                        // the image exists for that note -> no need to download
                        print("exists locally")
                        return
                    }
                }

                FirestoreHandler.downloadPicture(pathToImgInFirestore: firestoreURL,
                                                 localURL: fileURL, completion: { url in
                    // double check just to be sure
                    for img in note.photos {
                        let path = img.components(separatedBy: "/")
                        if path[path.count - 1] == imageID {
                            // if it has been added second time to the queue
                            print("exists locally")
                            return
                        }
                    }

                    try? realm.write {
                        note.photos.append(url)
                    }
                })
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    static func getAllPhotosIDs() -> [String] {
        var photos: [String] = []
        do {
            let realm = try Realm(configuration: RealmHandler.configurationHelper(), queue: nil)

            let notes = self.getAllNotes(inRealmObject: realm)

            for note in notes {
                for photo in note.photos {
                    let components = photo.components(separatedBy: "/")
                    photos.append(components[components.count - 1])
                }
            }

            return photos
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return photos
    }

    static func getAllPhotosURLs() -> [String] {
        guard let realm = try? Realm(configuration: RealmHandler.configurationHelper(), queue: nil) else { return [""] }
        let notes = self.getAllNotes(inRealmObject: realm)

        var photosURLs: [String] = []

        for note in notes {
            for photo in note.photos {
                photosURLs.append(photo)
            }
        }

        return photosURLs
    }

    static func getNoteIDforImageURL(url: String) -> String? {
        do {
            let realm = try Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
            let notes = self.getAllNotes(inRealmObject: realm)

            for note in notes {
                for photoURL in note.photos where photoURL == url {
                    return note.id
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }

}

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

func isInCurrentWeek(date: Date) -> Bool {
    var startDate = Date()
    var interval: TimeInterval = 0.0
    let calendar = Calendar.current
    // calendar.firstWeekday = 1 set the index of the first weekday if necessary
    _ = calendar.dateInterval(of: .weekOfYear, start: &startDate, interval: &interval, for: Date())
    let endDate = calendar.date(byAdding: .second, value: Int(interval), to: startDate)!
    return date >= startDate && date < endDate

}

extension DateFormatter {
    func getDefaultDateFormatter() -> DateFormatter {
        self.dateFormat = "dd MMM yyyy, HH:mm:ss"
        return self
    }
}

extension Date {
    func formatedToStringDate() -> String {
        let dateFormatter = DateFormatter().getDefaultDateFormatter()
        return dateFormatter.string(from: self)
    }
}

extension Array where Element: NoteWrapper {
    func toNotes() -> [Note] {
        var result: [Note] = []

        do {
            let realm = try Realm(configuration: RealmHandler.configurationHelper(), queue: nil)
            for res in self {
                let note = Note()
                note.id = res.id
                note.title = res.title
                note.category = RealmHandler.getCategoryWith(ID: res.categoryID, inRealmObject: realm)
                note.textHtmlString = res.textHtmlString
                note.createdAt = res.createdAt
                note.updatedAt = res.updatedAt
                note.revisions = res.revisions
                note.favourite = res.favourite
                note.reminderDate = res.reminderDate
                result.append(note)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }

        return result
    }
}

extension Array where Element: Note {

    func toNoteWrapper() -> [NoteWrapper] {
        var result: [NoteWrapper] = []

        self.forEach {
            let wrapper = $0.toWrapper()
            result.append(wrapper)
        }

        return result
    }

    func onlyThisWeek() -> [Note] {
        var result: [Note] = []

        self.forEach {
            guard let date = $0.reminderDate?.toDate() else {
                return
            }
            if isInCurrentWeek(date: date) {
                result.append($0)
            }
        }
        return result
    }

    func sortedByUpdatedAt() -> [Note] {
        return self.sorted {
            $0.updatedAt.toDate()! < $1.updatedAt.toDate()!
        }
    }

    func sortedByRemindersDate() -> [Note] {
        return self.sorted {
            $0.reminderDate!.toDate()! < $1.reminderDate!.toDate()!
        }
    }

    func returnDatesAfterToday() -> [Note] {
        var result: [Note] = []

        self.forEach {
            guard let date = $0.reminderDate?.toDate() else {
                return
            }

            if date > Date() {
                result.append($0)
            }
        }
        return result
    }

}
