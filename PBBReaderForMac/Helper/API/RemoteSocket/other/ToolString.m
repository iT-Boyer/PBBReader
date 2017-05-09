//
//  ToolString.m
//  PBB
//
//  Created by pycnyp on 13-12-23.
//  Copyright (c) 2013年 pyc.com.cn. All rights reserved.
//

#import "ToolString.h"
#import "sys/sysctl.h"
#import "Reachability.h"
@implementation ToolString
/**
 *  是否为同一天
 */
+(BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2
{
//    NSCalendar* calendar = [NSCalendar currentCalendar];
//    
//    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
//    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
//    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
//    
//    return [comp1 day]   == [comp2 day] &&
//    [comp1 month] == [comp2 month] &&
//    [comp1 year]  == [comp2 year];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *comp1= [dateFormatter stringFromDate:date1];
    NSString *comp2=[dateFormatter stringFromDate:date2];
    return [comp1 isEqualToString:comp2];
}


+(int)getVersionStr{
    
    NSString *str=[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSArray *array = [str componentsSeparatedByString:@"."];
    int versionStr = [array[0] intValue]*1000000+[array[1] intValue]*10000+[array[2] intValue]*100;
    return versionStr;
}

/**
 *  转化本地时间
 */
+ (NSDate *)tDate

{
    
    NSDate *date = [NSDate date];
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    
    NSInteger interval = [zone secondsFromGMTForDate: date];
    
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    
    return localeDate;
    
}
+ (NSString *)getVersionCode
{
    // 判断是否第一次使用这个版本
    NSString *currentVersionCode  = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return currentVersionCode;
}


+(NSString *)getUuid
{
    CFUUIDRef puuid = CFUUIDCreate(nil);
    CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
    NSString *result = [NSString stringWithFormat:@"%@",CFStringCreateCopy(NULL, uuidString)];
    return result;
}
//使用系统的一个函数sysctlbyname 来获取设备名称
+ (NSString *) platformString
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    //NSString *platform = [NSString stringWithCString:machine];
    //    NSString* []'i9platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    NSLog(@"不同平台(platformString)的代表值:%@",platform);
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus ";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    //虚拟机
    if ([platform isEqualToString:@"i386"]||[platform isEqualToString:@"x86_64"])         return @"Mac";
    
    return platform;
}

+(BOOL)isConnectionAvailable
{
    BOOL able = NO;
    Reachability *r = [Reachability reachabilityWithHostName:@"0.0.0.0"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
//            NSLog(@"无网络");
            able = NO;
            break;
        default:
//            NSLog(@"有网络");
            able = YES;
            break;
    }
    return able;
}


+(BOOL) isBlankString:(NSString *)string
{
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

+(NSArray *)sourceArr:(NSArray *)sourceArr resultPredicate:(NSString *)text
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@",text];
    return  [sourceArr filteredArrayUsingPredicate:resultPredicate];
}
@end
