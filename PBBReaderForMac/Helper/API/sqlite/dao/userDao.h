//
//  userDao.h
//  PBB
//
//  Created by pengyucheng on 13-11-4.
//  Copyright (c) 2013年 pengyucheng. All rights reserved.
//

#import "BaseDao.h"
#import "UserModel.h"
#import "Singleton.h"
@interface userDao : BaseDao
singleton_interface(userDao)

//-(BOOL)insert:(UserModel *)theUser;
-(BOOL)selectByPwd:(NSString *)pwd;

-(BOOL)updateUser:(UserModel *)theUser;

-(BOOL)savePass:(NSString *)pwd;
-(BOOL)changePass:(NSString *)newPwd pwd:(NSString *)oldPwd;
-(BOOL)isPassOK:(NSString *)pwd;
-(NSString *)getPass;
-(BOOL)saveLogname:(NSString *)logname;
-(BOOL)getLogName:(NSString *)logname;
-(NSString *)getLogName;
-(BOOL)saveNickName:(NSString *)nickname;
-(NSString *)getNickName;
-(NSString *)getUid;
-(BOOL)getUid:(NSString *)uid;
-(BOOL)saveUid:(NSString *)uid;
-(BOOL)saveEmail:(NSString *)email;
-(BOOL)getEmail:(NSString *)email;

//手机号
-(BOOL)savePhone:(NSString *)phone;
-(BOOL)getPhone:(NSString *)phone;
-(NSString *)getPhone;
//手机号验证状态
-(BOOL)saveTelStatus:(int)phone;
-(BOOL)getTelStatus;


//邮箱验证状态
-(NSString *)GetEmail;
-(BOOL)saveEmailStatus:(int)status;
-(int)getEmailStatus;


//密码状态
-(BOOL)updatePwdStatus:(int)PwdStatus;
-(BOOL)getPwdStatus;

//更新QQ昵称
-(BOOL)updateQQNickName:(NSString *)QNickName;
-(NSString *)getQQNickName;
//QQ验证状态
-(BOOL)savePhoneStatus:(int)status;
-(int)getPhoneStatus;


-(NSString *)getPicStatus;
-(BOOL)updatePicStatus:(NSString *)status;

//是否为企业账号
-(BOOL)getchildStatus;
-(void)updateChildStatus;

//向表中添加新字段，更新表结构
-(void)updateTable;
@end
