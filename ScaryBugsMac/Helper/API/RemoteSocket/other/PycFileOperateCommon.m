//
//  PycFileOperateCommon.m
//  PBB
//
//  Created by Fairy on 14-3-20.
//  Copyright (c) 2014年 pyc.com.cn. All rights reserved.
//

#import "PycFileOperateCommon.h"
#import "PycCode.h"

@implementation PycFileOperateCommon

+(NSInteger)GetFileType:(NSString *)filePath
{
    NSDictionary * fileTypeDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"mp4",
                                  [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"rmvb",
                                  [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"mkv",
                                  [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"mpeg",
                                  [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"mov",
                                  [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"avi",
                                  [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"3gp",
                                  [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"flv",
                                  [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"wmv",
                                  [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"mpg",
                                  [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"vob",
                                  [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"rm",
                                  [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"wav",
                                  [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"dat",
                                  [NSNumber numberWithInteger:FILE_TYPE_PIC], @"jpg",
                                  [NSNumber numberWithInteger:FILE_TYPE_PIC], @"bmp",
                                  [NSNumber numberWithInteger:FILE_TYPE_PIC], @"gif",
                                  [NSNumber numberWithInteger:FILE_TYPE_PIC], @"jpeg",
                                  [NSNumber numberWithInteger:FILE_TYPE_PIC], @"jpe",
                                  [NSNumber numberWithInteger:FILE_TYPE_PIC], @"png",nil];

    
    
    
    NSNumber *nsfileType  = fileTypeDic[[[filePath pathExtension] lowercaseString]];
    
    if (nsfileType == nil) {
        return  FILE_TYPE_UNKOWN;
    }
    else
    {
       return  [nsfileType integerValue];
    }
}

+(int64_t)codeFile:(NSString *)filePath length:(NSInteger) codeLen  byKey:(NSData *)key
{
    //get file len
    int64_t readReallen = 0;
    NSInteger preReadMaxLen = 1024 * 1024;
    NSInteger filePos = 0;
    NSInteger encodelen = 0;
    BOOL bFinish = NO;
    
    NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    if (handle == nil) {
        return -1;
    }
    
    while (!bFinish) {
        
        NSData *data = [handle readDataOfLength:preReadMaxLen];
        
        readReallen += [data length];
        if ([data length] == 0) {
            NSLog(@"finish code %lld", readReallen); //-------
            break;
        }
        
        
        if (readReallen >= codeLen) {
            encodelen = [data length] - (readReallen -codeLen);
            NSLog(@"last encrypt len %ld", (long)encodelen);
            readReallen = codeLen;//-------
            bFinish = YES;
        }else
        {
            encodelen = [data length];
        }
        
        
        PycCode *coder = [[PycCode alloc] init];
        [coder codeBufferOfFile:(Byte *)[data bytes] length:(int)encodelen withKey:(Byte *)[key bytes]];
        
        [handle seekToFileOffset:filePos];
        [handle writeData:data];
        filePos += encodelen;
    }
    
    [handle closeFile];
    
    return readReallen;
    
}

@end
