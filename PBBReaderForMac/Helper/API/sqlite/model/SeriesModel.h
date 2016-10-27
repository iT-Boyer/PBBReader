//
//  SeriesModel.h
//  PBB
//
//  Created by pengyucheng on 15/6/10.
//  Copyright (c) 2015年 pyc.com.cn. All rights reserved.
//

#import "LKDaoBase.h"

@interface SeriesModelBase : LKDAOBase

@end

@interface SeriesModel : LKModelBase

//系列ID
@property(nonatomic,assign)NSInteger seriesID;
//系列文件个数
@property(nonatomic,assign)NSInteger seriesFileNum;
//系列名称
@property(nonatomic,strong)NSString *seriesName;
//系列类型：hand:手动， auto:自动
@property(nonatomic,assign)NSInteger seriesClass;
//作者昵称
@property(nonatomic,strong)NSString *seriesAuthor;
//文件个数
@property(nonatomic,strong)NSString *seriesFileNumStr;

@end
