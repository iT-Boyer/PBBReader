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

//@objc(ddd)
public enum NetworkType:String
{
    //    case NetworkTypeUnknown(weight:Double,name:String) = "未知"
    case NetworkTypeUnknown = "未知"
    case NetworkTypeNone  = "其他"
    case NetworkType3G  = "3G"
    case NetworkType4G  = "4G"
    case NetworkTypeWifi = "Wifi"
}
