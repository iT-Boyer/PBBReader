//
//  BindingPhoneViewController.swift
//  ScaryBugsMac
//
//  Created by pengyucheng on 16/7/12.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Cocoa

class BindingPhoneViewController: NSViewController {

    
    @IBOutlet weak var phoneTF: NSTextField!
    @IBOutlet weak var messageTF: NSTextField!
    @IBOutlet weak var getMessageBtn: NSButton!
    @IBOutlet weak var submitBtn: NSButton!
    @IBOutlet weak var showMessageLabel: NSTextField!
   
    @objc var filePath:String!
    var timer:NSTimer!  // 计时器
    var phoneNumber:String!  // 手机号码
    var remainedTime:Int!   // 剩余时间
//    var indicator:
    var codeModel:VerificationCodeModel!
    var userPhone:Bool!
    
    let pycFileHelper = AppDelegateHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        codeModel = VerificationCodeModel()

    }
    
    @IBAction func getMessageBtnAction(sender: AnyObject) {
        /* 判断手机号是否合法 */
        
//        [alert runModal];
        if (!isPhoneNumberOfString(phoneTF.stringValue)) {
            // 手机号不合法
            pycFileHelper.setAlertView("请输入正确的手机号")
            return ;
        }
        phoneNumber = phoneTF.stringValue;
        getMessageBtn.hidden = true; // 获取验证码按钮不可用

        // 调取获取验证码业务
        pycFileHelper.getVerificationCodeByPhone(phoneNumber, userPhone: userPhone)
        getCodeFinish()  // 获取验证码成功后 调整界面
    }
    
    @IBAction func submitBtnAction(sender: AnyObject) {
        /* 判断手机号是否合法 */
        if (!isPhoneNumberOfString(phoneTF.stringValue)) {
            // 手机号不合法
            pycFileHelper.setAlertView("请输入正确的手机号")
            return
        }
        
        //用户输入短信验证码后，查询本地是否存在
        codeModel.seeFile = "1"
        if ((userPhone) != nil) {
            codeModel.seeFile = "0"
        }
        
        codeModel.verificationCode = messageTF.stringValue
        
        let messageId = VerificationCodeDao.sharedVerificationCodeDao().searchVerificationCodeOfMessageId(codeModel)
        
        /* 判断输入验证码正确性，如果正确，调用查看文件接口，不正确给出提示*/
        if (messageId != nil) {
            getCodeStateYes() // 调整界面控件状态

            if(!userPhone){
                pycFileHelper.phoneNo = messageTF.stringValue
                pycFileHelper.messageID = messageId
                pycFileHelper.openedNum = 0
                pycFileHelper.loadVideoWithLocalFiles(filePath)// 查看文件
            }else{
                //完善个人信息，绑定手机号
                PycFile().bindPhoneByVerificationCode(messageTF.stringValue, logname: userDao.shareduserDao().getLogName(), messageId: messageId)
            }
            
        } else {
//            [self.view makeToast:@"验证码失效，请重新获取！" duration:1.0 position:@"center"];
        }
    }
    

    /**
     * 此方法用来刷新获取验证码后界面
     */
    func getCodeStateYes() {
        //
        timer.invalidate()   // 停止时间刷新计时器
        showMessageLabel.stringValue = "\(60)秒后可重新获取验证码"
        showMessageLabel.hidden = true   // 剩余时间隐藏
        getMessageBtn.hidden = false    // 获取验证码按钮可用
    }
    
    /**
     * 此方法用来点击获取验证码后调整界面
     */
    func getCodeFinish() {
        ///
        remainedTime = 59  // 剩余时间
        showMessageLabel.hidden = false  // 剩余时间label变为可见
        timer = NSTimer.init(timeInterval: 1, target: self, selector: #selector(BindingPhoneViewController.changeLabelTime), userInfo: nil, repeats: true) // 启用计时器更改剩余时间
    }
    
    /**
     * 此方法用来改变剩余时间label
     * 根据_remainedTime来调整剩余时间，如果_remainedTime为0时，计时器停止。
     */
    func changeLabelTime() {
        //
        showMessageLabel.stringValue = "\(remainedTime)秒后可重新获取验证码"
        remainedTime = remainedTime - 1
        
        if (remainedTime == 0) {
             getCodeStateYes()  // 剩余时间还有0秒，可重新获取
        }
    }
    
    /**
     * 此方法用来判断手机号是否合法
     * @param  phoneString 传入的手机号字符串
     * @return 合法返回Yes 不合法返回No
     */
    func isPhoneNumberOfString(phone:String) -> Bool {
        //
        let phoneString = (phone as NSString)
        if (phoneString.length != 11) {
            return false // 不满11位
        }
        if (!phoneString.hasPrefix("1")) {
            return false // 不以1开头
        }
        if ((phoneString.longLongValue < 13000000000) || (phoneString.longLongValue > 18999999999)) {
            return false  // 不在13X－18X之间
        }
        
        return true
    }
    
    
}
