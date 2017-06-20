//
//  SendFileManager.m
//  PBB
//
//  Created by pengyucheng on 13-11-25.
//  Copyright (c) 2013年 pyc.com.cn. All rights reserved.
//

#import "SendFileManager.h"
#import "FMDatabase.h"
#import "NSDate+String.h"

#import "SandboxFile.h"

@interface SendFileManager()
{
    //定义数据库成员变量
    FMDatabase *_db;
}
@end

@implementation SendFileManager

singleton_implementation(SendFileManager)

#pragma mark 重写init方法，设置数据库
-(id)init
{
    if (self = [super init]) {
//        NSLog(@"%@",KDataBasePath);
        _db = [FMDatabase databaseWithPath:KDataBasePath];
    }
    return self;
}

#pragma mark 重写子类的创建表方法
-(void)createTable
{
    //打开数据库
    if (![_db open]) return;
    
    [_db executeUpdate:@"create table if not exists t_send(sqlId integer primary key autoincrement NOT NULL,fileId integer NOT NULL,fileName text,logName text NOT NULL,fileUrl text,fileType VARCHAR(20),sendTime TEXT,startTime TEXT,endTime TEXT,limitTime integer,note text,forbid integer, limitNum integer,readNum integer,fileQQ text,fileEmail text,filePhone text,fileOpenDay integer,fileOpenYear integer,fileMakeType integer,fileBindMachineNum integer,fileActivationNum integer,orderNum text, isEye integer);"];
    
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}else{
//        NSLog(@"t_send表成功,%d",result);
    }
    // 关闭数据库
    [_db close];
}

- (NSString *)selectSendFileURLByFileId:(NSInteger)sendFileId LogName:(NSString *)logname
{
    if (![_db open]) {
        return nil;
    }
    NSString *fileurl = nil;
    NSString *sql = @"select fileUrl from t_send  where fileId = ? and logName=?;";
    FMResultSet *rs =[_db executeQuery:sql,[NSNumber numberWithInteger:sendFileId],logname];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    while ([rs next]) {
        fileurl = [rs stringForColumnIndex:0];
    }
    [_db close];
    if (fileurl) {
        fileurl = [[SandboxFile GetHomeDirectoryPath] stringByAppendingString:fileurl];
    }
    return fileurl;
}

-(BOOL)tableExist
{
    //打开数据库
    if (![_db open]) return NO;
    
    FMResultSet *rs = [_db executeQuery:@"select [sql] from sqlite_master where [type] = 'table' and lower(name) = t_send"];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    //if at least one next exists, table exists
    BOOL returnBool = [rs next];
    
    //close and free object
    [rs close];
    [_db close];
    return returnBool;
}

//
-(NSInteger)countOfSendFile:(NSString *)logName
{
    //打开数据库
    if (![_db open]) return 0;
    logName = [self base64encode:logName];
    NSString *sql = @"select count(*) from t_send where logName = ?";
    FMResultSet *rs = [_db executeQuery:sql,logName];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    int totalCount = 0;
    if ([rs next]) {
        totalCount = [rs intForColumnIndex:0];
//        NSLog(@"%@发送文件的总个数：%d",logName,totalCount);
    }
    [_db close];
    return totalCount;
    
}
//
-(BOOL)saveSendFile:(OutFile *)sendFile{
    
    if (![_db open]) return NO;
    
    NSString *sql = @"INSERT INTO t_send (fileId, fileName, logName, fileUrl ,fileType, sendTime, startTime,endTime,limitTime,note,forbid,limitNum,readNum,fileQQ,fileEmail,filePhone,fileOpenDay,fileOpenYear,fileMakeType,fileBindMachineNum,fileActivationNum,orderNum) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);";
    NSString *sendtime = [sendFile.sendtime dateString];
    NSString *starttime = [sendFile.starttime dateStringByDay];
    NSString *endtime = [sendFile.endtime dateStringByDay];
//    NSLog(@"时间date类型，转为string类型:%@",sendtime);
    
    
    NSString *fileNameNotExt = [sendFile.filename stringByDeletingPathExtension];
    NSString *fileNameExt = [fileNameNotExt pathExtension];
//    NSString *fileName = [sendFile.filename lastPathComponent];
    NSString *fileUrl = [sendFile.fileurl stringByReplacingOccurrencesOfString:[SandboxFile GetHomeDirectoryPath] withString:@""];
    
    sendFile.filename = [self base64encode:sendFile.filename];
    sendFile.logname = [self base64encode:sendFile.logname];
    fileUrl = [self base64encode:fileUrl];
    fileNameExt = [self base64encode:fileNameExt];
    sendtime = [self base64encode:sendtime];
    starttime = [self base64encode:starttime];
    endtime = [self base64encode:endtime];
    sendFile.note = [self base64encode:sendFile.note];
    sendFile.fileQQ = [self base64encode:sendFile.fileQQ];
    sendFile.fileEmail = [self base64encode:sendFile.fileEmail];
    sendFile.filePhone = [self base64encode:sendFile.filePhone];
    sendFile.orderNum = [self base64encode:sendFile.orderNum];
    
    BOOL result = [_db executeUpdate:sql, [NSNumber numberWithInteger:sendFile.fileid],
                   sendFile.filename,
                   sendFile.logname,
                   fileUrl,
                   fileNameExt,
                   
                   sendtime,
                   starttime,
                   endtime,
                   [NSNumber numberWithInteger:sendFile.limittime],
                   sendFile.note,
                   [NSNumber numberWithInteger:sendFile.forbid],
                   [NSNumber numberWithInteger:sendFile.limitnum],
                   [NSNumber numberWithInteger:sendFile.readnum],
                   sendFile.fileQQ,
                   sendFile.fileEmail,
                   sendFile.filePhone,
                   [NSNumber numberWithInteger:sendFile.fileOpenDay],
                   [NSNumber numberWithInteger:sendFile.fileOpenYear],
                   [NSNumber numberWithInteger:sendFile.fileMakeType],
                   [NSNumber numberWithInteger:sendFile.fileBindMachineNum],
                   [NSNumber numberWithInteger:sendFile.fileActivationNum],
                   sendFile.orderNum
                ];

	if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}    
    [_db close];
    return result;
}

-(BOOL)deleteSendFile:(NSInteger)sendFileId Logname:(NSString *)logname{
    
    if (![_db open]) return NO;
    NSString *sql = @"DELETE FROM t_send WHERE fileId = ? and logName=?;";
    logname = [self base64encode:logname];
    BOOL result = [_db executeUpdate:sql, [NSNumber numberWithInteger:sendFileId],logname];
	if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    [_db close];
    return result;
}

-(BOOL)updateSendFile:(OutFile *)sendFile{
    
    if (![_db open]) return NO;
    NSString *sql = @"UPDATE t_send SET startTime=?, endTime = ?, limitTime=?, note=?, limitNum=?,readNum=?,fileQQ=?,fileEmail=?,filePhone=?,fileBindMachineNum = ?,fileActivationNum = ? WHERE fileId=?;";
//    NSString *sendtime = [sendFile.sendtime dateStringByDay];
    NSString *starttime = [sendFile.starttime dateStringByDay];
    NSString *endtime = [sendFile.endtime dateStringByDay];
    
    starttime = [self base64encode:starttime];
    endtime = [self base64encode:endtime];
    sendFile.note = [self base64encode:sendFile.note];
    sendFile.fileQQ = [self base64encode:sendFile.fileQQ];
    sendFile.fileEmail = [self base64encode:sendFile.fileEmail];
    sendFile.filePhone = [self base64encode:sendFile.filePhone];
    
    BOOL result = [_db executeUpdate:sql,
                
                   starttime,
                   endtime,
                   [NSNumber numberWithInteger:sendFile.limittime],
                   sendFile.note,
                   [NSNumber numberWithInteger:sendFile.limitnum],
                   [NSNumber numberWithInteger:sendFile.readnum],   //刷新发送列表，更新阅读次数
                   sendFile.fileQQ,
                   sendFile.fileEmail,
                   sendFile.filePhone,
                   [NSNumber numberWithInteger:sendFile.fileBindMachineNum],
                   [NSNumber numberWithInteger:sendFile.fileActivationNum],
                   [NSNumber numberWithInteger:sendFile.fileid]
                   ];
	if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    [_db close];
    return result;
}
-(BOOL)updateSendFileForChangeInfo:(OutFile *)sendFile
{
    if (![_db open]) return NO;
    NSString *sql = @"UPDATE t_send SET startTime=?, endTime = ?, limitTime=?, note=?, limitNum=?,fileQQ=?,fileEmail=?,filePhone=?,fileBindMachineNum = ?,fileActivationNum = ? WHERE fileId=?;";
    //    NSString *sendtime = [sendFile.sendtime dateStringByDay];
    NSString *starttime = [sendFile.starttime dateStringByDay];
    NSString *endtime = [sendFile.endtime dateStringByDay];
    
    starttime = [self base64encode:starttime];
    endtime = [self base64encode:endtime];
    sendFile.note = [self base64encode:sendFile.note];
    sendFile.fileQQ = [self base64encode:sendFile.fileQQ];
    sendFile.fileEmail = [self base64encode:sendFile.fileEmail];
    sendFile.filePhone = [self base64encode:sendFile.filePhone];
    
    BOOL result = [_db executeUpdate:sql,
                   
                   starttime,
                   endtime,
                   [NSNumber numberWithInteger:sendFile.limittime],
                   sendFile.note,
                   [NSNumber numberWithInteger:sendFile.limitnum],
                   sendFile.fileQQ,
                   sendFile.fileEmail,
                   sendFile.filePhone,
                   [NSNumber numberWithInteger:sendFile.fileBindMachineNum],
                   [NSNumber numberWithInteger:sendFile.fileActivationNum],
                   [NSNumber numberWithInteger:sendFile.fileid]
                   ];
	if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    [_db close];
    return result;


}


-(BOOL)updateSendFileByLogName:(NSString *)logName
{
    if (![_db open]) return NO;
    NSString *sql = @"UPDATE t_send SET logName = ? WHERE logName = ''";
    
    logName = [self base64encode:logName];
    BOOL result = [_db executeUpdate:sql,logName];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    [_db close];
    return result;
}


-(BOOL)updateRefreshSendFile:(OutFile *)sendFile
{
    if (![_db open]) return NO;
    
    NSString *sql = @"UPDATE t_send SET startTime=?, endTime = ?, forbid=?, readNum=?, limitNum=?,fileBindMachineNum = ?,fileActivationNum = ?,isEye=? WHERE fileId=?;";
    //    NSString *sendtime = [sendFile.sendtime dateStringByDay];
    NSString *starttime = [sendFile.starttime dateStringByDay];
    NSString *endtime = [sendFile.endtime dateStringByDay];
    
    starttime = [self base64encode:starttime];
    endtime = [self base64encode:endtime];
    
    BOOL result = [_db executeUpdate:sql,
                   
                   //                   sendtime,
                   starttime,
                   endtime,
                   [NSNumber numberWithInteger:sendFile.forbid],
                   [NSNumber numberWithInteger:sendFile.readnum],
                   [NSNumber numberWithInteger:sendFile.limitnum],
                   [NSNumber numberWithInteger:sendFile.fileBindMachineNum],
                   [NSNumber numberWithInteger:sendFile.fileActivationNum],
                   [NSNumber numberWithBool:sendFile.isEye],
                   [NSNumber numberWithInteger:sendFile.fileid]
                   ];
	if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    [_db close];
    return result;

}


-(OutFile *)fetchSendFileByFileId:(NSInteger)sendFileId LogName:(NSString *)logname
{
    if(![_db open]) return nil;
    NSString *sql = @"select * from t_send where fileId = ? and logName = ?;";
    logname = [self base64encode:logname];
    
    FMResultSet *rs = [_db executeQuery:sql,[NSNumber numberWithInteger:sendFileId],logname];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    OutFile *of;
    while ([rs next]) {

        NSString *stime = [self base64decode:[rs stringForColumn:@"startTime"]];
        NSString *etime = [self base64decode:[rs stringForColumn:@"endTime"]];
        NSString *sendtime = [self base64decode:[rs stringForColumn:@"sendTime"]];
        NSLog(@"开始时间:%@ ,结束时间:%@",stime,etime);
        NSString *fileUrl = [[SandboxFile GetHomeDirectoryPath] stringByAppendingString:[self base64decode:[rs stringForColumn:@"fileUrl"]]];
        
        NSString *filename = [self base64decode:[rs stringForColumn:@"fileName"]];
         NSString *logName = [self base64decode:[rs stringForColumn:@"logName"]];
         NSString *fileType = [self base64decode:[rs stringForColumn:@"fileType"]];
         NSString *note = [self base64decode:[rs stringForColumn:@"note"]];
         NSString *fileQQ = [self base64decode:[rs stringForColumn:@"fileQQ"]];
         NSString *fileEmail = [self base64decode:[rs stringForColumn:@"fileEmail"]];
         NSString *filePhone = [self base64decode:[rs stringForColumn:@"filePhone"]];
         NSString *orderNum = [self base64decode:[rs stringForColumn:@"orderNum"]];
        
        of = [OutFile initWithSendFileId:[rs intForColumn:@"fileId"]
                                FileName:filename
                                LogName:logName
                                FileUrl:fileUrl
                                FileType:fileType
                                StartTime:[NSDate dateWithStringByDay:stime]
                                EndTime:[NSDate dateWithStringByDay:etime]
                                LimitTime:[rs intForColumn:@"limitTime"]
                                Forbid:[rs intForColumn:@"forbid"]
                                LimitNum:[rs intForColumn:@"limitNum"]
                                ReadNum:[rs intForColumn:@"readNum"]
                                Note:note
                                SendTime:[NSDate dateWithStringByDay:sendtime]
                                  FileQQ:fileQQ
                               FileEmail:fileEmail
                               FilePhone:filePhone
                             FileOpenDay:[rs intForColumn:@"fileOpenDay"]
                            FileOpenYear:[rs intForColumn:@"fileOpenYear"]
                            FileMakeType:[rs intForColumn:@"fileMakeType"]
                      FileBindMachineNum:[rs intForColumn:@"FileBindMachineNum"]
                       FileActivationNum:[rs intForColumn:@"fileActivationNum"]
                                OrderNum:orderNum
                                   isEye:[rs boolForColumn:@"isEye"]
              ];
    }
    [_db close];
    return of;
}

-(OutFile *)fetchSendFileCellByFileId:(NSInteger)sendFileId LogName:(NSString *)logname
{
    if(![_db open]) return nil;
    NSString *sql = @"select * from t_send where fileId = ? and logName = ?;";
    
    logname = [self base64encode:logname];
    FMResultSet *rs = [_db executeQuery:sql,[NSNumber numberWithInteger:sendFileId],logname];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    OutFile *of;
    while ([rs next]) {
        
        //时间是否限制：
        BOOL FreeTime = YES;
        NSString *startDay = [self base64decode:[rs stringForColumn:@"startTime"]];
        NSString *endDay = [self base64decode:[rs stringForColumn:@"endTime"]];
       
        if([startDay isEqualToString:@"1900-01-01"]
           ||[endDay isEqualToString:@"1900-01-01"]
           ||[startDay isEqualToString:@"1980-01-01"]
           ||[endDay isEqualToString:@"1980-01-01"]
           ||[startDay isEqualToString:@""]
           ||[endDay isEqualToString:@""])
            FreeTime = NO;
        
        //次数是否限制：
        BOOL FreeNum = YES;
        if ([rs intForColumn:@"limitNum"]==0) {
            FreeNum = NO;
        }
        
        NSDate *startTime = [NSDate dateWithStringByDay:startDay];
        NSDate *endTime = [NSDate dateWithStringByDay:endDay];
        NSInteger allDay = [NSDate DayByFromDate:startTime ToDate:endTime];
        NSInteger lastDay = [NSDate LastDayByFromDate:startTime ToDate:endTime];
        
        
        //剩余阅读的次数
        NSInteger lastNum = [rs intForColumn:@"limitNum"] - [rs intForColumn:@"readNum"];
        
        //0未打开，1 已打开 2 终止
        NSInteger open = 0;
        
        //是否禁止查阅 NO:禁止 ,YES :未禁止
        BOOL status = YES;
        if ([rs intForColumn:@"readNum"]>0) {
            open = 1;
        }
        
        
        //制作者 1：开放，0：终止
        NSInteger forbid = [rs intForColumn:@"forbid"];
        if (forbid==0) {
            open = 2;
            status = NO;
        }
        
        //剩余天数等于/小于0天，剩余的阅读次数等于小于0次
        NSString *tody = [[NSDate date] dateStringByDay];
        NSDate *today = [NSDate dateWithStringByDay:tody];
        BOOL b = ([[today laterDate:startTime] isEqualToDate:startTime] &&![today isEqualToDate:startTime]);
        if (lastNum<=0&&FreeNum)
        {
            //当都受限制时
            open = 2;
            status = NO;
            lastNum = 0;
        }
        if (lastDay<=0 && FreeTime) {
            //当都受限制时
            open = 2;
            status = NO;
            lastDay = 0;
        }
        if (b) {
            open = 2;
            status = NO;
        }
        NSString *fileUrl = [[SandboxFile GetHomeDirectoryPath] stringByAppendingString:[self base64decode:[rs stringForColumn:@"fileUrl"]]];
        of = [OutFile initWithSendFileId:[rs intForColumn:@"fileId"]
                                FileName:[self base64decode:[rs stringForColumn:@"fileName"]]
                                 FileUrl:fileUrl
                                SendTime:[NSDate dateWithStringByDay:[self base64decode:[rs stringForColumn:@"sendTime"]]]
                                 LastNum:lastNum
                                LimitNum:[rs intForColumn:@"limitNum"]
                                 LastDay:lastDay
                                  AllDay:allDay
                               limitTime:[rs intForColumn:@"limitTime"]
                                  Forbid:forbid
                                    Open:open
                                  Status:status
                                FreeTime:FreeTime
                                 FreeNum:FreeNum
                                    Note:[self base64decode:[rs stringForColumn:@"note"]]
                            FileMakeType:[rs intForColumn:@"fileMakeType"]
                      FileBindMachineNum:[rs intForColumn:@"fileBindMachineNum"]
                       FileActivationNum:[rs intForColumn:@"fileActivationNum"]
                                   isEye:[rs boolForColumn:@"isEye"]
              ];
    }
    [_db close];
    return of;

}
-(NSMutableArray *)selectSendFileByPage:(NSString *)logName Count:(NSInteger)limitCount FromIndex:(NSInteger)fromIndex
{
    if (![_db open]) return nil;
    if (!logName&&[logName length]!=0) {
        logName = @"";
    }
    logName = [self base64encode:logName];
    NSString *sql = @"select *from t_send where logName = ?  order by sqlId DESC;";
    if (limitCount!=0) {
        sql = [NSString stringWithFormat:@"select *from t_send Limit %ld Offset %ld where logName = ? order by sqlId DESC;",(long)limitCount,(long)fromIndex];
    }
    FMResultSet *rs = [_db executeQuery:sql,logName];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    OutFile *of;
    NSMutableArray *sendArr = [[NSMutableArray alloc] init];
    while ([rs next]) {
        
        //时间是否限制：
        BOOL FreeTime = YES;
        NSString *startDay = [self base64decode:[rs stringForColumn:@"startTime"]];
        NSString *endDay = [self base64decode:[rs stringForColumn:@"endTime"]];
        if([startDay isEqualToString:@"1900-01-01"]
           ||[endDay isEqualToString:@"1900-01-01"]
           ||[startDay isEqualToString:@"1980-01-01"]
           ||[endDay isEqualToString:@"1980-01-01"]
           ||[startDay isEqualToString:@""]
           ||[endDay isEqualToString:@""])
            FreeTime = NO;
        
        //次数是否限制：
        BOOL FreeNum = YES;
        if ([rs intForColumn:@"limitNum"]==0) {
            FreeNum = NO;
        }
        
        NSDate *startTime = [NSDate dateWithStringByDay:startDay];
        NSDate *endTime = [NSDate dateWithStringByDay:endDay];
        NSInteger allDay = [NSDate DayByFromDate:startTime ToDate:endTime];
        NSInteger lastDay = [NSDate LastDayByFromDate:startTime ToDate:endTime];
        
        
        //剩余阅读的次数
        NSInteger lastNum = [rs intForColumn:@"limitNum"] - [rs intForColumn:@"readNum"];
        
        //0未打开，1 已打开 2 终止
        NSInteger open = 0;
        
        //是否禁止查阅 NO:禁止 ,YES :未禁止
        BOOL status = YES;
        if ([rs intForColumn:@"readNum"]>0) {
            open = 1;
        }
        
        
        //制作者 1：开放，0：终止
        NSInteger forbid = [rs intForColumn:@"forbid"];
        if (forbid==0) {
            open = 2;
            status = NO;
        }
        
        //剩余天数等于/小于0天，剩余的阅读次数等于小于0次
        NSString *tody = [[NSDate date] dateStringByDay];
        NSDate *today = [NSDate dateWithStringByDay:tody];
        BOOL b = ([[today laterDate:startTime] isEqualToDate:startTime] &&![today isEqualToDate:startTime]);
        if (lastNum<=0&&FreeNum)
        {
            //当都受限制时
            open = 2;
            status = NO;
            lastNum = 0;
        }
        if (lastDay<=0 && FreeTime) {
            //当都受限制时
            open = 2;
            status = NO;
            lastDay = 0;
        }
        if (b) {
            open = 2;
            status = NO;
        }
        NSString *fileUrl = [[SandboxFile GetHomeDirectoryPath] stringByAppendingString:[self base64decode:[rs stringForColumn:@"fileUrl"]]];
        of = [OutFile initWithSendFileId:[rs intForColumn:@"fileId"]
                                FileName:[self base64decode:[rs stringForColumn:@"fileName"]]
                                 FileUrl:fileUrl
                                SendTime:[NSDate dateWithStringByDay:[self base64decode:[rs stringForColumn:@"sendTime"]]]
                                 LastNum:lastNum
                                LimitNum:[rs intForColumn:@"limitNum"]
                                 LastDay:lastDay
                                  AllDay:allDay
                               limitTime:[rs intForColumn:@"limitTime"]
                                  Forbid:forbid
                                    Open:open
                                  Status:status
                                FreeTime:FreeTime
                                 FreeNum:FreeNum
                                    Note:[self base64decode:[rs stringForColumn:@"note"]]
                            FileMakeType:[rs intForColumn:@"fileMakeType"]
                      FileBindMachineNum:[rs intForColumn:@"fileBindMachineNum"]
                       FileActivationNum:[rs intForColumn:@"fileActivationNum"]
                                   isEye:[rs boolForColumn:@"isEye"]
              ];
        
        [sendArr addObject:of];
        
//        NSLog(@"%@", of);
    }
    
    [_db close];
    return sendArr;
}



-(NSMutableArray *)selectSendFileAll:(NSString *)logName
{
    if (![_db open]) return nil;
    if (!logName&&[logName length]!=0) {
        logName = @"";
    }
    logName = [self base64encode:logName];
    NSString *sql = @"select *from t_send where logName = ? order by sqlId DESC;";
    FMResultSet *rs = [_db executeQuery:sql,logName];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    OutFile *of;
    NSMutableArray *sendArr = [[NSMutableArray alloc] init];
    while ([rs next]) {
        
        //时间是否限制：
        BOOL FreeTime = YES;
        NSString *startDay = [self base64decode:[rs stringForColumn:@"startTime"]];
        NSString *endDay = [self base64decode:[rs stringForColumn:@"endTime"]];
        if([startDay isEqualToString:@"1900-01-01"]
           ||[endDay isEqualToString:@"1900-01-01"]
           ||[startDay isEqualToString:@"1980-01-01"]
           ||[endDay isEqualToString:@"1980-01-01"]
           ||[startDay isEqualToString:@""]
           ||[endDay isEqualToString:@""])
            FreeTime = NO;
       
        //次数是否限制：
        BOOL FreeNum = YES;
        if ([rs intForColumn:@"limitNum"]==0) {
            FreeNum = NO;
        }
        
        NSDate *startTime = [NSDate dateWithStringByDay:startDay];
        NSDate *endTime = [NSDate dateWithStringByDay:endDay];
        NSInteger allDay = [NSDate DayByFromDate:startTime ToDate:endTime];
        NSInteger lastDay = [NSDate LastDayByFromDate:startTime ToDate:endTime];
        
        
        //剩余阅读的次数
        NSInteger lastNum = [rs intForColumn:@"limitNum"] - [rs intForColumn:@"readNum"];
        
        //0未打开，1 已打开 2 终止
        NSInteger open = 0;
        
        //是否禁止查阅 NO:禁止 ,YES :未禁止
        BOOL status = YES;
        if ([rs intForColumn:@"readNum"]>0) {
            open = 1;
        }
       
        
        //制作者 1：开放，0：终止
        NSInteger forbid = [rs intForColumn:@"forbid"];
        if (forbid==0) {
            open = 2;
            status = NO;
        }
        
        //剩余天数等于/小于0天，剩余的阅读次数等于小于0次
        NSString *tody = [[NSDate date] dateStringByDay];
        NSDate *today = [NSDate dateWithStringByDay:tody];
        BOOL b = ([[today laterDate:startTime] isEqualToDate:startTime] &&![today isEqualToDate:startTime]);
        if (lastNum<=0&&FreeNum)
        {
            //当都受限制时
            open = 2;
            status = NO;
            lastNum = 0;
        }
        if ((lastDay<=0 && FreeTime)) {
            //当都受限制时
            open = 2;
            status = NO;
            lastDay = 0;
        }
        if (b) {
            open = 2;
            status = NO;
        }
        NSString *fileUrl = [[SandboxFile GetHomeDirectoryPath] stringByAppendingString:[self base64decode:[rs stringForColumn:@"fileUrl"]]];
        of = [OutFile initWithSendFileId:[rs intForColumn:@"fileId"]
                                FileName:[self base64decode:[rs stringForColumn:@"fileName"]]
                                 FileUrl:fileUrl
                                SendTime:[NSDate dateWithStringByDay:[self base64decode:[rs stringForColumn:@"sendTime"]]]
                                 LastNum:lastNum
                                LimitNum:[rs intForColumn:@"limitNum"]
                                 LastDay:lastDay
                                  AllDay:allDay
                               limitTime:[rs intForColumn:@"limitTime"]
                                  Forbid:forbid
                                    Open:open
                                  Status:status
                                FreeTime:FreeTime
                                 FreeNum:FreeNum
                                    Note:[self base64decode:[rs stringForColumn:@"note"]]
                            FileMakeType:[rs intForColumn:@"fileMakeType"]
                      FileBindMachineNum:[rs intForColumn:@"fileBindMachineNum"]
                       FileActivationNum:[rs intForColumn:@"fileActivationNum"]
                                   isEye:[rs boolForColumn:@"isEye"]
              ];
        
        [sendArr addObject:of];
//        NSLog(@"发送列表的所有字段：%@", of);
    }
    
    [_db close];
    return sendArr;
}

-(NSMutableArray *)refreshSendFileAll:(NSString *)logName
{
    if (![_db open]) return nil;
    if (!logName&&[logName length]!=0) {
        logName = @"";
    }
    logName = [self base64encode:logName];
    NSString *sql = @"select fileId from t_send where logName = ?";
    FMResultSet *rs = [_db executeQuery:sql,logName];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    NSMutableArray *sendArr = [[NSMutableArray alloc] init];
    while ([rs next]) {
        NSString *fileId =[NSString stringWithFormat:@"%d",[rs intForColumn:@"fileId"]];
        [sendArr addObject:fileId];
    }
    [_db close];
    return sendArr;
}

-(NSMutableArray *)refreshSendFileByPage:(NSString *)logName  Count:(NSInteger)limitCount FromIndex:(NSInteger)fromIndex
{
    if (![_db open]) return nil;
    if (!logName&&[logName length]!=0) {
        logName = @"";
    }
    NSString *sql = [NSString stringWithFormat:@"select fileId from t_send where logName = ? limit %ld Offset %ld ",(long)limitCount,(long)fromIndex];
    MyLog(@"%@",sql);
    logName = [self base64encode:logName];
    FMResultSet *rs = [_db executeQuery:sql,logName];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}

    NSMutableArray *sendArr = [[NSMutableArray alloc] init];
    while ([rs next]) {
        NSString *fileId =[NSString stringWithFormat:@"%d",[rs intForColumn:@"fileId"]];
        [sendArr addObject:fileId];
    }
    [_db close];
    return sendArr;
}

-(BOOL)changeSendFileForbid:(NSString *)logname FileId:(NSInteger)sendFileId Forbid:(NSInteger)forbid
{
    if (![_db open]) return NO;
    NSString *sql = @"UPDATE t_send SET forbid=? WHERE fileId = ? and logName = ?;";
    logname = [self base64encode:logname];
    BOOL result = [_db executeUpdate:sql,[NSNumber numberWithInteger:forbid],[NSNumber numberWithInteger:sendFileId],logname];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    [_db close];
    return result;
}

#pragma mark 更新isEye字段值
-(BOOL)updateIsEye:(NSInteger)sendFileId isEye:(BOOL)isEye
{
    if (![_db open]) return NO;
    
    NSInteger isE = 0;  //1:可以看，0，不能看
    if (isEye) {
        isE = 1;
    }
    NSString *sql = @"UPDATE t_send SET isEye=? WHERE fileId = ?;";
    BOOL result = [_db executeUpdate:sql,[NSNumber numberWithInteger:isE],[NSNumber numberWithInteger:sendFileId]];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    [_db close];
    return result;
}

#pragma mark 获取isEye字段值
-(BOOL)fetchIsEye:(NSInteger)sendFileId
{
    if (![_db open]) {
        return NO;
    }
    BOOL isEye;
    NSString *sql = @"select isEye from t_send  where fileId = ?;";
    FMResultSet *rs =[_db executeQuery:sql,[NSNumber numberWithInteger:sendFileId]];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    while ([rs next]) {
        isEye = [rs boolForColumnIndex:0];
    }
    [_db close];
    return isEye;

}

-(BOOL)isExistByfileId:(NSInteger) fileId forLogName:(NSString *)logname;
{
    if (![_db open])
        return NO;
    
    logname = [self base64encode:logname];
    NSString *sql = [NSString stringWithFormat:@"select fileId from t_send where fileId = %ld and logname = '%@' ",(long)fileId,logname];
    MyLog(@"%@",sql);
    
    FMResultSet *rs = [_db executeQuery:sql];

    while ([rs next]) {
       
        return YES;
    }
    
     [_db close];
    return NO;
}


-(BOOL)updateSendFileForVersionPBB
{
    if (![_db open]) return NO;
    NSString *sql1 = @"select sqlId,fileUrl from t_send;";
    FMResultSet *rs = [_db executeQuery:sql1];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    
//    NSMutableArray *sendArr = [[NSMutableArray alloc] init];
    BOOL result = NO;
    while ([rs next]) {
        NSString *fileUrl =[NSString stringWithFormat:@"%@",[self base64decode:[rs stringForColumn:@"fileUrl"]]];
        NSInteger fileId = [rs intForColumn:@"sqlId"];
        NSRange strRag = [fileUrl rangeOfString:@"Documents"];
        if (strRag.location>2) {
            fileUrl = [fileUrl substringFromIndex:strRag.location];
        }else{
            continue;
        }
        
//        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//        fileUrl = [NSString stringWithFormat:@"%@%@",path,fileUrl];
        NSString *sql = @"UPDATE t_send SET fileUrl = '%@' where sqlId = %d ;";
        
         fileUrl = [self base64encode:fileUrl];
        sql = [NSString stringWithFormat:sql,fileUrl,fileId];
        result = [_db executeUpdate:sql];
        if ([_db hadError]) {
            NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        }

    }
    NSString *sql = @"UPDATE t_send SET limitTime = 0 where fileUrl like '%.pyc' ;";
    result = [_db executeUpdate:sql];
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }

    [_db close];
    return result;
}

-(BOOL)intoFieldByName:(NSString *)fieldName FieldType:(NSString *)fieldtype
{
    if (![_db open]) {
        return NO;
    }
    //获取旧表中的字段名
    NSString *theSql=[NSString stringWithFormat:@"select * from t_send"];
    FMResultSet *resultSet=[_db executeQuery:theSql];
    [resultSet setupColumnNames];
    //拼接sql语句中的老字段
    NSEnumerator *columnNames = [resultSet.columnNameToIndexMap keyEnumerator];

    NSString *tempColumnName= nil;
    while ((tempColumnName = [columnNames nextObject]))
    {
        if ([[fieldName lowercaseString] isEqualToString:tempColumnName]) {
//            NSLog(@"t_send 表，已存在该字段名：%@",tempColumnName);
            return NO;
        }
    }

    NSString *sqlstr = [NSString stringWithFormat:@"alter table t_send add %@ %@",fieldName,fieldtype];
    BOOL result = [_db executeUpdate:sqlstr];
    if ([_db hadError]) {
        NSLog(@"Err %d:%@",[_db lastErrorCode],[_db lastErrorMessage]);
    }
    [_db close];
    return result;
}

-(BOOL)updateSendFileMakeType
{
    if (![_db open]) {
        return NO;
    }

    BOOL result = NO;
    NSString *sql = @"UPDATE t_send SET fileMakeType = 1;";
    result = [_db executeUpdate:sql];
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    
    [_db close];
    return result;

}

-(BOOL)updateSendFileIsEye
{
    if (![_db open]) {
        return NO;
    }
    BOOL result = NO;
    NSString *sql = @"UPDATE t_receive SET isEye = 1;";
    result = [_db executeUpdate:sql];
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    
    [_db close];
    return result;
    
}

//将fileUrl更新为相对路径
-(void)updateFileUrl
{
    
}
//版本升级
-(void)updateTable
{
    NSUserDefaults *myUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sendEncode = [myUserDefaults objectForKey:@"sendEncode"];
    
    if (![sendEncode isEqualToString:@"encode"]) {
        [self base64encode];  // 读取数据库用户表里的数据，加密后再存入
        [myUserDefaults setObject:@"encode" forKey:@"sendEncode"];  // 将发送表设置为加密过
        [myUserDefaults synchronize];
    }
    
    //    fileQQ text,fileEmail text,filePhone text,fileOpenDay integer,fileOpenYear integer,fileMakeType integer
    [self intoFieldByName:@"fileQQ" FieldType:@"text"];
    [self intoFieldByName:@"fileEmail" FieldType:@"text"];
    [self intoFieldByName:@"filePhone" FieldType:@"text"];
    [self intoFieldByName:@"fileOpenDay" FieldType:@"integer"];
    [self intoFieldByName:@"fileOpenYear" FieldType:@"integer"];
    [self intoFieldByName:@"fileBindMachineNum" FieldType:@"integer"];
    [self intoFieldByName:@"fileActivationNum" FieldType:@"integer"];
    [self intoFieldByName:@"orderNum" FieldType:@"text"];
    
    if ([self intoFieldByName:@"fileMakeType" FieldType:@"integer"]) {
        [self updateSendFileMakeType];
    }
    
    if ([self intoFieldByName:@"isEye" FieldType:@" integer"]) {
        [self updateSendFileIsEye];
    }

}

/**
 * 读取数据库用户表里的数据，加密后再存入
 */
-(void)base64encode
{
    if (![_db open]) {
        return ;
    }
    
    NSString *theSql=[NSString stringWithFormat:@"select * from t_send"];
    FMResultSet *resultSet=[_db executeQuery:theSql];
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    
    NSArray *columnNames = @[@"fileName", @"logName", @"fileUrl", @"fileType", @"sendTime", @"startTime", @"endTime", @"note", @"fileQQ", @"fileEmail", @"filePhone", @"orderNum"];
    
    while ([resultSet next]) {
        for (NSString *columeName in columnNames) {
            [self updateEncodeData:columeName inResultSet:resultSet];  // 更新每一条数据
        }
    }

    [_db close];
    return ;
}

/**
 * 读取数据库用户表里的一条数据，加密后再存入
 */
-(void)updateEncodeData:(NSString *)columnName inResultSet:(FMResultSet *)resultSet
{
    NSString *content = [resultSet stringForColumn:columnName];
    int fileId = [resultSet intForColumn:@"fileId"];

    content = [self base64encode:content];
    if (![content isEqualToString:@""]) {
        NSString *theSql=[NSString stringWithFormat:@"update t_send set %@ = '%@' where fileId = %d", columnName, content, fileId];
        [_db executeUpdate:theSql];
        if ([_db hadError]) {
            NSLog(@"Err %d:%@",[_db lastErrorCode],[_db lastErrorMessage]);
        }
    }
    

}


#define mark - base64加密解密字符串
/**
 * base64加密字符串调用方法
 */
- (NSString *)base64encode:(NSString *)str
{
    if (str == nil ) {
        str = nil;
    }
    
    NSData *nsdata = [str dataUsingEncoding:NSUTF8StringEncoding];  // 将明文转成data
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];// 将data数据进行base64加密
    
    return base64Encoded;  // 返回加密后的字符串
}

/**
 * base64解码字符串调用方法
 */
- (NSString *)base64decode:(NSString *)str
{
    if (str == nil || [str isEqualToString:@""]) {
        return @"";
    }
    // NSData from the Base64 encoded str
    NSData *nsdataFromBase64String = [[NSData alloc]
                                      initWithBase64EncodedString:str options:0];  // 将密文转成data
    
    // Decoded NSString from the NSData
    NSString *nsstr = [[NSString alloc]
                       initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];  // 将data数据转成明文
    
    const char *cstr = [nsstr UTF8String];
    NSString *base64Decoded = [NSString stringWithUTF8String:cstr];
    
//    NSLog(@"userDecoded:%@ － end", base64Decoded);
    if (base64Decoded) {
        return base64Decoded;  // 返回解密后的字符串
    } else {
        return str;
    }
}

@end
