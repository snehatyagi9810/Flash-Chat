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
    
    
    var messages : [Message] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        messageTextfield.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        navigationItem.hidesBackButton =  true
        title = K.appName
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        loadMessages()
        
    }
    
    func loadMessages(){
      
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener{ (querySnapshot, error) in
            
            self.messages = []
            
            if let e = error {
                print(" there is an issue in retrieving data\(e)")
            } else{
                if let snapShotDocuments = querySnapshot?.documents{
                    for doc in snapShotDocuments{
                        let data = doc.data()
                        if   let sender = data[K.FStore.senderField] as? String, let body = data[K.FStore.bodyField] as? String{
                            let newMessage = Message(sender: sender, body: body)
                            self.messages.append(newMessage)
                            
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath  = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                           
                        }
                    }
                }
            }
        }
    }
        @IBAction func sendPressed(_ sender: UIButton) {
            
            if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email{
                db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.senderField : messageSender, K.FStore.bodyField: messageBody, K.FStore.dateField : Date().timeIntervalSince1970]) { error in
                    if let e = error {
                        print(e)
                    } else{
                        print("Sucessfully added message")
                        DispatchQueue.main.async{
                            self.messageTextfield.text = ""
                        }
                        
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


extension ChatViewController: UITableViewDataSource, UITableViewDelegate , UITextFieldDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.body
        
        // This is a message from current sender
        if message.sender == Auth.auth().currentUser?.email{
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        }
        
        // This is a message from the another user
        else{
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
            
        }
        
        
        return cell
    }
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        print("Keyboard appear")
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        messageTextfield.resignFirstResponder()
//    }
  
    }


