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
    case HasName(userName: String)
}

import UIKit
import MultipeerConnectivity
import CoreData

class OpeningVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    let context = appDelegate.managedObjectContext
    var results:[User] = []
    var userState = UserState.EntryPoint
    var imagePicker:UIImagePickerController!
    
    //var profileImage=UIImage()
    //var userName:String? = "Ryan"
    
    var user:User!
    let bigFont = UIFont(name: "arial", size: CGFloat(35.0))
    
    @IBOutlet weak var selfieLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var whereNextLabel: UILabel!
    
    @IBOutlet weak var photoButton: UIButton!
    
    @IBOutlet weak var profileButton: UIButton!
    
    @IBOutlet weak var chatButton: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBAction func photoButtonTapped(sender: AnyObject) {
        print("photo tapped")
        
        // add ability to take photo as well
        
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)

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
            //self.determineUserState()
            self.userState = .HasPicture
            self.respondToUserState(self.userState)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func profileButtonTapped(sender: AnyObject) {

    }
    func respondToUserState(userState: UserState){
// The purpose of this function is to make the view show or hide sub-views based on where the user is in the registration process, remove extraneous stuff to make more modular
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
            nameLabel.font = bigFont
            profileButton.hidden = false
            chatButton.hidden = false
            whereNextLabel.hidden = false
            /*
            if let validName = userName{
                //persist data
                nameLabel.text = validName
                nameTextField.text = validName
            }*/
        }
    }
    func determineUserState(){
        
        // make more complex after you figure out pictures
        if let name = self.user.userName {
            if name != "John Doe" {
                userState = .HasName(userName: name)
            }else{
                userState = .HasPicture
            }
        }
    }
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
// MARK ADD CODE
// NEED RIGHT FONT SIZE
        if let name = textField.text {
            nameLabel.text = name
            nameLabel.adjustsFontSizeToFitWidth = false
            nameLabel.font = UIFont(name: "arial", size: CGFloat(35.0))
            self.user.userName = name
            print("adding name")
            self.userState = .HasName(userName: name)
            self.respondToUserState(userState)
        }
    }
    
/*
     
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //initializeUser()
        // Core Data managed entity "user" should not be nil at this point.
        respondToUserState(userState)
    }*/
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToConnections" {
            print("Phase 3 Complete, Moving to Connections")
            // pass any information needed for connectionsVC with this reference
            let connectionsVC = segue.destinationViewController as! ConnectionsVC
            connectionsVC.user = self.user
        }
        super.prepareForSegue(segue, sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Loading view")
        // title first, catches their eyes probably
        navigationItem.title = "Net DM"
        initializeUser()
        respondToUserState(.EntryPoint)
        // Core Data managed entity "user" should not be nil at this point.
        nameTextField.delegate = self
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
    }
    
    func initializeUser(){
// fetch data from stack
        do{
            let request = NSFetchRequest(entityName: "User")
            results = try context.executeFetchRequest(request) as! [User]
        }catch let error as NSError{
            print("You fucked up \(error.localizedDescription)")
        }
// check to see if there's any saved data, if not make a new one and save.
        if results.count == 0 {
            print("No persistent data found")
            let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: context)
            user = User(entity: entity!, insertIntoManagedObjectContext: appDelegate.managedObjectContext)
            user.userName = "John Doe"
            print("Instantiated name")
            user.imageData = NSData()
            /*
            if let validImage = UIImage(named: "BlueDialogueBox") {
                print("Found default picture")
                user.imageData = NSData(data: UIImageJPEGRepresentation(validImage, 1.0)!)
            }*/
            // user.imageData = UIImagePNGRepresentation(UIImage(named: "Background")!)
            // user.imageData is optional
           // user.imageData = UIImagePNGRepresentation(self.profileImage)
            do{
                try context.save()
            }catch let error as NSError{
                print("Failed to save, error: \(error.localizedDescription)")
            }
        }else{
            print("Populating user with persistent data")
// if you found some data, use the first one you found to populate user
            user = results.first
            do{
                try context.save()
            }catch let error as NSError {
                print("Failed to save context: \(error.localizedDescription)")
            }
            
            self.photoButton.imageView?.image = UIImage()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

