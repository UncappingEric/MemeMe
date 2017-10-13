//
//  ViewController.swift
//  MemeMe
//
//  Created by Eric Cajuste on 10/10/17.
//  Copyright © 2017 Cajuste. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topField: UITextField!
    @IBOutlet weak var bottomField: UITextField!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    var savedMeme: Meme?
    
    //MARK: Meme Structure
    
    struct Meme {
        var top: String
        var bottom: String
        var original: UIImage
        var meme: UIImage
        
        init(top: String, bottom: String, original: UIImage, meme: UIImage) {
            self.top = top
            self.bottom = bottom
            self.original = original
            self.meme = meme
        }
    }
    
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
        
        topField.defaultTextAttributes = memeTextAttributes
        topField.textAlignment = .center
        topField.delegate = self
        bottomField.defaultTextAttributes = memeTextAttributes
        bottomField.textAlignment = .center
        bottomField.delegate = self
        shareButton.isEnabled = false
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
    
    @IBAction func photoPickerFromAlbum(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func photoPickerFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
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
        switch textField {
        case topField:
            unsubscribeFromKeyboardNotifications()
            if textField.text == "TOP" {
                textField.text = ""
            }
        default:
            if textField.text == "BOTTOM" {
                textField.text = ""
            }
        }
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
        
        topToolbar.isHidden = true
        bottomToolbar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let meme:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        
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

