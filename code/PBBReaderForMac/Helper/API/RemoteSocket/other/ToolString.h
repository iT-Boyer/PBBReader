//
//  ToolString.h
//  PBB
//
//  Created by pycnyp on 13-12-23.
//  Copyright (c) 2013年 pyc.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToolString : NSObject

+(BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2;

+ (NSDate *)tDate;

+(NSString *)getVersionCode;

+(CGSize)getStringSize:(NSString *)str;

+(NSString *)getUuid;

//判断运行环境，区别（虚拟机【Simulator】，或真机）
+ (NSString *) platformString;

+(int)getVersionStr;

//判断本机网络是否正常
+(BOOL)isConnectionAvailable;

+(BOOL) isBlankString:(NSString *)string;

+(NSArray *)sourceArr:(NSArray *)sourceArr resultPredicate:(NSString *)text;
@end
