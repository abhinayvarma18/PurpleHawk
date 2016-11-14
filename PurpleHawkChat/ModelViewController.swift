//
//  ModelViewController.swift
//  PurpleHawkChat
//
//  Created by Abhinay Varma on 14/11/16.
//  Copyright © 2016 Abhinay Varma. All rights reserved.
//

import UIKit
import Firebase

class ModelViewController: UITableViewController {
    var channelRef: FIRDatabaseReference?
    var email: String!
private lazy var userRef: FIRDatabaseReference = FIRDatabase.database().reference().child("users")
    @IBOutlet weak var user: UITextField!
    private var valueArray: [String] = []
    private var keyArray: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.channelRef!.child("users").observeSingleEvent(of: .value, with: { snapshot1 in
            var channelUsers = snapshot1.value as! Dictionary<String, String>
            self.userRef.observeSingleEvent(of: .value, with: { snapshot in
                let channelData = snapshot.value as! Dictionary<String, AnyObject>
                var flag = Bool(true)
                for (key,value) in channelData {
                    for (key1,value1) in channelUsers {
                        if(value as? String == value1) {
                            flag = false
                        }
                    }
                    if(flag) {
                        self.valueArray.append(value as! String)
                        self.keyArray.append(key)
                    }else{
                        flag = true
                    }
                    
                }
                self.tableViewValue.reloadData()
            })
        })
        
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var tableViewValue: UITableView!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return valueArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewValue.dequeueReusableCell(
            withIdentifier: "cell", for: indexPath as IndexPath)
        cell.textLabel?.text = keyArray[(indexPath as NSIndexPath).row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let addValue = channelRef!.child("users").child(self.keyArray[(indexPath as NSIndexPath).row])
        addValue.setValue(self.valueArray[(indexPath as NSIndexPath).row])
        valueArray.remove(at: (indexPath as NSIndexPath).row)
        keyArray.remove(at: (indexPath as NSIndexPath).row)
        tableViewValue.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        let alert = UIAlertController(title: "Alert", message: "Succesfully added in the chatroom", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        super.prepare(for: segue, sender: sender)
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
