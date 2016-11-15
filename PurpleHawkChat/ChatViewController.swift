//
//  ChatViewController.swift
//  PurpleHawkChat
//
//  Created by Abhinay Varma on 13/11/16.
//  Copyright © 2016 Abhinay Varma. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    var channelRef: FIRDatabaseReference?
    private var messages: [JSQMessage] = []
    private lazy var messageRef: FIRDatabaseReference = self.channelRef!.child("messages")
    private var newMessageRefHandle: FIRDatabaseHandle?
    private var updatedMessageRefHandle: FIRDatabaseHandle?
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    var channel: ChatRoom? {
        didSet {
            title = channel?.name
        }
    }

    var email: String!

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = senderDisplayName
        observeMessages()
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let adminRef = self.channelRef!.child("admin")
        adminRef.observeSingleEvent(of: .value, with: { snapshot in
            if(self.email == snapshot.value as? String) {
                self.editButton?.isEnabled = true
                self.addButton?.isEnabled = true
            }else {
                self.editButton?.isEnabled = false
                self.addButton?.isEnabled = false
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == email { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == email { // 1
            cell.textView?.textColor = UIColor.white // 2
        } else {
            cell.textView?.textColor = UIColor.black // 3
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
        let message = messages[indexPath.item]
        switch message.senderId {
        case self.email:
            return nil
        default:
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        // 1
        let itemRef = messageRef.childByAutoId()
        
        // 2
        let messageItem = [
            "senderName": self.senderDisplayName!,
            "body": text!,
            "senderId": email!
            ]
        
        // 3
        itemRef.setValue(messageItem)
        
        // 4
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        // 5
        finishSendingMessage()
//        isTyping = false
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }

    
    private func observeMessages() {
        messageRef = channelRef!.child("messages")
        let messageQuery = messageRef.queryLimited(toLast:25)
        
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["body"] as String!, text.characters.count > 0 {
                self.addMessage(withId: id, name: name, text: text)
                self.finishReceivingMessage()
            } else {
                print("Error! Could not decode message data")
            }
        })
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    @IBAction func AddUser(_ sender: Any) {
        self.performSegue(withIdentifier: "AddUser", sender: nil)
    }
    
    @IBAction func removeUser(_ sender: Any) {
        let alertController = UIAlertController( title:"Delete Any User From Chatroom:", message:nil,preferredStyle:UIAlertControllerStyle.alert)
        let userRef = channelRef!.child("users")
        userRef.observe(.childAdded, with: { (snapshot) -> Void in
            if(snapshot.value as! String! != self.email) {
                let action = UIAlertAction(title:snapshot.key, style:UIAlertActionStyle.default,
                                           handler:self.handleDelete)
                alertController.addAction(action)
            }
        })
        let cancelAction = UIAlertAction(title:"Cancel", style:UIAlertActionStyle.default,handler:nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated:true, completion:nil)
    }
    
    func handleDelete(alert: UIAlertAction!) {
        let deleteRef = channelRef!.child("users").child(alert.title!)
        deleteRef.removeValue()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if(segue.identifier == "AddUser") {
            let chatVc = segue.destination as! ModelViewController
            chatVc.channelRef = channelRef
            chatVc.email = email
        }else {
            let chatvc = segue.destination as! RoomListTableViewController
            chatvc.email = email
            chatvc.senderDisplayName = senderDisplayName
        }
    }
}
