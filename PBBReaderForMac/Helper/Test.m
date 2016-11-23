//
//  Test.m
//  CYHZ
//
//  Created by liqiang on 16/11/23.
//  Copyright © 2016年 liqiang. All rights reserved.
//

#import "Test.h"
#import "RequestAddLog.h"

@implementation Test


#pragma mark - Interface

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self initialize];
    }
    
    return self;
}

#pragma mark - Private

- (void)initialize {
    RequestAddLog *request =[[RequestAddLog alloc] init];
    request.url = @"http://114.112.104.138:6001/HostMonitor/client/log/addLog";
    
    request.logType = LogTypeFatal;
    request.file_name = NSStringFromClass([self class]);
    request.method_name = [NSString stringWithFormat:@"%s", __FUNCTION__];
    request.content = @"自定义content";
    request.desc = @"自定义desc";
    request.extension1 = @"自定义extension1";
    request.extension2 = @"自定义extension2";
    request.extension3 = @"自定义extension3";
    request.appName = APPNameSuiZhi;
    request.account_name = @"自定义account_name";
    request.account_password = @"自定义account_password";
    request.loginType = LoginTypeAccount;
    request.networkType = NetworkTypeNone;
    request.systemType = SystemTypeiOS;
    
    [[RequestClient sharedRequestClient] request:request success: ^(Request *request, id data) {
        //ResponseAddLog *response = [[ResponseAddLog alloc] initWithData:data];
        
    } failed:^(Request *request, id data, NSError *error) {
        //ResponseAddLog *response = [[ResponseAddLog alloc] initWithData:data];
        
    }];
    
    
}

@end
