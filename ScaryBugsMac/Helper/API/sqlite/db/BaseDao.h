//
//  BaseDao.h
//  SQLiteSample
//
//  Created by wang xuefeng on 10-12-29.
//  Copyright 2010 www.5yi.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@class FMDatabase;


@interface BaseDao : NSObject
{
	FMDatabase *db;
}


@property (nonatomic, strong) FMDatabase *db;

-(NSString *)SQL:(NSString *)sql inTable:(NSString *)table;

-(BOOL)createT_User;
-(BOOL)deleteByTableName:(NSString *)tableName;

@end