//
//  Model.swift
//  Notes2
//
//  Created by by3m on 29.06.2023.
//

import CoreData

enum Section: Hashable {
    case main
}
@objc(Note)
public class Note: NSManagedObject {
    @NSManaged public var body: String
    @NSManaged public var title: String
    @NSManaged public var created: Date
}

extension Note {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        NSFetchRequest<Note>(entityName: "Note")
    }
}
