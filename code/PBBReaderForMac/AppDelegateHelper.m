//
//  AppDelegateHelper.m
//  PBBReaderForMac
//
//  Created by pengyucheng on 16/6/2.
//  Copyright © 2016年 recomend. All rights reserved.
//

#import "AppDelegateHelper.h"
#import "ReceiveFileDao.h"
#import "AdvertisingView.h"
#import "SeriesDao.h"
#import "LookMedia.h"
#import "ToolString.h"
#import "userDao.h"
#import <Cocoa/Cocoa.h>
#import "VerificationCodeDao.h"
#import "PlayerLoader.h"

//#if DEVELOPMENT
//#import "PBBReaderForMac-Swift.h"
//
//#else
//
//#endif
#import "PBBReader-Swift.h"
#import "MBProgressHUD.h"
#import "PlayerWindow.h"
#import "PBBLogSDK.h"
#import <MuPDFFramework/MuPDFFramework.h>

@implementation AppDelegateHelper
{
    PycFile *_fileManager;
    PycFile *fileM;
    int fileID;
    NSString *filePath;
    BOOL isReceiveFileExist;
    OutFile *outFile;
    PycFile *seePycFile;
    int returnValue;
    AdvertisingView *custormActivityView;
    NSInteger applyNum; //自动激活次数
    
    //绑定手机
    BOOL _userPhone;
    
    NSInteger bOpenInCome;
    
    //申请
    NSString *applyflag;
    
    NSAlert *alertShow;
    
    MBProgressHUD *hud;
    NSWindow *keyWindow;
    BOOL isLoading;
    NSString *logname;
}
singleton_implementation(AppDelegateHelper);

-(void)loadVideoWithLocalFiles:(NSString *)openFilePath
{
    //
    NSString *waterPath = [[NSBundle mainBundle] pathForResource:@"water" ofType:@"xml"];
    [[PlayerLoader sharedInstance] loadVideoWithLocalFiles:@[openFilePath,waterPath]];
}

-(BOOL)openURLOfPycFileByLaunchedApp:(NSString *)openURL
{
    if(![openURL hasSuffix:@"pbb"])
    {
        LookMedia *look = [[LookMedia alloc] init];
        look.receviveFileId = @"1";
        [look lookMedia:openURL];
        [[[PBBLogModel alloc] initWithType:LogINFO inApp:APPReaderMac desc:@"明文浏览"] sendToServer];
        return NO;
    }
    _fileManager = [[PycFile alloc] init];
    _fileManager.delegate = self;
    filePath = openURL;
    fileID = [_fileManager getAttributePycFileId:filePath];
    if (fileID==0)
    {
        [self setAlertView:@"读取文件失败。可能错误原因：文件下载不完整，请重新下载！"];
        return YES;
    }
    else if(fileID==3)
    {
        [self setAlertView:@"应用开启沙盒保护机制，无权限阅读该目录文件，请移动到下载目录重新查看！"];
        return YES;
    }
    //更新数据库中的本地路径
    [[[PBBLogModel alloc] initWithType:LogINFO inApp:APPReaderMac desc:@"查看文件时，更新数据库中的本地路径"] sendToServer];
    [[ReceiveFileDao sharedReceiveFileDao] updateReceiveFileLocalPath:fileID newPath:filePath];
    // 判断已接受数据库是否存在
    NSInteger openedNum = 0;
    BOOL OutLine = NO;
    logname = [[userDao shareduserDao] getLogName];
    // 判断已接受数据库是否存在
    isReceiveFileExist = [[ReceiveFileDao sharedReceiveFileDao] findFileById:fileID forLogName:logname];
    if (isReceiveFileExist)
    {
        //在接收列表存在
        outFile = [[ReceiveFileDao sharedReceiveFileDao] fetchReceiveFileCellByFileId:fileID LogName:logname];
        openedNum = outFile.readnum;
        
        if (outFile.fileMakeType == 0)
        {
            OutLine = YES;
        }
    }
    else
    {
        outFile = nil;
    }

    if (_isShowAvert)
    {
        //当手机号申请激活后，不显示广告
        [self show];
        [[[PBBLogModel alloc] initWithType:LogINFO inApp:APPReaderMac desc:@"手机号申请激活后，不显示广告"] sendToServer];
    }
    else
    {
        //custormActivityView = (AdvertisingView *)[[NSWindowController alloc] initWithWindowNibName:@"AdvertisingView"];
        //TODO: 加载广告
        if(!custormActivityView)
        {
            [self setKeyWindow:false];
            if (keyWindow)
            {
                NSArray *array;
                NSNib *nib = [[NSNib alloc] initWithNibNamed:@"AdvertisingViewOSX" bundle:nil];
                [nib instantiateWithOwner:self topLevelObjects:&array];
                for (int i = 0; i < array.count; i++)
                {
                    //
                    id obj = array[i];
                    if ([obj isKindOfClass:[AdvertisingView class]])
                    {
                        custormActivityView = (AdvertisingView *)array[i];
                        [custormActivityView startLoadingWindow:keyWindow
                                                         fileID:fileID
                                                      isOutLine:OutLine];
                    }
                }
            }
        }
        else
        {
            [self setKeyWindow:false];
            [custormActivityView startLoadingWindow:keyWindow
                                             fileID:fileID
                                          isOutLine:OutLine];
        }
    }
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isOffLine = FALSE;
        _fileManager.receiveFile = outFile;
        returnValue = 0;
        NSString *result =[_fileManager seePycFile2:filePath
                                        forUser:logname
                                        pbbFile:openURL
                                        phoneNo:_phoneNo
                                      messageID:_messageID
                                      isOffLine:&isOffLine
                                  FileOpenedNum:openedNum];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL outLine = NO;
            if (isReceiveFileExist
                && isOffLine
                && [[ReceiveFileDao sharedReceiveFileDao] fetchUid:fileID]) {
                //离线且广告已缓存
                outLine = YES;
            }
            if (![result isEqualToString:@"0"]) {
                //              applyNum=0;
                returnValue = result.intValue;
                if (custormActivityView.advertime<3) {
                    ////判断，广告加载完成后，再延迟3秒钟
                    [self performSelector:@selector(didFinishSeePycFileForUser) withObject:nil afterDelay:3.0f];
                }else{
                    [self didFinishSeePycFileForUser];
                }
            }
        });
    });
    return YES;
}

#pragma mark - PycFile
#pragma mark 查看文件
- (void)PycFile:(PycFile *)fileObject didFinishSeePycFileForUser:(MAKEPYCRECEIVE *)receiveData
{
    _isShowAvert = false;
    seePycFile = fileObject;
    returnValue = receiveData->returnValue;
    
    if (custormActivityView.advertime<3)
    {
        ////判断，广告加载完成后，再延迟3秒钟
        [self performSelector:@selector(didFinishSeePycFileForUser) withObject:nil afterDelay:3.0f];
    }
    else
    {
        [self didFinishSeePycFileForUser];
    }
}

- (void)didFinishSeePycFileForUser
{
    isReceiveFileExist = [[ReceiveFileDao sharedReceiveFileDao] findFileById:fileID forLogName:logname];
    
    if(returnValue == -1)
    {
        [custormActivityView removeFromSuperview];
        [self setAlertView:@"数据传输错误，请重试!"];
        return;
    }
    if(returnValue & ERR_NEED_UPDATE)
    {
        applyNum =0;
        [custormActivityView removeFromSuperview];
        [self setAlertView:@"当前版本过低，需要升级哦!"];
        return;
    }
    if (returnValue == 6) {
        //
        [self setAlertView:@"该文件不支持离线阅读！"];
        return;
    }
    NSString *fileExt = [seePycFile.fileExtentionWithOutDot lowercaseString];
    if (![fileExt fileIsTypeOfVideo] && ![fileExt isEqualToString:@"pdf"])
    {
        [self setAlertView:[NSString stringWithFormat:@"不支持该(%@)格式文件!",seePycFile.fileExtentionWithOutDot]];
        return;
    }
    
    
    //更新接收查看文件
    NSDate *startDay = [NSDate dateWithStringByDay:seePycFile.startDay];
    NSDate *endDay = [NSDate dateWithStringByDay:seePycFile.endDay];
    
    NSDate *receiveDay = [NSDate dateWithStringByDay:seePycFile.firstSeeTime];
    NSDate *makeTime = [NSDate dateWithStringByDay:seePycFile.makeTime];
    
    
    // MakeType:returnValue & ERR_FREE?1:0
    NSInteger makeType = returnValue & ERR_FREE?1:0;
    NSInteger forbid = 0;
    NSInteger isEye = 1;
    NSString *qq = seePycFile.QQ;
    //自由传播
    if (makeType == 1) {
        isEye = 1;
        forbid = seePycFile.iCanOpen;
    }else{
        //手动激活， 1，已激活，0:未激活
        forbid = 0;
        isEye = seePycFile.canseeCondition==1;
    }
    
    //能看且是手动激活
    if((returnValue & ERR_OK_OR_CANOPEN)&&(returnValue & ERR_OK_IS_FEE) && isReceiveFileExist)
    {
        qq = @"#cansee";
    }
    
    
    //第一open In 本地没有该文件时更新
    if (!isReceiveFileExist)
    {
        [[[PBBLogModel alloc] initWithType:LogINFO inApp:APPReaderMac desc:@"存储到SQLite 接收文件"] sendToServer];
        //存储到SQLite 接收文件
        [[ReceiveFileDao sharedReceiveFileDao] saveReceiveFile:[OutFile initWithReceiveFileId:fileID//seePycFile.fileID
                                                                                     FileName:[seePycFile.filePycNameFromServer stringByDeletingPathExtension]
                                                                                      LogName:seePycFile.fileSeeLogname
                                                                                    FileOwner:seePycFile.fileOwner
                                                                                FileOwnerNick:seePycFile.nickname
                                                                                      FileUrl:filePath
                                                                                     FileType:seePycFile.fileExtentionWithOutDot
                                                                                  ReceiveTime:receiveDay
                                                                                    StartTime:startDay
                                                                                      EndTime:endDay
                                                                                    LimitTime:seePycFile.openTimeLong
                                                                                       Forbid:forbid
                                                                                     LimitNum:seePycFile.AllowOpenmaxNum
                                                                                      ReadNum:seePycFile.haveOpenedNum
                                                                                         Note:seePycFile.remark
                                                                                       Reborn:0
                                                                                       FileQQ:qq
                                                                                    FileEmail:seePycFile.email
                                                                                    FilePhone:seePycFile.phone
                                                                                  FileOpenDay:seePycFile.openDay
                                                                                FileDayRemain:seePycFile.dayRemain
                                                                                 FileOpenYear:seePycFile.openYear
                                                                               FileYearRemain:seePycFile.yearRemain
                                                                                 FileMakeType:makeType
                                                                                 FileMakeTime:makeTime
                                                                                      AppType:seePycFile.makeFrom
                                                                                        isEye:isEye]];
        [[ReceiveFileDao sharedReceiveFileDao] updateReceiveFileFirstOpenTime:seePycFile.firstSeeTime FileId:fileID];//seePycFile.fileID];
        
    }
    else
    {
        [[[PBBLogModel alloc] initWithType:LogINFO inApp:APPReaderMac desc:@"接收文件插入到SQLite"] sendToServer];
        [[ReceiveFileDao sharedReceiveFileDao] updateReceiveFile:[OutFile initWithReceiveFileId:fileID//seePycFile.fileID
                                                                                       FileName:[seePycFile.filePycNameFromServer stringByDeletingPathExtension]
                                                                                        LogName:seePycFile.fileSeeLogname
                                                                                      FileOwner:seePycFile.fileOwner
                                                                                  FileOwnerNick:seePycFile.nickname
                                                                                        FileUrl:filePath
                                                                                       FileType:seePycFile.fileExtentionWithOutDot
                                                                                    ReceiveTime:receiveDay
                                                                                      StartTime:startDay
                                                                                        EndTime:endDay
                                                                                      LimitTime:seePycFile.openTimeLong
                                                                                         Forbid:forbid
                                                                                       LimitNum:seePycFile.AllowOpenmaxNum
                                                                                        ReadNum:seePycFile.haveOpenedNum
                                                                                           Note:seePycFile.remark
                                                                                         Reborn:0
                                                                                         FileQQ:qq
                                                                                      FileEmail:seePycFile.email
                                                                                      FilePhone:seePycFile.phone
                                                                                    FileOpenDay:seePycFile.openDay
                                                                                  FileDayRemain:seePycFile.dayRemain
                                                                                   FileOpenYear:seePycFile.openYear
                                                                                 FileYearRemain:seePycFile.yearRemain
                                                                                   FileMakeType:makeType
                                                                                   FileMakeTime:makeTime
                                                                                        AppType:seePycFile.makeFrom
                                                                                          isEye:isEye]];
        [[ReceiveFileDao sharedReceiveFileDao] updateReceiveFileFirstOpenTime:seePycFile.firstSeeTime FileId:fileID];//seePycFile.fileID];
        
    }
    
    /*!
     *  @author shuguang, 15-06-10 15:06:27
     *
     *  @brief 将以前的离线文件信息，转移至本地数据库中
     *
     */
    if((returnValue & ERR_OK_OR_CANOPEN) && (returnValue & ERR_OK_IS_FEE))
    {
        [[[PBBLogModel alloc] initWithType:LogINFO inApp:APPReaderMac desc:@"将以前的离线文件信息，转移至本地数据库中"] sendToServer];
        [[ReceiveFileDao sharedReceiveFileDao] updateByFileIdReceiveFile:[OutFile initWithReceiveFileId:fileID//seePycFile.fileID
                                                                                                ApplyId:seePycFile.applyId
                                                                                                actived:seePycFile.activeNum
                                                                                                 field1:seePycFile.field1
                                                                                                 field2:seePycFile.field2
                                                                                             field1name:seePycFile.fild1name
                                                                                             field2name:seePycFile.fild2name
                                                                                                 hardno:seePycFile.hardno
                                                                                              EncodeKey:seePycFile.fileSecretkeyR1
                                                                                           SelfFieldNum:seePycFile.selffieldnum
                                                                                          DefineChecked:seePycFile.definechecked
                                                                                            WaterMarkQQ:seePycFile.QQ
                                                                                         WaterMarkPhone:seePycFile.phone
                                                                                         WaterMarkEmail:seePycFile.email]];
    }
    
    //将系列ID和文件关联
    [[ReceiveFileDao sharedReceiveFileDao] updateReceiveSeriesID:seePycFile.seriesID fileId:fileID];//seePycFile.fileID];
    [[ReceiveFileDao sharedReceiveFileDao] updateReceiveFileTimeType:seePycFile.timeType FileId:fileID];
    //TODO:插入系列表信息
    SeriesModel *series = [[SeriesModel alloc] init];
    series.seriesID = seePycFile.seriesID;
    series.seriesFileNum = seePycFile.seriesFileNums;
    series.seriesName = [seePycFile.seriesName stringByReplacingOccurrencesOfString:@"\0"withString:@""];//seePycFile.seriesName;
    series.seriesAuthor = seePycFile.nickname;
    series.seriesClass = makeType;
    [[SeriesDao sharedSeriesDao] insertToSeries:series];

    //查看广告后，保存Uid
    if (custormActivityView.uid != -1) {
        [[ReceiveFileDao sharedReceiveFileDao] updateReceiveUid:custormActivityView.uid fileId:fileID];//seePycFile.fileID];
    }
    
    //can open
    if(returnValue & ERR_OK_OR_CANOPEN)
    {
        //能看状态
        [[[PBBLogModel alloc] initWithType:LogDEBUG inApp:APPReaderMac desc:@"can open"] sendToServer];
        [custormActivityView removeFromSuperview];
        applyNum =0;
        if (returnValue & ERR_OK_IS_FEE)
        {
            [[[PBBLogModel alloc] initWithType:LogDEBUG inApp:APPReaderMac desc:@"开始阅读文件"] sendToServer];
            [self hide:-0.5];
            //重生0：未使用 1：已使用
            [[ReceiveFileDao sharedReceiveFileDao] updateReceiveFileToRebornedByFileId:fileID Status:0];//seePycFile.fileID Status:0];
            [[ReceiveFileDao sharedReceiveFileDao] updateReceiveFileApplyOpen:1 FileId:fileID];//seePycFile.fileID];
            
            LookMedia *look = [[LookMedia alloc] init];
            look.urlImagePath = seePycFile.fileName;
            look.limitTime = seePycFile.openTimeLong;
            look.bOpenInCome = 1;
            look.receviveFileId = [NSString stringWithFormat:@"%ld",(long)fileID];//seePycFile.fileID];
            //水印
            look.waterMark = [self waterMark:seePycFile];
            look.openinfoid = seePycFile.openinfoid;
            look.fileSecretkeyR1 = seePycFile.fileSecretkeyR1;
            look.EncryptedLen = seePycFile.encryptedLen;
            look.fileSize = seePycFile.fileSize;
            look.offset = seePycFile.offset;
            
            look.imageData = seePycFile.imageData;
            [look lookMedia:seePycFile.filePycName];
        }
        else if(returnValue & ERR_FEE_SALER)
        {
            //有独享条件可以申请，目前用不到 ，自由传播转为手动激活的情况
            
        }
        else
        {
            [[[PBBLogModel alloc] initWithType:LogDEBUG inApp:APPReaderMac desc:@"自由传播"] sendToServer];
            [self hide:-0.5];
            //自由传播
            //重生0：未使用 1：已使用
            [[ReceiveFileDao sharedReceiveFileDao] updateReceiveFileToRebornedByFileId:fileID Status:0];//seePycFile.fileID
            LookMedia *look = [[LookMedia alloc] init];
            look.urlImagePath = seePycFile.fileName;
            look.limitTime = seePycFile.openTimeLong;
            look.bOpenInCome = 1;
            look.receviveFileId = [NSString stringWithFormat:@"%ld",(long)fileID];//seePycFile.fileID];
            //自由传播不需要水印
            //look.waterMark = [self waterMark:seePycFile];
            look.openinfoid = seePycFile.openinfoid;
            look.fileSecretkeyR1 = seePycFile.fileSecretkeyR1;
            look.EncryptedLen = seePycFile.encryptedLen;
            look.fileSize = seePycFile.fileSize;
            look.offset = seePycFile.offset;
            
            look.imageData = seePycFile.imageData;
            [look lookMedia:seePycFile.filePycName];
        }
    }
    else if (seePycFile.iResultIsOffLine)
    {
        //离线不能看状态
        applyNum =0;
        [custormActivityView removeFromSuperview];
        
        if (returnValue & ERR_OUTLINE_HDID_ERR)
        {
            //硬件标识不对
            /**
             1、  检查到不同设备，提示：不能阅读！与原阅读设备不符！是否在此设备上申请阅读？
             2、  界面上出现【是】、【否】按钮，点击【否】，转4
             3、  点击【是】，清除离线结构中设置的值，提示：再次打开后进行申请。（手机端提示文字：再次打开/阅读时进行申请）
             4、  结束
             */
            //            MyBlockAlertView *alert = [[MyBlockAlertView alloc] initWithTitle:nil
            //                                                                      message:@"不能阅读！与原阅读设备不符！是否在此设备上申请阅读？"
            //                                                            cancelButtonTitle:@"否" otherButtonTitles:@"是"
            //                                                                  ButtonBlock:^(NSInteger i) {
            //
            //                                                                      if (i == 0) {
            //                                                                          [[ReceiveFileDao sharedReceiveFileDao]updateReceiveFileApplyOpen:0 FileId:_fileID];//_fileObject.fileID];
            //                                                                      }
            //
            //                                                                      if (i == 1) {
            //
            //                                                                          if ([_fileObject setOutLineStructData:_fileObject.filePycName isFirstSee:0 isSetFirst:1 isSee:0 isVerifyOk:0 isTimeIsChanged:0 isApplySucess:0 data:NULL]) {
            //                                                                              // 设置成功
            //                                                                              [self.window makeToast:@"再次打开/阅读时进行申请!" duration:1.0 position:@"center"];
            //                                                                          } else {
            //                                                                              // 设置失败时重新设置一次
            //                                                                              if ([_fileObject setOutLineStructData:_fileObject.filePycName  isFirstSee:0 isSetFirst:1 isSee:0 isVerifyOk:0 isTimeIsChanged:0 isApplySucess:0 data:NULL]) {
            //                                                                                  [self.window makeToast:@"再次打开/阅读时进行申请!" duration:1.0 position:@"center"];
            //                                                                              }
            //                                                                          }
            //                                                                      }
            //                                                                  }];
            //            [alert show];
            [self setAlertView:@"不能阅读！"];
            return;
        }
        
        [[ReceiveFileDao sharedReceiveFileDao]updateReceiveFileApplyOpen:0 FileId:fileID];//_fileObject.fileID];

        if (returnValue & ERR_OUTLINE_NUM_ERR)
        {
            //次数已到
            [self setAlertView:@"阅读次数已用完！再次打开该文件，需要重新申请！"];
            return;
        }
        if (returnValue & ERR_OUTLINE_DAY_ERR)
        {
            //时效已到
            [self setAlertView:@"阅读时间已用完！再次打开该文件，需要重新申请！"];
            return;
        }
        
        if (returnValue & ERR_OUTLINE_IS_OTHER_ERR)
        {
            //并非原文件
            [self setAlertView:@"不能阅读！"];
            return;
        }
        if (returnValue & ERR_OUTLINE_TIME_CHANGED_ERR) {
            //本地时间被修改  本地时间被人为修改，需要联网获取授权！
             [self setAlertView:@"本地时间被人为修改，需要联网获取授权！"];
            //联网校验
//            MyBlockAlertView *alert = [[MyBlockAlertView alloc] initWithTitle:nil
//                                                                      message:@"本地时间被人为修改，需要联网获取授权！"
//                                                            cancelButtonTitle:@"获取" otherButtonTitles:@"取消"
//                                                                  ButtonBlock:^(NSInteger i) {
//                                                                      if (i == 0) {
//                                                                          [custormActivityView startLoading:-1 isOutLine:NO];
//                                                                          BOOL result = [_pycFile ClientFileById:_fileObject.applyId fileOpenedNum:_fileObject.haveOpenedNum];
//                                                                          if (!result) {
//                                                                              //
//                                                                              [self errRemoveCustormActivityView];
//                                                                          }
//                                                                      }
//                                                                      
//                                                                  }];
//            [alert show];
        }
        if (returnValue & ERR_OUTLINE_STRUCTION_ERR)
        {
            //文件结构不对
            [self setAlertView:@"不能阅读！文件阅读错误！"];
            return;
        }
    }
    else
    {
        //非离线不能看
        if(returnValue & ERR_APPLIED)
        {
            if (returnValue & ERR_AUTO_APPLIED)
            {
                [self performSelector:@selector(seeFile:) withObject:seePycFile afterDelay:2.0f];
            }
            else
            {
                applyNum=0;
                [custormActivityView removeFromSuperview];
                //申请成功界
                [self letusGOActivationSucVc:seePycFile];
            }
        }
        else if(returnValue & ERR_OK_IS_FEE)
        {
            applyNum =0;
            [custormActivityView removeFromSuperview];
            [self letusGOActivationController:seePycFile];
        }
        else if((returnValue) & ERR_FREE && ((returnValue & ERR_FEE_SALER) == 0))
        {
            applyNum =0;
            [custormActivityView removeFromSuperview];
            // 自由传播不能看
            if (seePycFile.bNeedBinding)
            {
                // 需要验证手机号
                BindingPhoneViewController *bindingPhone = (BindingPhoneViewController *)[[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"BindingPhoneViewController"];
                bindingPhone.filePath = seePycFile.filePycName;
                bindingPhone.fileID = seePycFile.fileID;
//                NSWindow *superView = [[NSApplication sharedApplication] keyWindow];
//                superView.contentViewController = bindingPhone;
                [self setKeyWindow:true];
                [keyWindow.contentViewController presentViewControllerAsSheet:bindingPhone];
            }
            else
            {
                applyNum =0;
                [self setAlertView:@"可读次数或可读时间不够，无法阅读!"];
                [custormActivityView removeFromSuperview];
                return;
            }
        }
        else if(returnValue & ERR_FREE)
        {
            applyNum =0;
            [custormActivityView removeFromSuperview];
            //目前用不到
        }
        else
        {
            applyNum =0;
            [custormActivityView removeFromSuperview];
            //目前用不到
        }
    }
}

-(void)setAlertView:(NSString *)msg
{
    [self setKeyWindow:true];
    NSLog(@"提示框口keyWindow：%@",keyWindow);
    if (!alertShow)
    {
        alertShow = [[NSAlert alloc] init];
        [alertShow addButtonWithTitle:@"确定"];
//        [alertShow addButtonWithTitle:@"我知道了"];
    }

    //        [alert addButtonWithTitle:@"Cancel"];
    [alertShow setMessageText:msg];
    //        [alert setInformativeText:@"Deleted records cannot be restored."];
    [alertShow setAlertStyle:NSWarningAlertStyle];
    if ([alertShow runModal] == NSAlertFirstButtonReturn || [alertShow runModal] == NSAlertSecondButtonReturn)
    {
        //当提示框在播放器页面时，通知关闭播放器窗口
        NSDictionary  *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:fileID] forKey:@"pycFileID"];
        if([keyWindow isKindOfClass:[PlayerWindow class]]
           || [keyWindow isKindOfClass:[MuPDFWindow class]])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CancleClosePlayerWindows"
                                                                object:self
                                                              userInfo:dic];
        }
    }
}

#pragma mark  组装水印信息
-(NSString *)waterMark:(PycFile *)fileObject
{
    NSString *waterMark = nil;
    NSMutableArray *replace = [[NSMutableArray alloc] initWithArray:@[@"Q Q:",@"邮箱:",@"\n",@"手机:"]];
    if (fileObject.definechecked || fileObject.selffieldnum) {
        //QQ
        if (fileObject.definechecked&1
            && ![ToolString isBlankString:fileObject.QQ]) {
            waterMark = [NSString stringWithFormat:@"Q Q:%@",fileObject.QQ];
        }
        //手机
        if (fileObject.definechecked&2
            && ![ToolString isBlankString:fileObject.phone]) {
            
            if (![ToolString isBlankString:waterMark]) {
                waterMark = [NSString stringWithFormat:@"%@\n手机:%@",waterMark,fileObject.phone];
            }else{
                waterMark = [NSString stringWithFormat:@"手机:%@",fileObject.phone];
            }
            
        }
        //邮箱
        if (fileObject.definechecked&4
            && ![ToolString isBlankString:fileObject.email]) {
            
            if (![ToolString isBlankString:waterMark]) {
                waterMark = [NSString stringWithFormat:@"%@\n邮箱:%@",waterMark,fileObject.email];
            }else{
                waterMark = [NSString stringWithFormat:@"邮箱:%@",fileObject.email];
            }
        }
        
        //自定义1
        if (fileObject.selffieldnum==1
            && fileObject.field1needprotect!=1
            && ![ToolString isBlankString:fileObject.fild1name]
            && ![ToolString isBlankString:fileObject.field1]) {
            
            [replace addObject:fileObject.fild1name];
            if (![ToolString isBlankString:waterMark]) {
                waterMark = [NSString stringWithFormat:@"%@\n%@:%@",waterMark,fileObject.fild1name,fileObject.field1];
            }else{
                waterMark = [NSString stringWithFormat:@"%@:%@",fileObject.fild1name,fileObject.field1];
            }
        }
        //自定义2
        if (fileObject.selffieldnum==2) {
            
            if (fileObject.field1needprotect!=1
                && ![ToolString isBlankString:fileObject.fild1name]
                && ![ToolString isBlankString:fileObject.field1]) {
                
                [replace addObject:fileObject.fild1name];
                if (![ToolString isBlankString:waterMark]) {
                    waterMark = [NSString stringWithFormat:@"%@\n%@:%@",waterMark,fileObject.fild1name,fileObject.field1];
                }else{
                    waterMark = [NSString stringWithFormat:@"%@:%@",fileObject.fild1name,fileObject.field1];
                }
            }
            
            if (fileObject.field2needprotect!=1
                && ![ToolString isBlankString:fileObject.fild2name]
                && ![ToolString isBlankString:fileObject.field2]) {
                
                [replace addObject:fileObject.fild2name];
                
                if (![ToolString isBlankString:waterMark]) {
                    waterMark = [NSString stringWithFormat:@"%@\n%@:%@",waterMark,fileObject.fild2name,fileObject.field2];
                }else{
                    waterMark = [NSString stringWithFormat:@"%@:%@",fileObject.fild2name,fileObject.field2];
                }
            }
        }
    } else {
        //默认选项
        NSString *qq = fileObject.QQ;
        NSString *email = fileObject.email;
        NSString *phone = fileObject.phone;
        
        if (![ToolString isBlankString:qq]) {
            waterMark = [NSString stringWithFormat:@"Q Q:%@", qq];
        }
        if (![ToolString isBlankString:phone]) {
            if(![ToolString isBlankString:waterMark])
            {
                waterMark = [NSString stringWithFormat:@"%@\n手机:%@", waterMark,phone];
            }else{
                waterMark = [NSString stringWithFormat:@"手机:%@",phone];
            }
        }
        if (![ToolString isBlankString:email]) {
            if(![ToolString isBlankString:waterMark])
            {
                waterMark = [NSString stringWithFormat:@"%@\n邮箱:%@", waterMark,email];
            }else{
                waterMark = [NSString stringWithFormat:@"邮箱:%@",phone];
            }
        }
    }
    
    //仅当视频时处理
    if([fileObject.fileExtentionWithOutDot fileIsTypeOfVideo])
    {
        waterMark = [waterMark stringReplaceDelWater:replace];
    }
    
    return waterMark;
    
}

#pragma mark - 刷新文件详情
-(BOOL)getFileInfoById:(NSInteger)theFileId pbbFile:(NSString *)pbbFileName PycFile:(NSString *)pycFileName fileType:(NSInteger)theFileType
{
//    if (!_fileManager) {
//        //
//        _fileManager = [[PycFile alloc] init];
//        _fileManager.delegate = self;
//    }
    //
    fileM = [PycFile new];
    fileM.delegate = self;
    BOOL result = [fileM getFileInfoById:theFileId pbbFile:pbbFileName PycFile:pycFileName fileType:1];
    if (!result)
    {
        NSAlert *alertV = [NSAlert new];
        [alertV addButtonWithTitle:@"确定"];
        [alertV setMessageText:@"刷新失败，请稍后再试！"];
    }
    return result;
}

/**
 *  更新文件信息
 *
 *  @param fileObject  文件对象
 *  @param receiveData 返回值
 */
-(void)PycFile:(PycFile *)fileObject didFinishGetFileInfo:(MAKEPYCRECEIVE *)receiveData
{
    int _returnValue = receiveData->returnValue;
    if(receiveData == nil || _returnValue == 0)
    {
        NSAlert *alertV = [NSAlert new];
        [alertV addButtonWithTitle:@"确定"];
        [alertV setMessageText:@"刷新失败，请稍后再试！"];
        return;
    }
    if(_returnValue == -1)
    {
        [self setAlertView:@"数据传输错误，请重试！"];
        NSAlert *alertV = [NSAlert new];
        [alertV addButtonWithTitle:@"确定"];
        [alertV setMessageText:@"数据传输错误，请重试！"];
        return;
    }
    if(_returnValue & ERR_NEED_UPDATE)
    {
//        [[[VersionOldAlertView alloc] initWithIsInstalled:NO] show];
        return;
    }
    
    NSString *qq = fileObject.QQ;
    NSInteger makeType = _returnValue & ERR_FREE?1:0;
    NSInteger forbid = 0;  //0:不可读 1:可读
    
    NSInteger isEye = 1;
    //更新接收查看文件
    if(_returnValue & ERR_OK_OR_CANOPEN)
    {
        
        if (makeType == 1)
        {
            forbid = fileObject.iCanOpen;
        }
        else
        {
            isEye = fileObject.canseeCondition==1;
            forbid = (_returnValue) & ERR_SALER?0:1;
            //1:没申请未激活 _returnValue & ERR_SALER
            //0:已激活
            //1:已申请 _returnValue & ERR_APPLIED
            //0:未申请
            if (forbid == 1)
            {
                //用于区分能看时，需要更新的字段
                qq = @"#cansee";
            }
            
        }
    }
    NSDate *startDay = [NSDate dateWithStringByDay:fileObject.startDay];
    NSDate *endDay = [NSDate dateWithStringByDay:fileObject.endDay];
    NSDate *receiveDay = [NSDate dateWithStringByDay:[[NSDate date] dateStringByDay]];
    [[ReceiveFileDao sharedReceiveFileDao] updateReceiveFile:[OutFile initWithReceiveFileId:fileObject.fileID
                                                                                   FileName:[fileObject.filePycNameFromServer stringByDeletingPathExtension]
                                                                                    LogName:[[userDao shareduserDao] getLogName]
                                                                                  FileOwner:fileObject.fileOwner
                                                                              FileOwnerNick:fileObject.nickname
                                                                                    FileUrl:fileObject.filePycName
                                                                                   FileType:fileObject.fileExtentionWithOutDot
                                                                                ReceiveTime:receiveDay
                                                                                  StartTime:startDay
                                                                                    EndTime:endDay
                                                                                  LimitTime:fileObject.openTimeLong
                                                                                     Forbid:forbid
                                                                                   LimitNum:fileObject.AllowOpenmaxNum
                                                                                    ReadNum:fileObject.haveOpenedNum
                                                                                       Note:fileObject.remark
                                                                                     Reborn:0
                                                                                     FileQQ:qq
                                                                                  FileEmail:fileObject.email
                                                                                  FilePhone:fileObject.phone
                                                                                FileOpenDay:1
                                                                              FileDayRemain:fileObject.dayRemain
                                                                               FileOpenYear:1
                                                                             FileYearRemain:fileObject.yearRemain
                                                                               FileMakeType:makeType
                                                                               FileMakeTime:nil
                                                                                    AppType:fileObject.makeFrom
                                                                                      isEye:isEye]];
    //首次阅读
    if(![fileObject.firstSeeTime isEqualToString:@""]){
        [[ReceiveFileDao sharedReceiveFileDao] updateReceiveFileFirstOpenTime:fileObject.firstSeeTime FileId:fileObject.fileID];
    }
    
    if (_returnValue==1)
    {
        [[ReceiveFileDao sharedReceiveFileDao] updateReceiveFileToRebornedByFileId:fileObject.fileID Status:0];
        
    }
    //将系列ID和文件关联
    [[ReceiveFileDao sharedReceiveFileDao] updateReceiveSeriesID:fileObject.seriesID fileId:fileObject.fileID];
    
    //    if (fileObject.seriesID != 0) {
    //TODO:插入系列表信息
    SeriesModel *series = [[SeriesModel alloc] init];
    series.seriesID = fileObject.seriesID;
    series.seriesFileNum = fileObject.seriesFileNums;
    series.seriesName = [fileObject.seriesName stringByReplacingOccurrencesOfString:@"\0"withString:@""];//fileObject.seriesName;
    series.seriesAuthor = fileObject.nickname;
    series.seriesClass = makeType;
    [[SeriesDao sharedSeriesDao] insertToSeries:series];
   
    //通知主页面刷新
    NSDictionary  *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:fileObject.fileID] forKey:@"pycFileID"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshOpenInFile" object:self userInfo:dic];
}

#pragma mark - 绑定手机号
-(BOOL)getVerificationCodeByPhone:(NSString *)phone userPhone:(BOOL)userPhone
{
    if (!_fileManager) {
        //
        _fileManager = [[PycFile alloc] init];
        _fileManager.delegate = self;
        _userPhone = userPhone;
    }
    return [_fileManager getVerificationCodeByPhone:phone userPhone:userPhone];
}

-(void)PycFile:(PycFile *)fileObject didFinishGetVerificationCode:(MAKEPYCRECEIVE *)receiveData
{
    VerificationCodeModel *codeModel = [[VerificationCodeModel alloc] init];
    if (receiveData->returnValue == 0) {
        [self setAlertView:@"验证码发送失败！"];
    } else if(receiveData->returnValue == -1) {
        [self setAlertView:@"数据传输错误，请重试！"];
    }
    else if (receiveData->returnValue == 256 && _userPhone)
    {
        [self setAlertView:@"该手机号已绑定其他账户，请输入新的手机号重新获取验证码！"];
    }
    else if(receiveData->returnValue)
    {
        // 保存messageId,verrificationCode到本地数据库，以备用户提交验证时使用
        codeModel.messageId = fileObject.verificationCodeID;
        codeModel.verificationCode = fileObject.verificationCode;
        if(_userPhone)
        {
            codeModel.seeFile = @"1";
        }
        else
        {
            codeModel.seeFile = @"0";
        }
        [[VerificationCodeDao sharedVerificationCodeDao] insertVerificationCode:codeModel];
        //开始倒计时
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getCodeFinish" object:nil];
    }
}

/**
 *  查看文件的接口
 *
 *  @param fileObject pycFile
 */
-(void)seeFile:(PycFile *)fileObject
{
    BOOL reslut1 = NO;
    if (!fileObject.needShowDiff) {
        applyNum++;
        if (applyNum <= 1) {
            reslut1 = YES;
            [self setText:@"自动申请激活"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *userName = [[userDao shareduserDao] getLogName];
                BOOL isOffLine = FALSE;
                
                NSString *result=[_fileManager seePycFile2:fileObject.filePycName
                                               forUser:userName
                                               pbbFile:fileObject.filePycNameFromServer
                                               phoneNo:@""
                                             messageID:@""
                                             isOffLine:&isOffLine
                                         FileOpenedNum:fileObject.haveOpenedNum];
        
                if (![result isEqualToString:@"0"]) {
                    applyNum=0;
                    [self hide:-0.5];
                    if ([result isEqualToString:@"1"]||[result isEqualToString:@"2"]||[result isEqualToString:@"3"]||
                        [result isEqualToString:@"4"]||[result isEqualToString:@"5"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [custormActivityView removeFromSuperview];
                            [self setAlertView:@"读取文件失败。可能错误原因：文件下载不完整，请重新下载！"];
                        });
                    }else if([result isEqualToString:@"6"]){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [custormActivityView removeFromSuperview];
                            [self setAlertView:@"您的网络不给力哦，请检查网络连接后重试！"];
                        });
                    }
                }
            });
        }
    }
    
    if (!reslut1) {
        applyNum=0;
        [self hide:-0.5];
        [custormActivityView removeFromSuperview];
        //申请成功界面
        [self letusGOActivationSucVc:seePycFile];
    }
}


#pragma mark － 申请成功 0-0-0 重新提交
-(BOOL)getApplyFileInfoByApplyId:(NSInteger)applyId FileID:(NSInteger)applyFileID
{
    [self setKeyWindow:false];
    [self setText:@"重新申请激活"];
    return [_fileManager getApplyFileInfoByApplyId:applyId FileID:applyFileID];
}

//获取申请激活的文件信息
-(void)PycFile:(PycFile *)fileObject didFinishGetApplyFileInfo:(MAKEPYCRECEIVE *)receiveData
{
    [self hide:1.0];
    if (receiveData == nil || receiveData->returnValue == 0)
    {
        [self setAlertView:@"您的网络不给力哦，请重试！"];
    }
    else
    {
        if(receiveData->returnValue == -1)
        {
            [self setAlertView:@"数据传输错误，请重试！"];
            return;
        }
        
        if(receiveData->returnValue & ERR_NEED_UPDATE)
        {
//            [[[VersionOldAlertView alloc] initWithIsInstalled:NO] show];
            return;
        }
        
        if(receiveData->returnValue & ERR_OK_OR_CANOPEN)
        {
            
            [self letusGOActivationController:fileObject];
        }
        else
        {
            [self setAlertView:@"申请失败！"];
            return;
        }
        
    }

}

#pragma mark - 申请手动激活
- (NSString *)applyFileByFidAndOrderId:(NSInteger )fileId
                               orderId:(NSInteger )thOrderId
                               applyId:(NSInteger)theApplyId
                                    qq:(NSString *)theQQ
                                 email:(NSString *)theEmail
                                 phone:(NSString *)thePhone
                                field1:(NSString *)theField1
                                field2:(NSString *)theField2
                            seeLogName:(NSString *)theSeeLogName
                              fileName:(NSString*)theFileName
{
    [self setKeyWindow:false];
    applyNum = 0;
    //重新申请
    [self setText:@"申请激活"];
    if (_needReapply == 0) {
        applyflag = [_fileManager applyFileByFidAndOrderId:fileId
                                            orderId:thOrderId
                                                 qq:theQQ
                                              email:theEmail
                                              phone:thePhone
                                             field1:theField1
                                             field2:theField2
                                         seeLogName:theSeeLogName
                                           fileName:theFileName];
    }else{
        applyflag = [_fileManager reapplyFileByFidAndOrderId:fileId
                                              orderId:thOrderId
                                              applyId:theApplyId
                                                   qq:theQQ
                                                email:theEmail
                                                phone:thePhone
                                               field1:theField1
                                               field2:theField2];
    }

    _needReapply = 0;
    return  @"";
}

#pragma mark pycfile 代理
/**
 * 申请激活回调函数
 */
-(void)PycFile:(PycFile *)fileObject didFinishApply:(MAKEPYCRECEIVE *)receiveData
{
    if (receiveData == nil || receiveData->returnValue == 0) {
        [self hide:1.0];
        if([applyflag isEqualToString:@"1"]){
            [self setAlertView:@"您的网络不给力哦，请检查本地网络设置后重试！"];
        }else if ([applyflag isEqualToString:@"2"]){
            [self setAlertView:@"服务器繁忙，请使用移动网络重试！"];
        }else{
            [self setAlertView:@"服务器繁忙，请使用移动网络重试！"];
        }
    } else {
        
        if(receiveData->returnValue == -1)
        {
            [self hide:1.0];
            [self setAlertView:@"服务器繁忙，请稍候再试。错误代码：1003！"];
            return;
        }
        
        if(receiveData->returnValue & ERR_NEED_UPDATE)
        {
            [self hide:1.0];
//            [[[VersionOldAlertView alloc] initWithIsInstalled:NO] show];
            return;
        }
        
        /**
         *  申请成功并能自动激活时,即第十二位为1时
         *  此时，可以直接调用查看文件业务，且不需要展示广告页
         */
        if(receiveData->returnValue & ERR_OK_OR_CANOPEN || receiveData->returnValue & ERR_APPLIED)
        {
            
            if (receiveData->returnValue & ERR_AUTO_APPLIED) {
                [self performSelector:@selector(seeFile:) withObject:fileObject afterDelay:2.0f];
            }else{
                applyNum = 0;
                [self hide:1.0];
                //申请成功界面
                [self letusGOActivationSucVc:fileObject];
            }
        }
        else
        {
            [self hide:1.0];
            [self setAlertView:@"申请失败！"];
            return;
        }
    }
}

/**
 * 重新申请回调函数
 */
-(void)PycFile:(PycFile *)fileObject didFinishReapply:(MAKEPYCRECEIVE *)receiveData
{
    if (receiveData == nil || receiveData->returnValue == 0) {
        [self hide:1.0];
        if([applyflag isEqualToString:@"1"]){
            [self setAlertView:@"您的网络不给力哦，请检查本地网络设置后重试！"];
        }else if ([applyflag isEqualToString:@"2"]){
            [self setAlertView:@"服务器繁忙，请使用移动网络重试！"];
        }else{
            [self setAlertView:@"服务器繁忙，请使用移动网络重试！"];
        }
    } else {
        
        if(receiveData->returnValue == -1)
        {
            [self hide:1.0];
            [self setAlertView:@"数据传输错误，请重试！"];
            return;
        }
        
        if(receiveData->returnValue & ERR_NEED_UPDATE)
        {
            [self hide:1.0];
//            [[[VersionOldAlertView alloc] initWithIsInstalled:NO] show];
            return;
        }
        
        /**
         *  申请成功并能自动激活时,即第十二位为1时
         *  此时，可以直接调用查看文件业务，且不需要展示广告页
         */
        if(receiveData->returnValue & ERR_OK_OR_CANOPEN || receiveData->returnValue & ERR_APPLIED)
        {
            if (receiveData->returnValue & ERR_AUTO_APPLIED) {
                [self performSelector:@selector(seeFile:) withObject:fileObject afterDelay:2.0f];
            }else{
                applyNum = 0;
                [self hide:1.0];
                [self letusGOActivationSucVc:fileObject];
           }
        }
        else
        {
            [self hide:1.0];
            [self setAlertView:@"申请失败！"];
            return;
        }
    }
}

#pragma mark - 跳转页面
//申请激活成功页面
-(void)letusGOActivationSucVc:(PycFile*)pycfileObject
{
    [[[PBBLogModel alloc] initWithType:LogINFO inApp:APPReaderMac desc:@"申请成功，到成功界面"] sendToServer];
    //申请成功，到成功界面
    ActivationSuccessController *activationSucVc = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"ActivationSuccessController"];
    activationSucVc.fileId = pycfileObject.fileID;
    activationSucVc.qq = [NSString stringWithFormat:@"%@",pycfileObject.QQ];
    activationSucVc.email = [NSString stringWithFormat:@"%@",pycfileObject.email];
    activationSucVc.phone = [NSString stringWithFormat:@"%@",pycfileObject.phone];
    activationSucVc.showInfo = pycfileObject.showInfo;
    activationSucVc.needShowDiff = pycfileObject.needShowDiff;
    activationSucVc.makerNick = pycfileObject.nickname;
    activationSucVc.applyId = pycfileObject.applyId;
    activationSucVc.remark = pycfileObject.remark;
    activationSucVc.bOpenInCome = bOpenInCome;
    activationSucVc.needReapply = pycfileObject.needReapply;
    
    [[ReceiveFileDao sharedReceiveFileDao]updateReceiveFileApplyOpen:0 FileId:pycfileObject.fileID];
    [self setKeyWindow:true];
    NSLog(@"申请结果keyWindow：%@",keyWindow);
    [keyWindow.contentViewController presentViewControllerAsSheet:activationSucVc];
}


//填写申请表格页面
-(void)letusGOActivationController:(PycFile *)pycFileObject
{
    [[[PBBLogModel alloc] initWithType:LogINFO inApp:APPReaderMac desc:@"申请成功，到成功界面"] sendToServer];
    ActivationController *activationVc = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"ActivationController"];
    //带有申请条件，可以展示条件，并申请，目前到申请界面
    activationVc.fileId = pycFileObject.fileID;
    activationVc.orderId = pycFileObject.orderID;
    activationVc.filename = [pycFileObject.filePycNameFromServer stringByDeletingPathExtension];
    activationVc.selffieldnum = pycFileObject.selffieldnum;
    activationVc.definechecked = pycFileObject.definechecked;
    activationVc.bOpenInCome = bOpenInCome;
    activationVc.qq = pycFileObject.QQ;
    activationVc.email = pycFileObject.email;
    activationVc.phone = pycFileObject.phone;
    //自定义字段1
    activationVc.field1name = pycFileObject.fild1name;
    activationVc.self1 = pycFileObject.field1;
    activationVc.field1needprotect = (pycFileObject.field1needprotect==1)?YES:NO;
    //自定义字段2
    activationVc.field2name = pycFileObject.fild2name;
    activationVc.self2 = pycFileObject.field2;
    activationVc.field2needprotect =(pycFileObject.field2needprotect==1)?YES:NO;
    //重新申请参数
    activationVc.needReApply = pycFileObject.needReapply;
    activationVc.applyId = pycFileObject.applyId;
    
    if (pycFileObject.openDay >0 && pycFileObject.openYear >0) {
        activationVc.fileOpenDay = [NSString stringWithFormat:@"%ld 年 %ld 天",(long)pycFileObject.openYear,(long)pycFileObject.openDay];
    }else if(pycFileObject.openDay >0){
        activationVc.fileOpenDay = [NSString stringWithFormat:@"%ld 天",(long)pycFileObject.openDay];
    }else if(pycFileObject.openYear >0){
        activationVc.fileOpenDay = [NSString stringWithFormat:@"%ld 年",(long)pycFileObject.openYear];
    }else{
        activationVc.fileOpenDay = @"";
    }
    if (pycFileObject.AllowOpenmaxNum > 0) {
        activationVc.canSeeNum = [NSString stringWithFormat:@"%ld 次",(long)pycFileObject.AllowOpenmaxNum];
    }else{
        activationVc.canSeeNum = @"";
    }
    [[ReceiveFileDao sharedReceiveFileDao]updateReceiveFileApplyOpen:0 FileId:fileID];
    
    [self setKeyWindow:true];
    NSLog(@"申请激活keyWindow：%@",keyWindow);
    [keyWindow.contentViewController presentViewControllerAsSheet:activationVc];
}


- (void)setText:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self show];
        hud.labelText = NSLocalizedString(text, nil);
    });
}

- (void)show
{
    isLoading = YES;
    //    keyWindow = [[NSApplication sharedApplication] keyWindow];
    [self setKeyWindow:false];
    if(!hud){
        keyWindow.contentView.wantsLayer = true;
        hud = [MBProgressHUD showHUDAddedTo:keyWindow.contentView animated:YES];
        hud.removeFromSuperViewOnHide = YES;
        hud.mode = MBProgressHUDModeIndeterminate;
        [keyWindow setLevel:NSPopUpMenuWindowLevel];
        [keyWindow makeKeyAndOrderFront:self];
        [[keyWindow contentView] setHidden:NO];
        [NSApp activateIgnoringOtherApps:YES];
    }
}

-(void)setKeyWindow:(BOOL)isCanClose
{
    NSArray *windows = [[NSApplication sharedApplication] windows];
    for (NSWindow *window in windows)
    {
        if ([window.identifier isEqualToString:@"MainWindow"])
        {
            //详情页面窗口
            keyWindow = window;
        }
        
        if ([window isKindOfClass:[PlayerWindow class]])
        {
            //播放器窗口
            keyWindow = (PlayerWindow *)window;
            if (isCanClose)
            {
                //服务器响应之后，设置window关闭按钮可用
                [keyWindow setStyleMask:[window styleMask] | NSClosableWindowMask];
            }
            else
            {
                [keyWindow setStyleMask:[window styleMask] & ~ NSClosableWindowMask];
            }
        }
        
        if ([window isKindOfClass:[MuPDFWindow class]])
        {
            //播放器窗口
            keyWindow = (MuPDFWindow *)window;
            if (isCanClose)
            {
                //服务器响应之后，设置window关闭按钮可用
                [keyWindow setStyleMask:[window styleMask] | NSClosableWindowMask];
            }
            else
            {
                [keyWindow setStyleMask:[window styleMask] & ~ NSClosableWindowMask];
            }
        }

    }
}


- (void)hide:(NSTimeInterval)i{
    if (!isLoading) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [hud hide:YES afterDelay:i];
        [NSTimer scheduledTimerWithTimeInterval:i+0.5
                                         target:self
                                       selector:@selector(hideWindow)
                                       userInfo:nil
                                        repeats:NO];
    });
}

- (void)hideWindow{
    if ([keyWindow.identifier isEqualToString:@"MainWindow"]) {
//        [[keyWindow contentView] setHidden:YES];
        [keyWindow setLevel:NSNormalWindowLevel-1];
        [keyWindow orderBack:self];
    }
    hud = NULL;
    isLoading = NO;
}


@end
