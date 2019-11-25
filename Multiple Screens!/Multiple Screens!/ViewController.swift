//
//  ViewController.swift
//  Multiple Screens!
//
//  Created by Bo Yan on 10/30/19.
//  Copyright © 2019 Bo Yan. All rights reserved.
//

import UIKit
import os.log

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var contact: Contacts?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoImageView.isUserInteractionEnabled = true
        nameTextField.delegate = self
        nameTextField.tag = 1
        phoneNumberTextField.delegate = self
        phoneNumberTextField.tag = 2
        
        if let contact = contact {
            navigationItem.title = contact.name
            nameLabel.text = contact.name
            phoneNumberLabel.text = contact.phoneNumber
            photoImageView.image = contact.photo
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let addMode = presentingViewController is UINavigationController
        if addMode{
            dismiss(animated: true, completion: nil)
        }
        else if let back = navigationController{
            back.popViewController(animated: true)
        }
        else{
            fatalError("The ContactsViewController is not inside a navigation controller.")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        let name = nameLabel.text ?? ""
        let phoneNumber = phoneNumberLabel.text ?? ""
        let photo = photoImageView.image
        
        contact = Contacts(name: name, phoneNumber: phoneNumber, photo: photo)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(nameTextField.isFirstResponder){
            phoneNumberTextField.becomeFirstResponder()
        }else{
            nameTextField.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField.tag == 1){
            if(textField.text != ""){
                nameLabel.text = textField.text
            }
        }else{
            if(textField.text != ""){
                phoneNumberLabel.text = textField.text
            }
        }
        navigationItem.title = nameLabel.text
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        photoImageView.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        if(nameTextField.isFirstResponder){
            nameTextField.resignFirstResponder()
        }else{
            phoneNumberTextField.resignFirstResponder()
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func loadFromCloud(_ sender: UIButton) {
        guard let url = URL(string: "https://cs.binghamton.edu/~pmadden/courses/441score/getscores.php") else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard let dataResponse = data,
                  error == nil else {
                  print(error?.localizedDescription ?? "Response Error")
                  return }
            do{
                //here dataResponse received from a network request
                let jsonResponse = try JSONSerialization.jsonObject(with:
                                       dataResponse, options: [])
                guard let jsonArray = jsonResponse as? [[String: Any]] else {
                      return
                }
                guard let name = jsonArray[9]["player"] as? String else { return }
                guard let phoneNumber = jsonArray[9]["score"] as? String else { return }
                DispatchQueue.main.async { // Correct
                    self.nameLabel.text = name
                    self.phoneNumberLabel.text = phoneNumber
                    self.navigationItem.title = self.nameLabel.text
                }
             } catch let parsingError {
                print("Error", parsingError)
           }
        }
        task.resume()
    }
    
    @IBAction func saveToCloud(_ sender: UIButton) {
        let name:String = self.nameLabel.text!
        let phoneNumber:String = self.phoneNumberLabel.text!
        let urlStr = "https://cs.binghamton.edu/~pmadden/courses/441score/postscore.php?player=" + name + "&game=Contacts&score=" + phoneNumber
        let session = URLSession.shared
        let url = URL(string: urlStr)!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let json = [
            "player": "B",
            "game": "C",
            "score": "0"
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        let task = session.uploadTask(with: request, from: jsonData) { data, response, error in
            // Do something...
        }
        task.resume()
    }
}

