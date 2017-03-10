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
    if(self == nil || self.length == 0)
    {
        return NO;
    }
    NSString *str = [NSString stringWithFormat:@"%@",@"+rmvb+mkv+mpeg+mp4+mov+avi+3gp+flv+wmv+rm+mpg+vob+dat+"];
    //    NSComparisonResult *result = [pathExt commonPrefixWithString:str options:NSCaseInsensitiveSearch|NSNumericSearch];
    NSRange range=[str rangeOfString: [self lowercaseString]];
    if (!(range.location==NSNotFound))
    {
        return YES;
    }
    return NO;
}

-(NSDictionary *)getFileType
{
    //不是.pbb为扩展名的文件一律视为非法格式
    if (self == nil || ![self hasSuffix:@".pbb"])
    {
        return [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:4]
                                           forKey:self];
    }
    
    NSString * fileWithOutPBB = [self stringByReplacingOccurrencesOfString:@".pbb" withString:@""];
    NSString *fileExtention = [[fileWithOutPBB pathExtension] lowercaseString];
    
    NSDictionary * fileTypeDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:1], @"mp4",
                                  [NSNumber numberWithInt:1], @"rmvb",
                                  [NSNumber numberWithInt:1], @"mkv",
                                  [NSNumber numberWithInt:1], @"mpeg",
                                  [NSNumber numberWithInt:1], @"mov",
                                  [NSNumber numberWithInt:1], @"avi",
                                  [NSNumber numberWithInt:1], @"3gp",
                                  [NSNumber numberWithInt:1], @"flv",
                                  [NSNumber numberWithInt:1], @"wmv",
                                  [NSNumber numberWithInt:1], @"mpg",
                                  [NSNumber numberWithInt:1], @"vob",
                                  [NSNumber numberWithInt:1], @"rm",
                                  [NSNumber numberWithInt:1], @"wav",
                                  [NSNumber numberWithInt:1], @"dat",
                                  [NSNumber numberWithInt:2], @"jpg",
                                  [NSNumber numberWithInt:2], @"bmp",
                                  [NSNumber numberWithInt:2], @"gif",
                                  [NSNumber numberWithInt:2], @"jpeg",
                                  [NSNumber numberWithInt:2], @"jpe",
                                  [NSNumber numberWithInt:2], @"png",
                                  [NSNumber numberWithInt:3], @"pdf",nil];
    
    NSNumber *nsfileType  = fileTypeDic[fileExtention];
    NSNumber *ns = [fileTypeDic objectForKey:fileExtention];
    if (nsfileType == nil)
    {
        return [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:4]
                                           forKey:fileExtention];
    }
    else
    {
        return [NSDictionary dictionaryWithObject:nsfileType
                                           forKey:fileExtention];
    }
}

@end
