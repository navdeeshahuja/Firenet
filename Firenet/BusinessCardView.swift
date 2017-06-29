//
//  BusinessCardView.swift
//  Firenet
//
//  Created by Navdeesh Ahuja on 21/06/17.
//  Copyright © 2017 Navdeesh Ahuja. All rights reserved.
//

import UIKit

class BusinessCardView: UIView {

    
    @IBOutlet var profileLinkLabel: UILabel!
    
    @IBOutlet var occupationLabel: UILabel!
    
    @IBOutlet var mobileLabel: UILabel!
    
    @IBOutlet var emailLabel: UILabel!
    
    @IBOutlet var innerView: UIView!
    
    @IBOutlet var businessCardImageView: UIImageView!
    
    @IBOutlet var mainView: BusinessCardView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("BusinessCardView", owner: self, options: nil)
        mainView.frame = frame
        innerView.layer.cornerRadius = 10
        innerView.clipsToBounds = true
        self.addSubview(mainView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    @IBOutlet var nameLabel: UILabel!

}
