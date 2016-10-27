//
//  DataFactory.h
//
//
//  Created by mac  on 12-12-7.
//  Copyright (c) 2012年 sky. All rights reserved.
//  这个我是在原来的几个项目当做一个数据库处理工厂

#import <Foundation/Foundation.h>
#import "SandboxFile.h"
#import "FMDatabaseQueue.h"

//#define GetDataBasePath [SandboxFile GetPathForDocuments:@"PBB.db" inDir:@"DataBase"]

//#define GetDataBasePath [SandboxFile GetPathForDocuments:@"PBB.db"]
@interface DataFactory : NSObject
@property(retain,nonatomic)id classValues;

/**
 * @breif 数据库表名的枚举值
 *        这个是枚举是区别不同的实体;
 */
typedef enum
{
    secret,
    user,
    VerificationCode,
    Article,
    Series,
}FSO;


+(DataFactory *)shardDataFactory;
//是否存在数据库
-(BOOL)IsDataBase;
//创建数据库
-(void)CreateDataBase;
//创建表
-(void)CreateTable;
//添加数据
-(void)insertToDB:(id)Model Classtype:(FSO)type;
//应用升级版本时，更新数据库
-(void)updateTable:(id)Model Classtype:(FSO)type;
//修改数据
-(void)updateToDB:(id)Model Classtype:(FSO)type;
//修改某个字段数据
-(void)updateToDBWithWhere:(NSString *)where columeName:(NSString *)columeName columeValue:(id)columeValue Classtype:(FSO)type;
//获取某个字段值
-(void)fetchToDBWithWhere:(NSString *)where columeName:(NSString *)columeName Classtype:(FSO)type callback:(void(^)(NSString *))result;
//根据rowid/主键 删除单条数据
-(void)deleteToDB:(id)Model Classtype:(FSO)type;
//删除表的数据
-(void)clearTableData:(FSO)type;
//根据条件删除数据
-(void)deleteWhereData:(NSDictionary *)Model Classtype:(FSO)type;
//删除数据
-(void)deleteToDBWithWhere:(NSString *)where Classtype:(FSO)type;
//查数据 where语句是NSString
-(void)searchWhere:(NSString*)where orderBy:(NSString *)columeName count:(int)count Classtype:(FSO)type callback:(void(^)(NSArray*))result;
//查找 where语句是NSDictionary
-(void)searchWhere:(NSDictionary *)where orderBy:(NSString *)columeName offset:(int)offset count:(int)count Classtype:(FSO)type callback:(void(^)(NSArray *))result;

//查询数据表的记录数
-(void)searchTableNum:(NSString *)logname Classtype:(FSO)type callback:(void(^)(int))result;
-(void)isExistsModel:(id)Model  Classtype:(FSO)type callback:(void(^)(BOOL))block;
-(void)isExistsWithWhere:(NSString*)where Classtype:(FSO)type callback:(void (^)(BOOL))block;
//查询所有，遵守orderBy,可以是nil,或空字符串，此时按照默认排序
-(void)searchAllOrderBy:(NSString *)orderBy Classtype:(FSO)type callback:(void(^)(NSArray*))callback;
@end
