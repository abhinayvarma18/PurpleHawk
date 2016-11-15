//
//  LoginViewController.swift
//  PurpleHawkChat
//
//  Created by Abhinay Varma on 13/11/16.
//  Copyright © 2016 Abhinay Varma. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var email: UITextField!

    @IBOutlet weak var senderName: UITextField!
    
    private lazy var userRef: FIRDatabaseReference = FIRDatabase.database().reference().child("users")
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let navVc = segue.destination as! UINavigationController
        let channelVc = navVc.viewControllers.first as! RoomListTableViewController
        
        channelVc.senderDisplayName = senderName?.text
        channelVc.email = email?.text
        
        userRef.observeSingleEvent(of: .value, with: { snapshot in
            let emails = snapshot.value as! Dictionary<String, AnyObject>
            var flag = true
            for (_,value) in emails {
                if(value as! String == self.email.text!) {
                    flag = false
                }
            }
            if(flag) {
                let userNode = self.userRef.child((self.senderName?.text)! as String)
                userNode.setValue(self.email?.text)
            }
        })
        
    }

    @IBAction func loginAction(_ sender: Any) {
        if senderName?.text != "" {
            FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
                if let err:Error = error {
                    print(err.localizedDescription)
                    return
                }
                
                self.performSegue(withIdentifier: "LoginToChat", sender: nil)
            })
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
