//
//  SendFileManager.h
//  PBB
//
//  Created by pengyucheng on 13-11-25.
//  Copyright (c) 2013年 pyc.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "OutFile.h"
@interface SendFileManager : NSObject

singleton_interface(SendFileManager)

// 创建表方法
- (void)createTable;

-(BOOL)saveSendFile:(OutFile *)sendFile;

-(BOOL)deleteSendFile:(NSInteger)SendFileId Logname:(NSString *)logname;

-(BOOL)updateSendFile:(OutFile *)sendFile;

-(BOOL)updateSendFileForChangeInfo:(OutFile *)sendFile;
-(BOOL)updateRefreshSendFile:(OutFile *)sendfile;

-(OutFile *)fetchSendFileByFileId:(NSInteger)sendFileId LogName:(NSString *)logname;

-(OutFile *)fetchSendFileCellByFileId:(NSInteger)sendFileId LogName:(NSString *)logname;

//返回文件路径
-(NSString *)selectSendFileURLByFileId:(NSInteger)sendFileId LogName:(NSString*)logname;

//按用户名查询所有
-(NSMutableArray *)selectSendFileAll:(NSString *)logName;


-(NSMutableArray *)refreshSendFileAll:(NSString *)logName;

//
-(NSMutableArray *)refreshSendFileByPage:(NSString *)logName Count:(NSInteger)limitCount FromIndex:(NSInteger)fromIndex;

//按账户分页查询
-(NSMutableArray *)selectSendFileByPage:(NSString *)logName Count:(NSInteger)limitCount FromIndex:(NSInteger)fromIndex;

//按账户查询条数
-(NSInteger)countOfSendFile:(NSString *)logName;

//修改forbid
-(BOOL)changeSendFileForbid:(NSString *)logname FileId:(NSInteger)sendFileId Forbid:(NSInteger)forbid;

-(BOOL)tableExist;

-(BOOL)updateSendFileByLogName:(NSString *)logName;

-(BOOL)isExistByfileId:(NSInteger) fileId forLogName:(NSString *)logname;

-(BOOL)updateSendFileForVersionPBB;

-(void)updateTable;

-(BOOL)updateIsEye:(NSInteger)sendFileId isEye:(BOOL)isEye;
-(BOOL)fetchIsEye:(NSInteger)sendFileId;
@end
