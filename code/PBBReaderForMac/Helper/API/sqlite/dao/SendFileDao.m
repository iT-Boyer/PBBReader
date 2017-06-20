//
//  FileDao.m
//  PBB
//
//  Created by pengyucheng on 13-11-15.
//  Copyright (c) 2013年 pyc.com.cn. All rights reserved.
//

#import "SendFileDao.h"
#import "sendfileManager.h"
@implementation SendFileDao

singleton_implementation(SendFileDao)

-(id)init{
    
    if (self = [super init]) {
        //加载send表
        [[SendFileManager sharedSendFileManager]createTable];
    }
    return self;
}

-(NSString *)selectSendFileURLByFileId:(NSInteger)fileId LogName:(NSString *)logname
{
    return [[SendFileManager sharedSendFileManager] selectSendFileURLByFileId:fileId LogName:logname];
}

-(BOOL)saveSendFile:(OutFile *)sendFile{
    
    return [[SendFileManager sharedSendFileManager]saveSendFile:sendFile];
}

-(NSInteger)countOfSendFile:(NSString *)logName
{
    return [[SendFileManager sharedSendFileManager] countOfSendFile:logName];

}

-(BOOL)deleteSendFile:(NSInteger)sendFileId Logname:(NSString *)logname{

    return [[SendFileManager sharedSendFileManager]deleteSendFile:sendFileId Logname:(NSString *)logname];
}

-(BOOL)updateSendFile:(OutFile *)sendFile{

    return [[SendFileManager sharedSendFileManager]updateSendFile:sendFile];
}

-(BOOL)updateRefreshSendFile:(OutFile *)sendFile
{
    return [[SendFileManager sharedSendFileManager] updateRefreshSendFile:sendFile];
}
-(OutFile *)fetchSendFileByFileId:(NSInteger)sendFileId LogName:(NSString *)logname
{
    return [[SendFileManager sharedSendFileManager] fetchSendFileByFileId:sendFileId LogName:logname];

}

-(NSMutableArray *)selectSendFileAll:(NSString *)logName
{
    return [[SendFileManager sharedSendFileManager] selectSendFileAll:logName];
}

-(BOOL)tableExist
{
    return [[SendFileManager sharedSendFileManager] tableExist];
}

//按账户分页查询
-(NSMutableArray *)selectSendFileByPage:(NSString *)logName Count:(NSInteger)limitCount FromIndex:(NSInteger)fromIndex
{
    return [[SendFileManager sharedSendFileManager] selectSendFileByPage:logName Count:limitCount FromIndex:fromIndex];
}

-(BOOL)findFileById:(NSInteger )fileId forLogName:(NSString *)logName
{
    return [[SendFileManager sharedSendFileManager] isExistByfileId:fileId forLogName:logName];
}

-(NSMutableArray *)refreshSendFileAll:(NSString *)logName
{
    return [[SendFileManager sharedSendFileManager] refreshSendFileAll:logName];
}

-(NSMutableArray *)refreshSendFileByPage:(NSString *)logName  Count:(NSInteger)limitCount FromIndex:(NSInteger)fromIndex
{
    return [[SendFileManager sharedSendFileManager] refreshSendFileByPage:logName Count:limitCount FromIndex:fromIndex];
}

//修改forbid
-(BOOL)changeSendFileForbid:(NSString *)logname FileId:(NSInteger)sendFileId Forbid:(NSInteger)forbid
{
    return [[SendFileManager sharedSendFileManager] changeSendFileForbid:logname FileId:sendFileId Forbid:forbid];
}

-(OutFile *)fetchSendFileCellByFileId:(NSInteger)sendFileId LogName:(NSString *)logname
{
    return [[SendFileManager sharedSendFileManager]fetchSendFileCellByFileId:sendFileId LogName:logname];
}

-(BOOL)updateSendFileForChangeInfo:(OutFile *)sendFile
{
    return [[SendFileManager sharedSendFileManager] updateSendFileForChangeInfo:sendFile];
}

-(BOOL)updateSendFileByLogName:(NSString *)logName
{
    return [[SendFileManager sharedSendFileManager] updateSendFileByLogName:logName];
}

-(BOOL)updateSendFileForVersionPBB
{
    return  [[SendFileManager sharedSendFileManager] updateSendFileForVersionPBB];
}

-(void)updateTable
{
    [[SendFileManager sharedSendFileManager] updateTable];
}


-(BOOL)updateIsEye:(NSInteger)sendFileId isEye:(BOOL)isEye
{
    return [[SendFileManager sharedSendFileManager]updateIsEye:sendFileId isEye:isEye];
}
-(BOOL)fetchIsEye:(NSInteger)sendFileId
{
    return [[SendFileManager sharedSendFileManager]fetchIsEye:sendFileId];
}
@end
