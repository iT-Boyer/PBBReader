//
//  SeriesDao.h
//  PBB
//
//  Created by pengyucheng on 15/6/10.
//  Copyright (c) 2015年 pyc.com.cn. All rights reserved.
//

#import "LKDaoBase.h"
#import "Singleton.h"
#import "SeriesModel.h"

@interface SeriesDao : LKDAOBase

singleton_interface(SeriesDao);

/*!
 *  @author shuguang, 15-06-10 14:06:51
 *
 *  @brief  新系列文件
 *
 *  @param model 系列对象
 */
-(void)insertToSeries:(SeriesModel *)model;

/*!
 *  @author shuguang, 15-07-01 11:07:34
 *
 *  @brief  获取某个字段值
 *
 *  @param seriesId 系列ID
 *
 *  @return 系列名称
 */
-(NSString *)fetchSeriesNameFromSeriesId:(NSInteger)seriesId;
/*!
 *  @author shuguang, 15-06-10 14:06:49
 *
 *  @brief  获取系列表的所有字段信息
 *
 *  @return 系列表信息
 */
-(NSArray *)fetchAllSeries;
/**
 *  删除数据
 */


-(void)removeFromSeries:(SeriesModel*)model;

@end
