//
//  file.h
//  PBB
//
//  Created by pengyucheng on 13-11-15.
//  Copyright (c) 2013年 pyc.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OutFile : NSObject

//数据库存储ID
@property(assign,nonatomic)NSInteger sqlid;
//服务器放回的文件ID
@property(assign,nonatomic)NSInteger fileid;
//文件名
@property(copy,nonatomic)NSString *filename;
//文件的本地存储路径
@property(copy,nonatomic)NSString *fileurl;
//文件类型（图片，视频，文档等）暂时以文件后缀代替
@property(copy,nonatomic)NSString *filetype;
//文件所属的用户名
@property(copy,nonatomic)NSString *fileowner;
//账号
@property(copy,nonatomic)NSString *logname;

//起始限制时间
@property(copy,nonatomic)NSDate *starttime;
//接受限制时间
@property(copy,nonatomic)NSDate *endtime;
//限制查阅秒数
@property(assign,nonatomic)NSInteger limittime;

//是否终止 制作者 1：开放，0：终止
@property(assign,nonatomic)NSInteger forbid;
//限制阅读的总次数
@property(assign,nonatomic)NSInteger limitnum;
//已读次数
@property(assign,nonatomic)NSInteger readnum;

//文件备注
@property(copy,nonatomic)NSString *note;

//制作者Nick
@property(nonatomic,copy)NSString *fileOwnerNick;
//列表信息字段
//剩余可读次数
@property(assign,nonatomic)NSInteger lastnum;
//剩余可读天数
@property(assign,nonatomic)NSInteger lasttime;
//剩余可读天数
@property(assign,nonatomic)NSInteger lastday;
//总共可读天数
@property(assign,nonatomic)NSInteger allday;
//文件的打开状态 0未打开，1 已打开 2 终止
@property(assign,nonatomic)NSInteger open;
//是否禁止查阅 NO:禁止 ,YES :未禁止
@property(assign,nonatomic)BOOL status;
//手动激活文件，当前权限状态
@property(assign,nonatomic)int canSeeForOutline;

////天数是否限制：NO：不限制 ，YES：限制
@property(assign,nonatomic)BOOL freetime;
//次数是否限制： NO：不限制 ，YES：限制
@property(assign,nonatomic)BOOL freenum;

// qq:@"1" email:@"a" phone:@"a" maxOpenday:0 maxOpenyear:0 makeType:1
@property(copy,nonatomic)NSString *fileQQ;
@property(copy,nonatomic)NSString *fileEmail;
@property(copy,nonatomic)NSString *filePhone;
@property(assign,nonatomic)NSInteger fileOpenDay;      //总天数
@property(assign,nonatomic)NSInteger fileOpenYear;     //总年数
@property(assign,nonatomic)NSInteger fileDayRemain;   //剩余天数
@property(assign,nonatomic)NSInteger fileYearRemain;  //剩余年数
@property(assign,nonatomic)NSInteger fileMakeType;  //1：自由传播 0：手动激活

@property(assign,nonatomic)NSInteger fileBindMachineNum;
@property(assign,nonatomic)NSInteger fileActivationNum;

@property(nonatomic,strong)NSString *firstOpenTime;

@property(assign,nonatomic)BOOL isEye;  //买家是否能看到限制条件，1：能看，0：不可见

@property(assign,nonatomic)NSInteger fileTimeType; //fileTimeType=4时，表示采用时间段限制条件

//send
@property(copy,nonatomic)NSDate *sendtime;   //相当于 接收表中的makeTime
@property(nonatomic,strong)NSString *orderNum;

//receive
@property(assign,nonatomic)NSInteger reborn; //0:未使用  1:已使用过
@property(strong,nonatomic)NSDate *recevieTime; //相当于 接收表中的firstOpenTime
@property(nonatomic,assign)NSInteger appType;

//
//applyId integer,actived integer,field1 text,field2 text,field1name text,field2name text,hardno text,EncodeKey text)
/**
 *  离线文件结构体属性
 */
@property(assign,nonatomic)NSInteger applyId;
@property(assign,nonatomic)NSInteger actived;
@property(strong,nonatomic)NSString *field1;
@property(strong,nonatomic)NSString *field2;
@property(strong,nonatomic)NSString *field1name;
@property(strong,nonatomic)NSString *field2name;
@property(strong,nonatomic)NSString *hardno;
@property(strong,nonatomic)NSData *EncodeKey;
@property(nonatomic,assign)NSInteger selffieldnum;//自定义字段数
@property(nonatomic,assign)NSInteger definechecked;//自定义字段时选择的QQ、EMAIL、PHONE结果

@property(strong,nonatomic)NSString *waterMarkQQ;
@property(strong,nonatomic)NSString *waterMarkPhone;
@property(strong,nonatomic)NSString *waterMarkEmail;
@property(assign,nonatomic)NSInteger seriesID;
@property(assign,nonatomic)NSDate   *lastSeeTime;
@property(assign,nonatomic)NSInteger isChangedTime;
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
                  isEye:(BOOL)newIsEye;

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
                     isEye:(BOOL)newIsEye;

//发送列表单元格属性组
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
                  isEye:(BOOL)newIsEye;


//接收列表单元格属性组
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
                     isEye:(BOOL)newIsEye;


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
                   WaterMarkEmail:(NSString *)newWaterMarkEmail;


@end
