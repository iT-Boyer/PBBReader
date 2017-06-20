//
//  Article.m
//  PBB
//
//  Created by pengyucheng on 15/4/23.
//  Copyright (c) 2015年 pyc.com.cn. All rights reserved.
//

#import "ArticleModel.h"

@implementation ArticleModelBase



+(Class)getBindingModelClass
{
    return [ArticleModel class];  //特别提示：此处返回Model类，而不是ModelBase类
}

const static NSString * tablename = @"Article";

+(const NSString *)getTableName
{
    return tablename;
}

@end
@implementation ArticleModel

@synthesize rowid, Id,Title,Addtime,Url;

-(id)init
{
    self = [super init];
    if (self) {
//        self.primaryKey = @"Id";
//        self.rowid = super.rowid;
    }
    return self;
}
@end
