//
//  SecretDao.m
//  PBB
//
//  Created by pengyucheng on 14-3-27.
//  Copyright (c) 2014年 pyc.com.cn. All rights reserved.
//

#import "SecretDao.h"
#import "DataFactory.h"
@implementation SecretDao

singleton_implementation(SecretDao)

-(void)addSecretFile:(SecretModel *)secret1
{
    [[DataFactory shardDataFactory] insertToDB:secret1 Classtype:secret];
}

-(NSArray *)secretFileList:(NSString *)logName
{
    __block NSArray *fileList = [[NSArray alloc] init];
    NSString *sqlwhere = [NSString stringWithFormat:@"logName = '%@'",logName];
    
    [[DataFactory shardDataFactory]searchWhere:sqlwhere orderBy:@"makeTime DESC" count:0 Classtype:secret callback:^(NSArray *array) {
       fileList = array;
    }];
    return fileList;
}

-(void)deleteSecretFileId:(NSString *)fileId
{
    NSString *sqlwhere = [NSString stringWithFormat:@"rowid = %d",[fileId intValue]];
    
    [[DataFactory shardDataFactory] deleteToDBWithWhere:sqlwhere Classtype:secret];

}


-(void)deleteFileByModel:(SecretModel *)secret1
{
    [[DataFactory shardDataFactory] deleteToDB:secret1 Classtype:secret];

}


-(NSArray *)secretFileTypeListForImg
{
    __block NSArray *fileList = [[NSArray alloc] init];
    NSString *sqlwhere = [NSString stringWithFormat:@"fileType in ('jpg','png','bmp','gif','jpeg','jpe')"];
    
    [[DataFactory shardDataFactory]searchWhere:sqlwhere orderBy:@"makeTime DESC" count:0 Classtype:secret callback:^(NSArray *array) {
        fileList = array;
    }];
    return fileList;
}


-(NSArray *)secretFileTypeListForMov
{
    __block NSArray *fileList = [[NSArray alloc] init];
//    rmvb+mkv+mpeg+mp4+mov+avi+3gp+flv+wmv+rm+mpg+vob+wav+dat
    NSString *sqlwhere = [NSString stringWithFormat:@"fileType in ('mov','mp4','rmvb','mkv','mpeg','avi','3gp','flv','wmv','rm','mpg','vob','wav','dat')"];
    
    [[DataFactory shardDataFactory]searchWhere:sqlwhere orderBy:@"makeTime DESC" count:0 Classtype:secret callback:^(NSArray *array) {
        fileList = array;
    }];
    return fileList;

}


-(int)searchSecretNum:(NSString *)logname
{
    __block int result;
    [[DataFactory shardDataFactory] searchTableNum:logname Classtype:secret callback:^(int num) {
        result = num;
        
    }];
    return result;
}

@end
