//
//  PycUserRemote.h
//  PycSocket
//
//  Created by Fairy on 13-11-18.
//  Copyright (c) 2013年 Fairy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserPublic.h"
#import "PycSocket.h"

#define ERR_OK_NEW 1
#define ERR_NO_ACCOUNT_NEW 2
#define ERR_NOT_VALID_NEW 4
#define ERR_EMAIL_CHECKED_NEW 8
#define ERR_PHONE_CHECKED_NEW 16
#define ERR_QQ_CHECKED_NEW 32
#define ERR_EMAIL_USED_NEW 64
#define ERR_QQ_USED_NEW 128

@class PycUserRemote;
@class PycSocket;

@protocol PycUserRemoteDelegate <NSObject>
@optional
-(void)PycUserRemote:(PycUserRemote *)userobject didFinishGetPassWD:(MAKERECEIVE *)receiveData;
-(void)PycUserRemote: (PycUserRemote *)userobject didFinishRegiste: (MAKERECEIVE *)receiveData;
-(void)PycUserRemote:(PycUserRemote *)userobject didFinishGetNickName:(MAKERECEIVE *)receiveData;
-(void)PycUserRemote: (PycUserRemote *)userobject didFinishChangeNick: (MAKERECEIVE *)receiveData;
-(void)PycUserRemote:(PycUserRemote *)userobject didFinishGetStatus:(MAKERECEIVE *)receiveData;
-(void)PycUserRemote:(PycUserRemote *)userobject didFinishEmailVerify:(MAKERECEIVE *)receiveData;
-(void)PycUserRemote:(PycUserRemote *)userobject didFinishPhoneVerify:(MAKERECEIVE *)receiveData;
-(void)PycUserRemote:(PycUserRemote *)userobject didFinishVerificationVerify:(MAKERECEIVE *)receiveData;
-(void)PycUserRemote:(PycUserRemote *)userobject didFinishChangPass:(MAKERECEIVE *)receiveData;
-(void)PycUserRemote:(PycUserRemote *)userobject didFinishGetUid:(MAKERECEIVE *)receiveData;
-(void)PycUserRemote:(PycUserRemote *)userobject didFinishGetUidWithNickName:(MAKERECEIVE *)receiveData;

@end


@interface PycUserRemote : NSObject<PycSocketDelegate>

@property (nonatomic, weak) id<PycUserRemoteDelegate> delegate;
@property(nonatomic, strong) PycSocket * pycsocket;
@property(nonatomic, strong) PycSocket * pycsocket2;

@property(nonatomic,copy) NSString *    nickName;
@property(nonatomic, copy) NSString *   password;
@property(nonatomic, copy)NSString *    logname;
@property(nonatomic, copy)NSString *    uid;
@property(nonatomic, copy)NSString *    email;
@property(nonatomic,copy)NSString *     phone;
@property(nonatomic,copy)NSString *     verifyNum;
@property(nonatomic,copy)NSString *     lognameOut;
@property(nonatomic,copy)NSString *     versionStr;
@property(nonatomic,copy)NSString *     MoneyFree;
@property(nonatomic,assign)int Random;
@property(nonatomic,assign)int noticeNum;
@property(nonatomic,assign)int childStatus;

//如果返回失败，则表示参数错误或者联网错误
//如果返回成功，则需要实现代理函数，得到最终处理结果

-(BOOL) registerRemote:(NSString *) thePassword nickName: (NSString *) theNickName  version: (NSString *) theVersion;
//-(BOOL) getNickNameFromLogname:(NSString *)logname;
-(BOOL) changeNick:(NSString *) theLogName newNick:(NSString *)theNickName;
-(BOOL) getStatus:(NSString *) logname;
-(BOOL) emailVerify:(NSString *)logname email: (NSString *) email;


/* 根据新需求，为了安全取消手机验证
-(BOOL) phoneVerify_getVerifyNo:(NSString *)logname phoneNum:(NSString *)phone;
-(BOOL) phoneVerifyNo_check:(NSString *)logname verifyNum:(NSString *)verifyNum; 
 */
-(BOOL) changPass:(NSString *) logname password:(NSString *)password;
-(BOOL) getUid:(NSString *)logname password:(NSString *)password;

//在回调函数中  会返回nickname 
-(BOOL) getUidWithNickName:(NSString *)logname password:(NSString *)password;

-(BOOL) findPassWD:(NSString *)logname email: (NSString *) email;

@end
