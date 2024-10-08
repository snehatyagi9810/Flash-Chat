//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    
    var message : [Message] = [Message(sender: "1@2.com", body: "Hey!"), Message(sender: "a@b.com", body: "Hello!"), Message(sender: "1@2.com", body: "Whats up?") ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        navigationItem.hidesBackButton =  true
        title = K.appName
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
    }
        @IBAction func sendPressed(_ sender: UIButton) {
            
            if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email{
                db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.senderField : messageSender, K.FStore.bodyField: messageBody]) { error in
                    if let e = error {
                        print(e)
                    } else{
                        print("Sucessfully added message")
                    }
                }
                
            }
           
            
            
            
            
        }
        
        @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
            do {
                try Auth.auth().signOut()
                navigationController?.popToRootViewController(animated: true)
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
            
        }
    }


extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return message.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message[indexPath.row].body
        return cell
       
    }
    
    
    
}
