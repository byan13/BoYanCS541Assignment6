//
//  ContactsTableViewController.swift
//  Multiple Screens!
//
//  Created by Bo Yan on 11/3/19.
//  Copyright © 2019 Bo Yan. All rights reserved.
//

import UIKit
import os.log

class ContactsTableViewController: UITableViewController {
    var contactss = [Contacts]()
    
    private func saveContacts() {
//        let isSuccessfullySaved = NSKeyedArchiver.archiveRootObject(contactss, toFile: Contacts.ArchiveURL.path)
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: contactss, requiringSecureCoding: false)
            try data.write(to: Contacts.ArchiveURL)
            os_log("Contacts successfully saved.", log: OSLog.default, type: .debug)
        } catch  {
            os_log("Failed to save contacts.", log: OSLog.default, type: .error)
        }
//        if isSuccessfullySaved {
//            os_log("Contacts successfully saved.", log: OSLog.default, type: .debug)
//        } else {
//            os_log("Failed to save contacts.", log: OSLog.default, type: .error)
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        if let savedContacts = loadContacts() {
            contactss += savedContacts
        } else {
            loadSampleContacts()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactss.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsTableViewCell", for: indexPath) as? ContactsTableViewCell else {
            fatalError("The dequeued cell is not an instance of ContactsTableViewCell")
        }

        let contacts = contactss[indexPath.row]
        cell.nameLabel.text = contacts.name
        cell.phoneNumberLabel.text = contacts.phoneNumber
        cell.photoImageView.image = contacts.photo

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            contactss.remove(at: indexPath.row)
            saveContacts()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "AddContact":
            os_log("Adding a new contact.", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let contactDetailViewController = segue.destination as? ViewController
                else{
                fatalError("Unexpected destinition: \(segue.destination)")
            }
            guard let selectedContactCell = sender as? ContactsTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            guard let indexPath = tableView.indexPath(for: selectedContactCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let selectedContact = contactss[indexPath.row]
            contactDetailViewController.contact = selectedContact
        default:
            fatalError("Unexpected segue identifier: \(segue.identifier)")
        }
    }
    
    @IBAction func unwindToContactList(sender: UIStoryboardSegue){
        if let sourceViewController = sender.source as?
            ViewController, let contact = sourceViewController.contact{
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow{
                contactss[selectedIndexPath.row] = contact
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }else {
                let newIndexPath = IndexPath(row: contactss.count, section: 0)
                contactss.append(contact)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            saveContacts()
        }
    }
    
    private func loadSampleContacts(){
        let defaultPhoto = UIImage(named: "defaultPhoto")
        let samplePhoto = UIImage(named: "samplePhoto")
        guard let contact1 = Contacts(name: "Patrick", phoneNumber: "6077772943", photo: samplePhoto) else{
            fatalError("Unable to instantiate contact1")
        }
        guard let contact2 = Contacts(name: "H", phoneNumber: "6077772943", photo: defaultPhoto) else{
            fatalError("Unable to instantiate contact2")
        }
        guard let contact3 = Contacts(name: "Madden", phoneNumber: "6077772943", photo: defaultPhoto) else{
            fatalError("Unable to instantiate contact3")
        }
        contactss += [contact1, contact2, contact3]
    }

    private func loadContacts() -> [Contacts]? {
        do {
            if let loadedContacts = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Data(referencing: NSData(contentsOf: Contacts.ArchiveURL))) as? [Contacts]{
                return loadedContacts
            }
        } catch  {
            os_log("Failed to load contacts", log: OSLog.default, type: .error)
            return nil
        }
        return nil
//        return NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Data(referencing: NSData(contentsOf: Contacts.ArchiveURL))) as? [Contacts]
    }
}
