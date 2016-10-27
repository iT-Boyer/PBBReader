//
//  user.h
//  PBB
//
//  Created by pengyucheng on 13-11-4.
//  Copyright (c) 2013年 pengyucheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LKDaoBase.h"

@interface UserModelBase : LKDAOBase

@end

@interface UserModel : LKModelBase

//Uid, Uname, Upwd, Uemail, UemailStatus, Utel,UtelStatus,PwdStatus
@property(strong,nonatomic)NSString *loginName;
@property(strong,nonatomic)NSString *loginPwd;
@property(strong,nonatomic)NSString *userId;
@property(strong,nonatomic)NSString *userEmail;
@property(strong,nonatomic)NSString *emailStatus;
@property(strong,nonatomic)NSString *userTel;
@property(strong,nonatomic)NSString *telStatus;     //qq验证状态
@property(strong,nonatomic)NSString *nickName;
@property(strong,nonatomic)NSString *pwdStatus;
@property(strong,nonatomic)NSString *QQNickName;
@property(strong,nonatomic)NSString *picStatus;   //0:有更新，1:无更新
@property(strong,nonatomic)NSString *UphoneStatus;

+(UserModel *)initWithUserId:(NSString *)newUserId
                LogName:(NSString *)newLogName
               LoginPwd:(NSString *)newLoginPwd
              UserEmail:(NSString *)newUserEmail
                UserTel:(NSString *)newUserTel
            EmailStatus:(NSString *)newEmailStatus
              TelStatus:(NSString *)newTelStatus
               NickName:(NSString *)newNickName
              PwdStatus:(NSString *)newPwdStatus
             QQNickName:(NSString *)newQQNickName
              picStatus:(NSString *)newPicStatus;


@end
