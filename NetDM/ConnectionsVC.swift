//
//  ChatVC.swift
//  NetDM
//
//  Created by Ryan Dines on 4/29/16.
//  Copyright © 2016 Dimezee. All rights reserved.
//



import SystemConfiguration.CaptiveNetwork
import UIKit
import AVFoundation

class ConnectionsVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    // TO DO: Check that the tableView reloads dynamically based on connections.count
    
    @IBOutlet weak var networkTextField: UITextField!
    @IBOutlet weak var connectionsTable: UITableView!
    @IBOutlet weak var connectionSwitch: UISwitch!
    
    var connections:[String] = []
    var user:User!
    
    let chatService = ChatServiceManager()
    
    @IBAction func connectionSwitchHit(sender: AnyObject) {
        if connectionSwitch.on{
            print("reloading cells")
            reloadTableCells()
            //self.connectionsTable.beginUpdates()
            // set service to the textfield
            if networkTextField?.text != nil {
                //chatService.chatServiceName = networkTextField!.text!
                //print("advertising service:")
                //print(chatService.chatServiceName)
            }
            // start advertising
            print("advertising started")
            chatService.serviceAdvertiser.startAdvertisingPeer()
            chatService.serviceBrowser.startBrowsingForPeers()
            //let cell = self.connectionsTable.cellForRowAtIndexPath(NSIndexPath(forRow: connections.count, inSection: 0)) as! ConnectionsCell
            reloadTableCells()
            
        }else{
            // stop connections when switch is off
            chatService.serviceAdvertiser.stopAdvertisingPeer()
            chatService.serviceBrowser.stopBrowsingForPeers()
            let cell = self.connectionsTable.cellForRowAtIndexPath(NSIndexPath(forRow: connections.count, inSection: 0)) as! ConnectionsCell
            cell.activityIndicator.hidden = true
            cell.activityIndicator.stopAnimating()
        }
    }
    func reloadTableCells(){
        print("Manually reloading cells based on connections.count")
        for i in 0...7 {
            let cell = self.connectionsTable.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as! ConnectionsCell
            if i < connections.count {
                print("Printing to the first label in table if connection is made")
                cell.personConnectedLabel.text = connections[i]
                cell.activityIndicator.stopAnimating()
                cell.activityIndicator.color = UIColor.blueColor()
            }
            if i == connections.count {
                print("Animating the next pending label")
                cell.activityIndicator.hidden = false
                cell.activityIndicator.startAnimating()
            }
            if i > connections.count{
                print("Removing the remaining 6")
                cell.activityIndicator.hidden = true
                cell.activityIndicator.stopAnimating()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "segueToOpeningVC" {
            print("Returning to Opening Scene")
            let openingVC = segue.destinationViewController as! OpeningVC
            openingVC.userState = UserState.HasPicture
            openingVC.respondToUserState(openingVC.userState)
            print("Told OpeningVC to act like it know")
        }
        if segue.identifier == "segueToChatVC" {
            print("Found chat segue")
            let chatVC = segue.destinationViewController as! ChatVC
// NOT SURE REMOVE CODE HERE
            chatVC.chatServiceManager = self.chatService
        }
        super.prepareForSegue(segue, sender: sender)
    }
    
    @IBAction func getLocalButtonTapped(sender: AnyObject) {
        print("localButtonTapped:")
        var ssid = SSID.fetchSSIDInfo()
        if ssid == "" {
            // send alert saying that they're disconnected from WIFI
            // check for bluetooth availability, else send Alert to turn on bluetooth
            ssid = "bluetooth"
        }
        networkTextField.text = ssid
        // implement functionality where the WIFI connection that the device is logged into ends up being the advertising/receiving service
        // else{ network.name = bluetooth}
        // offline users will default to a default to a standard bluetooth implementation
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("Setting up tableview based on connections.count")
        let cell = tableView.dequeueReusableCellWithIdentifier("connectionsCell", forIndexPath: indexPath) as! ConnectionsCell
        cell.activityIndicator.color = UIColor.redColor()
        // hide indicators when connection switch is off
        if indexPath.row == connections.count-1 {
            print("Found the connected cell")
            // go to row 0 if you have a count of 1
            cell.personConnectedLabel.text = connections[indexPath.row]
            // populate the cells based on the row that you're in
            cell.activityIndicator.hidden = false
            // stop motion if necessary
            cell.activityIndicator.color = UIColor.blueColor()
            if cell.activityIndicator.isAnimating(){
                cell.activityIndicator.stopAnimating()
            }
        }
        if indexPath.row == connections.count {
            // the cell right below the active connections, or when they're both 0, the first cell
            print("Found the awaiting connections cell")
            if self.connectionSwitch.on {
                cell.activityIndicator.hidden = false
                cell.activityIndicator.startAnimating()
            }else{
                cell.activityIndicator.hidden = true
                cell.activityIndicator.stopAnimating()
            }
        }
        if indexPath.row > connections.count{
            print("Found the others (6 ea)")
            // the cells not doing anything
            cell.activityIndicator.hidden = true
            cell.userInteractionEnabled = false
        }
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Row selected: \(indexPath.row)")
        self.performSegueWithIdentifier("segueToChat", sender: self)
    }
    /*
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        print("Row selected: \(indexPath.row)")
        self.performSegueWithIdentifier("segueToChat", sender: self)
    }*/
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectionSwitch.on = false
        connectionsTable.delegate = self
        connectionsTable.dataSource = self
        connectionsTable.rowHeight = self.view.bounds.height/10.0
        chatService.delegate = self
    }
    override func didReceiveMemoryWarning() {

    }
}
extension ConnectionsVC : ChatServiceManagerDelegate {
    
    func connectedDevicesChanged(manager: ChatServiceManager, connectedDevices: [String]) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            for device in connectedDevices {
                print("Connected device: \(device)")
            }
        }
    }    
    
    func messageReceived(manager: ChatServiceManager, message: String) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            print("Message received:")
            print(message)
            // add to connectionVC
            if let navVC = appDelegate.window?.rootViewController as? UINavigationController {
                for vc in navVC.viewControllers {
                    
                    if let chatVC = vc as? ChatVC{
                        chatVC.messageTextField.text = message
                    }
                    if let connectionVC = vc as? ConnectionsVC {
                        let firstCell = connectionVC.connectionsTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! ConnectionsCell
                        firstCell.messageReceivedLabel.text = message
                        //self.playSystemSound()
                        print("Should see message: \(message)")
                    }
                }
            }
        }
    }
    /*
    func playSystemSound(){
        let systemSoundID: SystemSoundID = 1003
        AudioServicesPlaySystemSound(systemSoundID)
    }*/
}

    

