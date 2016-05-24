//
//  User.swift
//  NetDM
//
//  Created by Ryan Dines on 5/21/16.
//  Copyright © 2016 Dimezee. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class User: NSManagedObject {
    
    /*
    var profileImage:UIImage{
        get{
            let image = UIImage(data: imageData!)!
            return image
        }
        set{
            let image = self.profileImage
            imageData = UIImagePNGRepresentation(image)
        }
    }*/
    override func awakeFromFetch() {
        super.awakeFromFetch()
        print("Fetched stuff")
        // customization of fetched objects, the ones retrieved from memory
    }
    override func awakeFromInsert() {
        // customization of new objects, used when storing
        print("Created new stuff")
    }
     // compute image from saved data
    /*
    var profileImage:UIImage{
        if self.imageData != nil {
            if let image = UIImage(data: self.imageData!){
                return image
            }else{
                return UIImage()
            }
        }else{
            return UIImage()
        }
    }*/
    
    // computed property returns image when needed on run time
    /*
    var profileImage:UIImage{
        let blank = UIImage()
        if let validData = self.imageData {
            if let validImage = UIImage(data: validData){
                print("Made sense of the stored data")
                return validImage
            }else{
                print("Invalid saved image, attempting to load default")
                if let validImage = UIImage(named: "Background"){
                    // return default image to avoid crashing while using optionals scenario
                    print("Attempting to set the profile image to the default")
                    return validImage
                }else{
                    print("Nothing else worked, blank image it is")
                    // nil case should crash program, for development only
                    return blank
                }
            }
        }else{
            print("Two invalid data sets, blank image it is")
            // nil case should crash program, for development only
            return blank
        }
    }*/
    func returnProfileImage()->UIImage{
        let blank = UIImage()
        if let validData = self.imageData {
            if let validImage = UIImage(data: validData){
                print("Made sense of the stored data")
                return validImage
            }else{
                print("Invalid saved image, attempting to load default")
                if let validImage = UIImage(named: "Background"){
                    // return default image to avoid crashing while using optionals scenario
                    print("Attempting to set the profile image to the default")
                    return validImage
                }else{
                    print("Nothing else worked, blank image it is")
                    // nil case should crash program, for development only
                    return blank
                }
            }
        }else{
            print("Two invalid data sets, blank image it is")
            // nil case should crash program, for development only
            return blank
        }
    }
    
    
    
}
