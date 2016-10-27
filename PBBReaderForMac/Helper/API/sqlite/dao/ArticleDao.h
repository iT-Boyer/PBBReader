//
//  ArticleDao.h
//  PBB
//
//  Created by pengyucheng on 15/4/24.
//  Copyright (c) 2015年 pyc.com.cn. All rights reserved.
//

#import "LKDaoBase.h"
#import "Singleton.h"
#import "ArticleModel.h"

@interface ArticleDao : LKDAOBase

singleton_interface(ArticleDao);


/**
 *  插入数据
 */

-(void)insertToArticle:(ArticleModel*)article;

/**
 *  删除数据
 */
-(void)removeFromArticle:(ArticleModel*)article;

/**
 *  查询所有
 *
 *  @return 获取本地所有的推送通知
 */

-(NSArray *)fetchAllArticle;

/**
 *  清除本地所有推送信息
 */
-(void)clearArticle;
@end
