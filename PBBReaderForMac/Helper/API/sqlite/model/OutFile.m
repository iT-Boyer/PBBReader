//
//  file.m
//  PBB
//
//  Created by pengyucheng on 13-11-15.
//  Copyright (c) 2013年 pyc.com.cn. All rights reserved.
//

#import "OutFile.h"

@implementation OutFile

@synthesize sqlid,fileid,filename,filetype,logname,fileowner,sendtime,starttime,endtime,limittime,note,forbid,readnum,limitnum,reborn;

@synthesize lastnum,lasttime,open,status,lastday,allday,freenum,freetime,fileOwnerNick;

@synthesize fileEmail,fileMakeType,fileOpenDay,fileOpenYear,filePhone,fileQQ,fileurl;
@synthesize firstOpenTime,isEye;

@synthesize lastSeeTime,isChangedTime;

-(NSString *)description{

    NSString *stringAll = [NSString stringWithFormat:
@"\
fileid                 = %ld\n\
filename               = %@\n\
filetype               = %@\n\
logName                = %@\n\
fileowner              = %@\n\
sendtime               = %@\n\
starttime              = %@\n\
endtime                = %@\n\
note                   = %@\n\
forbid                 = %ld\n\
readnum                = %ld\n\
limitnum               = %ld\n\
lastnum                = %ld\n\
lasttime               = %ld\n\
lastday                = %ld\n\
allday                 = %ld\n\
freenum                = %d\n\
freetime               = %d\n\
open                   = %ld\n\
status                 = %d\n\
reborn                 = %ld\n\
fileOwnerNick          =%@",
                           
(long)fileid, filename, filetype,logname,fileowner,sendtime,starttime,endtime,note,(long)forbid,(long)readnum, (long)limitnum,(long)lastnum,(long)lasttime,(long)lastday,(long)allday,freenum,freetime,(long)open,status,(long)reborn,fileOwnerNick];
    
    return stringAll;

}

//初始化send
+(id)initWithSendFileId:(NSInteger)newFileid
               FileName:(NSString *)newFileName
                LogName:(NSString *)newLogName
                FileUrl:(NSString *)newFileUrl
               FileType:(NSString *)newFileType
              StartTime:(NSDate *)newStartTime
                EndTime:(NSDate *)newEndTime
              LimitTime:(NSInteger)newLimitTime
                 Forbid:(NSInteger)newForbid
               LimitNum:(NSInteger)newLimitNum
                ReadNum:(NSInteger)newReadNum
                   Note:(NSString *)newNote
               SendTime:(NSDate *)newSendTime
                 FileQQ:(NSString *)newFileQQ
              FileEmail:(NSString *)newFileEmail
              FilePhone:(NSString *)newFilePhone
            FileOpenDay:(NSInteger)newFileOpenDay
           FileOpenYear:(NSInteger)newFileOpenYear
           FileMakeType:(NSInteger)newFileMakeType
     FileBindMachineNum:(NSInteger)newFileBindMachineNum
      FileActivationNum:(NSInteger)newFileActivationNum
               OrderNum:(NSString *)newOrderNum
                  isEye:(BOOL)newIsEye
{
        OutFile *of = [[OutFile alloc] init];
        of.fileid = newFileid;
        of.filename = newFileName;
        of.fileurl = newFileUrl;
        of.filetype = newFileType;
        of.logname = newLogName;
        of.starttime = newStartTime;
        of.endtime = newEndTime;
        of.limittime = newLimitTime;
        of.note = newNote;
        of.forbid = newForbid;
        of.limitnum = newLimitNum;
        of.readnum  = newReadNum;
        of.sendtime = newSendTime;
        of.fileQQ = newFileQQ;
        of.fileEmail = newFileEmail;
        of.filePhone = newFilePhone;
        of.fileOpenDay = newFileOpenDay;
        of.fileOpenYear = newFileOpenYear;
        of.fileMakeType = newFileMakeType;
        of.fileBindMachineNum = newFileBindMachineNum;
        of.fileActivationNum = newFileActivationNum;
        of.orderNum = newOrderNum;
        of.isEye = newIsEye;
        return of;
}


//初始化receive 
+(id)initWithReceiveFileId:(NSInteger)newFileid
                  FileName:(NSString *)newFileName
                   LogName:(NSString *)newLogName
                 FileOwner:(NSString *)newFileOwner
             FileOwnerNick:(NSString *)newFileOwnerNick
                   FileUrl:(NSString *)newFileUrl
                  FileType:(NSString *)newFileType
               ReceiveTime:(NSDate *)newReceiveTime
                 StartTime:(NSDate *)newStartTime
                   EndTime:(NSDate *)newEndTime
                 LimitTime:(NSInteger)newLimitTime
                    Forbid:(NSInteger)newForbid
                  LimitNum:(NSInteger)newLimitNum
                   ReadNum:(NSInteger)newReadNum
                      Note:(NSString *)newNote
                    Reborn:(NSInteger)newReborn
                    FileQQ:(NSString *)newFileQQ
                 FileEmail:(NSString *)newFileEmail
                 FilePhone:(NSString *)newFilePhone
               FileOpenDay:(NSInteger)newFileOpenDay
             FileDayRemain:(NSInteger)newFileDayRemain
              FileOpenYear:(NSInteger)newFileOpenYear
            FileYearRemain:(NSInteger)newFileYearRemain
              FileMakeType:(NSInteger)newFileMakeType
              FileMakeTime:(NSDate *)newFileMakeTime
                   AppType:(NSInteger)newAppType
                     isEye:(BOOL)newIsEye
{
    OutFile *of = [[OutFile alloc] init];
    of.fileid = newFileid;
    of.filename = newFileName;
    of.fileOwnerNick = newFileOwnerNick;
    of.fileurl = newFileUrl;
    of.filetype = newFileType;
    of.recevieTime = newReceiveTime;
    of.logname = newLogName;
    of.fileowner = newFileOwner;
    of.starttime = newStartTime;
    of.endtime = newEndTime;
    of.limittime = newLimitTime;
    of.note = newNote;
    of.forbid = newForbid;
    of.limitnum = newLimitNum;
    of.readnum  = newReadNum;
    of.reborn = newReborn;
    
    of.fileQQ = newFileQQ;
    of.fileEmail = newFileEmail;
    of.filePhone = newFilePhone;
    of.fileOpenDay = newFileOpenDay;
    of.fileOpenYear = newFileOpenYear;
    of.fileMakeType = newFileMakeType;
    of.fileDayRemain = newFileDayRemain;
    of.fileYearRemain = newFileYearRemain;
    of.sendtime = newFileMakeTime;
    of.appType = newAppType;
    of.isEye = newIsEye;
    
    return of;
}


//返回发送列表的单元格信息
+(id)initWithSendFileId:(NSInteger)newFileid
               FileName:(NSString *)newFileName
                FileUrl:(NSString *)newFileUrl
               SendTime:(NSDate *)newSendTime
                LastNum:(NSInteger)newLastNum
               LimitNum:(NSInteger)newLimitNum
                LastDay:(NSInteger)newLastDay
                 AllDay:(NSInteger)newAllDay
              limitTime:(NSInteger)newLimitTime
                 Forbid:(NSInteger)newForbid
                   Open:(NSInteger)newOpen
                 Status:(BOOL)newStatus
               FreeTime:(BOOL)newFreeTime
                FreeNum:(BOOL)newFreeNum
                   Note:(NSString *)newNote
           FileMakeType:(NSInteger)newFileMakeType
     FileBindMachineNum:(NSInteger)newFileBindMachineNum
      FileActivationNum:(NSInteger)newFileActivationNum
                  isEye:(BOOL)newIsEye
{
    OutFile *of=[[OutFile alloc] init];
    of.fileid = newFileid;
    of.filename = newFileName;
    of.fileurl = newFileUrl;
    of.sendtime = newSendTime;
    of.lastnum = newLastNum;
    of.limitnum = newLimitNum;
    of.lastday = newLastDay;
    of.allday = newAllDay;
    of.limittime = newLimitTime;
    of.open = newOpen;
    of.status = newStatus;
    of.forbid = newForbid;
    of.freetime = newFreeTime;
    of.freenum = newFreeNum;
    of.note = newNote;
    of.fileMakeType = newFileMakeType;
    of.fileBindMachineNum = newFileBindMachineNum;
    of.fileActivationNum = newFileActivationNum;
    of.isEye = newIsEye;
    
    return of;
}

//返回接收列表的单元格信息
+(id)initWithReceiveFileId:(NSInteger)newFileid
                  FileName:(NSString *)newFileName
             FileOwnerNick:(NSString *)newFileOwnerNick
                   FileUrl:(NSString *)newFileUrl
                   LastNum:(NSInteger)newLastNum
                  LimitNum:(NSInteger)newLimitNum
               ReceiveTime:(NSDate *)newReceiveTime
                   LastDay:(NSInteger)newLastDay
                    AllDay:(NSInteger)newAllDay
                 limitTime:(NSInteger)newLimitTime
                    Forbid:(NSInteger)newForbid
                    Reborn:(NSInteger)newReborn
                      Open:(NSInteger)newOpen
                    Status:(BOOL)newStatus
                  FreeTime:(BOOL)newFreeTime
                   FreeNum:(BOOL)newFreeNum
                      Note:(NSString *)newNote
               FileOpenDay:(NSInteger)newFileOpenDay
             FileDayRemain:(NSInteger)newFileDayRemain
              FileOpenYear:(NSInteger)newFileOpenYear
            FileYearRemain:(NSInteger)newFileYearRemain
              FileMakeType:(NSInteger)newFileMakeType
              FileMakeTime:(NSDate *)newFileMakeTime
                   AppType:(NSInteger)newAppType
                     isEye:(BOOL)newIsEye
                    
{
    OutFile *of=[[OutFile alloc] init];
    of.fileid = newFileid;
    of.filename = newFileName;
    of.fileOwnerNick = newFileOwnerNick;
    of.fileurl = newFileUrl;
    of.lastnum = newLastNum;
    of.limitnum = newLimitNum;
    of.recevieTime = newReceiveTime;
    of.lastday = newLastDay;
    of.allday = newAllDay;
    of.limittime = newLimitTime;
    of.forbid = newForbid;
    of.reborn = newReborn;
    of.open = newOpen;
    of.status = newStatus;
    of.freetime = newFreeTime;
    of.freenum = newFreeNum;
    of.note = newNote;
    of.fileOpenDay = newFileOpenDay;
    of.fileOpenYear = newFileOpenYear;
    of.fileMakeType = newFileMakeType;
    of.fileDayRemain = newFileDayRemain;
    of.fileYearRemain = newFileYearRemain;
    of.sendtime = newFileMakeTime;
    of.appType = newAppType;
    of.isEye = newIsEye;
    
    return of;
}

+(OutFile *)initWithReceiveFileId:(NSInteger)newFileid
                          ApplyId:(NSInteger)newApplyId
                          actived:(NSInteger)newActived
                           field1:(NSString *)newField1
                           field2:(NSString *)newField2
                       field1name:(NSString *)newField1name
                       field2name:(NSString *)newField2name
                           hardno:(NSString *)newHardno
                        EncodeKey:(NSData *)newEncodeKey
                     SelfFieldNum:(NSInteger)newSelfFieldNum
                    DefineChecked:(NSInteger)newDefineChecked
                      WaterMarkQQ:(NSString *)newWaterMarkQQ
                   WaterMarkPhone:(NSString *)newWaterMarkPhone
                   WaterMarkEmail:(NSString *)newWaterMarkEmail
{
    OutFile *of = [[OutFile alloc] init];
    of.fileid = newFileid;
    of.applyId = newApplyId;
    of.actived = newActived;
    of.field1 = newField1;
    of.field2 = newField2;
    of.field1name = newField1name;
    of.field2name = newField2name;
    of.hardno = newHardno;
    of.EncodeKey = newEncodeKey;
    of.selffieldnum = newSelfFieldNum;
    of.definechecked = newDefineChecked;
    of.waterMarkQQ = newWaterMarkQQ;
    of.waterMarkPhone = newWaterMarkPhone;
    of.waterMarkEmail = newWaterMarkEmail;
    return of;
}
@end
