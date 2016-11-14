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
    @IBAction func createRoom(_ sender: Any) {
        
        if let name = newChatroomTextField?.text {
            let newChannelRef = channelRef.child(name);
            var emptyDict = [String : String]()
            emptyDict[senderDisplayName] = email
            let channelItem = [
                "id": name,
                "users": emptyDict,
                "admin": "",
                "messages": ""
            ] as [String : Any]
            
            newChannelRef.setValue(channelItem)
//            let userRef = newChannelRef.child("users").child(senderDisplayName)
//            userRef.setValue(email)
           
//            newChannelRef.setValue(channelItem) {(error,ref) in
//                let userRef = newChannelRef.child("users").child(senderDisplayName)
//                userRef.setValue(email)
//                
//            }
            
            
        }
    }
    var senderDisplayName: String!
    var email: String?
    private var chatRooms: [ChatRoom] = []
    private lazy var channelRef: FIRDatabaseReference = FIRDatabase.database().reference().child("ChatRooms")
    
    private var channelRefHandle: FIRDatabaseHandle?
    var newChatroomTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeChannels()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    private func observeChannels() {
        // We can use the observe method to listen for new
        // channels being written to the Firebase DB
        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) -> Void in
            let channelData = snapshot.value as! Dictionary<String, AnyObject>
            let id = snapshot.key
            if let name = channelData["id"] as! String!, name.characters.count > 0 {
                
                let users = channelData["users"] as! Dictionary<String, AnyObject>
                var flag = false
                for (key,value) in users {
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
    
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
