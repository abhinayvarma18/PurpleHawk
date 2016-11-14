//
//  ModelViewController.swift
//  PurpleHawkChat
//
//  Created by Abhinay Varma on 14/11/16.
//  Copyright © 2016 Abhinay Varma. All rights reserved.
//

import UIKit
import Firebase

class ModelViewController: UIViewController {
    var channelRef: FIRDatabaseReference?
private lazy var userRef: FIRDatabaseReference = FIRDatabase.database().reference().child("users")
    @IBOutlet weak var user: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func CheckUser(_ sender: Any) {
    
        userRef.observeSingleEvent(of: .value, with: { snapshot in
            let channelData = snapshot.value as! Dictionary<String, AnyObject>
            for (key,value) in channelData {
                if(value as! String == self.user.text!) {
                    let useraddRef = self.channelRef!.child("users").child(key)
                    useraddRef.setValue(value as! String)
                    let alert = UIAlertController(title: "Alert", message: "Added Successfully", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
        
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
