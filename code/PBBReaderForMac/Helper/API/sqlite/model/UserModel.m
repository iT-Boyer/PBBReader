//
//  user.m
//  PBB
//
//  Created by pengyucheng on 13-11-4.
//  Copyright (c) 2013年 pengyucheng. All rights reserved.
//

#import "UserModel.h"

@implementation UserModelBase

+(Class)getBindingModelClass
{
    return [UserModel class];//返回文件实体
}

const static NSString* tablename = TABLE_USER;//表名

+(const NSString *)getTableName
{
    return tablename;
}

@end

@implementation UserModel


@synthesize loginName,loginPwd,userEmail,userId,userTel,emailStatus,telStatus,nickName,pwdStatus,QQNickName,picStatus;

-(id)init
{
    self = [super init];
    if (self) {
        //        self.primaryKey = @"Bid";
        self.rowid = super.rowid;
    }
    return self;
}

+(UserModel *)initWithUserId:(NSString *)newUserId LogName:(NSString *)newLogName
                    LoginPwd:(NSString *)newLoginPwd UserEmail:(NSString *)newUserEmail
                     UserTel:(NSString *)newUserTel EmailStatus:(NSString *)newEmailStatus
                   TelStatus:(NSString *)newTelStatus NickName:(NSString *)newNickName
                   PwdStatus:(NSString *)newPwdStatus
                  QQNickName:(NSString *)newQQNickName
                   picStatus:(NSString *)newPicStatus
{
    UserModel *u = [[UserModel alloc] init];
    u.userId = newUserId;
    u.loginName = newLogName;
    u.loginPwd = newLoginPwd;
    u.userEmail = newUserEmail;
    u.userTel = newUserTel;
    u.emailStatus = newEmailStatus;
    u.telStatus = newTelStatus;
    u.nickName = newNickName;
    u.pwdStatus = newPwdStatus;
    u.QQNickName = newQQNickName;
    u.picStatus = newPicStatus;
    return u;
}

@end
