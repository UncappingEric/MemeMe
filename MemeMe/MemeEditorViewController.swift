//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Eric Cajuste on 10/10/17.
//  Copyright © 2017 Cajuste. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topField: UITextField!
    @IBOutlet weak var bottomField: UITextField!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    var savedMeme: Meme?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        subscribeToKeyboardHidindNotifications()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        let memeTextAttributes:[String:Any] = [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
            NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue: -3]
        
        configureTextField(topField, memeTextAttributes)
        configureTextField(bottomField, memeTextAttributes)
        
        if imageView.image == nil {
            shareButton.isEnabled = false
        }
    }
    
    func configureTextField(_ field: UITextField, _ attributes: [String:Any]) {
        field.defaultTextAttributes = attributes
        field.textAlignment = .center
        field.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        unsubscribeFromKeyboardHidingNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    // MARK: PhotoPicker Methods
    
    @IBAction func photoPicker(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = cameraButton.tag == (sender as! UIButton).tag ? .camera : .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Delegate Functions
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            //imageView.contentMode = .scaleToFill
        }
        
        dismiss(animated: true, completion: {self.shareButton.isEnabled = true})
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == topField {
            unsubscribeFromKeyboardNotifications()
        }
        
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == topField {
            subscribeToKeyboardNotifications()
        }
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Keyboard Functions
    
    @objc func keyboardWillShow(_ notification:Notification) {
        view.frame.origin.y = 0 - getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    func subscribeToKeyboardHidindNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardHidingNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    // MARK: Saving Functions
    
    func saveMeme() {
        savedMeme = Meme(top: topField.text!, bottom: bottomField.text!, original: imageView.image!, meme: generateMeme())
    }
    
    func generateMeme() -> UIImage {
        
        // Hide Toolbars and Navbar
        topToolbar.isHidden = true
        bottomToolbar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        
        // Snap Meme
        UIGraphicsBeginImageContext(imageView.frame.size)
        view.drawHierarchy(in: view.frame.offsetBy(dx: 0, dy: -imageView.frame.origin
            .y), afterScreenUpdates: true)
        let meme:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show Toolbars and Nav
        topToolbar.isHidden = false
        bottomToolbar.isHidden = false
        navigationController?.navigationBar.isHidden = false
        
        return meme
    }
    
    @IBAction func shareMeme() {
        let meme = generateMeme()
        
        let controller = UIActivityViewController(activityItems: [meme], applicationActivities: nil)
        present(controller, animated: true, completion:{self.saveMeme()})
    }
}

