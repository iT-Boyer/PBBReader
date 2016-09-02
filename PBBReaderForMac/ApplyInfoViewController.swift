//
//  ApplyInfoViewController.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 16/7/13.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Cocoa

class ApplyInfoViewController: NSViewController {
    var qq:String!
    var phone:String!
    var email:String!
    var field1Str:String!  // 自定义字段1内容
    var field2Str:String!  // 自定义字段2内容
    var field1name:String!  // 自定义字段1名称
    var field2name:String!  // 自定义字段2名称
    var fileId = 0
    var orderId = 0
    var bOpenInCome = 0
//
    var needReApply = 0
    var applyId = 0
//
    var field1needprotect:Bool!,field2needprotect:Bool!
    
    @IBOutlet weak var qqField: NSTextField!
    @IBOutlet weak var phoneField: NSTextField!
    @IBOutlet weak var emailField: NSTextField!
    @IBOutlet weak var field1NameLabel: NSTextField!
    @IBOutlet weak var field1ValueField: NSTextField!
    @IBOutlet weak var field2NameLabel: NSTextField!
    @IBOutlet weak var field2ValueField: NSTextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        qqField.stringValue = qq
        phoneField.stringValue = phone
        emailField.stringValue = email
        field1NameLabel.stringValue = field1name
        field2NameLabel.stringValue = field2name
        field1ValueField.stringValue = field1Str
        field2ValueField.stringValue = field2Str
    }
    @IBAction func applyAction(sender: AnyObject) {
        
        let userName = userDao.shareduserDao().getLogName()
        let fileUrl = ReceiveFileDao.sharedReceiveFileDao().selectReceiveFileURLByFileId(fileId, logName: userName)
        let pycFileHelper = AppDelegateHelper()
        pycFileHelper.phoneNo = ""
        pycFileHelper.messageID = ""
        pycFileHelper.applyFileByFidAndOrderId(fileId,
                                               orderId: orderId,
                                               applyId:  applyId,
                                               qq: qqField.stringValue,
                                               email: emailField.stringValue,
                                               phone: phoneField.stringValue,
                                               field1: field1ValueField.stringValue,
                                               field2: field2ValueField.stringValue,
                                               seeLogName: userName,
                                               fileName: fileUrl)
    }
    
}
