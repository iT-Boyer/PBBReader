//
//  NSString+More.m
//  Accounting
//
//  Created by ccg on 13-8-31.
//  Copyright (c) 2013年 ccg. All rights reserved.
//

#import "NSString+More.h"

#define FILE_TYPE_MOVIE 1
#define FILE_TYPE_PIC   2
#define FILE_TYPE_PDF   3
#define FILE_TYPE_UNKOWN    4

static NSDictionary * fileTypeDic;

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
    if (!fileTypeDic)
    {
        fileTypeDic = [NSDictionary dictionaryWithObjectsAndKeys:
                       [NSNumber numberWithInt:FILE_TYPE_MOVIE], @"mp4",
                       [NSNumber numberWithInt:FILE_TYPE_MOVIE], @"rmvb",
                       [NSNumber numberWithInt:FILE_TYPE_MOVIE], @"mkv",
                       [NSNumber numberWithInt:FILE_TYPE_MOVIE], @"mpeg",
                       [NSNumber numberWithInt:FILE_TYPE_MOVIE], @"mov",
                       [NSNumber numberWithInt:FILE_TYPE_MOVIE], @"avi",
                       [NSNumber numberWithInt:FILE_TYPE_MOVIE], @"3gp",
                       [NSNumber numberWithInt:FILE_TYPE_MOVIE], @"flv",
                       [NSNumber numberWithInt:FILE_TYPE_MOVIE], @"wmv",
                       [NSNumber numberWithInt:FILE_TYPE_MOVIE], @"mpg",
                       [NSNumber numberWithInt:FILE_TYPE_MOVIE], @"vob",
                       [NSNumber numberWithInt:FILE_TYPE_MOVIE], @"rm",
                       [NSNumber numberWithInt:FILE_TYPE_MOVIE], @"wav",
                       [NSNumber numberWithInt:FILE_TYPE_MOVIE], @"dat",
                       [NSNumber numberWithInt:FILE_TYPE_PIC], @"jpg",
                       [NSNumber numberWithInt:FILE_TYPE_PIC], @"bmp",
                       [NSNumber numberWithInt:FILE_TYPE_PIC], @"gif",
                       [NSNumber numberWithInt:FILE_TYPE_PIC], @"jpeg",
                       [NSNumber numberWithInt:FILE_TYPE_PIC], @"jpe",
                       [NSNumber numberWithInt:FILE_TYPE_PIC], @"png",
                       [NSNumber numberWithInt:FILE_TYPE_PDF], @"pdf",nil];
        
    }

    
    //先清空服务器数据中"\0"的填充部分
    NSString * fileWithOutPBB = [self stringByReplacingOccurrencesOfString:@"\0" withString:@""];
    //不是.pbb为扩展名的文件一律视为非法格式
    if (fileWithOutPBB == nil || !([fileWithOutPBB isEqualToString:@""] || [fileWithOutPBB hasSuffix:@".pbb"]))
    {
        return [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:FILE_TYPE_UNKOWN]
                                           forKey:fileWithOutPBB];
    }
    
    fileWithOutPBB = [fileWithOutPBB stringByReplacingOccurrencesOfString:@".pbb" withString:@""];
    NSString *fileExtention = [[fileWithOutPBB pathExtension] lowercaseString];
    

    NSNumber *nsfileType  = fileTypeDic[fileExtention];
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
