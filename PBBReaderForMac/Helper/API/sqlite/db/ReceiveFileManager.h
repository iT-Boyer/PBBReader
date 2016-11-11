//
//  ReceiveFileManager.h
//  PBB
//
//  Created by pengyucheng on 13-11-25.
//  Copyright (c) 2013年 pyc.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "OutFile.h"

@interface ReceiveFileManager : NSObject

singleton_interface(ReceiveFileManager)

// 创建表方法
- (void)createTable;

-(BOOL)saveReceiveFile:(OutFile *)receiveFile;

-(BOOL)updateReceiveFile:(OutFile *)receiveFile;

-(BOOL)updateRefreshReceiveFile:(OutFile *)receiveFile;

-(BOOL)deleteReceiveFile:(NSInteger)fileId LogName:(NSString *)logname;

-(BOOL)updateReceiveFileByLogName:(NSString *)logName;

-(BOOL)updateReceiveFileFirstOpenTime:(NSString *)openTime FileId:(NSInteger)fileId;
-(BOOL)updateReceiveFileApplyOpen:(NSInteger)ApplyOpen FileId:(NSInteger)fileId;
-(BOOL)updateReceiveFileTimeType:(NSInteger) timeType FileId:(NSInteger)fileId;
-(BOOL)updateReceiveFileByFileId:(NSInteger)fileId remainDay:(NSInteger)remainday remainYear:(NSInteger)remainyear;
-(BOOL)updateReceiveFileLastTime:(NSInteger)fileId lastSeeTime:(NSString *)lastSeeTime;
-(BOOL)updateReceiveFileLocalPath:(NSInteger)fileId newPath:(NSString *)filePath;
-(BOOL)updateReceiveFileIsChangeTime:(NSInteger)fileId isChangeTime:(NSInteger)isChangeTime;
-(NSString *)selectReceiveFileFistOpenTimeByFileId:(NSInteger)fileId;
-(OutFile *)fetchReceiveFileByFileId:(NSInteger)receiveFileId LogName:(NSString *)logname;

-(OutFile *)fetchReceiveFileCellByFileId:(NSInteger)receiveFileId LogName:(NSString *)logname;

-(NSInteger)countOfReceiveFile:(NSString *)logName;

//多个查询
-(NSMutableArray *)selectReceiveFileAll:(NSString *)logName;
//多个查询
-(NSMutableArray *)selectReceiveSeriesFileAll:(NSInteger)Series;

//按账户分页查询
-(NSMutableArray *)selectReceiveFileByPage:(NSString *)logName Count:(NSInteger)limitCount FromIndex:(NSInteger)fromIndex;

//返回文件路径
-(NSString *)selectReceiveFileURLByFileId:(NSInteger)fileId LogName:(NSString*)logname;

-(NSMutableArray *)refreshReceiveFileAll:(NSString *)logName;


-(NSMutableArray *)refreshReceiveFileByPage:(NSString *)logName  Count:(NSInteger)limitCount FromIndex:(NSInteger)fromIndex;
//查看是否存在

-(BOOL)updateReceiveFileToAddReadNumByFileId:(NSInteger)receiveFileId;

-(BOOL)updateReceiveFileToRebornedByFileId:(NSInteger)receiveFileId Status:(NSInteger)status;

-(BOOL)tableExist;

-(BOOL)updateReceiveFileForVersionPBB;

-(void)updateTable;

-(BOOL)canOpenAddReadNum:(NSInteger)fileId Logname:(NSString *)logname;

-(BOOL)isExistByfileId:(NSInteger) fileId forLogName:(NSString *)logname;


-(BOOL)updateIsEye:(NSInteger)ReceiveFileId isEye:(BOOL)isEye;
-(BOOL)fetchIsEye:(NSInteger)ReceiveFileId;

-(BOOL)updateReceiveUid:(NSInteger)uid fileId:(NSInteger)fileId;
//文件记录里，添加系列ID
-(BOOL)updateReceiveSeriesID:(NSInteger)SeriesID fileId:(NSInteger)fileId;
-(NSInteger)fetchUid:(NSInteger)ReceiveFileId;
-(NSInteger)fetchSeriesID:(NSInteger)ReceiveFileId;
-(NSInteger)fetchCountOfUid:(NSInteger)ReceiveUid;
//查询同一系列的文件个数
-(NSInteger)fetchCountOfSeriesID:(NSInteger)seriesID;

/**
 *  更新旧版离线文件时，使用
 *
 *
 *  @return 更新是否成功
 */
-(BOOL)updateByFileIdReceiveFile:(OutFile *)receiveFile;

-(NSData *)fetchEncodeKey:(NSInteger)fileId;
/**
 *  根据本地数据库的数据，判断文件是否能看
 *
 *  @param fileId 文件Id
 *
 *  @return 是否能看
 */
-(NSInteger)isCanOpenFileId:(NSInteger)fileId;
@end
