//
//  RequestAddLog.h
//  CYHZ
//
//  Created by liqiang on 16/11/23.
//  Copyright © 2016年 liqiang. All rights reserved.
//
#import <Foundation/Foundation.h>
typedef enum : NSUInteger {
    LogTypeFatal,//FATAL
    LogTypeError,//ERROR
    LogTypeWarn,//WARN
    LogTypeInfo,//INFO
    LogTypeDebug//DEBUG
} LogType;


typedef enum : NSUInteger {
    APPNameReader,//Reader for iOS
    APPNamePBBMaker,//PBBMaker for iOS
    APPNameReaderMac,//Reader for OS
    APPNameSuiZhi//SuiZhi for iOS
} APPName;


typedef enum : NSUInteger {
    LoginTypeAccount,//账号登录
    LoginTypeWeiXin,//微信登录
    LoginTypeQQ,//QQ登录
    LoginTypeVerificationCode//手机验证码登录
} LoginType;


typedef enum : NSUInteger {
    SystemTypeiOS,//iOS
    SystemTypeMac//Mac
} SystemType;


typedef enum : NSUInteger {
    NetworkTypeUnknown,//未知
    NetworkTypeNone,//断网
    NetworkType3G,//3G
    NetworkType4G,//4G
    NetworkTypeWifi,//Wifi
} NetworkType;


@interface RequestAddLog : NSObject

//日志等级
@property (nonatomic, assign) LogType logType;

//所在类名称
@property (nonatomic, strong) NSString *file_name;

//所在方法名称
@property (nonatomic, strong) NSString *method_name;

//所在行数
//@property (nonatomic, assign) NSInteger lines;未开通

//内容
@property (nonatomic, strong) NSString *content;

//描述
@property (nonatomic, strong) NSString *desc;

//扩展1
@property (nonatomic, strong) NSString *extension1;

//扩展2
@property (nonatomic, strong) NSString *extension2;

//扩展3
@property (nonatomic, strong) NSString *extension3;

//应用名称
@property (nonatomic, assign) APPName appName;

//用户名称
@property (nonatomic, strong) NSString *account_name;

//用户密码
@property (nonatomic, strong) NSString *account_password;

//登录方式
@property (nonatomic, assign) LoginType loginType;

//绑定设备数
//@property (nonatomic, assign) NSInteger bind_count;未开通

//网络类型
@property (nonatomic, assign) NetworkType networkType;

//推送设备号
@property (nonatomic, strong) NSString *device_token;

//操作系统
@property (nonatomic, assign) SystemType systemType;

//用户名称
//@property (nonatomic, strong) NSString *username;未开通

//登录令牌
//@property (nonatomic, strong) NSString *token;未开通

@end
