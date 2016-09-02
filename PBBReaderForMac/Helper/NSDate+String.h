//
//  NSDate+String.h
//  Accounting
//
//  Created by ccg on 13-8-30.
//  Copyright (c) 2013年 ccg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (String)

// 获取时间字符串
- (NSString *)dateString;
//获取pbb时间字符串
- (NSString *)dateStringForPbb;
// 获取时间字符串，天数类型
- (NSString *)dateStringByDay;
- (NSString *)dateStringByDayOfCN;
// 根据字符串获取时间
+ (NSDate *)dateWithString:(NSString *)str;

// 根据字符串获取时间，日期类型
+ (NSDate *)dateWithStringByDay:(NSString *)str;

// 根据当前时间和天数获取时间
//- (NSDate *)dateWithDay:(NSInteger)day;
// 根据当前时间和月份获取时间
//- (NSDate *)dateWithMonth:(NSInteger)month;
// 根据年份获取时间
//+ (NSDate *)dateWithYear:(NSInteger)year;

//根据指定的起始时间，与结束时间，计算天数并返回
+(NSInteger)DayByFromDate:(NSDate *)startDate ToDate:(NSDate *)endDate;

//计算实际倒计时剩余几天
+(NSInteger)LastDayByFromDate:(NSDate *)startDate ToDate:(NSDate *)endDate;

+(NSInteger)OffLineFileOfLastdayFromDate:(NSDate *)startDate ToDate:(NSDate *)endDate;

// 将指定时间的日期赋给当前对象的日期，时间不变
//- (NSDate *)copyDateButTimeWithDate:(NSDate *)date;


//获取IOS 世界标准时间UTC /GMT 转为当前系统时区对应的时间
+ (NSDate *)getNowDateFromatAnDate:(NSDate *)dateTime;

//
+(NSDate *)getUTCFormateLocalDate:(NSString *)localDate;


@end
