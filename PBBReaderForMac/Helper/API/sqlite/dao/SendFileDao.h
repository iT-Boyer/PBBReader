//
//  FileDao.h
//  PBB
//
//  Created by pengyucheng on 13-11-15.
//  Copyright (c) 2013年 pyc.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "OutFile.h"
@interface SendFileDao : NSObject

singleton_interface(SendFileDao)


-(BOOL)saveSendFile:(OutFile *)sendFile;

-(BOOL)deleteSendFile:(NSInteger)SendFileId Logname:(NSString *)logname;

-(BOOL)updateSendFile:(OutFile *)sendFile;

-(BOOL)updateSendFileForChangeInfo:(OutFile *)sendFile;

-(BOOL)updateRefreshSendFile:(OutFile *)sendFile;

-(OutFile *)fetchSendFileByFileId:(NSInteger)sendFileId LogName:(NSString *)logname;

// 返回文件路径
-(NSString *)selectSendFileURLByFileId:(NSInteger)fileId LogName:(NSString*)logname;

-(OutFile *)fetchSendFileCellByFileId:(NSInteger)sendFileId LogName:(NSString *)logname;
//多个查询
-(NSMutableArray *)selectSendFileAll:(NSString *)logName;

-(NSInteger)countOfSendFile:(NSString *)logName;

-(NSMutableArray *)refreshSendFileAll:(NSString *)logName;
//按账户分页查询
-(NSMutableArray *)selectSendFileByPage:(NSString *)logName Count:(NSInteger)limitCount FromIndex:(NSInteger)fromIndex;

-(BOOL)tableExist;

-(NSMutableArray *)refreshSendFileByPage:(NSString *)logName  Count:(NSInteger)limitCount FromIndex:(NSInteger)fromIndex;

//修改forbid
-(BOOL)changeSendFileForbid:(NSString *)logname FileId:(NSInteger)sendFileId Forbid:(NSInteger)forbid;

-(BOOL)updateSendFileByLogName:(NSString *)logName;

-(BOOL)findFileById:(NSInteger )fileId forLogName:(NSString *)logName;

-(BOOL)updateSendFileForVersionPBB;

-(void)updateTable;

-(BOOL)updateIsEye:(NSInteger)sendFileId isEye:(BOOL)isEye;
-(BOOL)fetchIsEye:(NSInteger)sendFileId;
@end
