//
//  NSDate+String.m
//  Accounting
//
//  Created by ccg on 13-8-30.
//  Copyright (c) 2013年 ccg. All rights reserved.
//

#import "NSDate+String.h"

@implementation NSDate (String)

#pragma mark 获取时间字符串
- (NSString *)dateString
{
    // 定义时间格式
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    df.dateFormat=@"yyyy-MM-dd HH:mm:ss";
    NSString * date = [df stringFromDate:self];
    NSRange ra = [date rangeOfString:@"1900"];
    if (ra.length >0) {
        return @"";
    }
    return date;
}

- (NSString *)dateStringForPbb
{
    // 定义时间格式
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    df.dateFormat=@"yyyyMMdd_HHmmss";
    
    return [df stringFromDate:self];
}

#pragma mark 获取时间字符串，天数类型
- (NSString *)dateStringByDay
{
    // 定义时间格式
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    df.dateFormat=@"yyyy-MM-dd";
    NSString * date = [df stringFromDate:self];
    NSRange ra = [date rangeOfString:@"1900"];
    if (ra.length >0) {
        return @"";
    }
    return date;
}

- (NSString *)dateStringByDayOfCN
{
    // 定义时间格式
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    df.dateFormat=@"yyyy年MM月dd日";
    
    NSString *dateStr = [df stringFromDate:self];
    if ([dateStr isEqualToString:@"1900年01月01日"]
        ||[dateStr isEqualToString:@"1980年01月01日"]) {
        return @"";
    }
    return dateStr;
}

#pragma mark 根据字符串获取时间
+ (NSDate *)dateWithString:(NSString *)str
{
    // 定义时间格式
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    df.dateFormat=@"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [df dateFromString:str];
    
    return date;
}

#pragma mark 根据字符串获取时间，日期类型
+ (NSDate *)dateWithStringByDay:(NSString *)str
{
    // 定义时间格式
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    df.dateFormat=@"yyyy-MM-dd";
    if ([str length]>11) {
        df.dateFormat=@"yyyy-MM-dd HH:mm:ss";
    }
    
    
    if ([str isEqualToString:@""]||str==nil) {
        str = @"1900-01-01";
    }
//    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*60*60]];
    NSDate *date = [df dateFromString:str];
    
    return date;
}

//根据起始时间，与结束时间，计算相差天数并返回
+(NSInteger)DayByFromDate:(NSDate *)startDate ToDate:(NSDate *)endDate
{
    if ([[startDate dateStringByDay] isEqualToString:@"1900-01-01"]
        ||[[startDate dateStringByDay] isEqualToString:@"1980-01-01"]
        ||[[endDate dateStringByDay] isEqualToString:@"1900-01-01"]
        ||[[endDate dateStringByDay] isEqualToString:@"1980-01-01"]) {
        return 0;
    }
    endDate = [endDate dateByAddingTimeInterval:+24*60*60];
    NSTimeInterval allseconds = [endDate timeIntervalSinceDate:startDate];
    float ftemp = allseconds/(24*60*60);
    int itemp = round(ftemp);
    if(ftemp > itemp)
    {
        itemp++;
    }
    return itemp;
}

//计算实际倒计时剩余几天
+(NSInteger)LastDayByFromDate:(NSDate *)startDate ToDate:(NSDate *)endDate
{
    if ([[startDate dateStringByDay] isEqualToString:@"1900-01-01"]
        ||[[startDate dateStringByDay] isEqualToString:@"1980-01-01"]
        ||[[endDate dateStringByDay] isEqualToString:@"1900-01-01"]
        ||[[endDate dateStringByDay] isEqualToString:@"1980-01-01"]) {
        return 0;
    }
    NSDate *nowDate = [NSDate date];
    //推迟一天
    endDate = [endDate dateByAddingTimeInterval:+24*60*60];
    NSDate *realDate = [nowDate laterDate:startDate];
    NSTimeInterval lastseconds = [endDate timeIntervalSinceDate:realDate];
//    NSLog(@"剩余天数:%f",lastseconds/(24*60*60));
    float ftemp = lastseconds/(24*60*60);
    int itemp = round(ftemp);
    if(ftemp > itemp)
    {
        itemp++;
    }
    return itemp;
}

//离线文件的剩余阅读的次数   当前系统时区对应的时间
+(NSInteger)OffLineFileOfLastdayFromDate:(NSDate *)startDate ToDate:(NSDate *)endDate
{
 //   endDate = [endDate dateByAddingTimeInterval:+24*60*60];
    NSTimeInterval allseconds = [endDate timeIntervalSinceDate:startDate];
    float ftemp = allseconds/(24*60*60);
    int itemp = round(ftemp);
    if(ftemp > itemp)
    {
        itemp++;
    }
    return itemp;
}

//本地日期格式:2013-08-03 12:53:51
//可自行指定输入输出格式
+(NSDate *)getUTCFormateLocalDate:(NSString *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:localDate];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
//    //输出格式
//    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
//    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateFormatted;
    
    
}

//获取IOS 世界标准时间UTC /GMT 转为当前系统时区对应的时间
+ (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
}

//计算两个日期之间的差距，过了多少天。。
+(NSInteger)getDateToDateDays:(NSDate *)date withSaveDate:(NSDate *)saveDate{
    NSCalendar* chineseClendar = [ [ NSCalendar alloc ] initWithCalendarIdentifier:NSCalendarIdentifierGregorian ];
    NSUInteger unitFlags =  NSCalendarUnitHour | NSCalendarUnitMinute |
    NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    NSDateComponents *cps = [ chineseClendar components:unitFlags fromDate:date  toDate:saveDate  options:0];
    NSInteger diffDay   = [ cps day ];
//    [chineseClendar release];
    return diffDay;
}
@end
