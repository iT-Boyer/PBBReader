//
//  NewPycUserRemote.h
//  PBB
//
//  Created by Fairy on 14-3-19.
//  Copyright (c) 2014年 pyc.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PycUserRemoteDefine.h"
#import "PycSocket.h"

@class NewPycUserRemote;

@protocol NewPycUserRemoteDelegate <NSObject>
/**
 *	@brief	所有操作均执行的代理函数
 *
 *	@param 	pycUserRemote 	当前对象，得到属性以便保存到数据库
 *	@param 	operateType 	枚举操作的类型分为注册  绑定  找回等
 *	@param 	operateResult 	枚举操作的最终结果
 */
-(void)newPycUserRemote:(NewPycUserRemote *)pycUserRemote finishOperateType:(NewPycUerRemoteOperateType)operateType didFinishWithResult:(PycUserRemoteResult)operateResult;


@end

@interface NewPycUserRemote : NSObject
{

}
@property(nonatomic,strong)PycSocket *pycSocket;
@property(nonatomic,strong)NSString *nickname;
@property(nonatomic,strong)NSString *openId;
@property(nonatomic,strong)NSString *versionStr;
@property(nonatomic,assign)NewPycUerRemoteAppType appType;


@property(nonatomic,strong)NSString *logname;
@property(nonatomic,strong)NSString *password;
@property(nonatomic,strong)NSString *email;
@property(nonatomic,strong)NSString *phone;
@property(nonatomic,strong)NSString *uid;
@property(nonatomic,copy)NSString *     MoneyFree;
@property(nonatomic,assign)int Random;
@property(nonatomic,assign)int noticeNum;

@property (nonatomic, weak) id<NewPycUserRemoteDelegate> delegate;

-(id)initWithDelegate:(id)delegate;

/**
 *	@brief	实现注册功能
 *
 *	@param 	qqnick      qq昵称
 *	@param 	openId      QQ open Id
 *	@param 	versionStr 	版本号
 *	@param 	appType 	区分android iphone windows phone
 *
 *	@return	no
 */
-(void) registerForQQByNickname:(NSString *)qqnick openId:(NSString *)openId version:(NSString *)versionStr appType:(NewPycUerRemoteAppType) appType;
-(void) registerForQQByNickname:(NSString *)qqnick openId:(NSString *)openId version:(NSString *)versionStr;
-(void) registerForQQByNickname:(NSString *)qqnick openId:(NSString *)openId;


/**
 *	@brief	QQ领会旧钥匙
 *
 *	@param 	openId 	QQ openId
 */
-(void) getKeyForQQByOpenId:(NSString*)openId;


/**
 *	@brief	绑定qq
 *
 *	@param 	qqnick 	qq昵称
 *	@param 	openId 	qq  open id
 *	@param 	logname 登录的钥匙
 */
-(void)bindKeyForQQByNickName:(NSString *)qqnick openId:(NSString *)openId logname:(NSString *)logname;


/**
 *	@brief	通过登录的账号得到用户密码
 *
 *	@param 	logname 	登录的user id
 */
-(void)getPassword:(NSString *)logname;

/**
 *	@brief	通过登录的账号得到logname password email phone uid
 *
 *	@param 	logname 	登录的user id
 */
-(void) getUserInfo:(NSString*)theLogname;
@end
