//
//  ReceiveFileDao.m
//  PBB
//
//  Created by pengyucheng on 13-11-25.
//  Copyright (c) 2013年 pyc.com.cn. All rights reserved.
//

#import "ReceiveFileDao.h"
#import "ReceiveFileManager.h"
@implementation ReceiveFileDao

singleton_implementation(ReceiveFileDao)

-(id)init
{
    if (self = [super init]) {
        [[ReceiveFileManager sharedReceiveFileManager]createTable];
    }
    return self;
}

-(BOOL)saveReceiveFile:(OutFile *)receiveFile
{
    return [[ReceiveFileManager sharedReceiveFileManager]saveReceiveFile:receiveFile];
}

-(BOOL)deleteReceiveFile:(NSInteger)fileId LogName:(NSString *)logname
{
    return [[ReceiveFileManager sharedReceiveFileManager]deleteReceiveFile:fileId LogName:logname];
}

-(BOOL)updateReceiveFile:(OutFile *)receiveFile
{
    return [[ReceiveFileManager sharedReceiveFileManager]updateReceiveFile:receiveFile];
}

-(BOOL)updateReceiveFileByLogName:(NSString *)logName
{
    return [[ReceiveFileManager sharedReceiveFileManager] updateReceiveFileByLogName:logName];

}

-(NSInteger)countOfReceiveFile:(NSString *)logName
{
    return [[ReceiveFileManager sharedReceiveFileManager] countOfReceiveFile:logName];
}

-(NSMutableArray *)selectReceiveFileAll:(NSString *)logName
{
    return [[ReceiveFileManager sharedReceiveFileManager] selectReceiveFileAll:logName];
}

-(BOOL)updateReceiveFileFirstOpenTime:(NSString *)openTime FileId :(NSInteger)fileId
{
   return  [[ReceiveFileManager sharedReceiveFileManager] updateReceiveFileFirstOpenTime:openTime FileId:fileId];
}

-(BOOL)updateReceiveFileTimeType:(NSInteger)timeType FileId:(NSInteger)fileId
{
    return [[ReceiveFileManager sharedReceiveFileManager] updateReceiveFileTimeType:timeType FileId:fileId];
}

-(BOOL)updateReceiveFileIsChangeTime:(NSInteger)fileId isChangeTime:(NSInteger)isChangeTime{
    return [[ReceiveFileManager sharedReceiveFileManager] updateReceiveFileIsChangeTime:fileId isChangeTime:isChangeTime];
}

-(BOOL)updateReceiveFileLastTime:(NSInteger)fileId lastSeeTime:(NSString *)lastSeeTime{
    return [[ReceiveFileManager sharedReceiveFileManager] updateReceiveFileLastTime:fileId lastSeeTime:lastSeeTime];
}

-(BOOL)updateReceiveFileByFileId:(NSInteger)fileId remainDay:(NSInteger)remainday remainYear:(NSInteger)remainyear
{
    return [[ReceiveFileManager sharedReceiveFileManager] updateReceiveFileByFileId:fileId remainDay:remainday remainYear:remainyear];
}
-(BOOL)updateReceiveFileApplyOpen:(NSInteger)ApplyOpen FileId:(NSInteger)fileId
{
    return [[ReceiveFileManager sharedReceiveFileManager] updateReceiveFileApplyOpen:ApplyOpen FileId:fileId];
}
-(BOOL)tableExist
{
    return [[ReceiveFileManager sharedReceiveFileManager] tableExist];
}

-(NSMutableArray *)selectReceiveFileByPage:(NSString *)logName Count:(NSInteger)limitCount FromIndex:(NSInteger)fromIndex
{
        return [[ReceiveFileManager sharedReceiveFileManager] selectReceiveFileByPage:logName Count:limitCount FromIndex:fromIndex];
}

-(OutFile *)fetchReceiveFileByFileId:(NSInteger)receiveFileId LogName:(NSString *)logname
{
    return [[ReceiveFileManager sharedReceiveFileManager]fetchReceiveFileByFileId:receiveFileId LogName:logname];
}

-(NSString *)selectReceiveFileURLByFileId:(NSInteger)fileId LogName:(NSString*)logname
{
    return [[ReceiveFileManager sharedReceiveFileManager] selectReceiveFileURLByFileId:fileId LogName:logname];
}

-(NSMutableArray *)refreshReceiveFileAll:(NSString *)logName
{
    return [[ReceiveFileManager sharedReceiveFileManager] refreshReceiveFileAll:logName];
}

-(NSMutableArray *)refreshReceiveFileByPage:(NSString *)logName  Count:(NSInteger)limitCount FromIndex:(NSInteger)fromIndex
{
    return [[ReceiveFileManager sharedReceiveFileManager] refreshReceiveFileByPage:logName Count:limitCount FromIndex:fromIndex];
}

-(BOOL)updateRefreshReceiveFile:(OutFile *)receiveFile
{
    return [[ReceiveFileManager sharedReceiveFileManager] updateRefreshReceiveFile:receiveFile];
}
-(OutFile *)fetchReceiveFileCellByFileId:(NSInteger)receiveFileId LogName:(NSString *)logname
{
    return [[ReceiveFileManager sharedReceiveFileManager] fetchReceiveFileCellByFileId:receiveFileId LogName:logname];
}

-(BOOL)updateReceiveFileToAddReadNumByFileId:(NSInteger)receiveFileId
{
    return [[ReceiveFileManager sharedReceiveFileManager] updateReceiveFileToAddReadNumByFileId:receiveFileId];
}
-(BOOL)updateReceiveFileToRebornedByFileId:(NSInteger)receiveFileId  Status:(NSInteger)status
{
    return [[ReceiveFileManager sharedReceiveFileManager]updateReceiveFileToRebornedByFileId:receiveFileId  Status:status];
}

-(BOOL)updateReceiveFileForVersionPBB
{
    return [[ReceiveFileManager sharedReceiveFileManager] updateReceiveFileForVersionPBB];
}

-(void)updateTable
{
    [[ReceiveFileManager sharedReceiveFileManager] updateTable];
}

-(NSString *)selectReceiveFileFistOpenTimeByFileId:(NSInteger)fileId
{
    return [[ReceiveFileManager sharedReceiveFileManager]selectReceiveFileFistOpenTimeByFileId:fileId];
    
}

-(BOOL)findFileById:(NSInteger )fileId forLogName:(NSString *)logName
{
    return [[ReceiveFileManager sharedReceiveFileManager] isExistByfileId:fileId forLogName:logName];
}

-(BOOL)updateIsEye:(NSInteger)ReceiveFileId isEye:(BOOL)isEye
{
    return [[ReceiveFileManager sharedReceiveFileManager] updateIsEye:ReceiveFileId isEye:isEye];
}
-(BOOL)fetchIsEye:(NSInteger)ReceiveFileId
{
    return [[ReceiveFileManager sharedReceiveFileManager] fetchIsEye:ReceiveFileId];
}

-(BOOL)updateReceiveUid:(NSInteger)uid fileId:(NSInteger)fileId
{
    return [[ReceiveFileManager sharedReceiveFileManager]updateReceiveUid:uid fileId:fileId];
}
-(BOOL)updateReceiveSeriesID:(NSInteger)SeriesID fileId:(NSInteger)fileId
{
    return [[ReceiveFileManager sharedReceiveFileManager]updateReceiveSeriesID:SeriesID fileId:fileId];
}
-(NSInteger)fetchUid:(NSInteger)ReceiveFileId
{
    return [[ReceiveFileManager sharedReceiveFileManager] fetchUid:ReceiveFileId];
}
-(NSInteger)fetchSeriesID:(NSInteger)ReceiveFileId
{
    return [[ReceiveFileManager sharedReceiveFileManager] fetchSeriesID:ReceiveFileId];
}
-(NSInteger)fetchCountOfUid:(NSInteger)ReceiveUid
{
    return [[ReceiveFileManager sharedReceiveFileManager] fetchCountOfUid:ReceiveUid];
}

-(NSMutableArray *)selectReceiveSeriesFileAll:(NSInteger)Series
{
    return [[ReceiveFileManager sharedReceiveFileManager] selectReceiveSeriesFileAll:Series];
}

/**
 *  更新旧版离线文件时，使用
 *
 *
 *  @return 更新是否成功
 */
-(BOOL)updateByFileIdReceiveFile:(OutFile *)receiveFile
{
    return [[ReceiveFileManager sharedReceiveFileManager] updateByFileIdReceiveFile:receiveFile];
}
-(NSData *)fetchEncodeKey:(NSInteger)fileId
{
    return [[ReceiveFileManager sharedReceiveFileManager] fetchEncodeKey:fileId];
}

-(NSInteger)fetchCountOfSeriesID:(NSInteger)seriesID
{
    return [[ReceiveFileManager sharedReceiveFileManager] fetchCountOfSeriesID:seriesID];
}
-(NSInteger)verifyOutFileCurrent:(NSInteger)receiveFileId{
    return [[ReceiveFileManager sharedReceiveFileManager] isCanOpenFileId:receiveFileId];
}
@end
