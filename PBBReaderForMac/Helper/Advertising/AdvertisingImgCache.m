//
//  AdvertisingImgCache.m
//  PBB
//
//  Created by pengyucheng on 14/12/9.
//  Copyright (c) 2014年 pyc.com.cn. All rights reserved.
//

#import "AdvertisingImgCache.h"
#import "SandboxFile.h"
#import "ToolString.h"
#import "ReceiveFileDao.h"
@implementation AdvertisingImgCache


- (void)AdvertisingForTerm:(NSString *)UidOrImgURL completionBlock:(AdvertisingCompletionBlock) completionBlock
{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        
         NSString *fileDir = [SandboxFile CreateList:[SandboxFile GetDocumentPath] ListName:@".PBBReader/advert"];
        
        
        if ([UidOrImgURL hasPrefix:@"http"]) {
            
             //在线/离线第次查看
            NSError *error = nil;
//            NSString *htmlSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:UidOrImgURL]
//                                                            encoding:NSUTF8StringEncoding
//                                                               error:&error];
            
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:UidOrImgURL]
                                                     cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                 timeoutInterval:3];
            NSURLResponse* response=nil;
            NSData* data=[NSURLConnection sendSynchronousRequest:request
                                               returningResponse:&response
                                                           error:&error];
            
            NSString    *htmlSource = [[NSString alloc] initWithData:data
                                                                encoding:NSUTF8StringEncoding];
            if (error != nil) {
                completionBlock(nil,-1,error);
            }
            else
            {
                //解析网页获取图片名字
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"http.*?(jpg|png|jpeg)"
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:&error];
                if(error != nil) {
                    completionBlock(nil,-1,error);
                } else {
                    
                    NSTextCheckingResult *result = [regex firstMatchInString:htmlSource
                                                                     options:0
                                                                       range:NSMakeRange(0, htmlSource.length)];
                    //获取图片名字
                    NSString *imgUrl = [htmlSource substringWithRange:[result rangeAtIndex:0]];

                    NSString *imageName = [imgUrl lastPathComponent];
                    NSString *ImgPath = [NSString stringWithFormat:@"%@/%@",fileDir,imageName];
                    
                    //如果存在，删除旧文件
                    NSString *uid = @"";
                    
                    //获取Uid正则表达式
                    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d{1,}"
                                                                                           options:0
                                                                                             error:nil];
                    NSTextCheckingResult *uidRex = [regex firstMatchInString:imageName
                                                                     options:0
                                                                       range:NSMakeRange(0, imageName.length)];
                    //获取图片uid
                    uid = [imageName substringWithRange:[uidRex rangeAtIndex:0]];

                    if ([SandboxFile IsFileExists:ImgPath]) {
                        //读缓存
                        NSLog(@"读取本地已缓存广告图:%@",ImgPath);
                        completionBlock(ImgPath,[uid integerValue],nil);
                    }else{
                        //根据Uid判断本地是否存在老广告图，并删除
                        [self removeFilesByUid:uid FileDir:fileDir];
                        //缓存新广告图
//                        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]
//                                                                  options:NSDataReadingMappedIfSafe
//                                                                    error:&error];
                        
                        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:imgUrl]
                                                                 cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                             timeoutInterval:3];
                        NSURLResponse* response=nil;
                        NSData* imageData=[NSURLConnection sendSynchronousRequest:request
                                                           returningResponse:&response
                                                                       error:&error];
                        
                        if(error != nil) {
                            completionBlock(nil,-1,error);
                        } else {
                            [imageData writeToFile:ImgPath atomically:YES];
                            completionBlock(ImgPath,[uid integerValue],nil);
                        }
                    }
                }
            }
        }else{
            //离线文件Uid
            NSString *oldfile = [self fetchFilesByUid:UidOrImgURL FileDir:fileDir];
            completionBlock(oldfile,-1,nil);
        }
        
    });
}


#pragma mark 根据Uid判断本地是否存在老广告图，并删除
-(void)removeFilesByUid:(NSString *)uid FileDir:(NSString *)fileDir
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@",uid];
    
    NSArray *filesNames = [SandboxFile GetSubpathsAtPath:fileDir];
    
    NSArray *oldFiles = [filesNames filteredArrayUsingPredicate:pre];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //删除旧的广告图
    [oldFiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *oldfile = [NSString stringWithFormat:@"%@/%@",fileDir,obj];
        if ([SandboxFile IsFileExists:oldfile]) {
            [fileManager removeItemAtPath:oldfile error:nil];
        }
    }];

}

//获取目录下，同系列的广告图片
-(NSString *)fetchFilesByUid:(NSString *)uid FileDir:(NSString *)fileDir
{
    if([uid isEqualToString:@"0"])
        return nil;
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@",uid];
    
    NSArray *filesNames = [SandboxFile GetSubpathsAtPath:fileDir];
    
    NSArray *oldFiles = [filesNames filteredArrayUsingPredicate:pre];
    
    if (oldFiles.count==0) {
        return nil;
    }else{
        return [NSString stringWithFormat:@"%@/%@",fileDir,oldFiles[0]];
    }
}
@end
