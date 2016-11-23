//
//  RequestAddLog.m
//  CYHZ
//
//  Created by liqiang on 16/11/23.
//  Copyright © 2016年 liqiang. All rights reserved.
//

#import "RequestAddLog.h"
#import "sys/utsname.h"


const NSArray *___LogType;
#define cLogTypeGet (___LogType == nil ? ___LogType = [[NSArray alloc] initWithObjects:\
@"FATAL",\
@"ERROR",\
@"WARN",\
@"INFO",\
@"DEBUG", nil]:___LogType)


const NSArray *___APPName;
#define cAPPNameGet (___APPName == nil ? ___APPName = [[NSArray alloc] initWithObjects:\
@"Reader for iOS",\
@"PBBMaker for iOS",\
@"Reader for OS",\
@"SuiZhi for iOS", nil]:___APPName)


const NSArray *___LoginType;
#define cLoginTypeGet (___LoginType == nil ? ___LoginType = [[NSArray alloc] initWithObjects:\
@"账号登录",\
@"微信登录",\
@"QQ登录",\
@"手机验证码登录", nil]:___LoginType)


const NSArray *___SystemType;
#define cSystemTypeGet (___SystemType == nil ? ___SystemType = [[NSArray alloc] initWithObjects:\
@"iOS",\
@"Mac", nil]:___SystemType)


const NSArray *___NetworkType;
#define cNetworkTypeGet (___NetworkType == nil ? ___NetworkType = [[NSArray alloc] initWithObjects:\
@"其他",\
@"其他",\
@"3G",\
@"4G",\
@"Wifi", nil]:___NetworkType)


@interface RequestAddLog()

@property (nonatomic, strong) NSString *level;

@property (nonatomic, strong) NSString *login_type;

@property (nonatomic, strong) NSString *application_name;

@property (nonatomic, strong) NSString *network_type;

@property (nonatomic, strong) NSString *system;


//设备唯一编号
@property (nonatomic, strong) NSString *imei;

//Wifi的MAC值
//@property (nonatomic, strong) NSString *wifi_mac;未开通

//操作系统版本
@property (nonatomic, strong) NSString *op_version;

//设备序列号
@property (nonatomic, strong) NSString *equip_serial;

//机主信息
@property (nonatomic, strong) NSString *equip_host;

//硬件制造商
//@property (nonatomic, strong) NSString *hardware_manufacturer;未开通

//硬件信息
//@property (nonatomic, strong) NSString *hardware_info;未开通

//设备型号
@property (nonatomic, strong) NSString *equip_model;

//设备参数
@property (nonatomic, strong) NSString *device_info;

//终端设备制造商
//@property (nonatomic, strong) NSString *product_manufacturer;未开通

//主板
//@property (nonatomic, strong) NSString *board_info;未开通

//@property (nonatomic, strong) NSString *cpu_abi;未开通

//@property (nonatomic, strong) NSString *cpu_abi2;未开通

//SDK版本
@property (nonatomic, strong) NSString *sdk_version;


@end

@implementation RequestAddLog

#pragma mark - Interface

- (instancetype)init {
    self = [super init];
    
    if (self) {
//        self.requestMethod = RequestPost;
//        
//        self.imei = [[UIDevice currentDevice] uniqueDeviceIdentifier];
//        self.op_version = [UIDevice currentDevice].systemVersion;
//        self.equip_serial = [[UIDevice currentDevice] uniqueDeviceIdentifier];
//        self.equip_host = [UIDevice currentDevice].name;
//        self.equip_model = [UIDevice currentDevice].model;
//        struct utsname systemInfo;
//        uname(&systemInfo);
//        NSString *machine = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
//        self.device_info = machine;
//        self.sdk_version = [UIDevice currentDevice].systemVersion;
    }
    
    return self;
}

- (void)setLogType:(LogType)logType {
    _logType = logType;
    
    self.level = [cLogTypeGet objectAtIndex:logType];
}

- (void)setAppName:(APPName)appName {
    _appName = appName;
    
    self.application_name = [cAPPNameGet objectAtIndex:appName];
}

- (void)setLoginType:(LoginType)loginType {
    _loginType = loginType;
    
    self.login_type = [cLoginTypeGet objectAtIndex:loginType];
}

- (void)setNetworkType:(NetworkType)networkType {
    _networkType = networkType;
    
    self.network_type = [cNetworkTypeGet objectAtIndex:networkType];
}

- (void)setSystemType:(SystemType)systemType {
    _systemType = systemType;
    
    self.system = [cSystemTypeGet objectAtIndex:systemType];
}


@end
