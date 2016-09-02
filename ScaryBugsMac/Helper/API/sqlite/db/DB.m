//
//  Database.m
//  SQLiteSample
//
//  Created by wang xuefeng on 10-12-29.
//  Copyright 2010 www.5yi.com. All rights reserved.
//

#import "DB.h"

@implementation DB


- (BOOL)initDatabase
{
    //获取数据库文件路径
	if(![[NSFileManager defaultManager] fileExistsAtPath:KDataBasePath]){
		db = [FMDatabase databaseWithPath:KDataBasePath];
        //打开或创建数据库
		if ([db open]) {
            //设置缓存状态
			[db setShouldCacheStatements:YES];
		}else{
			NSLog(@"Failed to open database.");
            return NO;
		}
	}
	
	return YES;
}

//删除数据库
-(BOOL)deleteDB{
    
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取数据库文件路径
	success = [fileManager fileExistsAtPath:KDataBasePath];

    if (success) {
//        NSLog(@"成功，删除数据库:%@",writableDBPath);
        [fileManager removeItemAtPath:KDataBasePath error:nil];
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
