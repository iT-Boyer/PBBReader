//
//  PbbEnum.swift
//  PBBReaderForMac
//
//  Created by huoshuguang on 2016/11/27.
//  Copyright © 2016年 recomend. All rights reserved.
//

#if os(OSX)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

//／枚举类:String类型原始值会自动赋值为枚举成员的字面值
public enum LogType:String
{
    case FATAL
    case ERROR
    case WARN
    case INFO
    case DEBUG
}

public enum APPName:String
{
    case Reader = "Reader for iOS"
    case PBBMaker = "PBBMaker for iOS"
    case ReaderMac = "Reader for OS"
    case SuiZhi = "SuiZhi for iOS"
}

public enum LoginType:String
{
    case Account = "账号登录"
    case WeiXin = "微信登录"
    case QQ   = "QQ登录"
    case VerificationCode = "手机验证码登录"
}

public enum SystemType:String
{
    case iOS = "iOS"
    case Mac = "Mac"
}

//@objc(ddd)
public enum NetworkType:String
{
    //    case NetworkTypeUnknown(weight:Double,name:String) = "未知"
    case Unknown = "未知"
    case None  = "其他"
    case G3 = "3G"
    case G4 = "4G"
    case Wifi = "Wifi"
}
