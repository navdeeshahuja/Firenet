//
//  SupportingFiles.swift
//  Crew
//
//  Created by Navdeesh Ahuja on 17/04/17.
//  Copyright © 2017 Navdeesh Ahuja. All rights reserved.
//

import UIKit
import Foundation

class CheckBox: UIButton {
    // Images
    let checkedImage = UIImage(named: "ic_check_box")! as UIImage
    let uncheckedImage = UIImage(named: "ic_check_box_outline_blank")! as UIImage
    
    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, for: .normal)
            } else {
                self.setImage(uncheckedImage, for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(buttonClicked), for: UIControlEvents.touchUpInside)
        self.isChecked = false
    }
    
    func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}


extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}






class Request
{
    var domainName:[String] = ["http://54.190.52.112"]
    
    func post(link: String, postData:Dictionary<String, Any>, callback: @escaping (String, Dictionary<String, Any>) -> Void) {
        
        //print(postData)
        
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        
        //        print(NSString(data: jsonData!, encoding: String.Encoding.utf8.rawValue) ?? "mmmm")
        
        if(jsonData == nil)
        {
            callback("errorInParsingJson", [:])
            return
        }
        
        let reqDomain = domainName.randomItem()
        //print(reqDomain)
        let url = URL(string: (reqDomain)+link)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            
            
            if(error != nil || data == nil || response == nil)
            {
                DispatchQueue.main.async {
                    callback("errorInInternet", [:])
                }
                return
            }
            
            
            print("\n\n\n\n\nresponse")
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue) ?? "nnn")
            print("response\n\n\n\n\n")
            
            
            DispatchQueue.main.async {
                let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: [])
                if(jsonObject == nil)
                {
                    callback("errorInParsingResponseJson", [:])
                    return
                }
                
                callback("OK", jsonObject as! [String:Any])
            }
            
        }
        
        task.resume()
        
    }
    
    func get(link: String, callback: @escaping (String, Dictionary<String, Any>) -> Void) {
        
        let url = URL(string: (domainName.randomItem())+link)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            
            //print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue) ?? "nnn")
            
            if(error != nil || data == nil || response == nil)
            {
                DispatchQueue.main.async {
                    callback("errorInInternet", [:])
                }
                return
            }
            DispatchQueue.main.async {
                let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: [])
                if(jsonObject == nil)
                {
                    callback("errorInParsingResponseJson", [:])
                    return
                }
                
                callback("OK", jsonObject as! [String:Any])
            }
            
        }
        
        task.resume()
        
    }
}








































open class FloatingTextLabel: UITextField {
    
    override open func draw(_ rect: CGRect) {
        
        let startingPoint   = CGPoint(x: rect.minX, y: rect.maxY)
        let endingPoint     = CGPoint(x: rect.maxX, y: rect.maxY)
        
        let path = UIBezierPath()
        
        path.move(to: startingPoint)
        path.addLine(to: endingPoint)
        path.lineWidth = 2.0
        
        inactiveTextColorfloatingLabel.setStroke()
        
        path.stroke()
    }
    
    
    open var floatingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    @IBInspectable open var activeTextColorfloatingLabel : UIColor = UIColor.blue {
        didSet {
            floatingLabel.textColor = activeTextColorfloatingLabel
        }
    }
    
    @IBInspectable open var inactiveTextColorfloatingLabel : UIColor = UIColor(white: 0.7, alpha: 1.0) {
        didSet {
            floatingLabel.textColor = inactiveTextColorfloatingLabel
        }
    }
    
    
    open var placeHolderTextSize : String = UIFontTextStyle.caption2.rawValue {
        didSet {
            floatingLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle(rawValue: placeHolderTextSize))
        }
    }
    
    
    fileprivate var cachedPlaceholder = NSString()
    
    fileprivate var shouldDrawPlaceholder = true
    
    open var verticalPadding : CGFloat = 0
    open var horizontalPadding : CGFloat = 0
    
    
    override convenience init(frame: CGRect) {
        self.init(frame: frame)
        setup()
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init () {
        fatalError("Using the init() initializer directly is not supported. use init(frame:) instead")
    }
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    override open var placeholder : String? {
        get {
            return super.placeholder
        }
        set (newValue) {
            super.placeholder = newValue
            if (cachedPlaceholder as String != newValue) {
                cachedPlaceholder = newValue! as NSString
                floatingLabel.text = self.cachedPlaceholder as String
                floatingLabel.sizeToFit()
            }
        }
    }
    
    override open var hasText :Bool {
        return !text!.isEmpty
    }
    
    
    fileprivate func setup() {
        setupObservers()
        setupFloatingLabel()
        applyFonts()
        setupViewDefaults()
    }
    
    fileprivate func setupObservers() {
        NotificationCenter.default.addObserver(self, selector:#selector(FloatingTextLabel.textFieldTextDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FloatingTextLabel.fontSizeDidChange), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(FloatingTextLabel.textFieldTextDidBeginEditing), name: NSNotification.Name.UITextFieldTextDidBeginEditing, object: self)
        NotificationCenter.default.addObserver(self, selector:#selector(FloatingTextLabel.textFieldTextDidEndEditing), name: NSNotification.Name.UITextFieldTextDidEndEditing, object: self)
    }
    
    fileprivate func setupFloatingLabel() {
        
        floatingLabel.alpha = 1
        floatingLabel.center = CGPoint(x: horizontalPadding, y: verticalPadding)
        addSubview(floatingLabel)
        
        
        
        floatingLabel.textColor = inactiveTextColorfloatingLabel
        floatingLabel.alpha = 0
        
    }
    
    fileprivate func applyFonts() {
        
        
        floatingLabel.font = UIFont(name: font!.fontName, size: UIFont.preferredFont(forTextStyle: UIFontTextStyle(rawValue: placeHolderTextSize)).pointSize)
    }
    
    fileprivate func setupViewDefaults() {
        
        
        verticalPadding = 0.5 * self.frame.height
        
        
        if let ph = placeholder {
            placeholder = ph
        } else {
            placeholder = ""
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        if (isFirstResponder && !hasText) {
            hideFloatingLabel()
        } else if(hasText) {
            showFloatingLabelWithAnimation(true)
        }
    }
    
    func showFloatingLabelWithAnimation(_ isAnimated : Bool)
    {
        let fl_frame = CGRect(
            x: horizontalPadding,
            y: 0,
            width: self.floatingLabel.frame.width,
            height: self.floatingLabel.frame.height
        )
        if (isAnimated) {
            let options: UIViewAnimationOptions = [UIViewAnimationOptions.beginFromCurrentState, UIViewAnimationOptions.curveEaseOut]
            UIView.animate(withDuration: 0.2, delay: 0, options: options, animations: {
                self.floatingLabel.alpha = 1
                self.floatingLabel.frame = fl_frame
            }, completion: nil)
        } else {
            self.floatingLabel.alpha = 1
            self.floatingLabel.frame = fl_frame
        }
    }
    
    func hideFloatingLabel () {
        let fl_frame = CGRect(
            x: horizontalPadding,
            y: verticalPadding,
            width: self.floatingLabel.frame.width,
            height: self.floatingLabel.frame.height
        )
        let options: UIViewAnimationOptions = [UIViewAnimationOptions.beginFromCurrentState, UIViewAnimationOptions.curveEaseIn]
        UIView.animate(withDuration: 0.2, delay: 0, options: options, animations: {
            self.floatingLabel.alpha = 0
            self.floatingLabel.frame = fl_frame
        }, completion: nil
        )
    }
    
    override open var intrinsicContentSize : CGSize {
        return sizeThatFits(frame.size)
    }
    
    override open func textRect (forBounds bounds :CGRect) -> CGRect
    {
        return UIEdgeInsetsInsetRect(super.textRect(forBounds: bounds), floatingLabelInsets())
    }
    
    override open func editingRect (forBounds bounds : CGRect) ->CGRect
    {
        return UIEdgeInsetsInsetRect(super.editingRect(forBounds: bounds), floatingLabelInsets())
    }
    
    
    fileprivate func floatingLabelInsets() -> UIEdgeInsets {
        floatingLabel.sizeToFit()
        return UIEdgeInsetsMake(
            floatingLabel.font.lineHeight,
            horizontalPadding,
            0,
            horizontalPadding)
    }
    
    
    
    func textFieldTextDidChange(_ notification : Notification) {
        let previousShouldDrawPlaceholderValue = shouldDrawPlaceholder
        shouldDrawPlaceholder = !hasText
        
        
        if (previousShouldDrawPlaceholderValue != shouldDrawPlaceholder) {
            if (self.shouldDrawPlaceholder) {
                hideFloatingLabel()
            } else {
                showFloatingLabelWithAnimation(true)
            }
        }
    }
    
    func textFieldTextDidEndEditing(_ notification : Notification) {
        if (hasText)  {
            floatingLabel.textColor = inactiveTextColorfloatingLabel
        }
    }
    
    func textFieldTextDidBeginEditing(_ notification : Notification) {
        floatingLabel.textColor = activeTextColorfloatingLabel
    }
    
    
    func fontSizeDidChange (_ notification : Notification) {
        applyFonts()
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }
    
}


























extension String {
    
    static func random(length: Int = 30) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.characters.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}























class Alert
{
    func showError(_ message:String, _ viewController:UIViewController)
    {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func showSuccess(_ message:String, _ viewController:UIViewController)
    {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}





























class ActivityViewIndicator
{
    var activityViewIndicator = UIActivityIndicatorView()
    var label = UILabel()
    
    func show(_ view:UIView, _ message:String, _ size:CGFloat = 17)
    {
        activityViewIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        activityViewIndicator.startAnimating()
        activityViewIndicator.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        activityViewIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.text = message
        label.font = label.font.withSize(size)
        label.sizeToFit()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.center = CGPoint(x: view.center.x, y: view.center.y + 36)
        view.addSubview(activityViewIndicator)
        view.addSubview(label)
        view.bringSubview(toFront: activityViewIndicator)
        view.bringSubview(toFront: label)
        
    }
    
    func hide()
    {
        activityViewIndicator.stopAnimating()
        activityViewIndicator.removeFromSuperview()
        label.removeFromSuperview()
    }
    
}


























extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, for: forState)
    }}

































public class Countries {
    public private(set) static var countries: [Country] = {
        var countries: [Country] = []
        
        countries.append(Country(countryCode: "AF", phoneExtension: "93", isMain: true))
        countries.append(Country(countryCode: "AL", phoneExtension: "355", isMain: true))
        countries.append(Country(countryCode: "DZ", phoneExtension: "213", isMain: true))
        countries.append(Country(countryCode: "AS", phoneExtension: "1", isMain: false))
        countries.append(Country(countryCode: "AD", phoneExtension: "376", isMain: true))
        countries.append(Country(countryCode: "AO", phoneExtension: "244", isMain: true))
        countries.append(Country(countryCode: "AI", phoneExtension: "1", isMain: false))
        countries.append(Country(countryCode: "AQ", phoneExtension: "672", isMain: true))
        countries.append(Country(countryCode: "AG", phoneExtension: "1", isMain: false))
        countries.append(Country(countryCode: "AR", phoneExtension: "54", isMain: true))
        countries.append(Country(countryCode: "AM", phoneExtension: "374", isMain: true))
        countries.append(Country(countryCode: "AW", phoneExtension: "297", isMain: true))
        countries.append(Country(countryCode: "AU", phoneExtension: "61", isMain: true))
        countries.append(Country(countryCode: "AT", phoneExtension: "43", isMain: true))
        countries.append(Country(countryCode: "AZ", phoneExtension: "994", isMain: true))
        
        
        countries.append(Country(countryCode: "BS", phoneExtension: "1", isMain: false))
        countries.append(Country(countryCode: "BH", phoneExtension: "973", isMain: true))
        countries.append(Country(countryCode: "BD", phoneExtension: "880", isMain: true))
        countries.append(Country(countryCode: "BB", phoneExtension: "1", isMain: false))
        countries.append(Country(countryCode: "BY", phoneExtension: "375", isMain: true))
        countries.append(Country(countryCode: "BE", phoneExtension: "32", isMain: true))
        countries.append(Country(countryCode: "BZ", phoneExtension: "501", isMain: true))
        countries.append(Country(countryCode: "BJ", phoneExtension: "229", isMain: true))
        countries.append(Country(countryCode: "BM", phoneExtension: "1", isMain: false))
        countries.append(Country(countryCode: "BT", phoneExtension: "975", isMain: true))
        countries.append(Country(countryCode: "BO", phoneExtension: "591", isMain: true))
        countries.append(Country(countryCode: "BA", phoneExtension: "387", isMain: true))
        countries.append(Country(countryCode: "BW", phoneExtension: "267", isMain: true))
        countries.append(Country(countryCode: "BR", phoneExtension: "55", isMain: true))
        countries.append(Country(countryCode: "IO", phoneExtension: "246", isMain: true))
        countries.append(Country(countryCode: "VG", phoneExtension: "1", isMain: false))
        countries.append(Country(countryCode: "BN", phoneExtension: "673", isMain: true))
        countries.append(Country(countryCode: "BG", phoneExtension: "359", isMain: true))
        countries.append(Country(countryCode: "BF", phoneExtension: "226", isMain: true))
        countries.append(Country(countryCode: "BI", phoneExtension: "257", isMain: true))
        countries.append(Country(countryCode: "KH", phoneExtension: "855", isMain: true))
        countries.append(Country(countryCode: "CM", phoneExtension: "237", isMain: true))
        countries.append(Country(countryCode: "CA", phoneExtension: "1", isMain: false))
        countries.append(Country(countryCode: "CV", phoneExtension: "238", isMain: true))
        
        countries.append(Country(countryCode: "KY", phoneExtension: "1", isMain: false))
        countries.append(Country(countryCode: "CF", phoneExtension: "236", isMain: true))
        countries.append(Country(countryCode: "TD", phoneExtension: "235", isMain: true))
        countries.append(Country(countryCode: "CL", phoneExtension: "56", isMain: true))
        countries.append(Country(countryCode: "CN", phoneExtension: "86", isMain: true))
        countries.append(Country(countryCode: "CX", phoneExtension: "61", isMain: false))
        countries.append(Country(countryCode: "CC", phoneExtension: "61", isMain: false))
        countries.append(Country(countryCode: "CO", phoneExtension: "57", isMain: true))
        countries.append(Country(countryCode: "KM", phoneExtension: "269", isMain: true))
        countries.append(Country(countryCode: "CK", phoneExtension: "682", isMain: true))
        countries.append(Country(countryCode: "CR", phoneExtension: "506", isMain: true))
        countries.append(Country(countryCode: "HR", phoneExtension: "385", isMain: true))
        countries.append(Country(countryCode: "CU", phoneExtension: "53", isMain: true))
        countries.append(Country(countryCode: "CW", phoneExtension: "599", isMain: true))
        countries.append(Country(countryCode: "CY", phoneExtension: "357", isMain: true))
        countries.append(Country(countryCode: "CZ", phoneExtension: "420", isMain: true))
        countries.append(Country(countryCode: "CD", phoneExtension: "243", isMain: true))
        
        countries.append(Country(countryCode: "DK", phoneExtension: "45", isMain: true))
        countries.append(Country(countryCode: "DJ", phoneExtension: "253", isMain: true))
        countries.append(Country(countryCode: "DM", phoneExtension: "1", isMain: false))
        countries.append(Country(countryCode: "DO", phoneExtension: "1", isMain: false))
        
        countries.append(Country(countryCode: "TL", phoneExtension: "670", isMain: true))
        countries.append(Country(countryCode: "EC", phoneExtension: "593", isMain: true))
        countries.append(Country(countryCode: "EG", phoneExtension: "20", isMain: true))
        countries.append(Country(countryCode: "SV", phoneExtension: "503", isMain: true))
        countries.append(Country(countryCode: "GQ", phoneExtension: "240", isMain: true))
        countries.append(Country(countryCode: "ER", phoneExtension: "291", isMain: true))
        countries.append(Country(countryCode: "EE", phoneExtension: "372", isMain: true))
        countries.append(Country(countryCode: "ET", phoneExtension: "251", isMain: true))
        
        countries.append(Country(countryCode: "FK", phoneExtension: "500", isMain: true))
        countries.append(Country(countryCode: "FO", phoneExtension: "298", isMain: true))
        countries.append(Country(countryCode: "FJ", phoneExtension: "679", isMain: true))
        countries.append(Country(countryCode: "FI", phoneExtension: "358", isMain: true))
        countries.append(Country(countryCode: "FR", phoneExtension: "33", isMain: true))
        countries.append(Country(countryCode: "PF", phoneExtension: "689", isMain: true))
        
        countries.append(Country(countryCode: "GA", phoneExtension: "241", isMain: true))
        countries.append(Country(countryCode: "GM", phoneExtension: "220", isMain: true))
        countries.append(Country(countryCode: "GE", phoneExtension: "995", isMain: true))
        countries.append(Country(countryCode: "DE", phoneExtension: "49", isMain: true))
        countries.append(Country(countryCode: "GH", phoneExtension: "233", isMain: true))
        countries.append(Country(countryCode: "GI", phoneExtension: "350", isMain: true))
        countries.append(Country(countryCode: "GR", phoneExtension: "30", isMain: true))
        countries.append(Country(countryCode: "GL", phoneExtension: "299", isMain: true))
        countries.append(Country(countryCode: "GD", phoneExtension: "1", isMain: false))
        countries.append(Country(countryCode: "GU", phoneExtension: "1", isMain: false))
        countries.append(Country(countryCode: "GT", phoneExtension: "502", isMain: true))
        countries.append(Country(countryCode: "GG", phoneExtension: "44", isMain: false))
        countries.append(Country(countryCode: "GN", phoneExtension: "224", isMain: true))
        countries.append(Country(countryCode: "GW", phoneExtension: "245", isMain: true))
        countries.append(Country(countryCode: "GY", phoneExtension: "592", isMain: true))
        
        countries.append(Country(countryCode: "HT", phoneExtension: "509", isMain: true))
        countries.append(Country(countryCode: "HN", phoneExtension: "504", isMain: true))
        countries.append(Country(countryCode: "HK", phoneExtension: "852", isMain: true))
        countries.append(Country(countryCode: "HU", phoneExtension: "36", isMain: true))
        
        countries.append(Country(countryCode: "IS", phoneExtension: "354", isMain: true))
        countries.append(Country(countryCode: "IN", phoneExtension: "91", isMain: true))
        countries.append(Country(countryCode: "ID", phoneExtension: "62", isMain: true))
        countries.append(Country(countryCode: "IR", phoneExtension: "98", isMain: true))
        countries.append(Country(countryCode: "IQ", phoneExtension: "964", isMain: true))
        countries.append(Country(countryCode: "IE", phoneExtension: "353", isMain: true))
        countries.append(Country(countryCode: "IM", phoneExtension: "44", isMain: false))
        countries.append(Country(countryCode: "IL", phoneExtension: "972", isMain: true))
        countries.append(Country(countryCode: "IT", phoneExtension: "39", isMain: true))
        countries.append(Country(countryCode: "CI", phoneExtension: "225", isMain: true))
        
        countries.append(Country(countryCode: "JM", phoneExtension: "1", isMain: false))
        countries.append(Country(countryCode: "JP", phoneExtension: "81", isMain: true))
        countries.append(Country(countryCode: "JE", phoneExtension: "44", isMain: false))
        countries.append(Country(countryCode: "JO", phoneExtension: "962", isMain: true))
        
        countries.append(Country(countryCode: "KZ", phoneExtension: "7", isMain: false))
        countries.append(Country(countryCode: "KE", phoneExtension: "254", isMain: true))
        countries.append(Country(countryCode: "KI", phoneExtension: "686", isMain: true))
        countries.append(Country(countryCode: "XK", phoneExtension: "383", isMain: true))
        countries.append(Country(countryCode: "KW", phoneExtension: "965", isMain: true))
        countries.append(Country(countryCode: "KG", phoneExtension: "996", isMain: true))
        
        countries.append(Country(countryCode: "LA", phoneExtension: "856", isMain: true))
        countries.append(Country(countryCode: "LV", phoneExtension: "371", isMain: true))
        countries.append(Country(countryCode: "LB", phoneExtension: "961", isMain: true))
        countries.append(Country(countryCode: "LS", phoneExtension: "266", isMain: true))
        countries.append(Country(countryCode: "LR", phoneExtension: "231", isMain: true))
        countries.append(Country(countryCode: "LY", phoneExtension: "218", isMain: true))
        countries.append(Country(countryCode: "LI", phoneExtension: "423", isMain: true))
        countries.append(Country(countryCode: "LT", phoneExtension: "370", isMain: true))
        countries.append(Country(countryCode: "LU", phoneExtension: "352", isMain: true))
        
        countries.append(Country(countryCode: "MO", phoneExtension: "853", isMain: true))
        countries.append(Country(countryCode: "MK", phoneExtension: "389", isMain: true))
        countries.append(Country(countryCode: "MG", phoneExtension: "261", isMain: true))
        countries.append(Country(countryCode: "MW", phoneExtension: "265", isMain: true))
        countries.append(Country(countryCode: "MY", phoneExtension: "60", isMain: true))
        countries.append(Country(countryCode: "MV", phoneExtension: "960", isMain: true))
        countries.append(Country(countryCode: "ML", phoneExtension: "223", isMain: true))
        countries.append(Country(countryCode: "MT", phoneExtension: "356", isMain: true))
        countries.append(Country(countryCode: "MH", phoneExtension: "692", isMain: true))
        countries.append(Country(countryCode: "MR", phoneExtension: "222", isMain: true))
        countries.append(Country(countryCode: "MU", phoneExtension: "230", isMain: true))
        countries.append(Country(countryCode: "YT", phoneExtension: "262", isMain: true))
        countries.append(Country(countryCode: "MX", phoneExtension: "52", isMain: true))
        countries.append(Country(countryCode: "FM", phoneExtension: "691", isMain: true))
        countries.append(Country(countryCode: "MD", phoneExtension: "373", isMain: true))
        countries.append(Country(countryCode: "MC", phoneExtension: "377", isMain: true))
        countries.append(Country(countryCode: "MN", phoneExtension: "976", isMain: true))
        countries.append(Country(countryCode: "ME", phoneExtension: "382", isMain: true))
        countries.append(Country(countryCode: "MS", phoneExtension: "1", isMain: false))
        countries.append(Country(countryCode: "MA", phoneExtension: "212", isMain: true))
        countries.append(Country(countryCode: "MZ", phoneExtension: "258", isMain: true))
        countries.append(Country(countryCode: "MM", phoneExtension: "95", isMain: true))
        
        countries.append(Country(countryCode: "NA", phoneExtension: "264", isMain: true))
        countries.append(Country(countryCode: "NR", phoneExtension: "674", isMain: true))
        countries.append(Country(countryCode: "NP", phoneExtension: "977", isMain: true))
        countries.append(Country(countryCode: "NL", phoneExtension: "31", isMain: true))
        countries.append(Country(countryCode: "AN", phoneExtension: "599", isMain: true))
        countries.append(Country(countryCode: "NC", phoneExtension: "687", isMain: true))
        countries.append(Country(countryCode: "NZ", phoneExtension: "64", isMain: true))
        countries.append(Country(countryCode: "NI", phoneExtension: "505", isMain: true))
        countries.append(Country(countryCode: "NE", phoneExtension: "227", isMain: true))
        countries.append(Country(countryCode: "NG", phoneExtension: "234", isMain: true))
        countries.append(Country(countryCode: "NU", phoneExtension: "683", isMain: true))
        countries.append(Country(countryCode: "KP", phoneExtension: "850", isMain: true))
        countries.append(Country(countryCode: "MP", phoneExtension: "1", isMain: false))
        countries.append(Country(countryCode: "NO", phoneExtension: "47", isMain: true))
        
        countries.append(Country(countryCode: "OM", phoneExtension: "968", isMain: true))
        
        countries.append(Country(countryCode: "PK", phoneExtension: "92", isMain: true))
        countries.append(Country(countryCode: "PW", phoneExtension: "680", isMain: true))
        countries.append(Country(countryCode: "PS", phoneExtension: "970", isMain: true))
        countries.append(Country(countryCode: "PA", phoneExtension: "507", isMain: true))
        countries.append(Country(countryCode: "PG", phoneExtension: "675", isMain: true))
        countries.append(Country(countryCode: "PY", phoneExtension: "595", isMain: true))
        countries.append(Country(countryCode: "PE", phoneExtension: "51", isMain: true))
        countries.append(Country(countryCode: "PH", phoneExtension: "63", isMain: true))
        countries.append(Country(countryCode: "PN", phoneExtension: "64", isMain: false))
        countries.append(Country(countryCode: "PL", phoneExtension: "48", isMain: true))
        countries.append(Country(countryCode: "PT", phoneExtension: "351", isMain: true))
        countries.append(Country(countryCode: "PR", phoneExtension: "1", isMain: false))
        
        countries.append(Country(countryCode: "QA", phoneExtension: "974", isMain: true))
        
        countries.append(Country(countryCode: "CG", phoneExtension: "242", isMain: true))
        countries.append(Country(countryCode: "RE", phoneExtension: "262", isMain: false))
        countries.append(Country(countryCode: "RO", phoneExtension: "40", isMain: true))
        countries.append(Country(countryCode: "RU", phoneExtension: "7", isMain: true))
        countries.append(Country(countryCode: "RW", phoneExtension: "250", isMain: true))
        
        countries.append(Country(countryCode: "BL", phoneExtension: "590", isMain: true))
        countries.append(Country(countryCode: "SH", phoneExtension: "290", isMain: true))
        countries.append(Country(countryCode: "KN", phoneExtension: "1", isMain: false))
        countries.append(Country(countryCode: "LC", phoneExtension: "1", isMain: false))
        countries.append(Country(countryCode: "MF", phoneExtension: "590", isMain: false))
        countries.append(Country(countryCode: "PM", phoneExtension: "508", isMain: true))
        
        countries.append(Country(countryCode: "VC", phoneExtension: "1", isMain: false))
        countries.append(Country(countryCode: "WS", phoneExtension: "685", isMain: true))
        countries.append(Country(countryCode: "SM", phoneExtension: "378", isMain: true))
        countries.append(Country(countryCode: "ST", phoneExtension: "239", isMain: true))
        countries.append(Country(countryCode: "SA", phoneExtension: "966", isMain: true))
        countries.append(Country(countryCode: "SN", phoneExtension: "221", isMain: true))
        countries.append(Country(countryCode: "RS", phoneExtension: "381", isMain: true))
        countries.append(Country(countryCode: "SC", phoneExtension: "248", isMain: true))
        countries.append(Country(countryCode: "SL", phoneExtension: "232", isMain: true))
        countries.append(Country(countryCode: "SG", phoneExtension: "65", isMain: true))
        countries.append(Country(countryCode: "SX", phoneExtension: "1", isMain: false))
        countries.append(Country(countryCode: "SK", phoneExtension: "421", isMain: true))
        countries.append(Country(countryCode: "SI", phoneExtension: "386", isMain: true))
        countries.append(Country(countryCode: "SB", phoneExtension: "677", isMain: true))
        countries.append(Country(countryCode: "SO", phoneExtension: "252", isMain: true))
        countries.append(Country(countryCode: "ZA", phoneExtension: "27", isMain: true))
        countries.append(Country(countryCode: "KR", phoneExtension: "82", isMain: true))
        countries.append(Country(countryCode: "SS", phoneExtension: "211", isMain: true))
        countries.append(Country(countryCode: "ES", phoneExtension: "34", isMain: true))
        countries.append(Country(countryCode: "LK", phoneExtension: "94", isMain: true))
        countries.append(Country(countryCode: "SD", phoneExtension: "249", isMain: true))
        countries.append(Country(countryCode: "SR", phoneExtension: "597", isMain: true))
        countries.append(Country(countryCode: "SJ", phoneExtension: "47", isMain: true))
        countries.append(Country(countryCode: "SZ", phoneExtension: "268", isMain: true))
        countries.append(Country(countryCode: "SE", phoneExtension: "46", isMain: true))
        countries.append(Country(countryCode: "CH", phoneExtension: "41", isMain: true))
        countries.append(Country(countryCode: "SY", phoneExtension: "963", isMain: true))
        
        countries.append(Country(countryCode: "TW", phoneExtension: "886", isMain: true))
        countries.append(Country(countryCode: "TJ", phoneExtension: "992", isMain: true))
        countries.append(Country(countryCode: "TZ", phoneExtension: "255", isMain: true))
        countries.append(Country(countryCode: "TH", phoneExtension: "66", isMain: true))
        countries.append(Country(countryCode: "TG", phoneExtension: "228", isMain: true))
        countries.append(Country(countryCode: "TK", phoneExtension: "690", isMain: true))
        countries.append(Country(countryCode: "TO", phoneExtension: "676", isMain: true))
        countries.append(Country(countryCode: "TT", phoneExtension: "1", isMain: false))
        countries.append(Country(countryCode: "TN", phoneExtension: "216", isMain: true))
        countries.append(Country(countryCode: "TR", phoneExtension: "90", isMain: true))
        countries.append(Country(countryCode: "TM", phoneExtension: "993", isMain: true))
        countries.append(Country(countryCode: "TC", phoneExtension: "1", isMain: false))
        countries.append(Country(countryCode: "TV", phoneExtension: "688", isMain: true))
        
        countries.append(Country(countryCode: "VI", phoneExtension: "1", isMain: false))
        countries.append(Country(countryCode: "UG", phoneExtension: "256", isMain: true))
        countries.append(Country(countryCode: "UA", phoneExtension: "380", isMain: true))
        countries.append(Country(countryCode: "AE", phoneExtension: "971", isMain: true))
        countries.append(Country(countryCode: "GB", phoneExtension: "44", isMain: true))
        countries.append(Country(countryCode: "US", phoneExtension: "1", isMain: true))
        countries.append(Country(countryCode: "UY", phoneExtension: "598", isMain: true))
        countries.append(Country(countryCode: "UZ", phoneExtension: "998", isMain: true))
        
        countries.append(Country(countryCode: "VU", phoneExtension: "678", isMain: true))
        countries.append(Country(countryCode: "VA", phoneExtension: "379", isMain: true))
        countries.append(Country(countryCode: "VE", phoneExtension: "58", isMain: true))
        countries.append(Country(countryCode: "VN", phoneExtension: "84", isMain: true))
        
        countries.append(Country(countryCode: "WF", phoneExtension: "681", isMain: true))
        countries.append(Country(countryCode: "EH", phoneExtension: "212", isMain: true))
        
        countries.append(Country(countryCode: "YE", phoneExtension: "967", isMain: true))
        
        countries.append(Country(countryCode: "ZM", phoneExtension: "260", isMain: true))
        countries.append(Country(countryCode: "ZW", phoneExtension: "263", isMain: true))
        
        
        return countries
    }()
    
    public class func countryFromPhoneExtension(phoneExtension: String) -> Country {
        let phoneExtension = (phoneExtension as NSString).replacingOccurrences(of: "+", with: "")
        for country in countries {
            if country.isMain && phoneExtension == country.phoneExtension {
                return country
            }
        }
        return Country.emptyCountry
    }
    
    public class func countryFromCountryCode(countryCode: String) -> Country {
        for country in countries {
            if countryCode == country.countryCode {
                return country
            }
        }
        return Country.emptyCountry
    }
    
    public class func countriesFromCountryCodes(countryCodes: [String]) -> [Country] {
        return countryCodes.map { Countries.countryFromCountryCode(countryCode: $0) }
    }
}



public func ==(lhs: Country, rhs: Country) -> Bool {
    return lhs.countryCode == rhs.countryCode
}

public class Country: NSObject {
    public static var emptyCountry: Country { return Country(countryCode: "", phoneExtension: "", isMain: true) }
    
    public func flag() -> String {
        let base = 127397
        var usv = String.UnicodeScalarView()
        for i in countryCode.utf16 {
            usv.append(UnicodeScalar(base + Int(i))!)
        }
        return String(usv)
    }
    
    public func countryName() -> String {
        if let name = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: countryCode) {
            return name
        } else {
            return countryCode
        }
    }
    
    public var countryCode: String
    public var phoneExtension: String
    public var isMain: Bool
    
    public init(countryCode: String, phoneExtension: String, isMain: Bool) {
        self.countryCode = countryCode
        self.phoneExtension = phoneExtension
        self.isMain = isMain
    }
    
    
}

class overLayerForImageView
{
    var activityViewIndicator:UIActivityIndicatorView!
    public var isAnimating:Bool!
    
    init()
    {
        activityViewIndicator = UIActivityIndicatorView()
        isAnimating = false
    }
    
    public func put(_ imageView:UIImageView)
    {
        activityViewIndicator = UIActivityIndicatorView(frame: imageView.frame)
        activityViewIndicator.frame.origin = CGPoint(x: 0, y: 0)
        activityViewIndicator.activityIndicatorViewStyle = .white
        activityViewIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        isAnimating = true
        activityViewIndicator.startAnimating()
        imageView.addSubview(activityViewIndicator)
    }
    
    public func remove()
    {
        activityViewIndicator.stopAnimating()
        activityViewIndicator.removeFromSuperview()
    }
    
    
    
}





















extension Date
{
    static func getCurrentMillis()->String {
        return "\(Int64(Date().timeIntervalSince1970 * 1000))"
    }
    
    static func getCurrentSeconds()->Int {
        return Int(Int64(Date().timeIntervalSince1970))
    }
    
    static func getLocalDateText(ofFormat: String, fromUTCSeconds: Double) -> String
    {
        let utcDateTimeGiven = Date.init(timeIntervalSince1970: TimeInterval(fromUTCSeconds))
        
        
        var formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy hh:mm:ss a"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let utcDateString = formatter.string(from: utcDateTimeGiven)
        
        formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy hh:mm:ss a"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let utcDate = formatter.date(from: utcDateString)
        {
            formatter = DateFormatter()
            formatter.dateFormat = ofFormat
            formatter.timeZone = NSTimeZone.local
            return formatter.string(from: utcDate)
        }
        return ""
        
    }
}




































class Interactor: UIPercentDrivenInteractiveTransition {
    var hasStarted = false
    var shouldFinish = false
}

enum Direction
{
    case up
    case down
    case left
    case right
}


struct MenuHelper {
    
    static let menuWidth: CGFloat = 0.65
    static let percentThreshold = 0.4
    static let snapshotNumber = 12345
    
    static let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
    
    static let blurView = UIVisualEffectView(effect: blurEffect)
    
    static func calculateProgress(_ translationView:CGPoint, viewBounds: CGRect, direction: Direction) -> CGFloat
    {
        let pointOnAxis: CGFloat
        let axisLength: CGFloat
        
        switch direction
        {
        case .up , .down: pointOnAxis = translationView.y
        axisLength = viewBounds.height
        case .left, .right: pointOnAxis = translationView.x
        axisLength = viewBounds.width
        }
        
        let movementOnAxis = pointOnAxis / axisLength
        let positiveMovementOnAxis: Float
        let positiveMovementOnAxisPercent: Float
        
        switch direction
        {
        //handle Positive Directions
        case .right, .down:
            positiveMovementOnAxis = fmaxf(Float(movementOnAxis), 0.0)
            positiveMovementOnAxisPercent = fminf(positiveMovementOnAxis, 1.0)
            return CGFloat(positiveMovementOnAxisPercent)
        // handle Negative Directions
        case .left, .up:
            positiveMovementOnAxis = fminf(Float(movementOnAxis), 0.0)
            positiveMovementOnAxisPercent = fmaxf(positiveMovementOnAxis, -1.0)
            return CGFloat(-positiveMovementOnAxisPercent)
        }
        
    }
    
    
    static func mapGestureStateToInteractor(_ gestureState:UIGestureRecognizerState, progress:CGFloat, interactor: Interactor?, triggerSegue: () -> Void){
        guard let interactor = interactor else { return }
        switch gestureState {
        case .began:
            interactor.hasStarted = true
            triggerSegue()
        case .changed:
            interactor.shouldFinish = Bool(Double(progress) > percentThreshold)
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
        default:
            break
        }
    }
    
}


class PresentMenuAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else
        {
            return
        }
        
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        
        let snapshot = fromVC.view.snapshotView(afterScreenUpdates: false)
        //print("ever called")
        snapshot?.tag = MenuHelper.snapshotNumber
        snapshot?.isUserInteractionEnabled = false
        //snapshot?.layer.shadowOpacity = 0.7
        toVC.view?.layer.shadowOpacity = 0.7
        containerView.insertSubview(snapshot!, aboveSubview: toVC.view)
        fromVC.view.isHidden = true
        
        MenuHelper.blurView.alpha = 0.90
        MenuHelper.blurView.frame = snapshot!.frame
        snapshot?.addSubview(MenuHelper.blurView)
        
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            
            
            snapshot?.center.x += UIScreen.main.bounds.width * MenuHelper.menuWidth
            
            
            
        }, completion: {
            
            _ in
            
            fromVC.view.isHidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
        })
    }
    
}





class DismissMenuAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else {
                return
        }
        let snapshot = containerView.viewWithTag(MenuHelper.snapshotNumber)
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                snapshot?.frame = CGRect(origin: CGPoint.zero, size: UIScreen.main.bounds.size)
        },
            completion: { _ in
                let didTransitionComplete = !transitionContext.transitionWasCancelled
                if didTransitionComplete {
                    containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
                    snapshot?.removeFromSuperview()
                }
                transitionContext.completeTransition(didTransitionComplete)
        }
        )
    }
}

struct SlideInteractors
{
    static var interactor = Interactor()
}


class SlideOutMenu: NSObject, UIViewControllerTransitioningDelegate
{
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMenuAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMenuAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return SlideInteractors.interactor.hasStarted ? SlideInteractors.interactor : nil
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return SlideInteractors.interactor.hasStarted ? SlideInteractors.interactor : nil
    }
    
}


extension UIColor {
    
    func lighter(by percentage:CGFloat=10.0) -> UIColor {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage:CGFloat=10.0) -> UIColor {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage:CGFloat=30.0) -> UIColor {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }else{
            return self
        }
    }
}


var SlideOutMenuDelegate = SlideOutMenu()



class MergeSort
{
    
    func mergeSortBottomUp<T>(_ a: [T], _ isOrderedBefore: (T, T) -> Bool) -> [T] {
        let n = a.count
        
        var z = [a, a]      // 1
        var d = 0
        
        var width = 1
        while width < n {   // 2
            
            var i = 0
            while i < n {     // 3
                
                var j = i
                var l = i
                var r = i + width
                
                let lmax = min(l + width, n)
                let rmax = min(r + width, n)
                
                while l < lmax && r < rmax {                // 4
                    if isOrderedBefore(z[d][l], z[d][r]) {
                        z[1 - d][j] = z[d][l]
                        l += 1
                    } else {
                        z[1 - d][j] = z[d][r]
                        r += 1
                    }
                    j += 1
                }
                while l < lmax {
                    z[1 - d][j] = z[d][l]
                    j += 1
                    l += 1
                }
                while r < rmax {
                    z[1 - d][j] = z[d][r]
                    j += 1
                    r += 1
                }
                
                i += width*2
            }
            
            width *= 2
            d = 1 - d      // 5
        }
        return z[d]
    }
    
    func use()
    {
        var array = [2, 1, 5, 4, 9]
        array = mergeSortBottomUp(array, <)
        print(array)
    }
    
}


public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension UITableView {
    func scrollToBottom(animated: Bool = true) {
        let sections = self.numberOfSections
        let rows = self.numberOfRows(inSection: sections - 1)
        if (rows > 0)
        {
            let lastIndexPath = NSIndexPath(row: rows - 1, section: sections - 1) as IndexPath
            self.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
        }
    }
}


class ResizeImage
{
    func resize(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
