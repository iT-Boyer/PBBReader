//
//  SecretModel.m
//  GoAppTest
//
//  Created by pengyucheng on 14-3-24.
//  Copyright (c) 2014年 sqliteTest. All rights reserved.
//

#import "SecretModel.h"

@implementation SecretModelBase

+(Class)getBindingModelClass
{
    return [SecretModel class];//返回文件实体
}

const static NSString* tablename = @"Secret";//表名

+(const NSString *)getTableName
{
    return tablename;
}

@end


@implementation SecretModel

@synthesize rowid;
@synthesize fileType,filePath,fileName,logName,makeTime;

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
