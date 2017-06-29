//
//  ShowCardsViewController.swift
//  Firenet
//
//  Created by Navdeesh Ahuja on 21/06/17.
//  Copyright © 2017 Navdeesh Ahuja. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth

class UploadPicture: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    
    var ref: DatabaseReference!
    
    let loader = ActivityViewIndicator()
    
    var picker:UIImagePickerController?=UIImagePickerController()
    
    var popover:UIPopoverPresentationController?=nil
    
    var photoSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.clipsToBounds = true
        
        imageView.layer.cornerRadius = 75

        let gradient: CAGradientLayer = CAGradientLayer()
        
        let color1 = UIColor(red: 63/255.0, green: 62/255.0, blue: 158/255.0, alpha: 1).cgColor
        let color2 = UIColor(red: 207/255.0, green: 136/255.0, blue: 237/255.0, alpha: 1).cgColor
        gradient.colors = [color1, color2]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        self.view.layer.insertSublayer(gradient, at: 0)
        
        picker?.delegate = self
        
        ref = Database.database().reference()
        
    }

    

    @IBAction func uploadPictureButtonDidPress(_ sender: UIButton)
    {
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        {
            UIAlertAction in
        }
        
        picker?.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            popover=UIPopoverPresentationController(presentedViewController: self, presenting: alert)
            popover?.sourceRect = imageView.frame
        }
    }
    
    @IBAction func uploadButtonDidPress(_ sender: UIButton)
    {
        if(!photoSelected)
        {
            Alert().showError("Please select a image", self)
            return
        }
        
        
        let smallImage = ResizeImage().resize(image: imageView.image!, newWidth: 150)
        
        if let imageData = UIImagePNGRepresentation(smallImage)
        {
            let uid = Globals.uid
            let imageDataEncodedString = imageData.base64EncodedString()
            Globals.postDict["imageData"] = imageDataEncodedString
            self.ref.child("Users").child(uid).setValue(Globals.postDict)
            loader.show(self.view, "Setting up the satellites...")
            Timer.scheduledTimer(withTimeInterval: 4, repeats: false, block: {
                _ in
                
                self.loader.hide()
                
                let showCardsViewController = self.storyboard!.instantiateViewController(withIdentifier: "ShowCardsViewController")
                Globals.loggedIn = true
                self.present(showCardsViewController, animated: true, completion: nil)
                
            })
            
            
        }
        else
        {
            Alert().showError("Some Error", self)
        }
        
        
        
        
        
        
        
        
        
        
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            picker!.sourceType = UIImagePickerControllerSourceType.camera
            self .present(picker!, animated: true, completion: nil)
        }
    }
    
    func openGallery()
    {
        picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(picker!, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        picker .dismiss(animated: true, completion: nil)
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage

        photoSelected = true
        
        
        
    }
    
}
