//
//  Article.h
//  PBB
//
//  Created by pengyucheng on 15/4/23.
//  Copyright (c) 2015年 pyc.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LKDaoBase.h"

@interface ArticleModelBase : LKDAOBase

@end


@interface ArticleModel : LKModelBase

@property NSInteger rowid;
@property(nonatomic,assign)NSInteger Id;
@property(nonatomic,strong)NSString *Title;
@property(nonatomic,strong)NSString *Addtime;
@property(nonatomic,strong)NSString *Url;
@end
