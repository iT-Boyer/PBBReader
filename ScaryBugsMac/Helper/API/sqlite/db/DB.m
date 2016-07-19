//
//  Database.m
//  SQLiteSample
//
//  Created by wang xuefeng on 10-12-29.
//  Copyright 2010 www.5yi.com. All rights reserved.
//

#import "DB.h"

#define DB_NAME @"PBB.db"


 
@implementation DB


- (BOOL)initDatabase
{
	BOOL success;
	NSError *error;
	NSFileManager *fm = [NSFileManager defaultManager];
    
    //获取数据库文件路径
	NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:DB_NAME];
	
	success = [fm fileExistsAtPath:writableDBPath];
	
	if(!success){
        //返回接收器的捆绑目录的完整路径。
		NSString *defaultDBPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:DB_NAME];
//		NSLog(@"返回接收器的捆绑目录的完整路径：%@",defaultDBPath);
		success = [fm copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
		if(!success){
			NSLog(@"error: %@", [error localizedDescription]);
		}
		success = YES;
	}
	
	if(success){
		db = [FMDatabase databaseWithPath:writableDBPath];
        //打开或创建数据库
		if ([db open]) {
            //设置缓存状态
			[db setShouldCacheStatements:YES];
		}else{
			NSLog(@"Failed to open database.");
			success = NO;
		}
	}
	
	return success;
}

//删除数据库
-(BOOL)deleteDB{
    
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取数据库文件路径
	NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:DB_NAME];
	
	success = [fileManager fileExistsAtPath:writableDBPath];

    if (success) {
//        NSLog(@"成功，删除数据库:%@",writableDBPath);
        [fileManager removeItemAtPath:writableDBPath error:nil];
        return YES;
    }
//    NSLog(@"删除失败，数据库不存在%@",writableDBPath);
    return NO;
    
}

- (void)closeDatabase
{
	[db close];
}


- (FMDatabase *)getDatabase
{
	if ([self initDatabase]){
		return db;
	}
	
	return NULL;
}


- (void)dealloc
{
	[self closeDatabase];

}

@end
