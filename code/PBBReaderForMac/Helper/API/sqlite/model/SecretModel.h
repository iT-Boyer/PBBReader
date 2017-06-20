//
//  SecretModel.h
//  GoAppTest
//
//  Created by pengyucheng on 14-3-24.
//  Copyright (c) 2014年 sqliteTest. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "LKDaoBase.h"

@interface SecretModelBase : LKDAOBase

@end


@interface SecretModel : LKModelBase

@property NSInteger rowid;
//@property(nonatomic,assign)NSInteger Bid;
// 密文路径
@property(nonatomic,copy)NSString *filePath;
// 密文文件名称
@property(nonatomic,copy)NSString *fileName;
// 加密时间
@property(nonatomic,copy)NSString *makeTime;
// 钥匙
@property(nonatomic,copy)NSString *logName;
// 明文拓展名
@property(nonatomic,copy)NSString *fileType;

@end