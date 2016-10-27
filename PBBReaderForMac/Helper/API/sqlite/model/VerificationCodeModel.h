//
//  VerificationCodeModel.h
//  PBB
//
//  Created by pengyucheng on 15/1/30.
//  Copyright (c) 2015年 pyc.com.cn. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "LKDaoBase.h"

@interface VerificationCodeModelBase : LKDAOBase

@end

@interface VerificationCodeModel : LKModelBase

@property NSInteger rowid;
//@property(nonatomic,assign)NSInteger Bid;
// 验证码id
@property(nonatomic,copy)NSString *messageId;
// 验证码
@property(nonatomic,copy)NSString *verificationCode;
// 接收时间
@property(nonatomic,copy)NSDate *reciveTime;
// 1:绑定用户手机号完善个人消息  0:激活文件
@property(nonatomic,copy)NSString *seeFile;


@end
