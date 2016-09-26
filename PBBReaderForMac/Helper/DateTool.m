//
//  DateTool.m
//  PBB
//
//  Created by bolin on 13-11-28.
//  Copyright (c) 2013年 pyc.com.cn. All rights reserved.
//

#import "DateTool.h"

@implementation DateTool

singleton_implementation(DateTool)
// 根据时间转换日期元素
- (NSDateComponents *)dateComponentsWithDate:(NSDate *)date{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
/**
 
 */
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfMonth | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    comps = [calendar components:unitFlags fromDate:date];
    return comps;
}



#pragma mark 获取指定日期在月的开始时间
- (NSDate *)startDateInMonthOfDate:(NSDate *)date
{
    NSDateComponents *comps = [self dateComponentsWithDate:date];
    NSString *dateStr = [NSString stringWithFormat:@"%ld-%ld-01 00:00:00", (long)comps.year, (long)comps.month];
    
    return [NSDate dateWithString:dateStr];
}

#pragma mark 获取指定日期在月的结束时间
- (NSDate *)endDateInMonthOfDate:(NSDate *)date
{
    NSDateComponents *comps = [self dateComponentsWithDate:date];
    NSInteger day = [self dayWithYear:comps.year Month:comps.month];
    NSString *dateStr = [NSString stringWithFormat:@"%ld-%ld-%ld 23:59:59", (long)comps.year, (long)comps.month, (long)day];
    
    return [NSDate dateWithString:dateStr];
}

#pragma mark 计算相应月份的天数
- (NSInteger)dayWithYear:(NSInteger)year Month:(NSInteger)month
{
    int day = 30;
    if (month == 2) {
        if ((year % 400 == 0) || (year % 4 == 0 && year % 100 == 0)) {
            day = 29;
        } else {
            day = 28;
        }
    } else if(month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
        day = 31;
    } else {
        day = 30;
    }
    
    return day;
}



@end
