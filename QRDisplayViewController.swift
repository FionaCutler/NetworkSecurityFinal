//
//  QRDisplayViewController.swift
//  NetworkSecurityFinal
//
//  Created by Benjamin Naugle on 12/6/15.
//  Copyright © 2015 0806564. All rights reserved.
//

import Foundation
import UIKit

protocol diffieDelegate: class
{
    func sendDiffie(diffePriv: String, diffePub: String)
}

class QRDisplayViewController: UIViewController, UITextFieldDelegate {
  
    var qrImg:UIImageView? = nil
    var qrCode:CIImage? = nil
    var delegate:diffieDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        qrImg = UIImageView(frame: CGRectMake(0, view.bounds.height/8, view.bounds.width, view.bounds.width))
        generate()
    }
    
    func generate(){
        let privatekey = SureCommCrypto.generateprivatekey()
        let publickey = SureCommCrypto.generatepublickey(privatekey)
        let data = publickey.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)
        
        delegate?.sendDiffie(privatekey, diffePub: publickey)
        
        //Create DiffieHellman Public
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        
        qrCode = filter?.outputImage
        
        let x = qrImg!.frame.size.width / qrCode!.extent.size.width
        let y = qrImg!.frame.size.height / qrCode!.extent.size.height
        
        let scaled = qrCode?.imageByApplyingTransform(CGAffineTransformMakeScale(x, y))
        qrImg?.image = UIImage(CIImage: scaled!)
        view.addSubview(qrImg!)
    }
    
    
    
}