//
//  ViewController.swift
//  Firenet
//
//  Created by Navdeesh Ahuja on 21/06/17.
//  Copyright © 2017 Navdeesh Ahuja. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate {
    
    var ref: DatabaseReference!
    
    @IBOutlet var detailsCardView: UIView!

    @IBOutlet var occupationTextField: FloatingTextLabel!
    
    @IBOutlet var profileLinkTextField: FloatingTextLabel!
    
    @IBOutlet var passwordTextField: FloatingTextLabel!
    
    @IBOutlet var mobileTextField: FloatingTextLabel!
    
    @IBOutlet var emailTextField: FloatingTextLabel!
    
    var keyboardShown = false
    
    @IBOutlet var nameTextField: FloatingTextLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        let gradient: CAGradientLayer = CAGradientLayer()
        
        let color1 = UIColor(red: 63/255.0, green: 62/255.0, blue: 158/255.0, alpha: 1).cgColor
        let color2 = UIColor(red: 207/255.0, green: 136/255.0, blue: 237/255.0, alpha: 1).cgColor
        gradient.colors = [color1, color2]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        self.view.layer.insertSublayer(gradient, at: 0)
        
        occupationTextField.delegate = self
        profileLinkTextField.delegate = self
        passwordTextField.delegate = self
        mobileTextField.delegate = self
        emailTextField.delegate = self
        nameTextField.delegate = self
        
        detailsCardView.clipsToBounds = true
        detailsCardView.layer.cornerRadius = 10
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func keyboardWillShow(_ notification:NSNotification)
    {
        if(keyboardShown)
        {
            return
        }
        
        self.view.frame.origin.y -=  100
        keyboardShown = true
    }
    
    func keyboardWillHide()
    {
        self.view.frame.origin.y = 0
        keyboardShown = false
    }
    
    func resignAllFirstResponders()
    {
        occupationTextField.resignFirstResponder()
        profileLinkTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        mobileTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        resignAllFirstResponders()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        resignAllFirstResponders()
        return true
    }
    
    func isEmptyTextField(_ textField:UITextField) -> Bool
    {
        if let text = textField.text
        {
            if(text == "")
            {
                return true
            }
        }
        
        return false
    }
    
    func textInside(_ textField:UITextField) -> String
    {
        if let text = textField.text
        {
            return text
        }
        
        return ""
    }
    
    
    
    @IBAction func createButtonDidPress(_ sender: UIButton)
    {
        
        if(isEmptyTextField(nameTextField) ||
            isEmptyTextField(emailTextField) ||
            isEmptyTextField(passwordTextField) ||
            isEmptyTextField(mobileTextField) ||
            isEmptyTextField(profileLinkTextField) ||
            isEmptyTextField(occupationTextField)
            )
        {
            Alert().showError("Please fill all the fields", self)
            return
        }
        
        
        let loader = ActivityViewIndicator()
        
        var currentLocation = CLLocation()
        var latitude = ""
        var longitude = ""
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            
            currentLocation = AppDelegate.locManager.location!
            latitude = "\(currentLocation.coordinate.latitude)"
            longitude = "\(currentLocation.coordinate.longitude)"
            
        }
        
        if(latitude == "" || longitude == "")
        {
            Alert().showError("We cannot fetch your location, please go to settings and provide the requireed permisssions", self)
            return
        }
        
        
        
            loader.show(self.view, "Getting you onboard...")
            Auth.auth().createUser(withEmail: textInside(emailTextField), password: textInside(passwordTextField)) { (user, error) in
                
                loader.hide()
                
                print(user ?? "noUser", error ?? "noError")
                if let _ = error
                {
                    Alert().showError("There was some error", self)
                    return
                }
                
                if let user = user
                {
                    
                    let postDict = [
                        "pno" : self.textInside(self.mobileTextField),
                        "profileLink" : self.textInside(self.profileLinkTextField),
                        "occupation" : self.textInside(self.occupationTextField),
                        "name" : self.textInside(self.nameTextField),
                        "email" : self.textInside(self.emailTextField),
                        "latitude" : latitude,
                        "longitude" : longitude,
                        "imageData" : ""
                    ]
                    
                    self.ref.child("Users").child(user.uid).setValue(postDict)
                    
                    self.performSegue(withIdentifier: "signupToTakeImageSegue", sender: nil)
                    
                    Globals.postDict = postDict
                    
                    Globals.uid = user.uid
                }
                
                
                
            }
        
    }

   


}





class Globals
{
    static var postDict : [String:String]{
        get{
            if let decoded  = UserDefaults.standard.object(forKey: "postDict") as? Data
            {
                if let decodedDictionary = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [String:String]
                {
                    return decodedDictionary
                }
                else
                {
                    print("here 2222")
                }
            }
            else
            {
                print("here 111111")
            }
            
            return [String:String]()
        }
        set(newValue){
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: newValue)
            UserDefaults.standard.set(encodedData, forKey: "postDict")
        }
    }
    
    static var uid : String{
        get{
            if let str = UserDefaults.standard.value(forKey: "uid") as? String
            {
                return str
            }
            return ""
            
        }
        set(newValue){
            UserDefaults.standard.set(newValue, forKey: "uid")
        }
    }
    
    static var loggedIn : Bool{
        get{
            if let str = UserDefaults.standard.value(forKey: "loggedIn") as? Bool
            {
                return str
            }
            return false
            
        }
        set(newValue){
            UserDefaults.standard.set(newValue, forKey: "loggedIn")
        }
    }
}
