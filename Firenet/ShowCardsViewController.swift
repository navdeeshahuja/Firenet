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
import FirebaseAuth
import FirebaseDatabase

class ShowCardsViewController: UIViewController {
    
    @IBOutlet var eventNameLabel: UILabel!
    
    @IBOutlet var mainScrollView: UIScrollView!
    
    static var profilesArray = [[String:Any]]()
    
    var ref: DatabaseReference!
    
    let loader = ActivityViewIndicator()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let gradient: CAGradientLayer = CAGradientLayer()
        
        let color1 = UIColor(red: 63/255.0, green: 62/255.0, blue: 158/255.0, alpha: 1).cgColor
        let color2 = UIColor(red: 207/255.0, green: 136/255.0, blue: 237/255.0, alpha: 1).cgColor
        gradient.colors = [color1, color2]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        self.view.layer.insertSublayer(gradient, at: 0)
        
        
        ref = Database.database().reference()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loader.show(self.view, "Getting the people near you...")
        ref.child("Users").observeSingleEvent(of: .value, with: { snapshot in
            
            if let dict = snapshot.value as? [String:Any]
            {
                for key in Array(dict.keys)
                {
                    if let profileObject = dict[key] as? [String:Any]
                    {
                        ShowCardsViewController.profilesArray.insert(profileObject, at: 0)
                    }
                }
                self.bringUsersToInterface()
            }
            
            
        
            

        })
        
    }
    
    func bringUsersToInterface()
    {
        loader.hide()
        
        
        let pagerWidth = self.view.frame.width * 0.8
        
        for i in 0..<ShowCardsViewController.profilesArray.count
        {
            let profile = ShowCardsViewController.profilesArray[i]
            if let imageDataString = profile["imageData"] as? String
            {
                if let imageData = Data(base64Encoded: imageDataString, options: .ignoreUnknownCharacters)
                {
                    if let profileImage = UIImage(data: imageData)
                    {
                        let newView = BusinessCardView(frame: CGRect(x: 0, y: 0, width: pagerWidth, height: mainScrollView.frame.height))
                        
                        newView.frame.origin.x = pagerWidth * CGFloat(i)
                        
                        newView.businessCardImageView.image = profileImage
                        
                        if let name = profile["name"] as? String
                        {
                            newView.nameLabel.text = "Name: "+name
                        }
                        if let profileLink = profile["profileLink"] as? String
                        {
                            newView.profileLinkLabel.text = "Link: "+profileLink
                        }
                        if let pno = profile["pno"] as? String
                        {
                            newView.mobileLabel.text = "Mobile: "+pno
                        }
                        if let occupation = profile["occupation"] as? String
                        {
                            newView.occupationLabel.text = "Occupation: "+occupation
                        }
                        if let email = profile["email"] as? String
                        {
                            newView.emailLabel.text = "Email: "+email
                        }
                        
                        newView.businessCardImageView.layer.cornerRadius = 75
                        
                        newView.businessCardImageView.clipsToBounds = true
                        
                        newView.clipsToBounds = true
                        
                        mainScrollView.addSubview(newView)
                    }
                }
                else
                {
                    print("didntGot")
                }
            }
            
            
            
            
        }
        
        mainScrollView.isPagingEnabled = true
        mainScrollView.contentSize = CGSize(width: pagerWidth * CGFloat(ShowCardsViewController.profilesArray.count), height: mainScrollView.frame.height)
        
        
        
    }
    

}
