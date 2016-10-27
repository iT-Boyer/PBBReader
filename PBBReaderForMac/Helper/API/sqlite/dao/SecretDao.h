//
//  SecretDao.h
//  PBB
//
//  Created by pengyucheng on 14-3-27.
//  Copyright (c) 2014年 pyc.com.cn. All rights reserved.
//

#import "LKDaoBase.h"
#import "Singleton.h"

#import "SecretModel.h"
@interface SecretDao : LKDAOBase

singleton_interface(SecretDao)

-(void)addSecretFile:(SecretModel *)secret;

-(NSArray *)secretFileList:(NSString *)logName;

-(void)deleteSecretFileId:(NSString *)fileId;

-(void)deleteFileByModel:(SecretModel *)secret;

-(NSArray *)secretFileTypeListForImg;

-(NSArray *)secretFileTypeListForMov;

-(int)searchSecretNum:(NSString *)logname;
@end
