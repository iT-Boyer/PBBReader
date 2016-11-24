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
#elseif os(iOS)

#endif
//枚举类
public enum LogType:String
{
    case LogTypeFatal = "FATAL"
    case LogTypeError = "ERROR"
    case LogTypeWarn = "WARN"
    case LogTypeInfo = "INFO"
    case LogTypeDebug = "DEBUG"
}

public enum APPName:String
{
    case APPNameReader = "Reader for iOS"
    case APPNamePBBMaker = "PBBMaker for iOS"
    case APPNameReaderMac = "Reader for OS"
    case APPNameSuiZhi = "SuiZhi for iOS"
}

public enum LoginType:String
{
    case LoginTypeAccount = "账号登录"
    case LoginTypeWeiXin = "微信登录"
    case LoginTypeQQ   = "QQ登录"
    case LoginTypeVerificationCode = "手机验证码登录"
}

public enum SystemType:String
{
    case SystemTypeiOS = "iOS"
    case SystemTypeMac = "Mac"
}

public enum NetworkType:String
{
    case NetworkTypeUnknown = "未知"
    case NetworkTypeNone  = "其他"
    case NetworkType3G  = "3G"
    case NetworkType4G  = "4G"
    case NetworkTypeWifi = "Wifi"
}

public class PBBLogModel: NSObject
{
    var level = ""
    var file_name = ""
    var method_name = ""
    var lines = 0  //日志行
    var content = "" //日志内容
    var desc = "" //描述
    var extension1 = ""
    var extension2 = ""
    var extension3 = ""
    
    var application_name = ""
    var account_name = ""
    var account_password = ""

    
    var login_type = ""
    
    var network_type:NetworkType!
    var system:SystemType!
    var imei = ""
    fileprivate var op_version = ""   //操作系统版本
    fileprivate var equip_serial = "" //设备序列号
    fileprivate var equip_host = ""   //机主信息
    fileprivate var equip_model = ""  //设备型号
    fileprivate var device_info = ""  //设备参数
    fileprivate var sdk_version = "" //SDK版本
    
    /*
      public func EVLog<T>(object: T, filename: String = #file, line: Int = #line, funcname: String = #function) {    }
     http://stackoverflow.com/questions/24402533/is-there-a-swift-alternative-for-nslogs-pretty-function
     
     */
   public init(_ level:LogType = LogType.LogTypeInfo,
         APPName:APPName = APPName.APPNameReaderMac,
         fileName filename:String=#file,
         inLine line: Int = #line,
         funcname: String = #function,
         description desc:String = "")
    {
        //默认赋值
        self.level = level.rawValue
        self.application_name = Bundle.main.object(forInfoDictionaryKey: "MakeInstallerName") as! String

        self.file_name = (filename as NSString).lastPathComponent
        self.lines = line
        self.method_name = funcname
        self.desc = desc
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss:SSS"
        let executionTime = dateFormatter.string(from: Date())
        let process = ProcessInfo.processInfo
        let processName = process.processName
        let threadId = "?"
        let processIdentifier = process.processIdentifier

        self.content = "\(executionTime) \(processName))[\(processIdentifier):\(threadId)] \(self.file_name)(\(line)) \(funcname):\r\t\(desc)\n"
    }
    
    ///手动设置设备信息
    func setDeviceForiOS(op_version:String?,
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

    public func toData()->Data
    {
        return try! JSONSerialization.data(withJSONObject: toDictionary(), options: .prettyPrinted)
    }
    
    func toDictionary() -> Dictionary<String, Any>
    {
        var targetDic:[String:Any?] = [:]
        var propsCount:UInt32 = 0;
        let properties:UnsafeMutablePointer<objc_property_t?> = class_copyPropertyList(object_getClass(self), &propsCount)
        for i in 0..<propsCount {
            //
            let property:objc_property_t = properties[Int(i)]!
            //http://stackoverflow.com/questions/30895578/get-all-the-keys-for-a-class/30895965#30895965
            let propName =  NSString(cString: property_getName(property), encoding: String.Encoding.utf8.rawValue)
            var value = self.value(forKey: propName as! String)
            if value == nil
            {
                value = ""
            }
            else
            {
                value = getObjectInternal(value: value)
            }
            targetDic.updateValue(value, forKey: propName as! String)
        }
        return targetDic
    }
    
    func getObjectInternal(value:Any?) -> Any?
    {
        //
        if value is String || value is Int
        {
            //
            return value
        }
        return ""
    }

}


