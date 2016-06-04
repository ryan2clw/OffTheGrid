//
//  ChatServiceManager.swift
//  NetDM
//
//  Created by Ryan Dines on 5/7/16.
//  Copyright © 2016 Dimezee. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol ChatServiceManagerDelegate {
    
    func connectedDevicesChanged(manager : ChatServiceManager, connectedDevices: [String])
    func messageReceived(manager : ChatServiceManager, message: String)
    
}

// CHAT SERVICE DOESN'T RELOAD A LOST PEER, FIX THAT

class ChatServiceManager : NSObject {
    
    private let chatServiceName = "NetDM"
    private let myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    let serviceAdvertiser : MCNearbyServiceAdvertiser
    let serviceBrowser : MCNearbyServiceBrowser
    var delegate : ChatServiceManagerDelegate?
    
    override init() {
        
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: chatServiceName)
        
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: chatServiceName)
        
        super.init()
   
        self.serviceAdvertiser.delegate = self
        //self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        //self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session.delegate = self
        return session
    }()
    
    func sendMessage(message : String) {
        NSLog("%@", "message sent: \(message)")
        if session.connectedPeers.count > 0 {
            do {
                try self.session.sendData(message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            } catch let error1 as NSError {
                NSLog("%@", "\(error1)")
            }
        }
    }
}

extension ChatServiceManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: ((Bool, MCSession) -> Void)) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
    
}

extension ChatServiceManager : MCNearbyServiceBrowserDelegate {
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
        // reload table to reflect lost connection
        
        self.reloadConnectionTable()
    }
}

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .NotConnected: return "NotConnected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
        }
    }
}

extension ChatServiceManager : MCSessionDelegate {
    
    func addConnectionToVC(){
        // always get the main queue, chat service runs on private queue
        dispatch_async(dispatch_get_main_queue()) {
            let navVC = appDelegate.window?.rootViewController as! UINavigationController
            print("Updating the UI from the background thread with the connected device name")
            for vc in navVC.viewControllers{
                if vc.title == "Connects" {
                    print("Found connections view controller")
                    let connectionsVC = vc as! ConnectionsVC
                    let connections = connectionsVC.connections
                    for connectedPeer in self.session.connectedPeers {
                        let newConnection = connectedPeer.displayName
                        
                        print(newConnection)
                        // makes array like a dictionary, one unique key per connection
                        //let connections = connectionsVC.connections
                        if connections.count == 0 {
                            connectionsVC.connections.append(newConnection)
                            connectionsVC.reloadTableCells()
                            //connectionsVC.connectionsTable.reloadData()
                            print("Adding initial connection completed")
                        }else{
                            for connection in connections{
                                if connection == newConnection {
                                    print("Duplicate connection, possible reconnect")
                                    // don't reload anything
                                    return
                                }
                                else{
                                    connectionsVC.connections.append(newConnection)
                                    print("Multiple connections")
                                    print("Connections count:")
                                    print(connections.count)
                                    connectionsVC.reloadTableCells()
                                }
                            }
                        }
                    }
                    print("Connections:")
                    print(connectionsVC.connections)
                    //connectionsVC.connectionsTable.beginUpdates()
                    //connectionsVC.connectionsTable.reloadData()
                }
            }
        }
    }
    
    func reloadConnectionTable(){
        //always get main queue when on the private one
        dispatch_async(dispatch_get_main_queue()) {
            let navVC = appDelegate.window?.rootViewController as! UINavigationController
            print("Updating the UI to reflect the loss of peerID")
            for vc in navVC.viewControllers{
                if vc.title == "ConnectionsVC" {
                    let connectionsVC = vc as! ConnectionsVC
                    connectionsVC.reloadTableCells()
                    //connectionsVC.connectionsTable.reloadData()
                    print("tableView finished reloading from background thread")
                }
            }
        }
    }

    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
        self.delegate?.connectedDevicesChanged(self, connectedDevices: session.connectedPeers.map({$0.displayName}))
        self.addConnectionToVC()
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data.length) bytes")
        let str = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        self.delegate?.messageReceived(self, message: str)
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
}
