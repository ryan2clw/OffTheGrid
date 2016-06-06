//
//  ViewController.swift
//  NetDM
//
//  Created by Ryan Dines on 4/27/16.
//  Copyright © 2016 Dimezee. All rights reserved.
//

enum UserState{
    case EntryPoint
    // no data to load
    case HasPicture
    case HasName
}

import UIKit
import MultipeerConnectivity
import CoreData

class OpeningVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    let context = appDelegate.managedObjectContext
    var results:[User] = []
    var user:User!
    var userState = UserState.EntryPoint
    var imagePicker:UIImagePickerController!
    
    @IBOutlet weak var selfieLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var whereNextLabel: UILabel!
    
    @IBOutlet weak var photoButton: UIButton!
    
    @IBOutlet weak var profileButton: UIButton!
    
    @IBOutlet weak var chatButton: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBAction func photoButtonTapped(sender: AnyObject) {
        
        print("photo tapped")
        
// MARK ADD CODE: the ability to take a photo
        
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)

    }
    func respondToUserState(userState: UserState){
        // The purpose of this function is to make the view show or hide sub-views based on the user
        switch userState{
        case .EntryPoint:
            nameTextField.hidden = true
            nameLabel.hidden = true
            profileButton.hidden = true
            chatButton.hidden = true
            whereNextLabel.hidden = true
        case .HasPicture:
            photoButton.setTitle("", forState: .Normal)
            selfieLabel.hidden = true
            nameTextField.hidden = false
            print("unhiding text field")
            nameLabel.hidden = false
            profileButton.hidden = true
            chatButton.hidden = true
            whereNextLabel.hidden = true
        case .HasName:
            selfieLabel.hidden = true
            nameTextField.hidden = true
            nameLabel.hidden = false
            nameLabel.text = user.userName
            nameLabel.font = UIFont(name: "arial", size: CGFloat(35.0))
            profileButton.hidden = false
            chatButton.hidden = false
            whereNextLabel.hidden = false
        }
    }
    
    func initializeUser(){
        do{
            let request = NSFetchRequest(entityName: "User")
            print("fetching user")
            results = try context.executeFetchRequest(request) as! [User]
        }catch let error as NSError{
            print("You fucked up \(error.localizedDescription)")
        }
        // check to see if there's any saved data, if not make a new one and save.
        if results.count == 0 {
            print("No persistent data found")
            userState = .EntryPoint
            let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: context)
            user = User(entity: entity!, insertIntoManagedObjectContext: context)
            user.userName = "-"
            print("Instantiated blank name")
            user.imageData = NSData()
            print("Instantiated blank data")
        }else{
            print("Populating user with persistent data")
            // if you found some data, use the first one you found to populate user
            user = results.first
            print("Setting photoButton image")
            self.photoButton.imageView?.contentMode = .ScaleAspectFill
            self.photoButton.setImage(user.profileImage, forState: .Normal)
            if user.userName == "-" {
                userState = .HasPicture
            }else{
                nameLabel.text = user.userName!
                userState = .HasName
            }

        }
        do{
            print("Saving user")
            try context.save()
        }catch let error as NSError{
            print("Failed to save, error: \(error.localizedDescription)")
        }
        respondToUserState(userState)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        //user.imageData = UIImagePNGRepresentation(pickedImage)

        dismissViewControllerAnimated(true) {
            // save the picked data to the VC's property
            let png = UIImagePNGRepresentation(pickedImage)
            self.user.imageData = png
            self.photoButton.imageView?.contentMode = .ScaleAspectFill
            self.photoButton.setImage(pickedImage, forState: .Normal)
            self.userState = .HasPicture
            self.respondToUserState(self.userState)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func profileButtonTapped(sender: AnyObject) {
        
    }

    // MARK: UITextFieldDelegate
    
    func textFieldDidEndEditing(textField: UITextField) {

        if let name = textField.text {
            nameLabel.text = name
            nameLabel.adjustsFontSizeToFitWidth = false
            nameLabel.font = UIFont(name: "arial", size: CGFloat(35.0))
            self.user.userName = name
            print("added name")
            self.userState = .HasName
            self.respondToUserState(userState)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hides the keyboard
        textField.resignFirstResponder()
        return true
    }
    
// MARK: STANDARD METHODS FOR VC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Loading view")
        // title first, catches their eyes probably
        navigationItem.title = "Net DM"
        initializeUser()
        // Core Data managed entity "user" should not be nil at this point.
        nameTextField.delegate = self
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToConnections" {
            print("Phase 3 Complete, Moving to Connections")
            // pass any information needed for connectionsVC with this reference
            let connectionsVC = segue.destinationViewController as! ConnectionsVC
            connectionsVC.user = self.user
        }
        super.prepareForSegue(segue, sender: sender)
    }
    
}

