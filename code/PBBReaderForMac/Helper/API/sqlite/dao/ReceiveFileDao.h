//
//  ReceiveFileDao.h
//  PBB
//
//  Created by pengyucheng on 13-11-25.
//  Copyright (c) 2013年 pyc.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OutFile.h"
#import "Singleton.h"
@interface ReceiveFileDao : NSObject

singleton_interface(ReceiveFileDao)

-(BOOL)saveReceiveFile:(OutFile *)receiveFile;

-(BOOL)updateReceiveFile:(OutFile *)receiveFile;

-(BOOL)updateReceiveFileByLogName:(NSString *)logName;

-(BOOL)deleteReceiveFile:(NSInteger)fileId LogName:(NSString *)logname;

-(BOOL)tableExist;

-(OutFile *)fetchReceiveFileByFileId:(NSInteger)receiveFileId LogName:(NSString *)logname;

-(OutFile *)fetchReceiveFileCellByFileId:(NSInteger)receiveFileId LogName:(NSString *)logname;

-(NSInteger)countOfReceiveFile:(NSString *)logName;

//多个查询
-(NSMutableArray *)selectReceiveFileAll:(NSString *)logName;
-(NSMutableArray *)selectReceiveSeriesFileAll:(NSInteger)Series;

//分页
-(NSMutableArray *)selectReceiveFileByPage:(NSString *)logName Count:(NSInteger)limitCount FromIndex:(NSInteger)fromIndex;

-(NSString *)selectReceiveFileURLByFileId:(NSInteger)fileId LogName:(NSString*)logname;

-(NSMutableArray *)refreshReceiveFileAll:(NSString *)logName;

-(NSMutableArray *)refreshReceiveFileByPage:(NSString *)logName  Count:(NSInteger)limitCount FromIndex:(NSInteger)fromIndex;

-(BOOL)updateRefreshReceiveFile:(OutFile *)receiveFile;

-(BOOL)updateReceiveFileToAddReadNumByFileId:(NSInteger)receiveFileId;
-(BOOL)updateReceiveFileToRebornedByFileId:(NSInteger)receiveFileId  Status:(NSInteger)status;
-(BOOL)updateReceiveFileByFileId:(NSInteger)fileId remainDay:(NSInteger)remainday remainYear:(NSInteger)remainyear;
-(BOOL)updateReceiveFileFirstOpenTime:(NSString *)openTime FileId:(NSInteger)fileId;
-(BOOL)updateReceiveFileTimeType:(NSInteger)timeType FileId:(NSInteger)fileId;
-(BOOL)updateReceiveFileLastTime:(NSInteger)fileId lastSeeTime:(NSString *)lastSeeTime;
-(BOOL)updateReceiveFileLocalPath:(NSInteger)fileId newPath:(NSString *)filePath;
-(BOOL)updateReceiveFileIsChangeTime:(NSInteger)fileId isChangeTime:(NSInteger)isChangeTime;
-(NSString *)selectReceiveFileFistOpenTimeByFileId:(NSInteger)fileId;
-(BOOL)updateReceiveFileForVersionPBB;

-(BOOL)updateReceiveFileApplyOpen:(NSInteger)ApplyOpen FileId:(NSInteger)fileId;

-(BOOL)findFileById:(NSInteger )fileId forLogName:(NSString *)logName;

-(void)updateTable;

-(BOOL)updateIsEye:(NSInteger)ReceiveFileId isEye:(BOOL)isEye;
-(BOOL)fetchIsEye:(NSInteger)ReceiveFileId;

-(BOOL)updateReceiveUid:(NSInteger)uid fileId:(NSInteger)fileId;
-(BOOL)updateReceiveSeriesID:(NSInteger)SeriesID fileId:(NSInteger)fileId;
-(NSInteger)fetchUid:(NSInteger)ReceiveFileId;
-(NSInteger)fetchSeriesID:(NSInteger)ReceiveFileId;
-(NSInteger)fetchCountOfUid:(NSInteger)ReceiveUid;
-(NSInteger)fetchCountOfSeriesID:(NSInteger)seriesID;
/**
 *  更新旧版离线文件时，使用
 *
 *
 *  @return 更新是否成功
 */
-(BOOL)updateByFileIdReceiveFile:(OutFile *)receiveFile;

-(NSData *)fetchEncodeKey:(NSInteger)fileId;

-(NSInteger)verifyOutFileCurrent:(NSInteger)receiveFileId;
@end
