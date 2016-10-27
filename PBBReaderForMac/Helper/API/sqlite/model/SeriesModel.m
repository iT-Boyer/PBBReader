//
//  SeriesModel.m
//  PBB
//
//  Created by pengyucheng on 15/6/10.
//  Copyright (c) 2015年 pyc.com.cn. All rights reserved.
//

#import "SeriesModel.h"

@implementation SeriesModelBase

+(Class)getBindingModelClass
{
    return [SeriesModel class];
}

const static NSString *tableName = @"Series";
+(const NSString *)getTableName
{
    return tableName;
}

@end

@implementation SeriesModel

-(id)init
{
    self = [super init];
    if (self) {
                self.primaryKey = @"seriesID";
        //        self.rowid = super.rowid;
    }
    return self;
}
@end
