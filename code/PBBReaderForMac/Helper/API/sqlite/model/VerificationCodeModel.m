//
//  VerificationCodeModel.m
//  PBB
//
//  Created by pengyucheng on 15/1/30.
//  Copyright (c) 2015年 pyc.com.cn. All rights reserved.
//

#import "VerificationCodeModel.h"


@implementation VerificationCodeModelBase

+(Class)getBindingModelClass
{
    return [VerificationCodeModel class];//返回文件实体
}

const static NSString* tablename = @"VerificationCode";//表名

+(const NSString *)getTableName
{
    return tablename;
}

@end
@implementation VerificationCodeModel

@synthesize rowid;
@synthesize messageId,verificationCode,reciveTime,seeFile;

-(id)init
{
    self = [super init];
    if (self) {
        //        self.primaryKey = @"Bid";
        self.rowid = super.rowid;
    }
    return self;
}

@end
