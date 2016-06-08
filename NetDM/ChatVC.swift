//
//  ChatVC.swift
//  NetDM
//
//  Created by Ryan Dines on 5/7/16.
//  Copyright © 2016 Dimezee. All rights reserved.
//

import UIKit

class ChatVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var stackViewConstraint: NSLayoutConstraint!
    
    //var chatServiceManager:ChatServiceManager!

    @IBAction func sendButtonHit(sender: AnyObject) {
        // send message to the connected device
        messageTextField.resignFirstResponder()
        if let message = messageTextField.text{
            let navVC = appDelegate.window!.rootViewController as! UINavigationController
            for vc in navVC.viewControllers {
                if vc.title == "Connects" {
                    print("Found Connections VC")
                    let connectionsVC = vc as! ConnectionsVC
                    connectionsVC.chatService.sendMessage(message)
                }
            }
        }
        messageTextField.text = ""
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        animateViewMoving(true, moveValue: self.view.bounds.height*0.395)
    }
    func textFieldDidEndEditing(textField: UITextField) {
        animateViewMoving(false, moveValue: self.view.bounds.height*0.395)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // implement sharing data across connectionsVC
    // reference the chatServiceManager....singleton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageTextField.delegate = self
        sendButton.setTitle(" Send ", forState: .Normal)
        sendButton.layer.cornerRadius = 5
        sendButton.layer.borderColor = UIColor.blueColor().CGColor
        sendButton.layer.borderWidth = 1
        messageTextField.layer.cornerRadius = 5
        messageTextField.layer.borderWidth = 1
        let blueView = UIImageView(image: UIImage(named: "BlueDialogueBox"))
        blueView.frame = CGRect(x: self.view.frame.width*0.25, y: self.view.frame.height*0.52, width: self.view.frame.width*0.75, height: self.view.frame.height*0.2)
        view.addSubview(blueView)
        let greyView = UIImageView(image: UIImage(named: "GreyDialogueBox"))
        greyView.frame = CGRect(x: 0, y: self.view.frame.height*0.72, width: self.view.frame.width*0.75, height: self.view.frame.height*0.2)
        view.addSubview(greyView)
    }
}
