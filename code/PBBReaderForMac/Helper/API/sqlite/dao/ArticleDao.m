//
//  ArticleDao.m
//  PBB
//
//  Created by pengyucheng on 15/4/24.
//  Copyright (c) 2015年 pyc.com.cn. All rights reserved.
//

#import "ArticleDao.h"
#import "DataFactory.h"

@implementation ArticleDao

singleton_implementation(ArticleDao);


-(void)insertToArticle:(ArticleModel *)article
{
    //判断记录是否存在
   __block BOOL result = NO;
    //方法一
//    [[DataFactory shardDataFactory] isExistsModel:article Classtype:Article callback:^(BOOL exist) {
//        result = exist;
//    }];
    //方法二
    NSString *where = [NSString stringWithFormat:@"Id=%ld",(long)article.Id];
    [[DataFactory shardDataFactory] isExistsWithWhere:where Classtype:Article callback:^(BOOL exist) {
        result = exist;
    }];
    
    //不存在,插入数据库中
    if (!result) {
         [[DataFactory shardDataFactory] insertToDB:article Classtype:Article];
    }
   
}

-(NSArray *)fetchAllArticle
{
    __block NSArray *articlelist = nil;
    [[DataFactory shardDataFactory] searchAllOrderBy:@"Id DESC"
                                           Classtype:Article
                                            callback:^(NSArray *all) {
                                                articlelist = all;
                                            }];
    return articlelist;

}


-(void)removeFromArticle:(ArticleModel *)article
{
    [[DataFactory shardDataFactory] deleteToDB:article Classtype:Article];
}

-(void)clearArticle
{
//    NSLog(@"%s", __func__);
    [[DataFactory shardDataFactory] clearTableData:Article];
}
@end
