//
//  ReceiveFileManager.m
//  PBB
//
//  Created by pengyucheng on 13-11-25.
//  Copyright (c) 2013年 pyc.com.cn. All rights reserved.
//

#import "ReceiveFileManager.h"
#import "FMDatabase.h"
#import "NSDate+String.h"
#import "SandboxFile.h"
#import "PycFile.h"
#import "SeriesDao.h"
#import "SeriesModel.h"


@interface ReceiveFileManager()
{
    FMDatabase *_db;
}

@end

@implementation ReceiveFileManager

singleton_implementation(ReceiveFileManager)

#pragma mark 重写init方法，设置数据库
-(id)init
{
    if (self = [super init]) {
        NSLog(@"数据库路径：%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:KDataBaseName]);
        _db = [FMDatabase databaseWithPath:KDataBasePath];
    }
    return self;
}

#pragma mark 重写子类的创建表方法
-(void)createTable
{
//    [self intoFieldByName:@"timeType" FieldType:@"interger"];
//    //最后阅读时间
//    [self intoFieldByName:@"lastSeeTime" FieldType:@"text"];
//    [self intoFieldByName:@"isChangeTime" FieldType:@"integer"];
    //打开数据库
    if (![_db open]) return;
    [_db executeUpdate:@"create table if not exists t_receive(sqlId integer primary key autoincrement,fileId integer,fileName text,logName text,fileOwner text,fileOwnerNick text,fileUrl text,fileType VARCHAR(20),receiveTime TEXT,startTime TEXT,endTime TEXT,limitTime integer,note text,forbid integer, limitNum integer,readNum integer,reborn integer,fileQQ text,fileEmail text,filePhone text,fileOpenDay integer,fileOpenYear integer,fileMakeType integer,fileDayRemain integer,fileYearRemain integer,makeTime TEXT,appType integer,firstOpenTime text,isEye integer,Uid integer,applyId integer,actived integer,field1 text,field2 text,field1name text,field2name text,hardno text,EncodeKey blob,SelfFieldNum integer,DefineChecked integer,WaterMarkQQ text,WaterMarkPhone text,WaterMarkEmail text,seriesID integer,timeType interger,lastSeeTime text,isChangeTime integer);"];
    // 关闭数据库
    [_db close];
}

-(BOOL)tableExist
{
    if (![_db open]) {
        return NO;
    }
    
    FMResultSet *rs = [_db executeQuery:@"select [sql] from sqlite_master where [type] = 'table' and lower(name) = t_receive"];
    
    //if at least one next exists, table exists
    BOOL returnBool = [rs next];
    
    //close and free object
    [rs close];
    return returnBool;
}
-(BOOL)saveReceiveFile:(OutFile *)receiveFile
{
    if (![_db open]) return NO;
    
    NSString *starttime = [receiveFile.starttime dateStringByDay];
    NSString *endtime = [receiveFile.endtime dateStringByDay];
    NSString *receiveTime = [receiveFile.recevieTime dateStringByDay];
    NSString *makeTime = [receiveFile.sendtime dateString];
    
//    NSString *fileNameNotExt = [receiveFile.filename stringByDeletingPathExtension];
//    NSString *fileNameExt = [fileNameNotExt pathExtension];
    receiveFile.filename = [self base64encode:receiveFile.filename];
    receiveFile.logname = [self base64encode:receiveFile.logname];
    receiveFile.fileowner = [self base64encode:receiveFile.fileowner];
    receiveFile.fileOwnerNick = [self base64encode:receiveFile.fileOwnerNick];
    receiveFile.fileurl = [self base64encode:receiveFile.fileurl];
    receiveFile.filetype = [self base64encode:receiveFile.filetype];
    receiveTime = [self base64encode:receiveTime];
    starttime = [self base64encode:starttime];
    endtime = [self base64encode:endtime];
    receiveFile.note = [self base64encode:receiveFile.note];
    makeTime = [self base64encode:makeTime];
    
    NSString *sql = @"INSERT INTO t_receive (fileId, fileName, logName, fileOwner,fileOwnerNick, fileUrl,fileType,receiveTime,startTime,endTime,limitTime,note,forbid,limitNum,readNum,reborn,fileQQ,fileEmail,filePhone,fileOpenDay,fileOpenYear,fileMakeType,fileDayRemain,fileYearRemain,makeTime,appType,isEye) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);";
    BOOL result;
    if ([receiveFile.fileQQ isEqualToString:@"#cansee"]) {
        //手动激活
        sql = @"INSERT INTO t_receive (fileId, fileName, logName, fileOwner,fileOwnerNick, fileUrl,fileType,receiveTime,startTime,endTime,limitTime,note,forbid,limitNum,readNum,reborn,fileOpenDay,fileOpenYear,fileMakeType,fileDayRemain,fileYearRemain,makeTime,appType,isEye) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);";

        
        result = [_db executeUpdate:sql,
                       [NSNumber numberWithInteger:receiveFile.fileid],
                       receiveFile.filename,
                       receiveFile.logname,
                       receiveFile.fileowner,
                       receiveFile.fileOwnerNick,
                       receiveFile.fileurl,
                       receiveFile.filetype,
                       receiveTime,
                       starttime,
                       endtime,
                       [NSNumber numberWithInteger:receiveFile.limittime],
                       receiveFile.note,
                       [NSNumber numberWithInteger:receiveFile.forbid],
                       [NSNumber numberWithInteger:receiveFile.limitnum],
                       [NSNumber numberWithInteger:receiveFile.readnum],
                       [NSNumber numberWithInteger:receiveFile.reborn],
//                       receiveFile.fileQQ,
//                       receiveFile.fileEmail,
//                       receiveFile.filePhone,
                       [NSNumber numberWithInteger:receiveFile.fileOpenDay],
                       [NSNumber numberWithInteger:receiveFile.fileOpenYear],
                       [NSNumber numberWithInteger:receiveFile.fileMakeType],
                       [NSNumber numberWithInteger:receiveFile.fileDayRemain],
                       [NSNumber numberWithInteger:receiveFile.fileYearRemain],
                       makeTime,
                       [NSNumber numberWithInteger:receiveFile.appType],
                       [NSNumber numberWithBool:receiveFile.isEye]
                       ];
    }else{
        
        receiveFile.fileQQ = [self base64encode:receiveFile.fileQQ];
        receiveFile.fileEmail = [self base64encode:receiveFile.fileEmail];
        receiveFile.filePhone = [self base64encode:receiveFile.filePhone];
        
        result = [_db executeUpdate:sql,
                  [NSNumber numberWithInteger:receiveFile.fileid],
                  receiveFile.filename,
                  receiveFile.logname,
                  receiveFile.fileowner,
                  receiveFile.fileOwnerNick,
                  receiveFile.fileurl,
                  receiveFile.filetype,
                  receiveTime,
                  starttime,
                  endtime,
                  [NSNumber numberWithInteger:receiveFile.limittime],
                  receiveFile.note,
                  [NSNumber numberWithInteger:receiveFile.forbid],
                  [NSNumber numberWithInteger:receiveFile.limitnum],
                  [NSNumber numberWithInteger:receiveFile.readnum],
                  [NSNumber numberWithInteger:receiveFile.reborn],
                  receiveFile.fileQQ,
                  receiveFile.fileEmail,
                  receiveFile.filePhone,
                  [NSNumber numberWithInteger:receiveFile.fileOpenDay],
                  [NSNumber numberWithInteger:receiveFile.fileOpenYear],
                  [NSNumber numberWithInteger:receiveFile.fileMakeType],
                  [NSNumber numberWithInteger:receiveFile.fileDayRemain],
                  [NSNumber numberWithInteger:receiveFile.fileYearRemain],
                  makeTime,
                  [NSNumber numberWithInteger:receiveFile.appType],
                  [NSNumber numberWithBool:receiveFile.isEye]
                  ];
    
    }
    
	if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    
    [_db close];
    return result;
}


-(BOOL)updateReceiveFile:(OutFile *)receiveFile
{
    if (![_db open]) return NO;
    NSString *starttime = [receiveFile.starttime dateStringByDay];
    NSString *endtime = [receiveFile.endtime dateStringByDay];
    
    
    receiveFile.filename = [self base64encode:receiveFile.filename];
    receiveFile.logname = [self base64encode:receiveFile.logname];
    receiveFile.fileowner = [self base64encode:receiveFile.fileowner];
    receiveFile.fileOwnerNick = [self base64encode:receiveFile.fileOwnerNick];
    receiveFile.filetype = [self base64encode:receiveFile.filetype];
    starttime = [self base64encode:starttime];
    endtime = [self base64encode:endtime];
    receiveFile.note = [self base64encode:receiveFile.note];
    
    NSString *sql=nil;
    BOOL result;
    
    if ([receiveFile.fileQQ isEqualToString:@"#cansee"])
    {
        sql = @"UPDATE t_receive SET fileName=?,fileOwner=?,fileOwnerNick = ?,startTime=?, endTime =?, limitTime=?, note=?, forbid=?,limitNum=?,fileDayRemain = ?,fileYearRemain = ?,isEye=? WHERE fileId=? and logName=?;";
        result = [_db executeUpdate:sql,
                  receiveFile.filename,
                  receiveFile.fileowner,
                  receiveFile.fileOwnerNick,
//                  receiveFile.filetype,
                  starttime,
                  endtime,
                  [NSNumber numberWithInteger:receiveFile.limittime],
                  receiveFile.note,
                  [NSNumber numberWithInteger:receiveFile.forbid],
                  [NSNumber numberWithInteger:receiveFile.limitnum],
                  [NSNumber numberWithInteger:receiveFile.fileDayRemain],
                  [NSNumber numberWithInteger:receiveFile.fileYearRemain],
                  [NSNumber numberWithBool:receiveFile.isEye],
                  [NSNumber numberWithInteger:receiveFile.fileid],
                  receiveFile.logname
                  ];
        
    }
    else
    {
        sql = @"UPDATE t_receive SET fileName=?,fileOwner=?,fileOwnerNick = ?,fileType=?, startTime=?, endTime =?, limitTime=?, note=?, forbid=?, limitNum=?, readNum=?, fileQQ=?,fileEmail=?,filePhone=?,fileDayRemain = ?,fileYearRemain = ?,isEye=? WHERE fileId=? and logName=?;";
        receiveFile.fileQQ = [self base64encode:receiveFile.fileQQ];
        receiveFile.fileEmail = [self base64encode:receiveFile.fileEmail];
        receiveFile.filePhone = [self base64encode:receiveFile.filePhone];
        
        result = [_db executeUpdate:sql,
                  receiveFile.filename,
                  receiveFile.fileowner,
                  receiveFile.fileOwnerNick,
                  receiveFile.filetype,
                  starttime,
                  endtime,
                  [NSNumber numberWithInteger:receiveFile.limittime],
                  receiveFile.note,
                  [NSNumber numberWithInteger:receiveFile.forbid],
                  [NSNumber numberWithInteger:receiveFile.limitnum],
                  [NSNumber numberWithInteger:receiveFile.readnum],
                  receiveFile.fileQQ,
                  receiveFile.fileEmail,
                  receiveFile.filePhone,
                  [NSNumber numberWithInteger:receiveFile.fileDayRemain],
                  [NSNumber numberWithInteger:receiveFile.fileYearRemain],
                  [NSNumber numberWithBool:receiveFile.isEye],
                  [NSNumber numberWithInteger:receiveFile.fileid],
                  receiveFile.logname
                  ];
        
    }
   
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    [_db close];
    return result;
}



-(BOOL)updateReceiveFileByLogName:(NSString *)logName
{
    if (![_db open]) return NO;
    NSString *sql = @"UPDATE t_receive SET logName = ? WHERE logName = '' ";
    
    logName = [self base64encode:logName];
    
    BOOL result = [_db executeUpdate:sql,logName];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    [_db close];
    return result;
}

-(BOOL)isExistByfileId:(NSInteger) fileId forLogName:(NSString *)logname;
{
    if (![_db open])
        return NO;
    
    logname = [self base64encode:logname];
    
    NSString *sql = [NSString stringWithFormat:@"select fileId from t_receive where fileId = %ld and logname = '%@' ",(long)fileId,logname];
    MyLog(@"%@",sql);
    
    FMResultSet *rs = [_db executeQuery:sql];
    
    while ([rs next]) {
        
        return YES;
    }
    
    [_db close];
    return NO;
}

-(BOOL)updateReceiveFileFirstOpenTime:(NSString *)openTime FileId:(NSInteger)fileId
{
//    NSLog(@"openTime length =%d",openTime.length);
    if ([openTime isEqualToString:@""]) {
        return NO;
    }
    if (![_db open]) return NO;
    NSString *sql = @"UPDATE t_receive SET firstOpenTime = ? WHERE fileId = ? ";
    
    openTime = [self base64encode:openTime];
    
    BOOL result = [_db executeUpdate:sql,openTime,[NSNumber numberWithInteger:fileId]];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    [_db close];
    return result;
}
-(BOOL)updateReceiveFileTimeType:(NSInteger)timeType FileId:(NSInteger)fileId{
    if (![_db open]) return NO;
    NSString *sql = @"UPDATE t_receive SET timeType = ? WHERE fileId = ? ";
    
    BOOL result = [_db executeUpdate:sql,[NSNumber numberWithInteger:timeType],[NSNumber numberWithInteger:fileId]];
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    [_db close];
    return result;
}
-(BOOL)updateReceiveFileLastTime:(NSInteger)fileId lastSeeTime:(NSString *)lastSeeTime{
    if ([lastSeeTime isEqualToString:@""]) {
        return NO;
    }
    if (![_db open]) return NO;
    NSString *sql = @"UPDATE t_receive SET lastSeeTime = ? WHERE fileId = ? ";
    
    lastSeeTime = [self base64encode:lastSeeTime];
    
    BOOL result = [_db executeUpdate:sql,lastSeeTime,[NSNumber numberWithInteger:fileId]];
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    [_db close];
    return result;
}

//更新数据库路径
-(BOOL)updateReceiveFileLocalPath:(NSInteger)fileId newPath:(NSString *)filePath
{
    
    if ([filePath isEqualToString:@""]) {
        return NO;
    }
    if (![_db open]) return NO;
    NSString *sql = @"UPDATE t_receive SET fileUrl = ? WHERE fileId = ? ";
    
    filePath = [self base64encode:filePath];
    
    BOOL result = [_db executeUpdate:sql,filePath,[NSNumber numberWithInteger:fileId]];
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    [_db close];
    return result;
}

-(BOOL)updateReceiveFileIsChangeTime:(NSInteger)fileId isChangeTime:(NSInteger)isChangeTime{
    if (![_db open]) return NO;
    NSString *sql = @"UPDATE t_receive SET isChangeTime = ? WHERE fileId = ? ";
    
    BOOL result = [_db executeUpdate:sql,[NSNumber numberWithInteger:isChangeTime],[NSNumber numberWithInteger:fileId]];
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    [_db close];
    return result;
}
-(BOOL)updateReceiveFileApplyOpen:(NSInteger)ApplyOpen FileId:(NSInteger)fileId
{
    if (![_db open]) return NO;
    NSString *sql = @"UPDATE t_receive SET forbid = ? WHERE fileId = ? ";
    BOOL result = [_db executeUpdate:sql,[NSNumber numberWithInteger:ApplyOpen],[NSNumber numberWithInteger:fileId]];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    [_db close];
    return result;
}


-(BOOL)canOpenAddReadNum:(NSInteger)fileId Logname:(NSString *)logname
{
    if (![_db open]) return NO;
    NSString *sql = @"UPDATE t_receive SET readNum = readNum+1 WHERE fileId = ? and logName=?;";
    
    logname = [self base64encode:logname];
    
    BOOL result = [_db executeUpdate:sql,[NSNumber numberWithInteger:fileId],logname];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    [_db close];
    return result;


}

-(NSMutableArray *)selectReceiveFileByPage:(NSString *)logName Count:(NSInteger)limitCount FromIndex:(NSInteger)fromIndex
{
    if (![_db open]) {
        return nil;
    }
    NSString *sql = @"select * from t_receive  where logName = ? order by sqlId DESC;";
    if (limitCount!=0) {
        sql = [NSString stringWithFormat:@"select * from t_receive Limit %ld Offset %ld  where logName = ? order by sqlId;",(long)limitCount,(long)fromIndex];
    }
    
    logName = [self base64encode:logName];
    
    FMResultSet *rs = [_db executeQuery:sql,logName];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    OutFile *of;
    NSMutableArray *receiveArr = [[NSMutableArray alloc] init];
    while ([rs next]) {
        
        //时间是否限制：NO:不受时间限制 YES受时间限制
        BOOL FreeTime = YES;
        NSString *startDay = [self base64decode:[rs stringForColumn:@"startTime"]];
        NSString *endDay = [self base64decode:[rs stringForColumn:@"endTime"]];
        NSString *receiveDay = [self base64decode:[rs stringForColumn:@"receiveTime"]];
        NSString *makeTime = [self base64decode:[rs stringForColumn:@"makeTime"]];
        
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
        
        //
        NSDate *startTime = [NSDate dateWithStringByDay:startDay];
        NSDate *endTime = [NSDate dateWithStringByDay:endDay];
        NSDate *receiveTime = [NSDate dateWithStringByDay:receiveDay];
        NSDate *fileMakeTime = [NSDate dateWithStringByDay:makeTime];
        NSInteger allDay = [NSDate DayByFromDate:startTime ToDate:endTime];
        NSInteger lastDay = [NSDate LastDayByFromDate:startTime ToDate:endTime];
        
        
        //剩余阅读的次数
        NSInteger lastNum = [rs intForColumn:@"limitNum"] - [rs intForColumn:@"readNum"];
        
        //0未打开，1 已打开 2 终止
        NSInteger open = 0;
        
        //是否禁止查阅 NO:禁止 ,YES :未禁止
        BOOL status = YES;
        if ([rs intForColumn:@"readNum"] > 0) {
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
        NSString *fileUrl = [self base64decode:[rs stringForColumn:@"fileUrl"]];
        
        of = [OutFile initWithReceiveFileId:[rs intForColumn:@"fileId"]
                                   FileName:[self base64decode:[rs stringForColumn:@"fileName"]]
                              FileOwnerNick:[self base64decode:[rs stringForColumn:@"fileOwnerNick"]]
                                    FileUrl:fileUrl
                                    LastNum:lastNum
                                   LimitNum:[rs intForColumn:@"limitNum"]
                                ReceiveTime:receiveTime
                                    LastDay:lastDay
                                     AllDay:allDay
                                  limitTime:[rs intForColumn:@"limitTime"]
                                     Forbid:forbid
                                     Reborn:[rs intForColumn:@"reborn"]
                                       Open:open
                                     Status:status
                                   FreeTime:FreeTime
                                    FreeNum:FreeNum
                                       Note:@""
                                FileOpenDay:[rs intForColumn:@"fileOpenDay"]
                              FileDayRemain:[rs intForColumn:@"fileDayRemain"]
                               FileOpenYear:[rs intForColumn:@"fileOpenYear"]
                             FileYearRemain:[rs intForColumn:@"fileYearRemain"]
                               FileMakeType:[rs intForColumn:@"fileMakeType"]
                               FileMakeTime:fileMakeTime
                                    AppType:[rs intForColumn:@"appType"]
                                      isEye:[rs boolForColumn:@"isEye"]
//                               fileTimeType:[rs intForColumn:@"timeType"]
              ];
        of.fileTimeType = [rs intForColumn:@"timeType"];
        
        [receiveArr addObject:of];
    }
    
    [_db close];
    return receiveArr;
}


-(NSMutableArray *)selectReceiveFileAll:(NSString *)logName
{
    if (![_db open]) {
        return nil;
    }
    NSString *sql = @"select * from t_receive where logName = ? order by sqlId DESC;";
//    NSString *sql = @"select * from t_receive";
     logName = [self base64encode:logName];
    
    FMResultSet *rs = [_db executeQuery:sql,logName];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    OutFile *of;
    NSMutableArray *receiveArr = [[NSMutableArray alloc] init];
    int canopenFile = ERR_OUTLINE_OTHER_ERR;
    while ([rs next]) {
        
        //0未打开，1 已打开 2 终止
        NSInteger open = 0;
        
        //是否禁止查阅 NO:禁止 ,YES :未禁止
        BOOL status = YES;
        
        //次数是否限制：
        BOOL FreeNum = YES;
        if ([rs intForColumn:@"limitNum"]==0) {
            FreeNum = NO;
        }
        //
        //时间是否限制：NO:不受时间限制 YES受时间限制
        BOOL FreeTime = YES;
        
        NSDate *receiveTime ;
        NSDate *fileMakeTime;
        NSInteger lastDay = 0;
        NSInteger allDay = 0;
        
        NSDate *startTime = nil;
        NSDate *endTime = nil;
        
        int FileOpenDay = [rs intForColumn:@"fileOpenDay"];
        int FileDayRemain = [rs intForColumn:@"fileDayRemain"];
        int FileOpenYear = [rs intForColumn:@"fileOpenYear"];
        int FileYearRemain = [rs intForColumn:@"fileYearRemain"];
        int FileMakeType = [rs intForColumn:@"fileMakeType"];
        int FileTimeType = [rs intForColumn:@"timeType"];
        if (FileMakeType == 0)
        {
            if(FileTimeType==4){
                //手动激活文件启用时间段限制
                NSString *startDay = [self base64decode:[rs stringForColumn:@"startTime"]];
                NSString *endDay = [self base64decode:[rs stringForColumn:@"endTime"]];
                startTime = [NSDate dateWithStringByDay:startDay];
                endTime = [NSDate dateWithStringByDay:endDay];
                lastDay = [NSDate LastDayByFromDate:startTime ToDate:endTime];
                if (lastDay<=0) {
                    open = 2;
                    status = NO;
                    canopenFile = ERR_OUTLINE_DAY_ERR;
                }
            }else{
                //手动激活文件
                if (FileOpenDay<=0 && FileOpenDay<=0) {
                    //能看多久不限制
                    FreeTime = NO;
                }
                else
                {
                    //剩余天数
                    if((FileDayRemain<=0 && FileOpenDay > 0)||
                       (FileYearRemain<=0 && FileOpenYear > 0))
                    {
                        open = 2;
                        status = NO;
                        canopenFile = ERR_OUTLINE_DAY_ERR;
                    }
                }

            }
            
            
        }else{
            
            NSString *startDay = [self base64decode:[rs stringForColumn:@"startTime"]];
            NSString *endDay = [self base64decode:[rs stringForColumn:@"endTime"]];
            
            
            
            if([startDay isEqualToString:@"1900-01-01"]
               ||[endDay isEqualToString:@"1900-01-01"]
               ||[startDay isEqualToString:@"1980-01-01"]
               ||[endDay isEqualToString:@"1980-01-01"]
               ||[startDay isEqualToString:@""]
               ||[endDay isEqualToString:@""])
            {
                FreeTime = NO;
            }
            else
            {
                startTime = [NSDate dateWithStringByDay:startDay];
                endTime = [NSDate dateWithStringByDay:endDay];
                allDay = [NSDate DayByFromDate:startTime ToDate:endTime];
                lastDay = [NSDate LastDayByFromDate:startTime ToDate:endTime];
                if (lastDay<=0 && FreeTime) {
                    //当都受限制时
                    open = 2;
                    status = NO;
                    lastDay = 0;
                    canopenFile = ERR_OUTLINE_NUM_ERR;
                }
                
                
                
                //剩余天数等于/小于0天，剩余的阅读次数等于小于0次
                //剩余天数等于/小于0天，剩余的阅读次数等于小于0次
                NSString *tody = [[NSDate date] dateStringByDay];
                NSDate *today = [NSDate dateWithStringByDay:tody];
                BOOL b = ([[today laterDate:startTime] isEqualToDate:startTime] &&![today isEqualToDate:startTime]);
                
                if (b) {
                    open = 2;
                    status = NO;
                    canopenFile = ERR_OUTLINE_DAY_ERR;
                }
            }
        }
        
        NSString *receiveDay = [self base64decode:[rs stringForColumn:@"receiveTime"]];
        NSString *makeTime = [self base64decode:[rs stringForColumn:@"makeTime"]];
        receiveTime = [NSDate dateWithStringByDay:receiveDay];
        fileMakeTime = [NSDate dateWithStringByDay:makeTime];
        //剩余阅读的次数
        NSInteger lastNum = [rs intForColumn:@"limitNum"] - [rs intForColumn:@"readNum"];
        
        if ([rs intForColumn:@"readNum"]>0) {
            open = 1;
        }
        
        //制作者 1：开放，0：终止
        NSInteger forbid = [rs intForColumn:@"forbid"];
        if (forbid==0) {
            open = 2;
            status = NO;
        }
        
        
        if (lastNum<=0&&FreeNum)
        {
            //当都受限制时
            open = 2;
            status = NO;
            lastNum = 0;
            canopenFile = ERR_OUTLINE_NUM_ERR;
        }
        
        if (FileMakeType == 0 && status)
        {
            canopenFile = ERR_OUTLINE_OK | ERR_OK_IS_FEE;
        }
        else
        {
            canopenFile = ERR_OUTLINE_OTHER_ERR; 
        }
        
        NSString *fileUrl = [self base64decode:[rs stringForColumn:@"fileUrl"]];
        of = [OutFile initWithReceiveFileId:[rs intForColumn:@"fileId"]
                                   FileName:[self base64decode:[rs stringForColumn:@"fileName"]]
                              FileOwnerNick:[self base64decode:[rs stringForColumn:@"fileOwnerNick"]]
                                    FileUrl:fileUrl
                                    LastNum:lastNum
                                   LimitNum:[rs intForColumn:@"limitNum"]
                                ReceiveTime:receiveTime
                                    LastDay:lastDay
                                     AllDay:allDay
                                  limitTime:[rs intForColumn:@"limitTime"]
                                     Forbid:forbid
                                     Reborn:[rs intForColumn:@"reborn"]
                                       Open:open
                                     Status:status
                                   FreeTime:FreeTime
                                    FreeNum:FreeNum
                                       Note:@""
                                FileOpenDay:[rs intForColumn:@"fileOpenDay"]
                              FileDayRemain:[rs intForColumn:@"fileDayRemain"]
                               FileOpenYear:[rs intForColumn:@"fileOpenYear"]
                             FileYearRemain:[rs intForColumn:@"fileYearRemain"]
                               FileMakeType:[rs intForColumn:@"fileMakeType"]
                               FileMakeTime:fileMakeTime
                                    AppType:[rs intForColumn:@"appType"]
                                      isEye:[rs boolForColumn:@"isEye"]
//                               fileTimeType:[rs intForColumn:@"timeType"]
              
              ];
        of.readnum = [rs intForColumn:@"readNum"];
        of.fileTimeType = [rs intForColumn:@"timeType"];
        of.filetype = [self base64decode:[rs stringForColumn:@"fileType"]];
        [receiveArr addObject:of];
    }
    
    [_db close];
    return receiveArr;
}


-(NSMutableArray *)selectReceiveSeriesFileAll:(NSInteger)Series
{
    if (![_db open]) {
        return nil;
    }
    NSString *sql = @"select * from t_receive where seriesID = ? order by sqlId DESC;";
    //    NSString *sql = @"select * from t_receive";
    
    FMResultSet *rs = [_db executeQuery:sql,[NSNumber numberWithInteger:Series]];
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    OutFile *of;
    NSMutableArray *receiveArr = [[NSMutableArray alloc] init];
    int canopenFile = ERR_OUTLINE_OTHER_ERR;
    while ([rs next]) {
        
        //0未打开，1 已打开 2 终止
        NSInteger open = 0;
        
        //是否禁止查阅 NO:禁止 ,YES :未禁止
        BOOL status = YES;
        
        //次数是否限制：
        BOOL FreeNum = YES;
        if ([rs intForColumn:@"limitNum"]==0) {
            FreeNum = NO;
        }
        //
        //时间是否限制：NO:不受时间限制 YES受时间限制
        BOOL FreeTime = YES;
        
        NSDate *receiveTime ;
        NSDate *fileMakeTime;
        NSInteger lastDay = 0;
        NSInteger allDay = 0;
        
        NSDate *startTime = nil;
        NSDate *endTime = nil;
        
        int FileOpenDay = [rs intForColumn:@"fileOpenDay"];
        int FileDayRemain = [rs intForColumn:@"fileDayRemain"];
        int FileOpenYear = [rs intForColumn:@"fileOpenYear"];
        int FileYearRemain = [rs intForColumn:@"fileYearRemain"];
        int FileMakeType = [rs intForColumn:@"fileMakeType"];
        int FileTimeType = [rs intForColumn:@"timeType"];
        if (FileMakeType == 0)
        {
            if (FileTimeType == 4) {
                //手动激活文件启用时间段限制
                NSString *startDay = [self base64decode:[rs stringForColumn:@"startTime"]];
                NSString *endDay = [self base64decode:[rs stringForColumn:@"endTime"]];
                startTime = [NSDate dateWithStringByDay:startDay];
                endTime = [NSDate dateWithStringByDay:endDay];
                lastDay = [NSDate LastDayByFromDate:startTime ToDate:endTime];
                if (lastDay<=0) {
                    open = 2;
                    status = NO;
                    canopenFile = ERR_OUTLINE_DAY_ERR;
                }
            }else{
                
                //手动激活文件
                if (FileOpenDay<=0 && FileOpenDay<=0) {
                    //能看多久不限制
                    FreeTime = NO;
                }
                else
                {
                    //剩余天数
                    if((FileDayRemain<=0 && FileOpenDay > 0)||
                       (FileYearRemain<=0 && FileOpenYear > 0))
                    {
                        open = 2;
                        status = NO;
                        canopenFile = ERR_OUTLINE_DAY_ERR;
                    }
                }
            }
            
        }else{
            
            NSString *startDay = [self base64decode:[rs stringForColumn:@"startTime"]];
            NSString *endDay = [self base64decode:[rs stringForColumn:@"endTime"]];
            
            
            
            if([startDay isEqualToString:@"1900-01-01"]
               ||[endDay isEqualToString:@"1900-01-01"]
               ||[startDay isEqualToString:@"1980-01-01"]
               ||[endDay isEqualToString:@"1980-01-01"]
               ||[startDay isEqualToString:@""]
               ||[endDay isEqualToString:@""])
            {
                FreeTime = NO;
            }
            else
            {
                startTime = [NSDate dateWithStringByDay:startDay];
                endTime = [NSDate dateWithStringByDay:endDay];
                allDay = [NSDate DayByFromDate:startTime ToDate:endTime];
                lastDay = [NSDate LastDayByFromDate:startTime ToDate:endTime];
                if (lastDay<=0 && FreeTime) {
                    //当都受限制时
                    open = 2;
                    status = NO;
                    lastDay = 0;
                    canopenFile = ERR_OUTLINE_NUM_ERR;
                }
                
                
                
                //剩余天数等于/小于0天，剩余的阅读次数等于小于0次
                //剩余天数等于/小于0天，剩余的阅读次数等于小于0次
                NSString *tody = [[NSDate date] dateStringByDay];
                NSDate *today = [NSDate dateWithStringByDay:tody];
                BOOL b = ([[today laterDate:startTime] isEqualToDate:startTime] &&![today isEqualToDate:startTime]);
                
                if (b) {
                    open = 2;
                    status = NO;
                    canopenFile = ERR_OUTLINE_DAY_ERR;
                }
            }
        }
        
        NSString *receiveDay = [self base64decode:[rs stringForColumn:@"receiveTime"]];
        NSString *makeTime = [self base64decode:[rs stringForColumn:@"makeTime"]];
        receiveTime = [NSDate dateWithStringByDay:receiveDay];
        fileMakeTime = [NSDate dateWithStringByDay:makeTime];
        //剩余阅读的次数
        NSInteger lastNum = [rs intForColumn:@"limitNum"] - [rs intForColumn:@"readNum"];
        
        if ([rs intForColumn:@"readNum"]>0) {
            open = 1;
        }
        
        //制作者 1：开放，0：终止
        NSInteger forbid = [rs intForColumn:@"forbid"];
        if (forbid==0) {
            open = 2;
            status = NO;
        }
        
        
        if (lastNum<=0&&FreeNum)
        {
            //当都受限制时
            open = 2;
            status = NO;
            lastNum = 0;
            canopenFile = ERR_OUTLINE_NUM_ERR;
        }
        
        if (FileMakeType == 0 && status)
        {
            canopenFile = ERR_OUTLINE_OK | ERR_OK_IS_FEE;
        }
        else
        {
            canopenFile = ERR_OUTLINE_OTHER_ERR;
        }
        
        NSString *fileUrl = [self base64decode:[rs stringForColumn:@"fileUrl"]];
        of = [OutFile initWithReceiveFileId:[rs intForColumn:@"fileId"]
                                   FileName:[self base64decode:[rs stringForColumn:@"fileName"]]
                              FileOwnerNick:[self base64decode:[rs stringForColumn:@"fileOwnerNick"]]
                                    FileUrl:fileUrl
                                    LastNum:lastNum
                                   LimitNum:[rs intForColumn:@"limitNum"]
                                ReceiveTime:receiveTime
                                    LastDay:lastDay
                                     AllDay:allDay
                                  limitTime:[rs intForColumn:@"limitTime"]
                                     Forbid:forbid
                                     Reborn:[rs intForColumn:@"reborn"]
                                       Open:open
                                     Status:status
                                   FreeTime:FreeTime
                                    FreeNum:FreeNum
                                       Note:@""
                                FileOpenDay:[rs intForColumn:@"fileOpenDay"]
                              FileDayRemain:[rs intForColumn:@"fileDayRemain"]
                               FileOpenYear:[rs intForColumn:@"fileOpenYear"]
                             FileYearRemain:[rs intForColumn:@"fileYearRemain"]
                               FileMakeType:[rs intForColumn:@"fileMakeType"]
                               FileMakeTime:fileMakeTime
                                    AppType:[rs intForColumn:@"appType"]
                                      isEye:[rs boolForColumn:@"isEye"]
//                               fileTimeType:[rs intForColumn:@"timeType"]
              
              ];
        of.readnum = [rs intForColumn:@"readNum"];
        of.seriesID = [rs intForColumn:@"seriesID"];
        of.fileTimeType = [rs intForColumn:@"timeType"];
        [receiveArr addObject:of];
    }
    
    [_db close];
    return receiveArr;
}


-(NSInteger)countOfReceiveFile:(NSString *)logName
{
    if (![_db open]) {
        return 0;
    }
    NSInteger count = 0;
    NSString *sql = @"select count(*) from t_receive where logName=?;";
    logName = [self base64encode:logName];
    
    FMResultSet *rs =[_db executeQuery:sql,logName];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    if ([rs next]) {
//        NSLog(@"%@接收文件的总个数：%d",logName,[rs intForColumnIndex:0]);
        count = [rs intForColumnIndex:0];
    }
    [_db close];
    return count;
}


-(BOOL)deleteReceiveFile:(NSInteger)fileId LogName:(NSString *)logname
{
    if (![_db open]) return NO;
    NSString *sql = @"DELETE FROM t_receive WHERE fileId = ? and logName=?;";
    logname = [self base64encode:logname];
    BOOL result = [_db executeUpdate:sql, [NSNumber numberWithInteger:fileId],logname];
	if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    [_db close];
    return result;
}

-(OutFile *)fetchReceiveFileCellByFileId:(NSInteger)receiveFileId LogName:(NSString *)logname
{
    if (![_db open]) {
        return nil;
    }
    NSString *sql = @"select * from t_receive  where fileId = ? and logName=?;";
    logname = [self base64encode:logname];
    FMResultSet *rs = [_db executeQuery:sql,[NSNumber numberWithInteger:receiveFileId],logname];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    int canopenFile = ERR_OUTLINE_OTHER_ERR;
    OutFile *of;
    while ([rs next]) {
        
        
        //0未打开，1 已打开 2 终止
        NSInteger open = 0;
        
        //是否禁止查阅 NO:禁止 ,YES :未禁止
        BOOL status = YES;
        
        //次数是否限制：
        BOOL FreeNum = YES;
        if ([rs intForColumn:@"limitNum"]==0) {
            FreeNum = NO;
        }
        //
        //时间是否限制：NO:不受时间限制 YES受时间限制
        BOOL FreeTime = YES;
        
        NSDate *receiveTime ;
        NSDate *fileMakeTime;
        NSInteger lastDay = 0;
        NSInteger allDay = 0;
        
        NSDate *startTime = nil;
        NSDate *endTime = nil;
        NSDate *lastSee = nil;
        int FileOpenDay = [rs intForColumn:@"fileOpenDay"];
        int FileDayRemain = [rs intForColumn:@"fileDayRemain"];
        int FileOpenYear = [rs intForColumn:@"fileOpenYear"];
        int FileYearRemain = [rs intForColumn:@"fileYearRemain"];
        int FileMakeType = [rs intForColumn:@"fileMakeType"];
        int FileTimeType = [rs intForColumn:@"timeType"];
        int isChangeTime = [rs intForColumn:@"isChangeTime"];
        NSString *startDay = [self base64decode:[rs stringForColumn:@"startTime"]];
        NSString *endDay = [self base64decode:[rs stringForColumn:@"endTime"]];
        NSString *lastSeeTime = [self base64decode:[rs stringForColumn:@"lastSeeTime"]];
        if (FileMakeType == 0)//手动激活文件
        {
            if (FileTimeType==4)
            {
                //手动激活文件启用时间段限制
                FreeTime=YES;
                
                startTime = [NSDate dateWithStringByDay:startDay];
                endTime = [NSDate dateWithStringByDay:endDay];
                allDay = [NSDate DayByFromDate:startTime ToDate:endTime];
                lastDay = [NSDate LastDayByFromDate:startTime ToDate:endTime];
                if (lastDay<=0)
                {
                    open = 2;
                    status = NO;
                    canopenFile = ERR_OUTLINE_DAY_ERR;
                }
            }
            else
            {
                
                //NSString *firstOpenTime = [rs intForColumn:@"firstOpenTime"];
                if (FileOpenDay<=0 && FileOpenDay<=0) {
                    //能看多久不限制
                    FreeTime = NO;
                }
                else
                {
                    //剩余天数
                    if((FileDayRemain<=0 && FileOpenDay > 0)||
                       (FileYearRemain<=0 && FileOpenYear > 0))
                    {
                        open = 2;
                        status = NO;
                        canopenFile = ERR_OUTLINE_DAY_ERR;
                    }
                }
            }
        }
        else
        {
            NSString *startDay = [self base64decode:[rs stringForColumn:@"startTime"]];
            NSString *endDay = [self base64decode:[rs stringForColumn:@"endTime"]];
            
            if([startDay isEqualToString:@"1900-01-01"]
               ||[endDay isEqualToString:@"1900-01-01"]
               ||[startDay isEqualToString:@"1980-01-01"]
               ||[endDay isEqualToString:@"1980-01-01"]
               ||[startDay isEqualToString:@""]
               ||[endDay isEqualToString:@""])
            {
                FreeTime = NO;
            }
            else
            {
                startTime = [NSDate dateWithStringByDay:startDay];
                endTime = [NSDate dateWithStringByDay:endDay];
                allDay = [NSDate DayByFromDate:startTime ToDate:endTime];
                lastDay = [NSDate LastDayByFromDate:startTime ToDate:endTime];
                
                if (lastDay<=0 && FreeTime) {
                    //当都受限制时
                    open = 2;
                    status = NO;
                    lastDay = 0;
                    canopenFile = ERR_OUTLINE_NUM_ERR;
                }
                
                
                
                //剩余天数等于/小于0天，剩余的阅读次数等于小于0次
                //剩余天数等于/小于0天，剩余的阅读次数等于小于0次
                NSString *tody = [[NSDate date] dateStringByDay];
                NSDate *today = [NSDate dateWithStringByDay:tody];
                BOOL b = ([[today laterDate:startTime] isEqualToDate:startTime] &&![today isEqualToDate:startTime]);
                
                if (b)
                {
                    open = 2;
                    status = NO;
                    canopenFile = ERR_OUTLINE_DAY_ERR;
                }
            }
            
        }
        
        NSString *receiveDay = [self base64decode:[rs stringForColumn:@"receiveTime"]];
        NSString *makeTime = [self base64decode:[rs stringForColumn:@"makeTime"]];
        receiveTime = [NSDate dateWithStringByDay:receiveDay];
        fileMakeTime = [NSDate dateWithStringByDay:makeTime];
       
        //剩余阅读的次数
        NSInteger lastNum = [rs intForColumn:@"limitNum"] - [rs intForColumn:@"readNum"];
        
        NSInteger openedNum = [rs intForColumn:@"readNum"];
        
        if ([rs intForColumn:@"readNum"]>0 && open != 2) {
            open = 1;
        }
        
        //制作者 1：开放，0：终止
        NSInteger forbid = [rs intForColumn:@"forbid"];
        if (forbid==0) {
            open = 2;
            status = NO;
        }
        
        
        if (lastNum<=0&&FreeNum)
        {
            //当都受限制时
            open = 2;
            status = NO;
            lastNum = 0;
            canopenFile = ERR_OUTLINE_NUM_ERR;
        }
      
        
       if (FileMakeType == 0 && status)
       {
           canopenFile = ERR_OUTLINE_OK|ERR_OK_IS_FEE;
//           canopenFile |=ERR_OK_IS_FEE ;
       }
        else
        {
            canopenFile = ERR_OUTLINE_OTHER_ERR;
        }

        NSString *fileUrl = [self base64decode:[rs stringForColumn:@"fileUrl"]];
        of = [OutFile initWithReceiveFileId:[rs intForColumn:@"fileId"]
                                   FileName:[self base64decode:[rs stringForColumn:@"fileName"]]
                              FileOwnerNick:[self base64decode:[rs stringForColumn:@"fileOwnerNick"]]
                                    FileUrl:fileUrl
                                    LastNum:lastNum
                                   LimitNum:[rs intForColumn:@"limitNum"]
                                ReceiveTime:receiveTime
                                    LastDay:lastDay
                                     AllDay:allDay
                                  limitTime:[rs intForColumn:@"limitTime"]
                                     Forbid:forbid
                                     Reborn:[rs intForColumn:@"reborn"]
                                       Open:open
                                     Status:status
                                   FreeTime:FreeTime
                                    FreeNum:FreeNum
                                       Note:[self base64decode:[rs stringForColumn:@"note"]]
                                FileOpenDay:FileOpenDay
                              FileDayRemain:FileDayRemain
                               FileOpenYear:FileOpenYear
                             FileYearRemain:FileYearRemain
                               FileMakeType:FileMakeType
                               FileMakeTime:fileMakeTime
                                    AppType:[rs intForColumn:@"appType"]
                                      isEye:[rs boolForColumn:@"isEye"]
              
              ];
        of.readnum = [rs intForColumn:@"readNum"];
        of.canSeeForOutline = canopenFile;
        of.applyId = [rs intForColumn:@"applyId"];
        of.actived = [rs intForColumn:@"actived"];
        of.field1 = [self base64decode:[rs stringForColumn:@"field1"]];
        of.field2 = [self base64decode:[rs stringForColumn:@"field2"]];
        of.field1name = [self base64decode:[rs stringForColumn:@"field1name"]];
        of.field2name = [self base64decode:[rs stringForColumn:@"field2name"]];
        of.hardno = [self base64decode:[rs stringForColumn:@"hardno"]];
        of.selffieldnum = [rs intForColumn:@"SelfFieldNum"];
        of.definechecked = [rs intForColumn:@"DefineChecked"];
        of.waterMarkQQ = [self base64decode:[rs stringForColumn:@"WaterMarkQQ"]];
        of.waterMarkPhone = [self base64decode:[rs stringForColumn:@"WaterMarkPhone"]];
        of.waterMarkEmail = [self base64decode:[rs stringForColumn:@"WaterMarkEmail"]];
        of.fileQQ = [self base64decode:[rs stringForColumn:@"fileQQ"]];
        of.fileEmail = [self base64decode:[rs stringForColumn:@"fileEmail"]];
        of.filePhone = [self base64decode:[rs stringForColumn:@"filePhone"]];
        
        of.starttime = startTime;
        of.endtime = endTime;
        of.readnum = [rs intForColumn:@"readNum"];
        
        of.filetype = [self base64decode:[rs stringForColumn:@"fileType"]];
        
//        NSData *ecodekey = [[rs stringForColumn:@"EncodeKey"] dataUsingEncoding:NSUTF16BigEndianStringEncoding];
//        of.EncodeKey = ecodekey;
        of.EncodeKey = [rs dataForColumn:@"EncodeKey"];
        of.seriesID = [rs intForColumn:@"seriesID"];
        of.fileTimeType=[rs intForColumn:@"timeType"];
    }
    [_db close];
    return of;
}

/**
 *  手动激活文件的属性存入本地数据库汇总
 *
 *  @param receiveFile 文件对象
 *
 *  @return 成功与否
 */
-(BOOL)updateByFileIdReceiveFile:(OutFile *)receiveFile
{
    if (![_db open])return NO;
    
//    NSString *ecodeKey = [[NSString alloc] initWithData:receiveFile.EncodeKey encoding:NSUTF16BigEndianStringEncoding];
    NSString *sql = @"update t_receive set applyId=?,actived=?,field1=?,field2=?,field1name=?,field2name=?,hardno=?,EncodeKey=?,SelfFieldNum=?,DefineChecked=?,WaterMarkQQ = ?,WaterMarkPhone = ?,WaterMarkEmail = ? where fileId=?;";
    
    receiveFile.field1 = [self base64encode:receiveFile.field1];
    receiveFile.field2 = [self base64encode:receiveFile.field2];
    receiveFile.field1name = [self base64encode:receiveFile.field1name];
    receiveFile.field2name = [self base64encode:receiveFile.field2name];
    receiveFile.hardno = [self base64encode:receiveFile.hardno];
    receiveFile.waterMarkQQ = [self base64encode:receiveFile.waterMarkQQ];
    receiveFile.waterMarkPhone = [self base64encode:receiveFile.waterMarkPhone];
    receiveFile.waterMarkEmail = [self base64encode:receiveFile.waterMarkEmail];
    
    BOOL result = [_db executeUpdate:sql,
                   [NSNumber numberWithInteger:receiveFile.applyId],
                   [NSNumber numberWithInteger:receiveFile.actived],
                   receiveFile.field1,
                   receiveFile.field2,
                   receiveFile.field1name,
                   receiveFile.field2name,
                   receiveFile.hardno,
                   //                   ecodeKey,
                   receiveFile.EncodeKey,
                   [NSNumber numberWithInteger:receiveFile.selffieldnum],
                   [NSNumber numberWithInteger:receiveFile.definechecked],
                   receiveFile.waterMarkQQ,
                   receiveFile.waterMarkPhone,
                   receiveFile.waterMarkEmail,
                   [NSNumber numberWithInteger:receiveFile.fileid]];
    if ([_db hadError]) {
        NSLog(@"Err %d:%@",[_db lastErrorCode],[_db lastErrorMessage]);
    }
    [_db close];
    return result;
}

-(BOOL)updateReceiveFileToAddReadNumByFileId:(NSInteger)receiveFileId
{
    if (![_db open]) return NO;
    NSString *sql = @"UPDATE t_receive SET readNum=readNum+1 WHERE fileId = ?;";
    BOOL result = [_db executeUpdate:sql,[NSNumber numberWithInteger:receiveFileId]];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    [_db close];
    return result;

}

-(BOOL)updateReceiveFileToRebornedByFileId:(NSInteger)receiveFileId Status:(NSInteger)status
{
    if (![_db open]) return NO;
    NSString *sql = @"UPDATE t_receive SET reborn=? WHERE fileId = ?;";
    BOOL result = [_db executeUpdate:sql,[NSNumber numberWithInteger:status],[NSNumber numberWithInteger:receiveFileId]];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    [_db close];
    return result;

}

-(BOOL)updateReceiveFileByFileId:(NSInteger)fileId remainDay:(NSInteger)remainday remainYear:(NSInteger)remainyear
{

    if (![_db open]) return NO;
    NSString *sql = @"UPDATE t_receive SET fileDayRemain=?,fileYearRemain = ? WHERE fileId = ?;";
    BOOL result = [_db executeUpdate:sql,
                   [NSNumber numberWithInteger:remainday],
                   [NSNumber numberWithInteger:remainyear],
                   [NSNumber numberWithInteger:fileId]
                   ];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    [_db close];
    return result;
    
    
}




-(NSData *)fetchEncodeKey:(NSInteger)fileId
{
    if (![_db open]) {
        return nil;
    }
    
    NSString *sql = @"select EncodeKey from t_receive where fileId = ?;";
    FMResultSet *rs = [_db executeQuery:sql,[NSNumber numberWithInteger:fileId]];
    
    if ([_db hadError]) {
        NSLog(@"Err %d:%@",[_db lastErrorCode],[_db lastErrorMessage]);
    }
    NSData *encodeKey = nil;
    while ([rs next]) {
        encodeKey = [rs dataForColumn:@"EncodeKey"];
    }
    
    [_db close];
    return encodeKey;
}

-(OutFile *)fetchReceiveFileByFileId:(NSInteger)receiveFileId LogName:(NSString *)logname
{
    if (![_db open]) {
        return nil;
    }
    NSString *sql = @"select * from t_receive  where fileId = ? and logName=?;";
    
    logname = [self base64encode:logname];
    
    FMResultSet *rs = [_db executeQuery:sql,[NSNumber numberWithInteger:receiveFileId],logname];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    OutFile *of;
    while ([rs next]) {
        //
        NSString *fileUrl = [self base64decode:[rs stringForColumn:@"fileUrl"]];
        NSDate *startTime = [NSDate dateWithStringByDay:[self base64decode:[rs stringForColumn:@"startTime"]]];
        NSDate *endTime = [NSDate dateWithStringByDay:[self base64decode:[rs stringForColumn:@"endTime"]]];
        NSDate *receiveTime = [NSDate dateWithStringByDay:[self base64decode:[rs stringForColumn:@"receiveTime"]]];
        NSDate *makeTime = [NSDate dateWithStringByDay:[self base64decode:[rs stringForColumn:@"makeTime"]]];
        of = [OutFile initWithReceiveFileId:[rs intForColumn:@"fileId"]
                                   FileName:[self base64decode:[rs stringForColumn:@"fileName"]]
                                    LogName:[self base64decode:[rs stringForColumn:@"logName"]]
                                  FileOwner:[self base64decode:[rs stringForColumn:@"fileOwner"]]
                              FileOwnerNick:[self base64decode:[rs stringForColumn:@"fileOwnerNick"]]
                                    FileUrl:fileUrl
                                   FileType:[self base64decode:[rs stringForColumn:@"fileType"]]
                                ReceiveTime:receiveTime
                                  StartTime:startTime
                                    EndTime:endTime
                                  LimitTime:[rs intForColumn:@"limitTime"]
                                     Forbid:[rs intForColumn:@"forbid"]
                                   LimitNum:[rs intForColumn:@"limitNum"]
                                    ReadNum:[rs intForColumn:@"readNum"]
                                       Note:[self base64decode:[rs stringForColumn:@"note"]]
                                     Reborn:[rs intForColumn:@"reborn"]
                                     FileQQ:[self base64decode:[rs stringForColumn:@"fileQQ"]]
                                  FileEmail:[self base64decode:[rs stringForColumn:@"fileEmail"]]
                                  FilePhone:[self base64decode:[rs stringForColumn:@"filePhone"]]
                                FileOpenDay:[rs intForColumn:@"fileOpenDay"]
                              FileDayRemain:[rs intForColumn:@"fileDayRemain"]
                               FileOpenYear:[rs intForColumn:@"fileOpenYear"]
                             FileYearRemain:[rs intForColumn:@"fileYearRemain"]
                               FileMakeType:[rs intForColumn:@"fileMakeType"]
                               FileMakeTime:makeTime
                                    AppType:[rs intForColumn:@"appType"]
                                      isEye:[rs boolForColumn:@"isEye"]
              ];
        
        of.applyId = [rs intForColumn:@"applyId"];
        of.actived = [rs intForColumn:@"actived"];
        of.field1 = [self base64decode:[rs stringForColumn:@"field1"]];
        of.field2 = [self base64decode:[rs stringForColumn:@"field2"]];
        of.field1name = [self base64decode:[rs stringForColumn:@"field1name"]];
        of.field2name = [self base64decode:[rs stringForColumn:@"field2name"]];
        of.hardno = [self base64decode:[rs stringForColumn:@"hardno"]];
        of.EncodeKey = [rs dataForColumn:@"EncodeKey"];
        of.waterMarkQQ = [self base64decode:[rs stringForColumn:@"WaterMarkQQ"]];
        of.waterMarkPhone = [self base64decode:[rs stringForColumn:@"WaterMarkPhone"]];
        of.waterMarkEmail = [self base64decode:[rs stringForColumn:@"WaterMarkEmail"]];
        of.seriesID = [rs intForColumn:@"seriesID"];
//        NSLog(@"查看对应表的数据:%@",of); 
        [_db close];
        return of;
    }
    [_db close];
    return nil;
}


-(BOOL)updateRefreshReceiveFile:(OutFile *)receiveFile
{
    
    if (![_db open]) return NO;
    
    NSString *sqlselect = @"select * from t_receive  where fileId = ? ;";
    
    FMResultSet *rsselect = [_db executeQuery:sqlselect,[NSNumber numberWithInteger:receiveFile.fileid]];
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }

    int fileTimeType = 0;
    while ([rsselect next]) {
        fileTimeType = [rsselect intForColumn:@"timeType"];
    }
    
    NSString *starttime = [receiveFile.starttime dateStringByDay];
    NSString *endtime = [receiveFile.endtime dateStringByDay];
    
    starttime = [self base64encode:starttime];
    endtime = [self base64encode:endtime];
    
    BOOL result;
    NSString *sql;
    if(receiveFile.fileMakeType == 0){
    
        if (fileTimeType==4) {
            sql = @"UPDATE t_receive SET forbid=?, limitNum=?,fileDayRemain=?,fileYearRemain=?,isEye=? WHERE fileId=?;";
            result = [_db executeUpdate:sql,
                      [NSNumber numberWithInteger:receiveFile.forbid],
                      [NSNumber numberWithInteger:receiveFile.limitnum],
                      [NSNumber numberWithInteger:receiveFile.fileDayRemain],
                      [NSNumber numberWithInteger:receiveFile.fileYearRemain],
                      [NSNumber numberWithBool:receiveFile.isEye],
                      [NSNumber numberWithInteger:receiveFile.fileid]
                      ];
        }else{
            sql = @"UPDATE t_receive SET startTime=?, endTime =?, forbid=?, limitNum=?,fileDayRemain=?,fileYearRemain=?,isEye=? WHERE fileId=?;";
            result = [_db executeUpdate:sql,
                      starttime,
                      endtime,
                      [NSNumber numberWithInteger:receiveFile.forbid],
                      [NSNumber numberWithInteger:receiveFile.limitnum],
                      [NSNumber numberWithInteger:receiveFile.fileDayRemain],
                      [NSNumber numberWithInteger:receiveFile.fileYearRemain],
                      [NSNumber numberWithBool:receiveFile.isEye],
                      [NSNumber numberWithInteger:receiveFile.fileid]
                      ];
        }
        
    }
    else
    {
        
        sql = @"UPDATE t_receive SET startTime=?, endTime =?, forbid=?, limitNum=?,readNum=?,fileDayRemain=?,fileYearRemain=?,isEye=? WHERE fileId=?;";
        result = [_db executeUpdate:sql,
                  starttime,
                  endtime,
                  [NSNumber numberWithInteger:receiveFile.forbid],
                  [NSNumber numberWithInteger:receiveFile.limitnum],
                  [NSNumber numberWithInteger:receiveFile.readnum],
                  [NSNumber numberWithInteger:receiveFile.fileDayRemain],
                  [NSNumber numberWithInteger:receiveFile.fileYearRemain],
                  [NSNumber numberWithBool:receiveFile.isEye],
                  [NSNumber numberWithInteger:receiveFile.fileid]
                  ];
    }
  
	if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    [_db close];
    return result;

}
-(NSString *)selectReceiveFileURLByFileId:(NSInteger)fileId LogName:(NSString *)logname
{
    if (![_db open]) {
        return nil;
    }
    NSString *fileurl = nil;
    NSString *sql = @"select fileUrl from t_receive  where fileId = ? and logName=?;";
    
    logname = [self base64encode:logname];
    
    FMResultSet *rs =[_db executeQuery:sql,[NSNumber numberWithInteger:fileId],logname];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    while ([rs next]) {
        fileurl = [self base64decode:[rs stringForColumnIndex:0]];
    }
    [_db close];

//    if (fileurl) {
//        fileurl = [[SandboxFile GetHomeDirectoryPath] stringByAppendingString:fileurl];
//    }
    
    return fileurl;
}

-(NSString *)selectReceiveFileFistOpenTimeByFileId:(NSInteger)fileId
{
    if (![_db open]) {
        return nil;
    }
    NSString *fileurl = nil;
    NSString *sql = @"select firstOpenTime from t_receive  where fileId = ?;";
    FMResultSet *rs =[_db executeQuery:sql,[NSNumber numberWithInteger:fileId]];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    while ([rs next]) {
        fileurl = [self base64decode:[rs stringForColumnIndex:0]];
    }
    [_db close];
    return fileurl;
}

-(NSMutableArray *)refreshReceiveFileAll:(NSString *)logName
{
    
    if (![_db open]) return nil;
    if (!logName&&[logName length]!=0) {
        logName = @"";
    }
    NSString *sql = @"select fileId from t_receive where logName = ?";
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

-(NSMutableArray *)refreshReceiveFileByPage:(NSString *)logName  Count:(NSInteger)limitCount FromIndex:(NSInteger)fromIndex
{
    if (![_db open]) return nil;
    if (!logName&&[logName length]!=0) {
        logName = @"";
    }
    NSString *sql = [NSString stringWithFormat:@"select fileId from t_receive where logName = ? Limit %ld Offset %ld ",(long)limitCount,(long)fromIndex];
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

#pragma mark 更新isEye字段值
-(BOOL)updateIsEye:(NSInteger)ReceiveFileId isEye:(BOOL)isEye
{
    if (![_db open]) return NO;
    
    NSInteger isE = 0;  //1:可以看，0，不能看
    if (isEye) {
        isE = 1;
    }
    NSString *sql = @"UPDATE t_receive SET isEye=? WHERE fileId = ?;";
    BOOL result = [_db executeUpdate:sql,[NSNumber numberWithInteger:isE],[NSNumber numberWithInteger:ReceiveFileId]];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    [_db close];
    return result;
}

#pragma mark 获取isEye字段值
-(BOOL)fetchIsEye:(NSInteger)ReceiveFileId
{
    if (![_db open]) {
        return NO;
    }
    BOOL isEye;
    NSString *sql = @"select isEye from t_receive where fileId = ?;";
    FMResultSet *rs =[_db executeQuery:sql,[NSNumber numberWithInteger:ReceiveFileId]];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    while ([rs next]) {
        isEye = [rs boolForColumnIndex:0];
    }
    [_db close];
    return isEye;
    
}


#pragma mark 获取isEye字段值
-(NSInteger)fetchUid:(NSInteger)ReceiveFileId
{
    if (![_db open]) {
        return NO;
    }
    NSInteger uid = 0;
    NSString *sql = @"select Uid from t_receive where fileId = ?;";
    FMResultSet *rs =[_db executeQuery:sql,[NSNumber numberWithInteger:ReceiveFileId]];
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    while ([rs next]) {
        uid = [rs intForColumnIndex:0];
    }
    [_db close];
    return uid;
}
-(NSInteger)fetchSeriesID:(NSInteger)ReceiveFileId{
    if (![_db open]) {
        return NO;
    }
    NSInteger seriesID = 0;
    NSString *sql = @"select seriesID from t_receive where fileId = ?;";
    FMResultSet *rs =[_db executeQuery:sql,[NSNumber numberWithInteger:ReceiveFileId]];
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    while ([rs next]) {
        seriesID = [rs intForColumnIndex:0];
    }
    [_db close];
    return seriesID;
}
-(NSInteger)fetchCountOfUid:(NSInteger)ReceiveUid
{
    if (![_db open]) {
        return 0;
    }
    NSInteger count = 0;
    NSString *sql = @"select count(*) from t_receive where Uid=?;";
    FMResultSet *rs =[_db executeQuery:sql,[NSNumber numberWithInteger:ReceiveUid]];
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    if ([rs next]) {
//        NSLog(@"%d接收文件的总个数：%d",ReceiveUid,[rs intForColumnIndex:0]);
        count = [rs intForColumnIndex:0];
    }
    [_db close];
    return count;
}
/*!
 *  @author shuguang, 15-06-12 15:06:03
 *
 *  @brief  查询接受列表中，同一系列的文件个数
 *
 *  @param seriesID 系列ID
 *
 *  @return 同一系列的文件总条数
 */
-(NSInteger)fetchCountOfSeriesID:(NSInteger)seriesID
{
    if (![_db open]) {
        return 0;
    }
    NSInteger count = 0;
    NSString *sql = @"select count(*) from t_receive where seriesID=?;";
    FMResultSet *rs =[_db executeQuery:sql,[NSNumber numberWithInteger:seriesID]];
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    if ([rs next]) {
        //        NSLog(@"%d接收文件的总个数：%d",ReceiveUid,[rs intForColumnIndex:0]);
        count = [rs intForColumnIndex:0];
    }
    [_db close];
    return count;
}

-(BOOL)updateReceiveUid:(NSInteger)uid fileId:(NSInteger)fileId
{
    if (![_db open]) {
        return NO;
    }
    BOOL result = NO;
    NSString *sql = [NSString stringWithFormat:@"UPDATE t_receive SET Uid = %ld where fileId = %ld;",(long)uid ,(long)fileId];
    result = [_db executeUpdate:sql];
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    
    [_db close];
    return result;
    
}

/*!
 *  @author shuguang, 15-06-10 13:06:45
 *
 *  @brief  更新系列ID
 *
 *  @param SeriesID 文件系列ID
 *  @param fileId   文件ID
 *
 *  @return BOOL是否成功
 */
-(BOOL)updateReceiveSeriesID:(NSInteger)SeriesID fileId:(NSInteger)fileId
{
    if (![_db open]) {
        return NO;
    }
    BOOL result = NO;
    NSString *sql = [NSString stringWithFormat:@"UPDATE t_receive SET seriesID = %ld where fileId = %ld;",(long)SeriesID ,(long)fileId];
    result = [_db executeUpdate:sql];
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    
    [_db close];
    return result;
    
}
-(BOOL)updateReceiveFileForVersionPBB
{
    if (![_db open]) return NO;
    NSString *sql1 = @"select sqlId,fileUrl from t_receive;";
    FMResultSet *rs = [_db executeQuery:sql1];
    if ([_db hadError]) {
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
    
    //    NSMutableArray *sendArr = [[NSMutableArray alloc] init];
    BOOL result = NO;
    while ([rs next]) {
        NSString *fileUrl =[NSString stringWithFormat:@"%@",[self base64decode:[rs stringForColumn:@"fileUrl"]]];
        NSInteger fileId = [rs intForColumn:@"sqlId"];
        NSRange strRag = [fileUrl rangeOfString:@"/Documents"];
        if (strRag.length>2) {
            fileUrl = [fileUrl substringFromIndex:strRag.location];
        }else{
            continue;
        }
        
//        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//        fileUrl = [NSString stringWithFormat:@"%@%@",path,fileUrl];
        fileUrl = [self base64encode:fileUrl];
        NSString *sql = @"UPDATE t_receive SET fileUrl = '%@' where sqlId = %d ;";
        sql = [NSString stringWithFormat:sql,fileUrl,fileId];
        result = [_db executeUpdate:sql];
        if ([_db hadError]) {
            NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        }
        
    }
    NSString *sql = @"UPDATE t_receive SET limitTime = 0 where fileUrl like '%.pyc' ;";
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
    NSString *theSql=[NSString stringWithFormat:@"select * from t_receive"];
    FMResultSet *resultSet=[_db executeQuery:theSql];
    [resultSet setupColumnNames];
    //拼接sql语句中的老字段
    NSEnumerator *columnNames = [resultSet.columnNameToIndexMap keyEnumerator];
    NSString *tempColumnName= nil;
    while ((tempColumnName = [columnNames nextObject]))
    {
        if ([[fieldName lowercaseString] isEqualToString:tempColumnName]) {
//            NSLog(@"t_receive 表，已存在该字段名：%@",tempColumnName);
            return NO;
        }

    }
    

    NSString *sqlstr = [NSString stringWithFormat:@"alter table t_receive add %@ %@",fieldName,fieldtype];
    BOOL result = [_db executeUpdate:sqlstr];
    if ([_db hadError]) {
        NSLog(@"Err %d:%@",[_db lastErrorCode],[_db lastErrorMessage]);
    }
    [_db close];
    return result;
}


-(BOOL)updateReceiveFileMakeType
{
    if (![_db open]) {
        return NO;
    }
    
    BOOL result = NO;
    NSString *sql = @"UPDATE t_receive SET fileMakeType = 1;";
    result = [_db executeUpdate:sql];
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    
    [_db close];
    return result;
    
}
-(BOOL)updateReceiveFileIsEye
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

-(BOOL)updateReceiveFileInSeries
{
    if (![_db open]) {
        return NO;
    }
    BOOL result = NO;
    NSString *sql = @"UPDATE t_receive SET seriesID = 0;";
    result = [_db executeUpdate:sql];
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    
    [_db close];
    return result;
}

//版本升级
-(void)updateTable
{
    
    
    NSUserDefaults *myUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *receiveEncode = [myUserDefaults objectForKey:@"receiveEncode"];
    
    if (![receiveEncode isEqualToString:@"encode"]) {
        [self base64encode];  // 读取数据库用户表里的数据，加密后再存入
        [myUserDefaults setObject:@"encode" forKey:@"receiveEncode"];  // 将接收表设置为加密过
        [myUserDefaults synchronize];
    }
    
//    fileQQ text,fileEmail text,filePhone text,fileOpenDay integer,fileOpenYear integer,fileMakeType integer
    [self intoFieldByName:@"fileQQ" FieldType:@"text"];
    [self intoFieldByName:@"fileEmail" FieldType:@"text"];
    [self intoFieldByName:@"filePhone" FieldType:@"text"];
    [self intoFieldByName:@"fileOpenDay" FieldType:@"integer"];
    [self intoFieldByName:@"fileOpenYear" FieldType:@"integer"];
    [self intoFieldByName:@"fileDayRemain" FieldType:@"integer"];
    [self intoFieldByName:@"fileYearRemain" FieldType:@"integer"];
    [self intoFieldByName:@"makeTime" FieldType:@"TEXT"];
    [self intoFieldByName:@"appType" FieldType:@"text"];
    [self intoFieldByName:@"firstOpenTime" FieldType:@"text"];
    [self intoFieldByName:@"Uid" FieldType:@"integer"];
    
    
    /**
     *  数据库中添加离线文件字段
     applyId integer,field1 text,field2 text,field1name text,field2name text,hardno text,EncodeKey text
     */
    [self intoFieldByName:@"applyId" FieldType:@"integer"];
    [self intoFieldByName:@"actived" FieldType:@"integer"];
    [self intoFieldByName:@"field1" FieldType:@"text"];
    [self intoFieldByName:@"field2" FieldType:@"text"];
    [self intoFieldByName:@"field1name" FieldType:@"text"];
    [self intoFieldByName:@"field2name" FieldType:@"text"];
    [self intoFieldByName:@"hardno" FieldType:@"text"];
    [self intoFieldByName:@"EncodeKey" FieldType:@"blob"];
    [self intoFieldByName:@"SelfFieldNum" FieldType:@"integer"];
    [self intoFieldByName:@"DefineChecked" FieldType:@"integer"];
    [self intoFieldByName:@"WaterMarkQQ" FieldType:@"text"];
    [self intoFieldByName:@"WaterMarkPhone" FieldType:@"text"];
    [self intoFieldByName:@"WaterMarkEmail" FieldType:@"text"];
    
    if ([self intoFieldByName:@"fileMakeType" FieldType:@"integer"]) {
        [self updateReceiveFileMakeType];
    }
    
    if ([self intoFieldByName:@"isEye" FieldType:@" integer"]) {
        [self updateReceiveFileIsEye];
    }

    /*!
     *  @author shuguang, 15-06-10 11:06:20
     *
     *  @brief  想数据库的接受列表中添加系类文件id字段
     */
    if ([self intoFieldByName:@"seriesID" FieldType:@"integer"]) {
        [self updateReceiveFileInSeries];
    }
    if([self fetchCountOfSeriesID:0]>0)
    {
        SeriesModel *series = [[SeriesModel alloc] init];
        series.seriesID = 0;
        [[SeriesDao sharedSeriesDao] insertToSeries:series];

    }
    
    //手动激活文件时间限制 3
    [self intoFieldByName:@"timeType" FieldType:@"interger"];
    //最后阅读时间
    [self intoFieldByName:@"lastSeeTime" FieldType:@"text"];
    [self intoFieldByName:@"isChangeTime" FieldType:@"integer"];
}

/**
 * 读取数据库用户表里的数据，加密后再存入
 */
-(void)base64encode
{
    if (![_db open]) {
        return ;
    }
    
    NSString *theSql=[NSString stringWithFormat:@"select * from t_receive"];
    FMResultSet *resultSet=[_db executeQuery:theSql];
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    
    NSArray *columnNames = @[@"fileName", @"logName",@"fileOwner", @"fileOwnerNick", @"fileUrl", @"fileType", @"receiveTime", @"startTime", @"endTime", @"note", @"fileQQ", @"fileEmail", @"filePhone",@"makeTime", @"firstOpenTime"];

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
        NSString *theSql=[NSString stringWithFormat:@"update t_receive set %@ = '%@' where fileId = %d", columnName, content, fileId];

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
    
    // Get NSString from NSData object in Base64
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];// 将data数据进行base64加密
    
    // Print the Base64 encoded string
//    NSLog(@"receiveEncoded: %@", base64Encoded);
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

-(NSInteger)isCanOpenFileId:(NSInteger)fileId{
    if (![_db open]) {
        return -1;
    }
    NSString *sql = @"select * from t_receive  where fileId = ?;";
    FMResultSet *rs = [_db executeQuery:sql,[NSNumber numberWithInteger:fileId]];
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    int canopenFile = ERR_OK_OR_CANOPEN;
    while ([rs next]) {
        
        
        
        int isChangeTime = [rs intForColumn:@"isChangeTime"];
        NSString *startDay = [self base64decode:[rs stringForColumn:@"startTime"]];
        NSString *endDay = [self base64decode:[rs stringForColumn:@"endTime"]];
        NSString *lastSeeTime = [self base64decode:[rs stringForColumn:@"lastSeeTime"]];
        
        
        NSString *receiveDay = [self base64decode:[rs stringForColumn:@"receiveTime"]];
        NSString *makeTime = [self base64decode:[rs stringForColumn:@"makeTime"]];
        
        
        //剩余阅读的次数
        NSInteger lastNum = [rs intForColumn:@"limitNum"] - [rs intForColumn:@"readNum"];
        
        NSInteger openedNum = [rs intForColumn:@"readNum"];
        NSDate *startTime = [NSDate dateWithStringByDay:startDay];
        NSDate *endTime = [NSDate dateWithStringByDay:endDay];
        NSDate *lasttime=[NSDate dateWithStringByDay:lastSeeTime];
        
        
        NSDate *nowTime = [NSDate getNowDateFromatAnDate:[NSDate date]];
        
        NSDate *lttime=[NSDate getNowDateFromatAnDate:lasttime];
        NSDate *btime=[NSDate getNowDateFromatAnDate:startTime];
        NSDate *etime=[NSDate getNowDateFromatAnDate:[endTime dateByAddingTimeInterval:24*60*60]];
        //NSDate *lstime=
        

//        if ([[nowTime earlierDate:btime] isEqualToDate:nowTime]||[[nowTime earlierDate:etime] isEqualToDate:endTime]) {
//            return canopenFile=ERR_OUTLINE_DAY_ERR;
//        }
        if ([[nowTime earlierDate:lttime] isEqualToDate:nowTime]||isChangeTime == 1) {
            return canopenFile=ERR_OUTLINE_TIME_CHANGED_ERR;
        }
    }

    return canopenFile;
}

@end
