//
//  LookMedia.m
//  PBB
//
//  Created by pengyucheng on 14-11-24.
//  Copyright (c) 2014年 pyc.com.cn. All rights reserved.
//

#import "LookMedia.h"
#import "ReceiveFileDao.h"
#import "userDao.h"
#import "ToolString.h"

#import "PlayerLoader.h"
#import "client.h"

@implementation LookMedia
{
    OutFile *_receiveFile;
    char *_filePath;
    NSString *_filename;
}

- (void)lookMedia:(NSString *)openFilePath
{
    //明文
    if(![openFilePath hasSuffix:@"pbb"]){
        [[PlayerLoader sharedInstance] loadVideoWithLocalFiles:@[openFilePath]];
    }

    //pbb文件
    [[ReceiveFileDao sharedReceiveFileDao] updateReceiveFileToAddReadNumByFileId:[_receviveFileId integerValue]];
    [[ReceiveFileDao sharedReceiveFileDao]updateReceiveFileApplyOpen:1 FileId:[_receviveFileId integerValue]];
    
    _receiveFile = [[ReceiveFileDao sharedReceiveFileDao] fetchReceiveFileCellByFileId:[_receviveFileId integerValue]
                                                                               LogName:[[userDao shareduserDao] getLogName]];
    if(!_receiveFile){
        return;
    }
    
    //bilibili
    NSString *bytestr = @"";
    for (int i = 0; i<16; i++)
    {
        bytestr = [bytestr stringByAppendingString:[NSString stringWithFormat:@"%d,",((Byte *)[_fileSecretkeyR1 bytes])[i]]];
    }
    NSLog(@"密钥=====:%@",bytestr);
    set_key_info((unsigned char*)(Byte *)[_fileSecretkeyR1 bytes],
                 (long)_EncryptedLen,
                 (long)_fileSize,
                 (long)_offset);
    [[PlayerLoader sharedInstance] loadVideoWithLocalFiles:@[openFilePath]];
    
}
-(BOOL)isShotScreen{
    //点击阅读，首先判断今天是否有过三次截图操作
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDate *defaultDate=[defaults objectForKey:@"firstDate"];
    NSNumber *count=[defaults objectForKey:@"screenShotCountToday"];
    NSLog(@"cishuwei:%@",count);
    int countint=[count intValue];
    NSDate *dateNow=[ToolString tDate];
    if (defaultDate!=nil) {
        if ([ToolString isSameDay:dateNow date2:defaultDate]) {
            //今天截图次数是否达到三次了
            if (countint>2) {
                //截图次数大于等于三次，不允许继续阅读了
//                [self setAlertView:@"由于恶意截屏，系统将禁止您今日继续阅读文件。"];
                return NO;
            }
        }else{
            [defaults setObject:0 forKey:@"screenShotCountToday"];
            [defaults setObject:dateNow forKey:@"firstDate"];
            [defaults synchronize];
        }
    }
    return YES;
}


-(BOOL)fileIsTypeOfImage:(NSString *)pathExt
{
    if (!pathExt) {
        return NO;
    }
    NSString *str = [NSString stringWithFormat:@"%@",@"+jpg+png+bmp+gif+jpeg+jpe+"];
    pathExt = [pathExt lowercaseString];
    //    NSComparisonResult *result = [pathExt commonPrefixWithString:str options:NSCaseInsensitiveSearch|NSNumericSearch];
    NSRange range=[str rangeOfString: pathExt];
    if (!(range.location==NSNotFound)) {
        return YES;
    }
    return NO;
}

-(BOOL)fileIsTypeOfPdf:(NSString*)pathExt
{
    pathExt = [pathExt lowercaseString];
    if ([pathExt isEqualToString:@"pdf"]) {
        return YES;
    }
    return NO;
}

-(BOOL)fileIsTypeOfMusic:(NSString *)pathExt
{
    NSString *str = [NSString stringWithFormat:@"%@",@"+mp3+wav+"];
    pathExt = [pathExt lowercaseString];
    NSRange range=[str rangeOfString: pathExt];
    if (!(range.location==NSNotFound)) {
        return YES;
    }
    return NO;
}

-(BOOL)fileIsTypeOfVideo:(NSString *)pathExt
{
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
