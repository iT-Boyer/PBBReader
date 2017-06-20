//
//  NSString+More.h
//  Accounting
//
//  Created by ccg on 13-8-31.
//  Copyright (c) 2013年 ccg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (More)

// 获取金额的字符串
+ (NSString *)stringWithFloat:(CGFloat)money;
// 获取金额的字符串，添加前缀
+ (NSString *)stringWithFloat:(CGFloat)money prefix:(NSString *)prefix;
// 添加文件名后缀
- (NSString *)fileNameAppend:(NSString *)append;

- (NSString *)fileNameAppendForPbb:(NSString *)append;

-(NSString *)stringReplaceDelWater:(NSArray *)items;
-(BOOL)fileIsTypeOfVideo;

//排查字符串包含
-(NSDictionary *)getFileType;
@end
