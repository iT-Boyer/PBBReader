//
//  ActivationController.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 16/7/12.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Cocoa
import Toasty

class ActivationController: NSViewController {
    
    @IBOutlet weak var qqField: NSTextField!
    @IBOutlet weak var emailField: NSTextField!
    @IBOutlet weak var phoneField: NSTextField!
    @IBOutlet weak var self1Field: NSTextField!
    @IBOutlet weak var self11Field: NSSecureTextField!
    @IBOutlet weak var self2Field: NSTextField!
    @IBOutlet weak var self22Field: NSSecureTextField!
    
    @IBOutlet weak var self1View: NSView!
    @IBOutlet weak var self1label: NSTextField!
    
    @IBOutlet weak var self2View: NSView!
    @IBOutlet weak var self2label: NSTextField!

    
    
    @IBOutlet weak var qqAsterisk: NSTextField!
    @IBOutlet weak var emailAsterisk: NSTextField!
    @IBOutlet weak var phoneAsterisk: NSTextField!
    
    //contraint
    //phone
    @IBOutlet weak var ibPhoneToViewVertical:NSLayoutConstraint!
    
    
    //email
    @IBOutlet weak var ibEmailToQQVertical:NSLayoutConstraint!
    
    @IBOutlet weak var ibEmailToViewVertical:NSLayoutConstraint!
    
    //self1
    @IBOutlet weak var ibSelf1ToPhoneVertical:NSLayoutConstraint!
    
    @IBOutlet weak var ibSelf1ToQQVertical:NSLayoutConstraint!
    
    @IBOutlet weak var ibSelf1ToViewVertical:NSLayoutConstraint!
    
    
    //self2
    @IBOutlet weak var ibSelf2ToEmailVertical:NSLayoutConstraint!
    
    @IBOutlet weak var ibSelf2ToPhoneVertical:NSLayoutConstraint!
    
    @IBOutlet weak var ibSelf2ToQQVertical:NSLayoutConstraint!
    
    @IBOutlet weak var ibSelf2ToViewVertical:NSLayoutConstraint!
    
    var needReApply = 0
    var applyId = 0
    var fileId = 0
    var orderId = 0
    var filename:String!
    var fileOpenDay:String!
    var canSeeNum:String!
    var bOpenInCome = 0
    
    var field1name:String!
    var field2name:String!
    
    var field1needprotect = false,field2needprotect = false
    var selffieldnum = 0    // 用户选择自定义列数量
    var bindNum = 0 // 用户选择系统定义数量。
    var definechecked = 0
    var qq:String!
    var email:String!
    var phone:String!
    var self1:String!
    var self2:String!
    

     let pycFileHelper = AppDelegateHelper.shared()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        if (needReApply != 0) {
            qqField.stringValue = qq!
            emailField.stringValue = email!
            phoneField.stringValue = phone!
            self1Field.stringValue = self1!
            self2Field.stringValue = self2!
            self1label.stringValue = "\(field1name!):"
            self2label.stringValue = "\(field2name!):"
        }else{
            //label
            self1label.stringValue = self1!
            self2label.stringValue = self2!
        }
      
        initWithWidgetLayout()

    }
    
    func initWithWidgetLayout() {
        //
        var isShowQQ = false
        var isSHowPhone = false
        var isSHowEmail = false
        var isShowSelf1 = false
        var isShowSelf2 = false
        
        if (definechecked != 0 || selffieldnum != 0) {
            // 用户手动选择列
            // 系统定义选项,ＱＱ，phone，email
            if (definechecked&1 != 0) {
                isShowQQ = true
            }
            if (definechecked&2 != 0) {
                isSHowPhone = true
            }
            if (definechecked&4 != 0) {
                isSHowEmail = true
            }
            // 用户自定义选项
            if (selffieldnum == 1) {
                isShowSelf1 = true
            } else if (selffieldnum == 2) {
                isShowSelf1 = true
                isShowSelf2 = true
            }
        }else{
            isShowQQ = true
            isSHowPhone = true
            isSHowEmail = true
        }
        
        var num = 1
        var y = 0
        //    NSInteger priority=0:String!
        
        
        //显示QQ
        if (isShowQQ) {
            //默认以相邻控件的约束为主
            num = num + 1
            
        }else{
            y = y + 1
            qqAsterisk.isHidden = true
            qqField.isHidden = true
        }
        
        //显示phone
        if (isSHowPhone) {
            //隐藏qq
            if (isShowQQ) {
                //默认以相邻控件的约束为主
            }else{
                ibPhoneToViewVertical.priority = 722.0
            }
            //        priority = 2-num-y:String!
            
            //        switch (priority) {
            //            case <#constant#>:
            //                <#statements#>
            //                break:String!
            //
            //            default:
            //                break:String!
            //        }
            
            
        }else{
            phoneAsterisk.isHidden = true
            phoneField.isHidden = true
        }
        
        //显示email
        if (isSHowEmail) {
            
            if (isSHowPhone) {
                //默认以相邻的控件之间的约束为主
                
            }else if(isShowQQ){
                //QQ显示时，提高约束优先级
                ibEmailToQQVertical.priority = 722.0
            }else{
                //隐藏qq,phone
                ibEmailToViewVertical.priority = 722.0
            }
            
        }else{
            emailAsterisk.isHidden = true
            emailField.isHidden = true
        }
        
        
        //field1name  field2name
        //field1needprotect  field2needprotect
        
        ////判断自定义字段的个数,是否用原有规则
        if (isShowSelf1) {
            if (isSHowEmail) {
                //默认以相邻的控件之间的约束为主
            }else if (isSHowPhone){
                //当isShowPhone真时,提升Phone控件之间的约束优先级
                ibSelf1ToPhoneVertical.priority = 722.0
            }else if(isShowQQ){
                //当isShowQQ真时,提升QQ控件之间的约束优先级
                ibSelf1ToQQVertical.priority = 722.0
            }else{
                //隐藏该控件以上的控件
                ibSelf1ToViewVertical.priority = 722.0
            }
            
            if (field1needprotect) {
                self1Field.isHidden = true
                self11Field.isHidden = false
            }else{
                self1Field.isHidden = false
                self11Field.isHidden = true
            }
            
        }else{
            self1label.isHidden = true
            self1Field.isHidden = true
            self11Field.isHidden = true
        }
        
        if (isShowSelf2) {
            if (isShowSelf1) {
                //默认以相邻的控件之间的约束为主
            }else if(isSHowEmail){
                //当isShowQQ真时,提升QQ控件之间的约束优先级
                ibSelf2ToEmailVertical.priority = 722.0
            }else if(isSHowPhone){
                //当isShowPhone真时,提升Phone控件之间的约束优先级
                ibSelf2ToPhoneVertical.priority = 722.0
            }else if(isShowQQ){
                //当isShowQQ真时,提升QQ控件之间的约束优先级
                ibSelf2ToQQVertical.priority = 722.0
            }else{
                ibSelf2ToViewVertical.priority = 722.0
            }
            
            if (field2needprotect) {
                self2Field.isHidden = true
                self22Field.isHidden = false
            }else{
                self2Field.isHidden = false
                self22Field.isHidden = true
            }
        } else {
            self2label.isHidden = true
            self2Field.isHidden = true
            self22Field.isHidden = true
        }
    }
   
    func trimSpace(_ inputStr:String) -> String {
        return inputStr.replacingOccurrences(of: " ", with: "")
    }
    @IBAction func nextStepAction(_ sender: AnyObject)
    {
        // Make a copy of default style.
        var style = Toasty.defaultStyle
        
        // Navigation bar is translucent so the view starts from under the bars. Set margin accordingly.
        style.margin.bottom = 0
        style.backgroundColor = NSColor.clear
        style.textColor = NSColor.black

        if (selffieldnum == 0 && selffieldnum == 0 && definechecked == 0 ) {
            
            if (trimSpace(qqField.stringValue) == "" && trimSpace(phoneField.stringValue) == "")
            {
                view.showToastWithText("QQ、手机至少填写一项！", usingStyle: style)
                return;
            }
            
        }
        
        if (trimSpace(qqField.stringValue)=="" && definechecked&1 != 0) {
            qqField.layer?.borderColor = NSColor.red.cgColor
            view.showToastWithText("QQ Q号不能为空！", usingStyle: style)
            return;
        }
        
        if (trimSpace(phoneField.stringValue) == "" && definechecked&2 != 0) {
            phoneField.layer?.borderColor = NSColor.red.cgColor
            view.showToastWithText("手机号不能为空！", usingStyle: style)
            return;
        }
        
        if (trimSpace(emailField.stringValue) == ""&&definechecked&4 != 0) {
            emailField.layer?.borderColor = NSColor.red.cgColor
            view.showToastWithText("邮箱不能为空！", usingStyle: style)
            return;
        }
        
        var sel1 = self1Field.stringValue
        var sel2 = self2Field.stringValue
        
        if (selffieldnum==1 || selffieldnum==2) {
            if (!self11Field.isHidden) {
                sel1 = self11Field.stringValue
            }
            if (!self22Field.isHidden) {
                sel2 = self22Field.stringValue
            }
            
            
            if (trimSpace(sel1) == "") {
                self1View.layer?.borderColor = NSColor.red.cgColor
                view.showToastWithText("\(self1!)不能为空！", usingStyle: style)
                return;
            }
            
            let fieldlen = trimSpace(sel1).lengthOfBytes(using: String.Encoding.utf8)
            if (fieldlen>24) {
                self1View.layer?.borderColor = NSColor.red.cgColor
                view.showToastWithText("\(self1!)长度最多24个字符！", usingStyle: style)
                return;
            }
            
            if (selffieldnum == 2) {
                
                if (trimSpace(sel2) == "") {
                    self2View.layer?.borderColor = NSColor.red.cgColor
                    view.showToastWithText("\(self2!)不能为空！", usingStyle: style)
                    return;
                }
                
                let fieldlen = trimSpace(sel2).lengthOfBytes(using: String.Encoding.utf8)
                if (fieldlen>24) {
                    self2View.layer?.borderColor = NSColor.red.cgColor
                    view.showToastWithText("\(self2!)长度最多24个字符！", usingStyle: style)
                    return;
                }
            }
            
        }
        self.dismiss(true as AnyObject?)
        let userName = userDao.shareduser().getLogName()
        let fileUrl = ReceiveFileDao.shared().selectReceiveFileURL(byFileId: fileId, logName: userName)
        pycFileHelper?.phoneNo = ""
        pycFileHelper?.messageID = ""
        pycFileHelper?.needReapply = needReApply
        _ = pycFileHelper?.applyFile(byFidAndOrderId: fileId,
                                               orderId: orderId,
                                               applyId: applyId,
                                               qq: qqField.stringValue,
                                               email: emailField.stringValue,
                                               phone: phoneField.stringValue,
                                               field1: sel1,
                                               field2: sel2,
                                               seeLogName: userName,
                                               fileName: fileUrl)
        
        
//        self.performSegueWithIdentifier("pushApplyInfo", sender: self)// 跳转信息确认
    }
    
    
//    override func shouldPerformSegue(withIdentifier: String, sender: AnyObject?) -> Bool {
//        return false
//    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
         return false
    }
    
//    override func prepare(for segue: NSStoryboardSegue, sender: AnyObject?) {
//        //
//        
//    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "pushApplyInfo") {
            
            let applyInfo = segue.destinationController as! ApplyInfoViewController
            
            applyInfo.qq = trimSpace(qqField.stringValue)
            applyInfo.phone = trimSpace(phoneField.stringValue)//_phoneField.text;
            applyInfo.email = trimSpace(emailField.stringValue)//_emailField.text;
            applyInfo.field1name = trimSpace(field1name)//_field1name;
            applyInfo.field2name = trimSpace(field2name)//_field2name;
            applyInfo.field1Str = trimSpace(self1Field.stringValue)//_self1Field.text;
            applyInfo.field2Str = trimSpace(self2Field.stringValue)//_self2Field.text;
            
            applyInfo.fileId = fileId
            applyInfo.orderId = orderId
            applyInfo.bOpenInCome = bOpenInCome
            applyInfo.field1needprotect = field1needprotect
            applyInfo.field2needprotect = field2needprotect
            applyInfo.needReApply = needReApply
            applyInfo.applyId = applyId
            
        }
    }
    
    
    override func dismiss(_ sender: Any?) {
        super.dismiss(sender)
        if !(sender is Bool){
            NotificationCenter.default.post(name: Notification.Name(rawValue: "CancleClosePlayerWindows"), object: nil, userInfo: ["pycFileID":fileId])
        }
    }
}
