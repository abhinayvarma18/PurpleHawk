//
//  RoomListTableViewController.swift
//  PurpleHawkChat
//
//  Created by Abhinay Varma on 13/11/16.
//  Copyright © 2016 Abhinay Varma. All rights reserved.
//

import UIKit
import Firebase

enum Section: Int {
    case createNewChannelSection = 0
    case currentChannelsSection
}

class RoomListTableViewController: UITableViewController {
    
    var senderDisplayName: String!
    var email: String?
    private var chatRooms: [ChatRoom] = []
    private lazy var channelRef: FIRDatabaseReference = FIRDatabase.database().reference().child("ChatRooms")
    private var channelRefHandle: FIRDatabaseHandle?
    var newChatroomTextField: UITextField?
    
    
    @IBAction func createRoom(_ sender: Any) {
        
        if let name = newChatroomTextField?.text {
            let newChannelRef = channelRef.child(name);
            var emptyDict = [String : String]()
            emptyDict[senderDisplayName] = email
            let channelItem = [
                "id": name,
                "users": emptyDict,
                "admin": email as Any,
                "messages": ""
            ] as [String : Any]
            
            newChannelRef.setValue(channelItem)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeChannels()
    }
    
    private func observeChannels() {
        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) -> Void in
            let channelData = snapshot.value as! Dictionary<String, AnyObject>
            let id = snapshot.key
            if let name = channelData["id"] as! String!, name.characters.count > 0 {
                
                let users = channelData["users"] as! Dictionary<String, AnyObject>
                var flag = false
                for (_,value) in users {
                    if(value as! String == self.email!){
                        flag = true
                    }
                }
                if(flag) {
                    self.chatRooms.append(ChatRoom(id: id, name: name))
                    self.tableView.reloadData()
                    flag = false;
                }
            } else {
                print("Error! Could not decode channel data")
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let currentSection: Section = Section(rawValue: section) {
            switch currentSection {
            case .createNewChannelSection:
                return 1
            case .currentChannelsSection:
                return chatRooms.count
            }
        }else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = (indexPath as NSIndexPath).section == Section.createNewChannelSection.rawValue ? "Static" : "Chatrooms"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if (indexPath as NSIndexPath).section == Section.createNewChannelSection.rawValue {
            if let createNewChannelCell = cell as? StaticTableViewCell {
                newChatroomTextField = createNewChannelCell.chatroomName
            }
        } else if (indexPath as NSIndexPath).section == Section.currentChannelsSection.rawValue {
            cell.textLabel?.text = chatRooms[(indexPath as NSIndexPath).row].id
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == Section.currentChannelsSection.rawValue {
            let channel = chatRooms[(indexPath as NSIndexPath).row]
            self.performSegue(withIdentifier: "ShowChat", sender: channel)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let channel = sender as? ChatRoom {
            let chatVc = segue.destination as! ChatViewController
            
            chatVc.senderDisplayName = senderDisplayName
            chatVc.email = email
            chatVc.channelRef = channelRef.child(channel.id)
            chatVc.channel = channel
        }
    }
}
