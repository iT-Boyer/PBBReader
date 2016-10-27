//
//  NSString+More.m
//  Accounting
//
//  Created by ccg on 13-8-31.
//  Copyright (c) 2013年 ccg. All rights reserved.
//

#import "NSString+More.h"

@implementation NSString (More)

#pragma mark 获取金额的字符串
+ (NSString *)stringWithFloat:(CGFloat)money
{
    return [self stringWithFloat:money prefix:@""];
}

#pragma mark 获取金额的字符串，添加前缀
+ (NSString *)stringWithFloat:(CGFloat)money prefix:(NSString *)prefix
{
    return [NSString stringWithFormat:@"%@%.1f", prefix, money];
}

#pragma mark 添加文件名后缀
- (NSString *)fileNameAppend:(NSString *)append
{
    // 1.获取没有拓展名的文件名
    NSString *fileName = [self stringByDeletingPathExtension];
    
    // 2.拼接字符串
    fileName = [fileName stringByAppendingString:append];
    NSString *exten = [self pathExtension];
    return [fileName stringByAppendingPathExtension:exten];
}
- (NSString *)fileNameAppendForPbb:(NSString *)append
{
    // 1.获取没有拓展名的文件名
    NSString *fileName = [self stringByDeletingPathExtension];
    NSString *filenameExt = [fileName pathExtension];
    NSString *fileNameWithNoPath = [fileName stringByDeletingPathExtension];
    
    // 2.拼接字符串
    fileNameWithNoPath = [fileNameWithNoPath stringByAppendingString:append];
    NSString *exten = [self pathExtension];
    fileNameWithNoPath =  [fileNameWithNoPath stringByAppendingPathExtension:filenameExt];
    return [fileNameWithNoPath stringByAppendingPathExtension:exten];
}

-(NSString *)stringReplaceDelWater:(NSMutableArray *)items
{
    NSString *water = self;
    for (int i = 0;  i<items.count;i++) {
        NSString *tmp = items[i];
        water = [water stringByReplacingOccurrencesOfString:tmp withString:@" "];
    }
    return [water stringByReplacingOccurrencesOfString:@":" withString:@""];
}


-(BOOL)fileIsTypeOfVideo
{
    NSString *pathExt = self;
    NSString *str = [NSString stringWithFormat:@"%@",@"+rmvb+mkv+mpeg+mp4+mov+avi+3gp+flv+wmv+rm+mpg+vob+dat+"];
    pathExt = [pathExt lowercaseString];
    //    NSComparisonResult *result = [pathExt commonPrefixWithString:str options:NSCaseInsensitiveSearch|NSNumericSearch];
    NSRange range=[str rangeOfString: pathExt];
    if (!(range.location==NSNotFound)) {
        return YES;
    }
    return NO;
}
@end
