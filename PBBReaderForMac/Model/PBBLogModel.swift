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
    var system = ""
    var imei = ""
    var username = ""
    var token = ""
    
    var login_type = ""
    var application_name = ""
    var account_name = ""
    var account_password = ""
    var network_type:NetworkType!
    
    var op_version = ""   //操作系统版本
    var equip_serial = "" //设备序列号
    var equip_host = ""   //机主信息
    lazy var equip_model = "" //设备型号
    var device_info = ""  //设备参数
    
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
        //默认赋值
        self.level = type.rawValue
        self.application_name = APPName.rawValue //Bundle.main.object(forInfoDictionaryKey: "MakeInstallerName") as! String
        self.file_name = (file_name as NSString).lastPathComponent
        self.method_name = method_name
        self.lines = lines
        self.desc = desc
        
        //必须的
        self.sdk_version = "10.12.1"
        self.system = SystemType.Mac.rawValue
        self.username = "Mac user"
        self.token = "Mac token"
        
        //宓钥加密
        self.account_password = aesEncryptPassword(password: self.account_password,
                                                 secret: "80F008F8C906098FCE93A89B3DB2EF4E")
        
        
        
        let confInfo = DeviceUtil()

        self.login_type = "Mac"
        self.imei = confInfo.platform_UUID
        self.op_version = confInfo.op_version
        self.equip_serial = confInfo.equip_serial
        self.equip_model = confInfo.equip_model
        self.device_info = confInfo.hostName
//        self.equip_host = ":\(process.userName)"
        
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
    @objc(inittWithType:inApp:desc:)
    public convenience init(type:Int, APPNdame:String, description desc:String)
    {
        //
        var logType = LogType.INFO
        switch type {
        case 1:
            logType = .FATAL
        case 2:
            logType = .ERROR
        case 3:
            logType = .WARN
        case 4:
            logType = .DEBUG
        default:
            logType = .INFO
        }
        self.init(logType,in:APPName.ReaderMac,desc:desc)
    }
    
    public override var description: String
    {
        return logModelDescription
    }
    ///手动设置设备信息
    public func setDeviceForiOS(op_version:String?,
                         equip_serial:String?,
                         equip_host:String?,
                         equip_model:String?,
                         device_info:String?,
                         sdk_version:String?)
    {
        self.op_version = op_version!
        self.equip_serial = equip_serial!
        self.equip_host = equip_host!
        self.equip_model = equip_model!
        self.device_info = device_info!
        self.sdk_version = sdk_version!
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


