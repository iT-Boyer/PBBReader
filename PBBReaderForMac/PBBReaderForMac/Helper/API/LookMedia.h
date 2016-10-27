//
//  LookMedia.h
//  PBB
//
//  Created by pengyucheng on 14-11-24.
//  Copyright (c) 2014年 pyc.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
@interface LookMedia : NSObject


@property (nonatomic, copy) NSString *urlImagePath;

@property(assign,nonatomic)NSInteger fileid;
//0:返回列表        1:返回详情页面
@property(nonatomic,strong)NSString *backFlage;
@property(nonatomic,copy)NSString *receviveFileId;

@property(nonatomic,assign) NSInteger bOpenInCome;
//阅读时长
@property(nonatomic,assign)NSInteger limitTime;

@property(nonatomic,assign)NSInteger openinfoid;
@property(nonatomic,strong)NSString *waterMark;

@property(nonatomic, strong)NSData      *fileSecretkeyR1;
@property(nonatomic, assign)long long     EncryptedLen;
@property(nonatomic, assign)long long     fileSize;
@property(nonatomic, assign)long long     offset;

@property(nonatomic,strong)NSData *imageData;
- (void)lookMedia:(NSString *)openFilePath;


@end
