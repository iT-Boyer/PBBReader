//
//  DataFactory.m
//  
//
//  Created by mac  on 12-12-7.
//  Copyright (c) 2012年 sky. All rights reserved.
//

#import "DataFactory.h"


#import "SecretModel.h"
#import "UserModel.h"
#import "VerificationCodeModel.h"
#import "ArticleModel.h"
#import "SeriesModel.h"

static FMDatabaseQueue* sqlqueue;
@implementation DataFactory
@synthesize classValues;

+(DataFactory *)shardDataFactory
{
    static id ShardInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ShardInstance=[[self alloc]init];
        if ([ShardInstance IsDataBase]) {
            [ShardInstance CreateDataBase];
        }
    });
    return ShardInstance;
}
-(BOOL)IsDataBase
{
    BOOL Value=NO;
    if (![SandboxFile IsFileExists:KDataBasePath])
    {
        Value=YES;
    }
    return Value;
}
-(void)CreateDataBase
{
    sqlqueue=[[FMDatabaseQueue alloc]initWithPath:KDataBasePath];
}
-(void)CreateTable
{
//    [[TestModelBase alloc]initWithDBQueue:queue];
//    [[SecretModelBase alloc]initWithDBQueue:queue];
}

#pragma mark 添加数据库
-(id)Factory:(FSO)type
{
    id result;
    sqlqueue=[[FMDatabaseQueue alloc]initWithPath:KDataBasePath];
    switch (type)
    {
        case secret:
            result = [[SecretModelBase alloc] initWithDBQueue:sqlqueue];
            break;
        case user:
            result = [[UserModelBase alloc] initWithDBQueue:sqlqueue];
            break;
        case VerificationCode:
            result = [[VerificationCodeModelBase alloc] initWithDBQueue:sqlqueue];
            break;
        case Article:
            result = [[ArticleModelBase alloc] initWithDBQueue:sqlqueue];
            break;
        case Series:
            result = [[SeriesModelBase alloc] initWithDBQueue:sqlqueue];
            break;
        default:
            break;
    }
    return result;
}
-(void)insertToDB:(id)Model Classtype:(FSO)type
{
     NSLog(@"%@",KDataBasePath);
    self.classValues=[self Factory:type];
    [classValues insertToDB:Model callback:^(BOOL Values)
     {
         NSLog(@"添加%d",Values);
     }];
}

-(void)updateTable:(id)Model Classtype:(FSO)type
{
    NSLog(@"%@",KDataBasePath);
    self.classValues=[self Factory:type];
    [classValues updateTable:Model callback:^(BOOL Values)
     {
         NSLog(@"更新数据库结构%d",Values);
     }];

}

-(void)updateToDB:(id)Model Classtype:(FSO)type
{
    self.classValues=[self Factory:type];
    [classValues updateToDB:Model callback:^(BOOL Values)
     {
         NSLog(@"修改%d",Values);
     }];
}

-(void)updateToDBWithWhere:(NSString *)where columeName:(NSString *)columeName columeValue:(id)columeValue Classtype:(FSO)type
{
    self.classValues=[self Factory:type];
    [classValues updateToDBWithWhere:where columeName:columeName columeValue:columeValue callback:^(BOOL Values) {
        NSLog(@"修改单个字段:%d",Values);
    }];
}

-(void)fetchToDBWithWhere:(NSString *)where columeName:(NSString *)columeName Classtype:(FSO)type callback:(void (^)(NSString *))result
{
    self.classValues=[self Factory:type];
    [classValues fetchToDBWithWhere:where columeName:columeName callback:^(NSString *columevalue) {
        result(columevalue);
    }];

}
-(void)deleteToDB:(id)Model Classtype:(FSO)type
{
    self.classValues=[self Factory:type];
    [classValues deleteToDB:Model callback:^(BOOL Values)
     {
         NSLog(@"删除%d",Values);
     }];
}

-(void)deleteToDBWithWhere:(NSString *)where Classtype:(FSO)type
{
    self.classValues = [self Factory:type];
    [classValues deleteToDBWithWhere:where callback:^(BOOL Values) {
        NSLog(@"删除%d",Values);
    }];

}
-(void)clearTableData:(FSO)type
{
    self.classValues=[self Factory:type];
    [classValues clearTableData];
    NSLog(@"删除全部数据");
}
-(void)deleteWhereData:(NSDictionary *)Model Classtype:(FSO)type
{
    self.classValues=[self Factory:type];
    [classValues deleteToDBWithWhereDic:Model callback:^(BOOL Values)
     {
         NSLog(@"删除成功");
     }];
}
-(void)searchWhere:(NSDictionary *)where orderBy:(NSString *)columeName offset:(int)offset count:(int)count Classtype:(FSO)type callback:(void(^)(NSArray *))result
{
    self.classValues=[self Factory:type];
    [classValues searchWhereDic:where orderBy:columeName offset:offset count:count callback:^(NSArray *array)
     {
         result(array);
     }];
}

-(void)searchTableNum:(NSString *)logname Classtype:(FSO)type callback:(void(^)(int))result
{
    self.classValues = [self Factory:type];
    [classValues searchTableNum:logname callback:^(int num) {
        result(num);
    }];
}
-(void)isExistsModel:(id)Model  Classtype:(FSO)type callback:(void(^)(BOOL))block
{
    self.classValues = [self Factory:type];
    [classValues isExistsModel:Model callback:^(BOOL exist) {
        block(exist);
    }];
}
-(void)isExistsWithWhere:(NSString*)where Classtype:(FSO)type callback:(void (^)(BOOL))block
{
    self.classValues = [self Factory:type];
    [classValues isExistsWithWhere:where callback:^(BOOL exist) {
        block(exist);
    }];
}
//count == 0 是查询所有
-(void)searchWhere:(NSString *)where orderBy:(NSString *)makeTime count:(int)count Classtype:(FSO)type callback:(void (^)(NSArray *))result
{
    self.classValues = [self Factory:type];
    
    [classValues searchWhere:where orderBy:makeTime offset:0 count:count callback:^(NSArray *array) {
        result(array);
    }];
}


-(void)searchAllOrderBy:(NSString *)orderBy Classtype:(FSO)type callback:(void(^)(NSArray*))callback
{
    self.classValues=[self Factory:type];
    [classValues searchAllOrderBy:orderBy callback:^(NSArray *array) {
        callback(array);
    }];
}

-(void)dealloc
{
//    [classValues release];
//    NSLog(@"DataFactory dealloc");
//    [super dealloc];
}
@end
