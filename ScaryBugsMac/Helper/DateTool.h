//
//  DateTool.h
//  PBB
//
//  Created by bolin on 13-11-28.
//  Copyright (c) 2013年 pyc.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateTool : NSObject
+ (DateTool *)sharedDateTool;

// 根据时间转换日期元素
- (NSDateComponents *)dateComponentsWithDate:(NSDate *)date;
// 获取指定日期在月的开始时间
- (NSDate *)startDateInMonthOfDate:(NSDate *)date;
// 获取指定日期在月的结束时间
- (NSDate *)endDateInMonthOfDate:(NSDate *)date;

@end
