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
    
    var chatServiceManager:ChatServiceManager!

    @IBAction func sendButtonHit(sender: AnyObject) {
        // send message to the connected device
        messageTextField.resignFirstResponder()
        if let message = messageTextField.text{
            chatServiceManager.sendMessage(message)
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
    
    // make art assets for response paragraph messages
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
        /*
        let greyView = UIImageView(image: UIImage(named: "GreyDialogueBox"))
        greyView.frame = CGRect(x: 0, y: self.view.frame.height*0.76, width: self.view.frame.width*0.75, height: self.view.frame.height*0.2)
        let greyTextView = UITextView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width*0.95, height: self.view.frame.height*0.95))
        let lorem = "Lorem ipsum epluribus unum. Maximus quintas blah, blah, blah. And many other things."
        greyTextView.attributedText = NSAttributedString(string: lorem, attributes: [:])
        greyTextView.textColor = UIColor.whiteColor()
        greyTextView.editable = false
        greyView.addSubview(greyTextView)
        view.addSubview(greyView)*/
        let blueView = UIImageView(image: UIImage(named: "BlueDialogueBox"))
        blueView.frame = CGRect(x: self.view.frame.width*0.25, y: self.view.frame.height*0.56, width: self.view.frame.width*0.75, height: self.view.frame.height*0.2)
        view.addSubview(blueView)
        if let navVC = appDelegate.window?.rootViewController as? UINavigationController{
            let myViewControllers = navVC.viewControllers
            for vc in myViewControllers{
                if vc.title == "ConnectionsVC"{
                    let connectionsVC = vc as! ConnectionsVC
                    self.chatServiceManager = connectionsVC.chatService
                    print("Set ChatVC to the same service manager as the last one, redundant I beleive")
                }
            }
        }
    }
}
