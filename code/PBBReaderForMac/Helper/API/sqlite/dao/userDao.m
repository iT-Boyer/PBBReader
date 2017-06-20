//
//  userDao.m
//  PBB
//
//  Created by pengyucheng on 13-11-4.
//  Copyright (c) 2013年 pengyucheng. All rights reserved.
//

#import "userDao.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "DataFactory.h"
#import "UserModel.h"
@implementation userDao
singleton_implementation(userDao)
- (id)init{
    if(self = [super init])
    {
        //创建user表
        [self createT_User];
    }
    
    return self;
}




-(BOOL)updateUser:(UserModel *)user
{
    if (![db open]) return NO;
    user.userId = [self base64encode:user.userId];
    user.loginName = [self base64encode:user.loginName];
    user.loginPwd = [self base64encode:user.loginPwd];
    user.userEmail = [self base64encode:user.userEmail];
    user.emailStatus = [self base64encode:user.emailStatus];
    user.userTel = [self base64encode:user.userTel];
    user.telStatus = [self base64encode:user.telStatus];
    user.QQNickName = [self base64encode:user.QQNickName];
    user.picStatus = [self base64encode:user.picStatus];
    
    BOOL result = [db executeUpdate:[self SQL:@"UPDATE %@ SET Uid=?, Uname=?, Upwd=?, Uemail=?, UemailStatus=?, Utel=?,UtelStatus=?,QQNickName = ?,picStatus = ?;" inTable:TABLE_USER],
                   user.userId,
                   user.loginName,
                   user.loginPwd,
                   user.userEmail,
                   user.emailStatus,
                   user.userTel,
                   user.telStatus,
                   user.QQNickName,
                   user.picStatus];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db close];
    return result;
}

-(BOOL)selectByPwd:(NSString *)pwd{
    
    if (![db open]) return NO;
    NSString *pwd1 = [self base64encode:[NSString stringWithFormat:@"%@",pwd]];
    FMResultSet *rs = [db executeQuery:[self SQL:@"SELECT * FROM %@ WHERE Upwd = ?" inTable:TABLE_USER],[NSString stringWithFormat:@"%@",pwd1]];
    [rs next];
    NSInteger count = [rs intForColumnIndex:0];
    
    if (count){
        [db close];
        return YES;
    }
    [db close];
    return NO;
    
}

#pragma mark
//保存密码
-(BOOL)savePass:(NSString *)pwd{
    if (![db open]) return NO;
    NSString *pwd1 = [self base64encode:[NSString stringWithFormat:@"%@",pwd]];
    BOOL result = [db executeUpdate:[self SQL:@"update %@ set Upwd = ?" inTable:TABLE_USER],pwd1];
    if ([db hadError]) {
        NSLog(@"Err %d :%@",[db lastErrorCode],[db lastErrorMessage]);
    }
    [db close];
    return result;
}

//修改密码
-(BOOL)changePass:(NSString *)newPwd pwd:(NSString *)oldPwd
{
    if (![db open]) return NO;
    BOOL result=NO;
    if ([self selectByPwd:oldPwd]) {
        NSString *oldPwd1 = [self base64encode:[NSString stringWithFormat:@"%@",oldPwd]];
        result = [db executeUpdate:[self SQL:@"update %@ set Upwd = ?" inTable:TABLE_USER],oldPwd1];
    }
    [db close];
    return result;
}

//验证密码
-(BOOL)isPassOK:(NSString *)pwd{
    return [self selectByPwd:pwd];
}

//保存用户名
-(BOOL)saveLogname:(NSString *)logname{
    if (![db open]) return NO;
    logname = [self base64encode:logname];
    BOOL result = [db executeUpdate:[self SQL:@"update %@ set Uname = ?" inTable:TABLE_USER],logname];
    if ([db hadError]) {
        NSLog(@"Err %d :%@",[db lastErrorCode],[db lastErrorMessage]);
    }
    [db close];
    return  result;
}

//保存昵称
-(BOOL)saveNickName:(NSString *)nickname{
    if (![db open]) return NO;
    nickname = [self base64encode:nickname];
    BOOL result = [db executeUpdate:[self SQL:@"update %@ set Nick = ?" inTable:TABLE_USER],nickname];
    if ([db hadError]) {
        NSLog(@"Err %d :%@",[db lastErrorCode],[db lastErrorMessage]);
    }
    [db close];
    return  result;
}
//验证用户名
-(BOOL)getLogName:(NSString *)logname{
    if (![db open]) return NO;
    logname = [self base64encode:logname];
    FMResultSet *rs = [db executeQuery:[self SQL:@"select Uname from %@ where Uname = ?" inTable:TABLE_USER],logname];
    if ([db hadError]) {
        NSLog(@"%d : %@",[db lastErrorCode],[db lastErrorMessage]);
    }
    while ([rs next]) {
        NSString *name = [self base64decode:[rs stringForColumnIndex:0]];
        //        NSLog(@"用户名：%@",name);
        if (name){
            [db close];
            return YES;
        }
    }
    
    [db close];
    return NO;
}

//获取昵称
-(NSString *)getNickName
{
    if (![db open]) return NO;
    FMResultSet * rs = [db executeQuery:[self SQL:@"select Nick from %@" inTable:TABLE_USER]];
    NSString *nickname = @"";
    while([rs next]){
        nickname = [self base64decode:[rs stringForColumnIndex:0]];
    }
    [db close];
    return nickname;
    
}

//获取Uid
-(NSString *)getUid
{
    if (![db open]) return NO;
    FMResultSet * rs = [db executeQuery:[self SQL:@"select Uid from %@" inTable:TABLE_USER]];
    NSString *Uid = @"";
    while([rs next]){
        Uid = [self base64decode:[rs stringForColumnIndex:0]];
    }
    [db close];
    return Uid;
    
}

-(NSString *)getLogName
{
//    return [SZUser sharedSZUser].userName;
    //
    if (![db open]) return @"";
    
    NSString *logname = @"";
    FMResultSet *rs = [db executeQuery:[self SQL:@"select Uname from %@" inTable:TABLE_USER]];
    if ([db hadError]) {
        NSLog(@"%d : %@",[db lastErrorCode],[db lastErrorMessage]);
    }
    
    while ([rs next]) {
        logname = [self base64decodeLogname:[rs stringForColumnIndex:0]];
        //        NSLog(@"用户名：%@",logname);
        if (logname){
            [db close];
            return logname;
        }
    }
    
    [db close];
    return logname;
}
//保存Uid
-(BOOL)saveUid:(NSString *)uid{
    if (![db open]) return NO;
    uid = [self base64encode:uid];
    BOOL result = [db executeUpdate:[self SQL:@"update %@ set Uid = ?" inTable:TABLE_USER],uid];
    if ([db hadError]) {
        NSLog(@"%d:%@",[db lastErrorCode],[db lastErrorMessage]);
    }
    [db close];
    return result;
}

//验证Uid
-(BOOL)getUid:(NSString *)uid{
    if (![db open]) return NO;
    uid = [self base64encode:uid];
    FMResultSet *rs = [db executeQuery:[self SQL:@"select Uid from %@ where Uid = ?" inTable:TABLE_USER],uid];
    if ([db hadError]) {
        NSLog(@"%d:%@",[db lastErrorCode],[db lastErrorMessage]);
    }
    while ([rs next]) {
        NSString *Uid = [self base64decode:[rs stringForColumnIndex:0]];
        //        NSLog(@"查询Uid得到的记录的id：%@",Uid);
        if (Uid){
            [db close];
            return YES;
        }
        
    }
    [db close];
    return NO;
}
//保存email
-(BOOL)saveEmail:(NSString *)email{
    if (![db open]) return NO;
    NSString *sqlstr = [NSString stringWithFormat:@"update %@ set Uemail = ?",TABLE_USER];
    //    NSLog(@"保存email的sql语句:%@",sqlstr);
    email = [self base64encode:email];
    BOOL result = [db executeUpdate:sqlstr,email];
    if ([db hadError]) {
        NSLog(@"%d: %@",[db lastErrorCode],[db lastErrorMessage]);
    }
    [db close];
    return result;
}

//验证email
-(BOOL)getEmail:(NSString *)email{
    if (![db open]) return NO;
    NSString *sqlstr = [NSString stringWithFormat:@"select * from %@ where Uemail = ?",TABLE_USER];
    //    NSLog(@"查询email的sql语句:%@",sqlstr);
    email = [self base64encode:email];
    FMResultSet *rs = [db executeQuery:sqlstr,email];
    if ([db hadError]) {
        NSLog(@"%d : %@",[db lastErrorCode],[db lastErrorMessage]);
    }
    //    NSLog(@"查询到的字段列数:%d",[rs columnCount]);
    while ([rs next]) {
        NSInteger idd = [rs intForColumnIndex:0];
        //        NSLog(@"存在的email的记录id:%d",idd);
        if (idd){
            [db close];
            return YES;
        }
    }
    [db close];
    return NO;
}

//保存手机号
-(BOOL)savePhone:(NSString *)phone{
    if (![db open]) return NO;
    phone = [self base64encode:phone];
    NSString *sqlstr = [NSString stringWithFormat:@"update %@ set Utel = %@",TABLE_USER,phone];
    BOOL result = [db executeUpdate:sqlstr];
    
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    if (result) {
        //        NSLog(@"手机号成功保存到数据库");
    }
    [db close];
    return result;
}
//验证手机号
-(BOOL)getPhone:(NSString *)phone{
    if (![db open]) return NO;
    // NSString *sqlstr = [NSString stringWithFormat:@"select Utel from %@ where Utel = %@",TABLE_USER,phone];
    //    NSLog(@"验证手机号的sql语句:%@",[NSString stringWithFormat:@"select Utel from %@ where Utel = %@",TABLE_USER,phone]);
    phone = [self base64encode:phone];
    FMResultSet *rs = [db executeQuery:[self SQL:@"select Utel from %@ where Utel = ?" inTable:TABLE_USER],phone];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    //    NSInteger intt = [rs columnCount];
    while ([rs next]) {
        //         NSLog(@"手机号验证根据%@查询到的条数:%@,%d",phone, [rs stringForColumnIndex:0],intt);
        [db close];
        return YES;
    }
    [db close];
    return NO;
}

-(NSString *)getPhone
{
    if (![db open]) return @"";
    FMResultSet *rs = [db executeQuery:[self SQL:@"select Utel from %@" inTable:TABLE_USER]];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    NSString *tel;
    while ([rs next]) {
        //         NSLog(@"手机号验证根据%@查询到的条数:%@,%d",phone, [rs stringForColumnIndex:0],intt);
        tel = [self base64decode:[rs stringForColumn:@"Utel"]];
    }
    [db close];
    return tel;
}
//保存手机号验证状态
-(BOOL)savePhoneStatus:(int)status{
    if (![db open]) return NO;
    NSString *sqlstr = [NSString stringWithFormat:@"update %@ set UtelStatus = %d",TABLE_USER,status];
    BOOL result = [db executeUpdate:sqlstr];
    if ([db hadError]) {
        NSLog(@"Err %d: %@",[db lastErrorCode],[db lastErrorMessage]);
    }
    //    NSLog(@"保存手机号验证状态");
    [db close];
    return result;
}
//查看用户是否需要手机号验证
-(int)getPhoneStatus{
    if (![db open]) return NO;
    int status;
    FMResultSet *rs = [db executeQuery:[self SQL:@"select UtelStatus from %@" inTable:TABLE_USER]];
    if ([db hadError]) {
        NSLog(@"Err %d:%@",[db lastErrorCode],[db lastErrorMessage]);
    }
    while ([rs next]) {
        status = [rs intForColumn:@"UtelStatus"];
        //        NSLog(@"手机验证状态:%d",status);
    }
    [db close];
    return status;
}

-(BOOL)saveTelStatus:(int)phone
{
    if (![db open]) return NO;
    NSString *sqlstr = [NSString stringWithFormat:@"update %@ set UphoneStatus = %d",TABLE_USER,phone];
    BOOL result = [db executeUpdate:sqlstr];
    if ([db hadError]) {
        NSLog(@"Err %d: %@",[db lastErrorCode],[db lastErrorMessage]);
    }
    //    NSLog(@"保存手机号验证状态");
    [db close];
    return result;
}
-(BOOL)getTelStatus
{
    if (![db open]) return NO;
    int status;
    FMResultSet *rs = [db executeQuery:[self SQL:@"select UphoneStatus from %@" inTable:TABLE_USER]];
    if ([db hadError]) {
        NSLog(@"Err %d:%@",[db lastErrorCode],[db lastErrorMessage]);
    }
    while ([rs next]) {
        status = [rs intForColumn:@"UphoneStatus"];
        //        NSLog(@"手机验证状态:%d",status);
    }
    [db close];
    return status;
}

//保存email验证状态
-(BOOL)saveEmailStatus:(int)status{
    if (![db open]) return NO;
    NSString *sqlstr = [NSString stringWithFormat:@"update %@ set UemailStatus = %d",TABLE_USER,status];
    //    NSLog(@"保存email验证状态的sql语句:%@",sqlstr);
    BOOL result = [db executeUpdate:sqlstr];
    if ([db hadError]) {
        NSLog(@"Err %d:%@",[db lastErrorCode],[db lastErrorMessage]);
    }
    //    NSLog(@"保存email验证状态");
    [db close];
    return result;
}
//查看用户是否需要email验证
-(int)getEmailStatus{
    if (![db open]) return NO;
    int status;
    FMResultSet *rs = [db executeQuery:[self SQL:@"select UemailStatus from %@" inTable:TABLE_USER]];
    if ([db hadError]) {
        NSLog(@"Err %d:%@",[db lastErrorCode],[db lastErrorMessage]);
    }
    while ([rs next]) {
        status = [rs intForColumn:@"UemailStatus"];
    }
    //    NSLog(@"获取Email验证状态:%d",status);
    [db close];
    return status;
}


-(NSString *)GetEmail
{
    if (![db open]) return @"";
    NSString *email;
    FMResultSet *rs = [db executeQuery:[self SQL:@"select Uemail from %@" inTable:TABLE_USER]];
    if ([db hadError]) {
        NSLog(@"Err %d:%@",[db lastErrorCode],[db lastErrorMessage]);
    }
    while ([rs next]) {
        email = [self base64decode:[rs stringForColumn:@"Uemail"]];
    }
    //    NSLog(@"获取Email:%@",email);
    [db close];
    return email;
    
}


-(BOOL)updatePwdStatus:(int)PwdStatus
{
    if (![db open]) return NO;
    NSString *sqlstr = [NSString stringWithFormat:@"update %@ set PwdStatus = %d",TABLE_USER,PwdStatus];
    BOOL result = [db executeUpdate:sqlstr];
    if ([db hadError]) {
        NSLog(@"Err %d:%@",[db lastErrorCode],[db lastErrorMessage]);
    }
    [db close];
    return result;
    
}

-(BOOL)updateQQNickName:(NSString *)QNickName
{
    if (![db open]) {
        return NO;
    }
    QNickName = [self base64encode:QNickName];
    NSString *sqlstr = [NSString stringWithFormat:@"update %@ set QQNickName = '%@'",TABLE_USER,QNickName];
    BOOL result = [db executeUpdate:sqlstr];
    if ([db hadError]) {
        NSLog(@"Err %d:%@",[db lastErrorCode],[db lastErrorMessage]);
    }
    [db close];
    return result;
}


-(NSString *)getQQNickName
{
    
    if (![db open]) return @"";
    NSString *qqnick;
    FMResultSet *rs = [db executeQuery:[self SQL:@"select QQNickName from %@" inTable:TABLE_USER]];
    if ([db hadError]) {
        NSLog(@"Err %d:%@",[db lastErrorCode],[db lastErrorMessage]);
    }
    while ([rs next]) {
        qqnick = [self base64decode:[rs stringForColumn:@"QQNickName"]];
    }
    //    NSLog(@"获取QQNickName:%@",qqnick);
    [db close];
    return qqnick;
    
}
-(BOOL)getPwdStatus
{
    if (![db open]) return NO;
    
    BOOL result;
    FMResultSet *rs = [db executeQuery:[self SQL:@"select PwdStatus from %@" inTable:TABLE_USER]];
    if ([db hadError]) {
        NSLog(@"Err %d:%@",[db lastErrorCode],[db lastErrorMessage]);
    }
    while ([rs next]) {
        result = [rs boolForColumn:@"PwdStatus"];
    }
    [db close];
    return result;
}

-(NSString *)getPass
{
    if (![db open]) return @"";
    
    NSString *pwd;
    FMResultSet *rs = [db executeQuery:[self SQL:@"select Upwd from %@" inTable:TABLE_USER]];
    if ([db hadError]) {
        NSLog(@"Err %d:%@",[db lastErrorCode],[db lastErrorMessage]);
    }
    while ([rs next]) {
        pwd = [self base64decode:[rs stringForColumn:@"Upwd"]];
    }
    //    NSLog(@"获取 Upwd:%@",pwd);
    [db close];
    return pwd;
    
}

-(BOOL)updatePicStatus:(NSString *)status
{
    if (![db open]) {
        return NO;
    }
    status = [self base64encode:status];
    NSString *sqlstr = [NSString stringWithFormat:@"update %@ set picStatus = '%@'",TABLE_USER,status];
    BOOL result = [db executeUpdate:sqlstr];
    if ([db hadError]) {
        NSLog(@"Err %d:%@",[db lastErrorCode],[db lastErrorMessage]);
    }
    [db close];
    return result;
}

-(NSString *)getPicStatus
{
    if (![db open]) return NO;
    
    NSString *status;
    FMResultSet *rs = [db executeQuery:[self SQL:@"select picStatus from %@" inTable:TABLE_USER]];
    if ([db hadError]) {
        NSLog(@"Err %d:%@",[db lastErrorCode],[db lastErrorMessage]);
    }
    while ([rs next]) {
        status = [self base64decode:[rs stringForColumn:@"picStatus"]];
    }
    [db close];
    return status;
    
}


-(BOOL)getchildStatus
{
    if (![db open]) return NO;
    
    BOOL childStatus;
    FMResultSet *rs = [db executeQuery:[self SQL:@"select childStatus from %@" inTable:TABLE_USER]];
    if ([db hadError]) {
        NSLog(@"Err %d:%@",[db lastErrorCode],[db lastErrorMessage]);
    }
    while ([rs next]) {
        childStatus = [rs boolForColumn:@"childStatus"];
    }
    [db close];
    return childStatus;
}

-(void)updateChildStatus
{
    if (![db open]) {
        return;
    }
    NSString *sqlstr = [NSString stringWithFormat:@"update %@ set childStatus = %d",TABLE_USER,1];
    BOOL result = [db executeUpdate:sqlstr];
    if ([db hadError]) {
        NSLog(@"Err %d:%@",[db lastErrorCode],[db lastErrorMessage]);
    }
    [db close];
    return;
}

//版本升级
-(void)updateTable
{
    NSUserDefaults *myUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userEncode = [myUserDefaults objectForKey:@"userEncode"];
    
    if (![userEncode isEqualToString:@"encode"]) {
        [self base64encode];  // 读取数据库用户表里的数据，加密后再存入
        [myUserDefaults setObject:@"encode" forKey:@"userEncode"];  // 将发送表设置为加密过
        [myUserDefaults synchronize];
    }
    
    [self intoFieldByName:@"PicStatus" FieldType:@"VARCHAR(4)"];
    [self intoFieldByName:@"QQNickName" FieldType:@"text"];
    [self intoFieldByName:@"PwdStatus" FieldType:@"boolean"];
    [self intoFieldByName:@"UphoneStatus" FieldType:@"boolean"];
    [self intoFieldByName:@"childStatus" FieldType:@"boolean"];
    
}

/**
 * 读取数据库用户表里的数据，加密后再存入
 */
-(void)base64encode
{
    if (![db open]) {
        return ;
    }

    NSString *theSql=[NSString stringWithFormat:@"select * from %@",TABLE_USER];
    FMResultSet *resultSet=[db executeQuery:theSql];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    NSArray *columnNames = @[@"Uid", @"Uname", @"Nick", @"Upwd", @"Uemail", @"Utel", @"QQNickName", @"picStatus"];
    if ([resultSet next]) {
        for (NSString *columeName in columnNames) {
            [self updateEncodeData:columeName inResultSet:resultSet];  // 更新每一条数据
        }
    }
    
    [db close];
    return ;
}

/**
 * 读取数据库用户表里的一条数据，加密后再存入
 */
-(void)updateEncodeData:(NSString *)columnName inResultSet:(FMResultSet *)resultSet
{
    NSString *content = [resultSet stringForColumn:columnName];
    content = [self base64encode:content];
    if (![content isEqualToString:@""]) {
        NSString *theSql=[NSString stringWithFormat:@"update %@ set %@ = '%@'",TABLE_USER, columnName, content];
        [db executeUpdate:theSql];
        if ([db hadError]) {
            NSLog(@"Err %d:%@",[db lastErrorCode],[db lastErrorMessage]);
        }
    }

}

-(BOOL)intoFieldByName:(NSString *)fieldName FieldType:(NSString *)fieldtype
{
    if (![db open]) {
        return NO;
    }
    //获取旧表中的字段名
    NSString *theSql=[NSString stringWithFormat:@"select * from %@",TABLE_USER];
    FMResultSet *resultSet=[db executeQuery:theSql];
    [resultSet setupColumnNames];
    //拼接sql语句中的老字段
    NSEnumerator *columnNames = [resultSet.columnNameToIndexMap keyEnumerator];
    
    NSString *tempColumnName= nil;
    while ((tempColumnName = [columnNames nextObject]))
    {
        if ([[fieldName lowercaseString] isEqualToString:tempColumnName]) {
            //            NSLog(@"TABLE_USER 表，已存在该字段名：%@",tempColumnName);
            return NO;
        }
    }
    NSString *sqlstr = [NSString stringWithFormat:@"alter table %@ add %@ %@",TABLE_USER,fieldName,fieldtype];
    BOOL result = [db executeUpdate:sqlstr];
    if ([db hadError]) {
        NSLog(@"Err %d:%@",[db lastErrorCode],[db lastErrorMessage]);
    }
    [db close];
    return result;
}



#define mark - base64加密解密字符串
/**
 * base64加密字符串调用方法
 */
- (NSString *)base64encode:(NSString *)str
{
    if (str == nil ) {
        str = nil;
    }
    NSData *nsdata = [str dataUsingEncoding:NSUTF8StringEncoding];  // 将明文转成data
    
    // Get NSString from NSData object in Base64
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];// 将data数据进行base64加密
    
    // Print the Base64 encoded string
    NSLog(@"userEncoded: %@ - end ", base64Encoded);
    return base64Encoded;  // 返回加密后的字符串
}

/**
 * base64解码字符串调用方法
 */
- (NSString *)base64decode:(NSString *)str
{
    if (str == nil || [str isEqualToString:@""]) {
        return @"";
    }
    // NSData from the Base64 encoded str
    NSData *nsdataFromBase64String = [[NSData alloc]
                                      initWithBase64EncodedString:str options:0];  // 将密文转成data
    
    // Decoded NSString from the NSData
    NSString *base64Decoded = [[NSString alloc]
                       initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];  // 将data数据转成明文
    
    if (base64Decoded) {
        return base64Decoded;
    } else {
        return str;
    }

    NSLog(@"userDecoded:%@ － end", base64Decoded);
    return  base64Decoded;  // 返回解密后的字符串
}

/**
 * base64解码logname字符串调用方法
 */
- (NSString *)base64decodeLogname:(NSString *)str
{
    if (str == nil || [str isEqualToString:@""]) {
        return @"";
    }
    // NSData from the Base64 encoded str
    NSData *nsdataFromBase64String = [[NSData alloc]
                                      initWithBase64EncodedString:str options:0];  // 将密文转成data
    
    // Decoded NSString from the NSData
    NSString *nsstr = [[NSString alloc]
                       initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];  // 将data数据转成明文
    
    const char *cstr = [nsstr UTF8String];
    NSString *base64Decoded = [NSString stringWithUTF8String:cstr];
    
    NSLog(@"userDecoded:%@ － end", base64Decoded);
    if (base64Decoded) {
        return base64Decoded;  // 返回解密后的字符串
    } else {
        return str;
    }

}


-(BOOL)trunUserTable{
    if (![db open]) return NO;
    NSString *sqlstr = [NSString stringWithFormat:@"delete from %@",TABLE_USER];
    
    BOOL result = [db executeUpdate:sqlstr];
    if ([db hadError]) {
        NSLog(@"Err %d:%@",[db lastErrorCode],[db lastErrorMessage]);
    }
    NSLog(@"清空user成功");
    [db close];
    return result;
}
@end
