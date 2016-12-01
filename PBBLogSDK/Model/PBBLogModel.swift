//
//  PBBLogModel.swift
//  PBBReaderForMac
//
//  Created by huoshuguang on 2016/11/23.
//  Copyright © 2016年 recomend. All rights reserved.
//

#if os(OSX)
    import Cocoa
    import AppKit
    import RNCryptor
#elseif os(iOS)
    import UIKit
    import RNCryptor
#endif


@objc(PBBLogModel)
public class PBBLogModel: NSObject
{
    public var level = ""
    var file_name = { return (#file as NSString).lastPathComponent}()
    var method_name = {return #function}()
    var lines = {return #line}()  //日志行
    public var content = "" //日志内容
    public var desc = "" //描述
    public var extension1 = ""
    public var extension2 = ""
    public var extension3 = ""

    var sdk_version = "" //SDK版本
    var system = ""     //
    var imei = ""      //移动设备唯一编码，非移动端忽略此参数
    var username = ""
    var token = ""    //登录令牌
    
    var login_type = ""
    var application_name = ""
    var account_name = ""
    var account_password = ""
    var network_type = ""
    
    var op_version = ""   //操作系统版本
    var equip_serial = "" //设备序列号，非移动端忽略此参数
    var equip_host = ""   //机主信息
    lazy var equip_model = "" //设备型号
    var device_info = ""  //设备参数
    
    fileprivate var bind_count = 0 //当前绑定设备数，非移动端忽略此参数
    fileprivate var wifi_mac = ""   //Wi-Fi的Mac值
    fileprivate var product_manufacturer = "" //终端设备制造商。如blackBerry。
    fileprivate var board_info = ""         //主板
    var cpu_abi = ""
    fileprivate var cpu_abi2 = ""
    fileprivate var device_token = ""  //推送设备号
    var hardware_info = "" //硬件信息
    fileprivate var hardware_manufecturer = "" //硬件制造商
    
    
    
    
    fileprivate var logModelDescription = ""
    /*
      public func EVLog<T>(object: T, filename: String = #file, line: Int = #line, funcname: String = #function) {    }
     http://stackoverflow.com/questions/24402533/is-there-a-swift-alternative-for-nslogs-pretty-function
     
     */
    ///LogModel构造器
    public convenience init(_ type:LogType = LogType.INFO,
                       in APPName:APPName = .ReaderMac,
                       file file_name:String = #file,
               method method_name:String = #function,
                       line lines:Int = #line,
                             desc:String = "")
    {
        self.init()
        if UserDefaults.standard.bool(forKey: "kSetUserInfo")
        {
            //当用户没有事先设置相关信息，执行初始化操作
            PBBLogModel.setUserInfo()
        }
        //默认赋值
        self.level = type.rawValue
        self.application_name = APPName.rawValue //Bundle.main.object(forInfoDictionaryKey: "MakeInstallerName") as! String
        self.file_name = (file_name as NSString).lastPathComponent
        self.method_name = method_name
        self.lines = lines
        self.desc = desc
        
        let confInfo = DeviceUtil()
        
        //用户信息
        self.username = confInfo.username
        self.account_name = confInfo.account_name
        self.account_password = confInfo.account_password
        self.network_type = confInfo.network_type
        self.token = confInfo.token
        self.login_type = confInfo.login_type
        //宓钥加密
        self.account_password = aesEncryptPassword(password: self.account_password,
                                                 secret: "80F008F8C906098FCE93A89B3DB2EF4E")
        
        //设备信息
        self.imei = confInfo.platform_UUID
        self.op_version = confInfo.op_version
        self.sdk_version = confInfo.op_version
        self.equip_serial = confInfo.serial_number
        self.equip_model = confInfo.machine_model
        self.device_info = confInfo.hostName
        self.cpu_abi = confInfo.cpu_type
        self.system = confInfo.system
        self.hardware_info = confInfo.physical_memory
        self.equip_host = confInfo.equip_host
        
        self.content = "\(confInfo.executionTime) \(confInfo.processName)[\(confInfo.processIdentifier):\(confInfo.threadId)] \(file_name)(\(lines)) \(method_name):\r\t\(desc)\n"
        
        let dict = self.convertToDictionary()
        if JSONSerialization.isValidJSONObject(dict)
        {
            let jsonData = try! JSONSerialization.data(withJSONObject:dict,
                                                       options: .prettyPrinted)
            logModelDescription = String.init(data: jsonData, encoding: String.Encoding.utf8)!
        }
    }
    ///便立构造器
    @objc(initWithType:inApp:desc:)
    public convenience init(type:Log, APPNam:APP, description desc:String)
    {
        //
        var log = LogType.INFO
        switch type {
        case .FATAL:
            log = .FATAL
        case .ERROR:
            log = .ERROR
        case .WARN:
            log = .WARN
        case .DEBUG:
            log = .DEBUG
        case .INFO:
            log = .INFO
        }
        
        var APP = APPName.ReaderMac
        switch APPNam {
        case .PBBMaker:
            APP = APPName.PBBMaker
        case .Reader:
            APP = APPName.Reader
        case .ReaderMac:
            APP = APPName.ReaderMac
        case .SuiZhi:
            APP = APPName.SuiZhi
        }
        
        self.init(log,in:APP,desc:desc)
    }
    
    public override var description: String
    {
        return logModelDescription
    }
    ///手动设置设备信息
    @objc(setUserName:id:pwd:token:netT:loginT:)
    public class func setUserInfo(userName:String = "",
                         account_name:String = "",
                         account_password:String = "",
                         token:String = "",
                         network_type:String = "",
                         login_type:String = "")
    {
        UserDefaults.standard.set(true, forKey: "kSetUserInfo")
        UserDefaults.standard.set(userName, forKey: "kusername")
        UserDefaults.standard.set(account_name, forKey: "kaccount_name")
        UserDefaults.standard.set(account_password, forKey: "kaccount_password")
        UserDefaults.standard.set(token, forKey: "ktoken")
        UserDefaults.standard.set(network_type, forKey: "knetwork_type")
        UserDefaults.standard.set(login_type, forKey: "klogin_type")
    }

    func toData()->Data?
    {
        var sendData:Data?
        let dict = self.convertToDictionary()
        if JSONSerialization.isValidJSONObject(dict)
        {
           sendData = try! JSONSerialization.data(withJSONObject: dict,
                                                         options:.prettyPrinted)
        logModelDescription = String.init(data: sendData!, encoding: String.Encoding.utf8)!
        }
        return sendData
    }

    ///aes加密
    func aesEncryptPassword(password:String,secret:String)->String
    {
        let data = "sdfhskhfsj".data(using: String.Encoding.utf8)!
        let ciphertext = RNCryptor.encrypt(data: data, withPassword: secret)
//        let ciphertext2 = RNCryptor.Encryptor(password: secret).encrypt(data: data)
        return ciphertext.base64EncodedString()

    }
    
    //aes解密
    func aesDecryptor(password:String,secret:String)->String
    {
        
        var plaintext: Data = Data.init(base64Encoded: password,
                                         options: .ignoreUnknownCharacters)!
        do {
            plaintext = try RNCryptor.Decryptor(password: secret).decrypt(data: plaintext)
        } catch {
            plaintext = Data(bytes: [0])
        }
        return String.init(data: plaintext, encoding: .utf8)!

    }
    
    ///上传到指定服务器
    public func sendTo(server serverUrl:String = url)
    {
        PBBLogClient().upLoadLog(to: serverUrl,logData: self)
    }
    
    ///上传到默认服务器
    public func sendToServer()
    {
        sendTo()
    }
}


