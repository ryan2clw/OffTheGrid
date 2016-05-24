//
//  User+CoreDataProperties.swift
//  NetDM
//
//  Created by Ryan Dines on 5/21/16.
//  Copyright © 2016 Dimezee. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var userName: String?
    @NSManaged var imageData: NSData?

}
