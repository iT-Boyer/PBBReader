//
//  BaseDao.m
//  SQLiteSample
//
//  Created by wang xuefeng on 10-12-29.
//  Copyright 2010 www.5yi.com. All rights reserved.
//

#import "DB.h"
#import "BaseDao.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"


@implementation BaseDao

@synthesize db;

- (id)init{
    if(self = [super init])
    {
        db = [[DB alloc] getDatabase];
    }
    
    return self;
}

-(NSString *)SQL:(NSString *)sql inTable:(NSString *)table {
    return [NSString stringWithFormat:sql, table];
}

//判断指定的表名是否存在／／等同于[db tableExists:TABLE_USER]；
- (BOOL) isTableOK:(NSString *)tableName
{
    
    FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
    while ([rs next])
    {
        // just print out what we've got in a number of formats.
        NSInteger count = [rs intForColumn:@"count"];
        //        NSLog(@"isTableOK %d", count);
        
        if (0 == count)
        {
            //            NSLog(@"数据表，不存在，需新建");
            return NO;
        }
        else
        {
            //            NSLog(@"数据表，已存在");
            return YES;
        }
    }
    
    return NO;
}
//建立table

-(BOOL)createT_User
{
    [db open];
    if (![self isTableOK:TABLE_USER]) {
        
        BOOL result =  [db executeUpdate:[self SQL:@"CREATE TABLE IF NOT EXISTS %@ (Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,Uid VARCHAR(4) NOT NULL,Uname VARCHAR(50) NOT NULL,Nick VARCHAR(50), Upwd VARCHAR(20) NOT NULL, Uemail VARCHAR(50), UemailStatus integer,Utel VARCHAR(20),UtelStatus integer,PwdStatus integer,QQNickName text,picStatus VARCHAR(4),UphoneStatus integer,childStatus integer)" inTable:TABLE_USER]];
        //        NSLog(@"%@ 表创建成功！",TABLE_USER);
        //新建表后，添加一条用户空记录
//        NSString *str = [self base64encode:@""];
//        NSString *str1 = [self base64encode:@"1"];
//        BOOL result = [db executeUpdate:[self SQL:@"INSERT INTO %@ (Uid, Uname, Nick, Upwd, Uemail, UemailStatus, Utel,UtelStatus,PwdStatus,QQNickName,picStatus,UphoneStatus,childStatus) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)" inTable:TABLE_USER],str,str,str,str,str,0,str,0,0,str,str1,0,0];
        if ([db hadError]) {
            NSLog(@"Err %d :%@",[db lastErrorCode],[db lastErrorMessage]);
        }
        if (result) {
            //            NSLog(@"用户空记录信息插入成功");

                    NSUserDefaults *myUserDefaults = [NSUserDefaults standardUserDefaults];
                    [myUserDefaults setObject:@"encode" forKey:@"userEncode"];  // 将用户表设置为加密过
                    [myUserDefaults setObject:@"encode" forKey:@"receiveEncode"];  // 将已接收表设置为加密过
                    [myUserDefaults setObject:@"encode" forKey:@"sendEncode"];  // 将发送表设置为加密过
                    [myUserDefaults synchronize];
                    

        }
        [db close];
        return YES;
    }
    //    NSLog(@"%@ 表已经存在！",TABLE_USER);
    [db close];
    return NO;
}


//删除表
-(BOOL)deleteByTableName:(NSString *)tableName
{
    [db open];
    if ([db tableExists:tableName]) {
        [db executeUpdate:@"drop table ?",tableName];
        //        NSLog(@"删除 %@ 表成功！再新建",tableName);
        [db close];
        return YES;
    }else{
        //         NSLog(@"想删除的 %@ 表不存在！",tableName);
    }
    [db close];
    return NO;
}

- (void)dealloc {
    
}



#define mark - base64加密解密字符串
/**
 * base64加密字符串调用方法
 */
- (NSString *)base64encode:(NSString *)str
{
    if (str == nil ) {
        str = @"";
    }
    NSData *nsdata = [str dataUsingEncoding:NSUTF8StringEncoding];  // 将明文转成data
    
    // Get NSString from NSData object in Base64
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];// 将data数据进行base64加密
    
    // Print the Base64 encoded string
    NSLog(@"Encoded: %@", base64Encoded);
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
    NSLog(@"Decoded: %@", base64Decoded);
    return  base64Decoded;  // 返回解密后的字符串
}
@end