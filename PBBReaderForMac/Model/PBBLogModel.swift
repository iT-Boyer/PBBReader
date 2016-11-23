//
//  PBBLogModel.swift
//  PBBReaderForMac
//
//  Created by huoshuguang on 2016/11/23.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Cocoa
import AppKit
//枚举类
enum LogType:String
{
    case LogTypeFatal = "FATAL"
    case LogTypeError = "ERROR"
    case LogTypeWarn = "WARN"
    case LogTypeInfo = "INFO"
    case LogTypeDebug = "DEBUG"
}

enum APPName:String
{
    case APPNameReader = "Reader for iOS"
    case APPNamePBBMaker = "PBBMaker for iOS"
    case APPNameReaderMac = "Reader for OS"
    case APPNameSuiZhi = "SuiZhi for iOS"
}

enum LoginType:String
{
    case LoginTypeAccount = "账号登录"
    case LoginTypeWeiXin = "微信登录"
    case LoginTypeQQ   = "QQ登录"
    case LoginTypeVerificationCode = "手机验证码登录"
}

enum SystemType:String
{
    case SystemTypeiOS = "iOS"
    case SystemTypeMac = "Mac"
}

enum NetworkType:String
{
    case NetworkTypeUnknown = "未知"
    case NetworkTypeNone  = "其他"
    case NetworkType3G  = "3G"
    case NetworkType4G  = "4G"
    case NetworkTypeWifi = "Wifi"
}

class PBBLogModel: NSObject
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
    var op_version = ""   //操作系统版本
    var equip_serial = "" //设备序列号
    var equip_host = ""   //机主信息
    var equip_model = ""  //设备型号
    var device_info = ""  //设备参数
    var sdk_version = "" //SDK版本
    
    /*
      public func EVLog<T>(object: T, filename: String = #file, line: Int = #line, funcname: String = #function) {    }
     http://stackoverflow.com/questions/24402533/is-there-a-swift-alternative-for-nslogs-pretty-function
     
     */
    init(_ level:LogType = LogType.LogTypeInfo,
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
    
}
