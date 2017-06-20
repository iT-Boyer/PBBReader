//
//  VerificationCodeDao.h
//  PBB
//
//  Created by pengyucheng on 15/1/30.
//  Copyright (c) 2015年 pyc.com.cn. All rights reserved.
//

#import "LKDaoBase.h"
#import "Singleton.h"

#import "VerificationCodeModel.h"
@interface VerificationCodeDao : LKDAOBase

singleton_interface(VerificationCodeDao)

/**
 *  保存服务器每一返回的验证码
 */

-(void)insertVerificationCode:(VerificationCodeModel*)model;

/**
 *  根据 短信验证码查询&seeFile类型 本地验证码
 */

-(NSString *)searchVerificationCodeOfMessageId:(VerificationCodeModel *)model;



/**
 *  根据短信验证码删除本地验证码
 */

-(void)deleteVerificationCode:(BOOL)model;

/**
 *  清除本地所有验证码
 */
-(void)clearVerificationCode:(VerificationCodeModel *)model;
@end
