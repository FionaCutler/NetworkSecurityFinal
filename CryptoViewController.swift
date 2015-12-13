//
//  CryptoViewController.swift
//  NetworkSecurityFinal
//
//  Created by Benjamin Naugle on 12/8/15.
//  Copyright © 2015 0806564. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import CryptoSwift

class CryptoViewController: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    internal var writeKey:[UInt8] = [UInt8](count:16,repeatedValue:0)
    internal var writeIV:[UInt8] = [UInt8](count:16,repeatedValue:0)
    internal var writeIntegrityKey:[UInt8] = [UInt8](count:16,repeatedValue:0)
    
    internal var readKey:[UInt8] = [UInt8](count:16,repeatedValue:0)
    internal var readIV:[UInt8] = [UInt8](count:16,repeatedValue:0)
    internal var readIntegrityKey = [UInt8](count:16,repeatedValue:0)

    func setKeys(value:[UInt8]){
        //Generate keys.
        let data:NSData = NSData(bytes: value)
        
        let hashOnce = data.sha1()
        let hashTwice = hashOnce!.sha1()
        let hashThrice = hashTwice!.sha1()
        
        
        hashOnce?.getBytes(&writeKey, length:16*sizeof(UInt8))
        hashTwice?.getBytes(&writeIV, length:16*sizeof(UInt8))
        hashThrice?.getBytes(&writeKey, length:16*sizeof(UInt8))
        
        
        readKey = writeKey
        readIV = writeIV
        readIntegrityKey = writeIntegrityKey
    }
    var message:UITextView? = nil
    var encrypt:UIButton? = nil
    var decrypt:UIButton? = nil
    var sendEmail:UIButton? = nil
    var encryptText:UIButton? = nil
    var decryptText:UIButton? = nil
    var recipient:UITextField? = nil
    
    var emailLabel:UILabel? = nil
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        title = "Write an email"
      
        recipient = UITextField(frame: CGRectMake(view.bounds.width/12, view.bounds.height/10, view.bounds.width*10/12, view.bounds.height/10))
        //Nice rounded borders with a slightly different color
        recipient?.layer.cornerRadius = 10
        recipient?.layer.borderWidth = 2
        recipient?.layer.borderColor = UIColor.grayColor().CGColor
        recipient?.backgroundColor = UIColor.whiteColor()
        recipient?.font = UIFont(name: "Helvetica", size: 20)
        recipient?.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        recipient?.placeholder = "Recipient Email"
        view.addSubview(recipient!)
        
        message = UITextView(frame: CGRectMake(view.bounds.width/12, view.bounds.height/4, view.bounds.width*10/12, view.bounds.height/4))
        //Nice rounded borders with a slightly different color
        message?.layer.cornerRadius = 10
        message?.layer.borderWidth = 2
        message?.layer.borderColor = UIColor.grayColor().CGColor
        message?.backgroundColor = UIColor.whiteColor()
        view.addSubview(message!)
        
        sendEmail = UIButton(type: UIButtonType.RoundedRect) as UIButton
        //Nice rounded borders with a slightly different color
        sendEmail?.frame = CGRectMake(view.bounds.width/12, view.bounds.height/2, view.bounds.width*3/12, view.bounds.height/10)
        sendEmail?.layer.cornerRadius = 10
        sendEmail?.layer.borderWidth = 2
        sendEmail?.layer.borderColor = UIColor.grayColor().CGColor
        sendEmail?.setTitle("Send", forState: UIControlState.Normal)
        sendEmail?.backgroundColor = UIColor.whiteColor()
        sendEmail?.addTarget(self, action: "sendMail", forControlEvents: UIControlEvents.TouchDown)
        view.addSubview(sendEmail!)
        
        encryptText = UIButton(type: UIButtonType.RoundedRect) as UIButton
        //Nice rounded borders with a slightly different color
        encryptText?.frame = CGRectMake(view.bounds.width*4.5/12, view.bounds.height/2, view.bounds.width*3/12, view.bounds.height/10)
        encryptText?.layer.cornerRadius = 10
        encryptText?.layer.borderWidth = 2
        encryptText?.layer.borderColor = UIColor.grayColor().CGColor
        encryptText?.setTitle("Encrypt", forState: UIControlState.Normal)
        encryptText?.backgroundColor = UIColor.whiteColor()
        //encryptText?.addTarget(self, action: "sendMail", forControlEvents: UIControlEvents.TouchDown)
        view.addSubview(encryptText!)
        
        decryptText = UIButton(type: UIButtonType.RoundedRect) as UIButton
        //Nice rounded borders with a slightly different color
        decryptText?.frame = CGRectMake(view.bounds.width*8/12, view.bounds.height/2, view.bounds.width*3/12, view.bounds.height/10)
        decryptText?.layer.cornerRadius = 10
        decryptText?.layer.borderWidth = 2
        decryptText?.layer.borderColor = UIColor.grayColor().CGColor
        decryptText?.setTitle("Decrypt", forState: UIControlState.Normal)
        decryptText?.backgroundColor = UIColor.whiteColor()
        //decryptText?.addTarget(self, action: "sendMail", forControlEvents: UIControlEvents.TouchDown)
        view.addSubview(decryptText!)
        
        
        //write encrypted text to file 
        
        
    }
    
    func sendMail(){
        
        let mailCompose = MFMailComposeViewController()
        mailCompose.mailComposeDelegate = self
        mailCompose.setToRecipients([recipient!.text!])
        mailCompose.setSubject("Encrypted Message from SureComm!")
        mailCompose.setMessageBody(message!.text, isHTML: false)
        
        self.presentViewController(mailCompose, animated: true, completion: nil)
        
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        message!.endEditing(true)
        textField.resignFirstResponder()
        return false
    }
    
}
