//
//  SeriesDao.m
//  PBB
//
//  Created by pengyucheng on 15/6/10.
//  Copyright (c) 2015年 pyc.com.cn. All rights reserved.
//

#import "SeriesDao.h"
#import "DataFactory.h"

@implementation SeriesDao
singleton_implementation(SeriesDao);


-(void)insertToSeries:(SeriesModel *)model
{
    //判断记录是否存在
    __block BOOL result = NO;
    //方法一
    //    [[DataFactory shardDataFactory] isExistsModel:article Classtype:Article callback:^(BOOL exist) {
    //        result = exist;
    //    }];
    //方法二
    NSString *where = [NSString stringWithFormat:@"seriesID=%ld",(long)model.seriesID];
    [[DataFactory shardDataFactory] isExistsWithWhere:where Classtype:Series callback:^(BOOL exist) {
        result = exist;
    }];
    
    //不存在,插入数据库中
    if (!result) {
        [[DataFactory shardDataFactory] insertToDB:model Classtype:Series];
    }else
    {
        //系列记录存在时，更新系列信息
        [[DataFactory shardDataFactory]updateToDB:model Classtype:Series];
        
    }

}

-(NSString *)fetchSeriesNameFromSeriesId:(NSInteger)seriesId
{
    __block NSString *seriesName = @"";
    NSString *whereStr = [NSString stringWithFormat:@"seriesID = %@",[NSNumber numberWithInteger:seriesId]];
    [[DataFactory shardDataFactory] fetchToDBWithWhere:whereStr columeName:@"seriesName" Classtype:Series callback:^(NSString *result) {
        seriesName = result;
    }];
    if (seriesName.length == 0) {
        seriesName = @"未分组文件";
    }
    return seriesName;
}
-(NSArray *)fetchAllSeries
{
    __block NSArray *serieslist = nil;
    [[DataFactory shardDataFactory] searchAllOrderBy:@"seriesID DESC"
                                           Classtype:Series
                                            callback:^(NSArray *all) {
                                                serieslist = all;
                                            }];
    return serieslist;
}


-(void)removeFromSeries:(SeriesModel *)model
{
   [[DataFactory shardDataFactory] deleteToDB:model Classtype:Series];
}
@end
