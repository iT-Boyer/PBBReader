

//
//  PycFile.m
//  PycSocket
//
//  Created by Fairy on 13-11-11.
//  Copyright (c) 2013年 Fairy. All rights reserved.
//

#import "PycFile.h"
#import "FileOutPublic.h"
#import "PycCode.h"
#import "GCDAsyncSocket.h"
#import "PycSocket.h"
#import "PycFolder.h"
#import "RefreshDataModel.h"
#import "PycCodeUrl.h"
#import "ReceiveFileDao.h"
#import "userDao.h"
#import "ToolString.h"
#import "OpenUDID.h"
#define MAX_RENAME_COUNT 100


@interface PycFile ()
{
    NSString *fileIDs;
    NSInteger fileOperateType;
   // BOOL seefileForuser;
    
}



@end


@implementation PycFile
{
    NSString *_sysInfoVersion;
    NSString *_OpenUUID;
    BOOL b_needNet;
    
    
}
//singleton_implementation(PycFile)

@synthesize fileRefreshInfo;
- (id)init
{
    self = [super init];
    if (self)
    {
//        _sysInfoVersion = [NSString stringWithFormat:@"%@%@",[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]];
        NSString *model = [[NSUserDefaults standardUserDefaults] objectForKey:@"kmachine_model"];
        if (model) {
            //
            _sysInfoVersion = model;
        }
//        _sysInfoVersion = [ToolString platformString];
//        _deviceIdfv = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
//        UserDefaults.standard.object(forKey: "kplatform_UUID") as! String
//        UserDefaults.standard.object(forKey: "kmachine_model") as! String
        NSString *UUID = [[NSUserDefaults standardUserDefaults] objectForKey:@"kplatform_UUID"];
        if(UUID)
        {
            _OpenUUID = UUID;
        }
//        _OpenUUID = [OpenUDID value];
        NSLog(@"init- pycfile-----");
        
    }
    return self;
}


-(NSString *)description
{
    NSString *stringAll = [NSString stringWithFormat:
                           @"\
                           fileName                 = %@\n\
                           filePycNameFromServer    = %@\n\
                           filePycName              = %@\n\
                           fileOwner                = %@\n\
                           startDay                 = %@\n\
                           endDay                   = %@\n\
                           AllowOpenmaxNum          = %ld\n\
                           haveOpenedNum            = %ld\n\
                           bCanprint                = %d\n\
                           iCanOpen                 = %ld\n\
                           nickname                 = %@\n\
                           remark                   = %@",
                           _fileName, _filePycNameFromServer, _filePycName,_fileOwner,_startDay,_endDay,(long)_AllowOpenmaxNum,(long)_haveOpenedNum,_bCanprint,(long)_iCanOpen, _nickname,_remark];
#ifdef WRITE_FILE_INFO_TO_FILE
    [stringAll writeToFile:[[PycFolder documentDirectory] stringByAppendingPathComponent:@"testinfo"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
#endif
    return stringAll;
}
-(void)printHash:(Byte *)hashValue
{
    NSString *hexStr;
    for(int i=0;i<32 ;i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",hashValue[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    
    NSLog(@"*******bytes 的 16进制数为:%@",hexStr);
}

-(void)printByte:(Byte *)theValue  len:(NSInteger)len description:(NSString *)theDescription
{
    NSString *hexStr;
    for(int i=0;i<len ;i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",theValue[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    
//    NSLog(@"%@:%@",theDescription, hexStr);
}

-(NSMutableArray *)checkSendByte:(Byte *)bytes len:(NSInteger)len
{
    NSMutableArray *result = [[NSMutableArray alloc] init];;
    //下面是Byte 转换为16进制。
    NSString *bytestr = @"";
    for (int i = 0; i<len; i++)
    {
        bytestr = [bytestr stringByAppendingString:[NSString stringWithFormat:@"%d,",bytes[i]]];
    }
    //NSLog(@"密钥=====:%@",bytestr);

    int j1=0;
    int j2=0;
    int r=0;
    for (int i=0; i<len; i++) {
        if (bytes[i]==0x0A) {
            if (bytes[i+1]==0x0A) {
                bytes[i+1]=0x00;
                if (r==0) {
                    j1=i+1;
                }
                r++;
                if (r==2) {
                    j2=i+1;
                    break;
                }
            }
        }
    }
    [result addObject:[NSNumber numberWithInteger:j1]];
    [result addObject:[NSNumber numberWithInteger:j2]];
    return result;
}

#pragma mark - 调用delegate方法
-(void)makeReturnMessage:(NSInteger)message forOperateType:(NSInteger)operateType
{
    NSLog(@"***********%s**********", __func__);
    MAKEPYCRECEIVE makeReceive;
    makeReceive.returnValue = (int)message;
    switch (operateType) {
        case TYPE_FILE_REFRESH:
           
            [self.delegate PycFile:self didFinishRefreshPycFile:&makeReceive];
            break;
        case TYPE_FILE_CHANGE_READ_CONDITION:
           [self.delegate PycFile:self didFinishChangeReadCondition:&makeReceive];
            break;
        case TYPE_FILE_CHANGE_FILE_CONTROLL:
           [self.delegate PycFile:self didFinishChangeFileControll:&makeReceive];
            break;
        case TYPE_FILE_OUT:
          [self.delegate PycFile:self didFinishMakePycFile:&makeReceive];
            break;
        case TYPE_FILE_OPEN:
                [self.delegate PycFile:self didFinishSeePycFileForUser:&makeReceive];
            break;
        case NewPycUerRemoteOperateTypeBindPhone: //绑定手机号
                [self.delegate PycFile:self didFinishSeePycFileForUser:&makeReceive];
            break;
        case TYPE_FILE_INFO:
            [self.delegate PycFile:self didFinishGetFileInfo:&makeReceive];
            break;
        case TYPE_FILE_CLIENT:
            [self.delegate PycFile:self didFinishClientFileInfo:&makeReceive];
            break;
        case TYPE_FILE_APPLYINFO:
            [self.delegate PycFile:self didFinishGetApplyFileInfo:&makeReceive];
            break;
        case TYPE_APPLY:
            [self.delegate PycFile:self didFinishApply:&makeReceive];
            break;
        case TYPE_REAPPLY:
            [self.delegate PycFile:self didFinishReapply:&makeReceive];
            break;
        case TYPE_SEE_ACTIVE_OVERLIST:
            [self.delegate PycFile:self didFinishGetOverList:&makeReceive];
            break;
        case TYPE_FILE_VERIFICATIONCODE:
            [self.delegate PycFile:self didFinishGetVerificationCode:&makeReceive];
            break;
        case NewPycUerRemoteOperateTypeGetConfirm:
            [self.delegate PycFile:self didFinishGetVerificationCode:&makeReceive];
            break;
        default:

            break;
    }
}


#pragma mark - 获取pbb文件的fileID 
//当hsg自由传播没有结构体，无法获取fileID
- (int)getAttributePycFileId:(NSString *)filename
{
    int bReturn = 0;
    if (![[filename pathExtension] isEqualToString:@"pbb"]
        ||
        ![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        NSLog(@"no file");
        //bReturn=-1;
        return bReturn;
        
    }

    NSNumber *fileSize ;
    NSError *err;
    //得到文件大小
    NSDictionary *fileAttributes = [[NSFileManager defaultManager]  attributesOfItemAtPath:filename error:&err];
    if (fileAttributes != nil) {
        
        fileSize = [fileAttributes objectForKey:NSFileSize];
        NSLog(@"%ld", fileSize.longValue);
    }
    
    long structsize = sizeof(PYCFILEEXT);
    long fileheadoffset = (fileSize.longValue > structsize)? (fileSize.longValue - structsize):0;
    if(fileheadoffset == 0)
    {
        NSLog(@"nothing in");
        //bReturn=-1;
        return bReturn;
    }
    
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filename];
    if (handle == nil)
    {
        //3:应用开启沙盒保护机制，无权限阅读该目录文件，请移动到下载目录重新查看！
        return 3;
    }
    [handle seekToFileOffset:fileheadoffset];
   /*NSData *data = [handle readDataOfLength:sizeof(PYCFILEHEADER)];
    NSLog(@"read len %d %s",[data length], [data bytes]);*/
   /* 
    PYCFILEHEADER *header = (PYCFILEHEADER *)[data bytes];
    NSLog(@"file original size really %lld", header->fileSize);
    */
    NSData *dataExt = [handle readDataOfLength:sizeof(PYCFILEEXT)];
    PYCFILEEXT *fileExtHeader = (PYCFILEEXT *)[dataExt bytes];
    PycCode *coder = [[PycCode alloc] init];
    [coder decodeFileExtension:fileExtHeader];
    if (fileExtHeader->uTag != PycTag0 && fileExtHeader->uTag != PycTag1) {
        //bReturn=-1;
        return bReturn;
    }
    bReturn= fileExtHeader->nFileId;
    [handle closeFile];
    
     return bReturn;
}


-(NSInteger)getFileType:(NSString *)filePath
{
    NSString *strFileExtend = [NSString stringWithFormat:@".%@",[filePath  pathExtension]];
    NSMutableString *fileWithOutExtention = [NSMutableString stringWithFormat:@"%@", filePath];
    NSRange range = [fileWithOutExtention rangeOfString:strFileExtend];
    [fileWithOutExtention deleteCharactersInRange:range];

//    NSMutableString *fileWithOutExtention = [NSMutableString stringWithFormat:@"%@", [filePath stringByDeletingPathExtension]];
    
    NSString *fileExtention1 = [fileWithOutExtention pathExtension];
    self.fileExtentionWithOutDot = [fileWithOutExtention pathExtension];
    
    NSString *fileExtention = [fileExtention1 lowercaseString];
    
    
     NSDictionary * fileTypeDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"mp4",
                                                 [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"rmvb",
                                                 [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"mkv",
                                                 [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"mpeg",
                                                 [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"mov",
                                                 [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"avi",
                                                 [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"3gp",
                                                 [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"flv",
                                                 [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"wmv",
                                                 [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"mpg",
                                                 [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"vob",
                                                 [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"rm",
                                                 [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"wav",
                                                 [NSNumber numberWithInteger:FILE_TYPE_MOVIE], @"dat",
                                                 [NSNumber numberWithInteger:FILE_TYPE_PIC], @"jpg",
                                                 [NSNumber numberWithInteger:FILE_TYPE_PIC], @"bmp",
                                                 [NSNumber numberWithInteger:FILE_TYPE_PIC], @"gif",
                                                 [NSNumber numberWithInteger:FILE_TYPE_PIC], @"jpeg",
                                                 [NSNumber numberWithInteger:FILE_TYPE_PIC], @"jpe",
                                                 [NSNumber numberWithInteger:FILE_TYPE_PIC], @"png",nil];
    
    NSNumber *nsfileType  = fileTypeDic[fileExtention];
    
    if (nsfileType == nil)
    {
        self.fileType = FILE_TYPE_UNKOWN;
    }
    else
    {
        self.fileType = [nsfileType integerValue];
    }
    return self.fileType;
}

/**
 * @breif 构建接收文件的存放目录
 *  FilePath inbox目录中的原始文件路径，含有文件名全路径
 *
 */
-(NSString *)getNotExistRecievePycName:(NSString *)FilePath forUser:(NSString *)logname
{
    NSLog(@"inbox 文件路径 %@", FilePath);
    
    if (logname == nil) {
        return nil;
    }
    //用户的存放接收文件的receive目录
    NSString *receiveFolderForUser = [PycFolder documentReceiveFolderWithUserID:logname];
    //构建目标文件的路径
    NSString *pycFilePath  =  [receiveFolderForUser stringByAppendingPathComponent:[FilePath lastPathComponent]];
//    NSString *pycFilePath = [pycFileWithOutExtention stringByAppendingPathExtension:PYC_FILE_EXTENTION];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    
    BOOL isDir;
    NSError *err;
    if (![manager fileExistsAtPath:receiveFolderForUser isDirectory:&isDir]) {
        
        if(![manager createDirectoryAtPath:receiveFolderForUser withIntermediateDirectories:YES attributes:nil error:&err])
        {
            NSLog(@"create dir err %@", err);
            return nil;
        }
        else{
            NSLog(@"create dir %@", receiveFolderForUser);
        }
    }
    else
    {
        NSLog(@"Recieve folder exist");
    }
    //如果文件不存在，直接返回新文件全路径
    if (![manager fileExistsAtPath:pycFilePath]) {
        NSLog(@"目标文件全路径 %@", pycFilePath);
        return pycFilePath;
    }
    
    /**
     *如果文件已经存在，重命名文件名
     */
    NSString *strFileExtend = [NSString stringWithFormat:@".%@",[FilePath pathExtension]];
    NSMutableString *fileWithOutAnyExtention = [NSMutableString stringWithFormat:@"%@",pycFilePath];
    NSRange range = [fileWithOutAnyExtention rangeOfString:strFileExtend];
    if (range.location == NSNotFound) {
        NSLog(@"*****file name err");
        return nil;
    }
    [fileWithOutAnyExtention deleteCharactersInRange:range];
    
    
    for (int i = 1; i<MAX_RENAME_COUNT; i++) {
        NSString *testFilePath = [fileWithOutAnyExtention stringByAppendingFormat:@"(%d)%@.%@",i, strFileExtend,PYC_FILE_EXTENTION];
//        NSLog(@"test pyc File Path %@", testFilePath);
        if (![manager fileExistsAtPath:testFilePath]) {
            return testFilePath;
        }
        if (i == MAX_RENAME_COUNT-1) {
            NSError *err;
            [manager removeItemAtPath:testFilePath error:&err];
            return testFilePath;
        }
        
    }
    return nil;//never do this
}

/**
 *  @breif 制作文件过程中，指定文件的存储位置，当文件路径冲突时，重命名文件名路径并保存到send目录中
 *
 */
-(NSString *)getNotExistPycName:(NSString *)FilePath forUser:(NSString *)logname
{
    NSLog(@"file path %@", FilePath);
    
    if (logname == nil) {
        return nil;
    }
    
    NSString *sendFolderForUser = [PycFolder documentSendFolderWithUserID:logname];
    NSString *pycFileWithOutExtention  =  [sendFolderForUser stringByAppendingPathComponent:[FilePath lastPathComponent]];
    NSString *pycFilePath = [pycFileWithOutExtention stringByAppendingPathExtension:PYC_FILE_EXTENTION];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    BOOL isDir;
    NSError *err;
    if (![manager fileExistsAtPath:sendFolderForUser isDirectory:&isDir])
    {
        if(![manager createDirectoryAtPath:sendFolderForUser withIntermediateDirectories:YES attributes:nil error:&err])
        {
            NSLog(@"create dir err %@", err);
            return nil;
        }
        else{
            NSLog(@"create dir %@", sendFolderForUser);
        }
    }
    else
    {
        NSLog(@"send folder exist");
    }
    
    if (![manager fileExistsAtPath:pycFilePath]) {
        NSLog(@"pyc file path %@", pycFilePath);
        return pycFilePath;
    }
    
    NSString *strFileExtend = [NSString stringWithFormat:@".%@",[FilePath pathExtension] ];
    NSMutableString *fileWithOutAnyExtention = [NSMutableString stringWithFormat:@"%@",pycFileWithOutExtention];
    NSRange range = [fileWithOutAnyExtention rangeOfString:strFileExtend];
    if (range.location == NSNotFound) {
        NSLog(@"*****file name err");
        return nil;
    }
    [fileWithOutAnyExtention deleteCharactersInRange:range];
    
    
    for (int i = 1; i<MAX_RENAME_COUNT; i++) {
        NSString *testFilePath = [fileWithOutAnyExtention stringByAppendingFormat:@"(%d)%@.%@",i, strFileExtend,PYC_FILE_EXTENTION];
        //        NSLog(@"test pyc File Path %@", testFilePath);
        if (![manager fileExistsAtPath:testFilePath]) {
            return testFilePath;
        }
        if (i == MAX_RENAME_COUNT-1) {
            NSError *err;
            [manager removeItemAtPath:testFilePath error:&err];
            return testFilePath;
        }
        
    }
    return nil;//never do this
}


-(BOOL)getReceiveFileINfo
{
//    if (![self.filePycNameFromServer isEqualToString:[self.filePycName lastPathComponent]]) {
//        NSFileManager *manager = [NSFileManager defaultManager];
//        BOOL isDir;
//        NSError *err;;//        NSString *stringDoc = [PycFolder documentReceiveFolderWithUserID:self.fileSeeLogname];
//        if (![manager fileExistsAtPath:stringDoc isDirectory:&isDir]) {
//            
//            if(![manager createDirectoryAtPath:stringDoc withIntermediateDirectories:YES attributes:nil error:&err])
//            {
//                NSLog(@"create dir err %@", err);
//                return NO;
//            }
//            
//        }
//
//        NSString *filePycRealPath = [NSString stringWithFormat:@"%@/%@", stringDoc,self.filePycNameFromServer];
//        if (![manager fileExistsAtPath:filePycRealPath]) {
//            
//            [manager copyItemAtPath:self.filePycName toPath:filePycRealPath error:&err];
//            NSLog(@"err %@",err);
//            if (err != nil) {
//                return NO;
//            }
//        }
//        
//        self.filePycName = filePycRealPath;
//        
//    }
//    
    return YES;
}

//新建明文释放到该路径
-(NSString *)getNotExistFileNameFromPycFile:(NSString *)filePycNameFromServer
                              withExtention:(NSString *)pycExtention
                                    forUser:(NSString *)logname
{
    if (logname == nil)
    {
        return nil;
    }
    
    NSMutableString *filePath = [NSMutableString stringWithFormat:@"%@", [filePycNameFromServer lastPathComponent]];
    NSString *pycExtentionDot = [[NSString alloc] initWithFormat:@".%@", pycExtention];
    NSRange range = [filePath rangeOfString:pycExtentionDot];
    if (range.location == NSNotFound) {
        NSLog(@"*****file name err");
        return nil;
    }
    //删除.pbb后缀
    [filePath deleteCharactersInRange:range];
    NSString *fileName = [filePath lastPathComponent];
    //tmp目录
    NSString *tmpDir = [PycFolder documentViewFolderWithUserID:logname];
    //明文路径
    NSString *filePathForOpenFile = [tmpDir stringByAppendingPathComponent:fileName];
    
    //新建tmp目录
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDir;
    NSError *err;
    if (![manager fileExistsAtPath:tmpDir isDirectory:&isDir])
    {
        if(![manager createDirectoryAtPath:tmpDir
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&err])
        {
            NSLog(@"create dir err %@", err);
            return nil;
        }
        else
        {
            NSLog(@"create dir %@", tmpDir);
        }
    }
    else
    {
        NSLog(@"send folder exist");
    }
    return filePathForOpenFile;
}


-(BOOL)fileIsTypeOfVideo:(NSString *)pathExt
{
    
    NSString *str = [NSString stringWithFormat:@"%@",@"+rmvb+mkv+mpeg+mp4+mov+avi+3gp+flv+wmv+rm+mpg+vob+dat+"];
    pathExt = [pathExt lowercaseString];
    //    NSComparisonResult *result = [pathExt commonPrefixWithString:str options:NSCaseInsensitiveSearch|NSNumericSearch];
    NSRange range=[str rangeOfString: pathExt];
    if (!(range.location==NSNotFound)) {
        return YES;
    }
    return NO;
}

#pragma mark - socket网络
#pragma mark socket 连接成功，封装请求数据包，并发送
-(void)PycSocket: (PycSocket *)fileObject didFinishConnect: (Byte *)receiveDataByte
{
    NSLog(@"*****************%s******************", __func__);
    // SENDDATA * receiveData = (SENDDATA *)receiveDataByte;
    NSLog(@"finish connect can send data");
    SENDDATA_NEW_NEW data;
    memset(&data, 0, sizeof(SENDDATA_NEW_NEW));
    data.suc=0;
    data.pos1=0;
    data.pos2=0;
    if (fileObject.connectType == TYPE_FILE_OUT) {
        NSLog(@"file out type");
         [self MakeFileOutPackage:&data];
    }
    else if(fileObject.connectType == TYEP_FILE_SAVE_HASH_ENCRYPT)
    {
        NSLog(@"hash type receive");
        [self MakeSaveHashAndSecretPackage:&data];
    }
    else if(fileObject.connectType == TYPE_FILE_OPEN)
    {
        NSLog(@"open type receive");
        [self MakeOpenFilePackage:&data];
    }
    else if (fileObject.connectType == TYPE_FILE_REFRESH)
    {
        NSLog(@"refresh file list receive");
        [self MakerefreshListInfoPackage:&data];
    }
    else if (fileObject.connectType == TYPE_FILE_CHANGE_READ_CONDITION)
    {
        [self makePycFileReadConditionPackage:&data];
    }
    else if (fileObject.connectType == TYPE_FILE_CHANGE_FILE_CONTROLL)
    {
        [self makePycFileChangeControllPackage:&data];
    }
    else if (fileObject.connectType == TYPE_FILE_INFO)
    {
        [self MakeGetFileInfoByIdPackage:&data];
    }
    else if(fileObject.connectType == TYPE_FILE_CLIENT)
    {
        [self MakeGetFileClientByFidAndOrderIdPackage:&data];
    }
    else if (fileObject.connectType == TYPE_FILE_APPLYINFO)
    {
        [self MakeGetApplyFileInfoByIdPackage:&data];
    }
    else if(fileObject.connectType == TYPE_APPLY)
    {
        [self MakeapplyFileByFidAndOrderIdPackage:&data];
    }
    else if(fileObject.connectType == TYPE_REAPPLY)
    {
        [self MakeReapplyFileByFidAndOrderIdPackage:&data];
    }
    else if(fileObject.connectType == TYPE_FILE_VERIFICATIONCODE
            || fileObject.connectType == NewPycUerRemoteOperateTypeGetConfirm)
    {
        [self MakeVerificationCodeByFidPackage:&data];
    }
    else if(fileObject.connectType == TYPE_SEE_FILE_OVER)
    {
        [self MakeSeeFileOVerPackage:&data];
    }
    else if (fileObject.connectType == NewPycUerRemoteOperateTypeBindPhone)
    {
        [self makeSendPackageForBindPhone:&data];
    }
    NSMutableArray *arry= [self checkSendByte:(Byte *)&data len:sizeof(SENDDATA_NEW_NEW)];
    int j1=[arry[0] intValue];
    int j2=[arry[1] intValue];
    
    data.pos1=j1;
    data.pos2=j2;
    if (fileObject.connectType == TYPE_SEE_FILE_OVER) {
        [self.pycsocket SocketWrite:(Byte *)&data length:sizeof(SENDDATA_NEW_NEW) receiveDataLength:sizeof(RECEIVEDATA_NEW_NEW)];
    }else{
        if (0 == [self.pycsocket SocketWrite:(Byte *)&data length:sizeof(SENDDATA_NEW_NEW) receiveDataLength:sizeof(RECEIVEDATA_NEW_NEW)]) {
            NSLog(@"err when doing:%ld",(long)fileObject.connectType);
            [self makeReturnMessage:0 forOperateType:fileObject.connectType];
        }
    }
}

#pragma mark socket 服务器响应，开始解析接收到的数据包
-(void)PycSocket: (PycSocket *)fileObject didFinishSend: (Byte *)receiveDataByte
{
    NSLog(@"*****************%s******************", __func__);
    RECEIVEDATA_NEW_NEW * receiveData = (RECEIVEDATA_NEW_NEW *)receiveDataByte;

    if (!receiveData) {
        
        if(!b_needNet && _receiveFile && fileOperateType == TYPE_FILE_OPEN)
        {
            
            //当网络不给力时，
            //旧版本手动激活文件，可读时
            //解析离线文件，并给self赋值,获取明文文件
            [self setValueOfSelfByNewFile:_receiveFile];
            //支持离线阅读的文件，且根据本地数据库的数据判断可阅读时
            [self makeReturnMessage:_receiveFile.canSeeForOutline forOperateType:fileOperateType];
        }
        else{
            [self makeReturnMessage:0 forOperateType:fileOperateType];
        }
        
        return;
    }
    int pos1 = receiveData->pos1;
    int pos2 = receiveData->pos2;
    if (pos1!=0) {
        ((Byte *)receiveData)[pos1]=0x0A;
    }
    if (pos2!=0) {
        ((Byte *)receiveData)[pos2]=0x0A;
    }
    PycCode *coder = [[PycCode alloc] init];
    
    if (receiveData->userData.random != self.Random)
    {
        [coder decodeBuffer:(Byte *)&(receiveData->userData) length:sizeof(STRUCTDATA_NEW_NEW)];
    }
    else
    {
        return;
    }

    
    if (receiveData->type == TYPE_FILE_OUT || receiveData->type == TYPE_FILE_OUT_SALER_APPLY)
    {
        //文件制作
        if (receiveData->suc == 0)
        {
            NSLog(@"return operate server suc = 0");
            [self makeReturnMessage:0 forOperateType:TYPE_FILE_OUT];
            return;
        }
        
        //随机因子不同
        if (receiveData->userData.random != self.Random)
        {
            NSLog(@"return operate server suc = 0");
            [self makeReturnMessage:-1 forOperateType:TYPE_FILE_OUT];
            return;
        }
        
        if (!(receiveData->suc & ERR_OK_OR_CANOPEN))
        {
            [self makeReturnMessage:receiveData->suc forOperateType:TYPE_FILE_OUT];
            return;
        }
       
        self.fileID = receiveData->userData.ID;
        self.orderNo =  [[NSString alloc]initWithBytes:receiveData->userData.orderno
                                                length:ORDERNO_LEN
                                              encoding:NSUTF8StringEncoding];
        NSLog(@"file id is %ld",(long)self.fileID);
        
        //制作.pbb文件
        if (![self makePycFile])
        {
            [self makeReturnMessage:0 forOperateType:TYPE_FILE_OUT];
            return;
        }
        //制作完成访问服务器
        [self uploadMakePycFile];
        
    }
    else if(receiveData->type == TYEP_FILE_SAVE_HASH_ENCRYPT)
    {

        NSLog(@"type is hash");
        if (receiveData->suc == 0) {
            NSLog(@"return operate server save hash suc = 0");
            [self makeReturnMessage:0 forOperateType:TYPE_FILE_OUT];
            return;
        }
        
        [self makeReturnMessage:receiveData->suc forOperateType:TYPE_FILE_OUT];
        
    }
    else if(receiveData->type == TYPE_FILE_OPEN)
    {
        //文件查看
        NSLog(@"type is open");
        //随机因子不同
        if (receiveData->userData.random != self.Random)
        {
            [self makeReturnMessage:-1 forOperateType:TYPE_FILE_OPEN];
            return;
        }
        [self ReceiveOpenFileByFidPackage:receiveData];
        [self makeReturnMessage:receiveData->suc forOperateType:TYPE_FILE_OPEN];
    }
    else if(receiveData->type == TYPE_FILE_REFRESH)
    {
        if(receiveData->suc & ERR_OK_OR_CANOPEN)
        {
            [self receiveRefreshListInfoPackage:receiveData];
        }
        
        [self makeReturnMessage:receiveData->suc forOperateType:TYPE_FILE_REFRESH];
    }
    else if (receiveData->type == TYPE_FILE_CHANGE_READ_CONDITION)
    {
        //随机因子不同
        if (receiveData->userData.random != self.Random)
        {
            NSLog(@"return operate server suc = 0");
            [self makeReturnMessage:-1 forOperateType:TYPE_FILE_CHANGE_READ_CONDITION];
            return;
        }
       [self makeReturnMessage:receiveData->suc forOperateType:TYPE_FILE_CHANGE_READ_CONDITION];
    }
    else if (receiveData->type == TYPE_FILE_CHANGE_FILE_CONTROLL)
    {
       //随机因子不同
        if (receiveData->userData.random != self.Random)
        {
            NSLog(@"return operate server suc = 0");
            [self makeReturnMessage:-1 forOperateType:TYPE_FILE_CHANGE_FILE_CONTROLL];
            return;
        }
        [self makeReturnMessage:receiveData->suc forOperateType:TYPE_FILE_CHANGE_FILE_CONTROLL];
    }
    else if (receiveData->type == TYPE_FILE_INFO)
    {
       //随机因子不同
        if (receiveData->userData.random != self.Random)
        {
            NSLog(@"return operate server suc = 0");
            [self makeReturnMessage:-1 forOperateType:TYPE_FILE_INFO];
            return;
        }
       [self receiveGetFileInfoByIdPackage:receiveData];
        [self makeReturnMessage:receiveData->suc forOperateType:TYPE_FILE_INFO];
    
    }
    else if (receiveData->type == TYPE_FILE_APPLYINFO)
    {
        //随机因子不同
        if (receiveData->userData.random != self.Random)
        {
            [self makeReturnMessage:-1 forOperateType:TYPE_FILE_APPLYINFO];
            return;
        }
        [self receiveApplyFileInfoByIdPackage:receiveData];
        [self makeReturnMessage:receiveData->suc forOperateType:TYPE_FILE_APPLYINFO];
        
    }
    else if (receiveData->type == TYPE_FILE_CLIENT)
    {
        //随机因子不同
        if (receiveData->userData.random != self.Random)
        {
            [self makeReturnMessage:-1 forOperateType:TYPE_FILE_CLIENT];
            return;
        }
        if (receiveData->suc & ERR_OK_OR_CANOPEN) {
        //能看
            [self setOutLineStructData:self.filePycName isFirstSee:0 isSetFirst:0 isSee:0 isVerifyOk:1 isTimeIsChanged:0 isApplySucess:0 data:receiveData];
        }
        [self ReceiveGetFileClientByFidAndOrderIdPackage:receiveData];
        [self makeReturnMessage:receiveData->suc forOperateType:TYPE_FILE_CLIENT];
        
    }
    else if (receiveData->type == TYPE_APPLY)
    {
        //随机因子不同
        if (receiveData->userData.random != self.Random)
        {
            NSLog(@"return operate server suc = 0");
            [self makeReturnMessage:-1 forOperateType:TYPE_APPLY];
            return;
        }
        [self receiveApplyFileByFidAndOrderIdPackage:receiveData];
        [self makeReturnMessage:receiveData->suc forOperateType:TYPE_APPLY];
        
    }
    else if (receiveData->type == TYPE_REAPPLY)
    {
        //随机因子不同
        if (receiveData->userData.random != self.Random)
        {
            [self makeReturnMessage:-1 forOperateType:TYPE_REAPPLY];
            return;
        }
        
        [self receiveReapplyFileInfoByIdPackage:receiveData];

        [self makeReturnMessage:receiveData->suc forOperateType:TYPE_REAPPLY];
        
    }
    else if (receiveData->type == TYPE_FILE_VERIFICATIONCODE
              || receiveData->type == NewPycUerRemoteOperateTypeGetConfirm)
    {
        //随机因子不同
        if (receiveData->userData.random != self.Random)
        {
            [self makeReturnMessage:-1 forOperateType:fileOperateType];
            return;
        }
        
        [self receiveVerificationCodeInfoByIdPackage:receiveData];
        
        [self makeReturnMessage:receiveData->suc forOperateType:fileOperateType];
        
    }
    else if(receiveData->type == NewPycUerRemoteOperateTypeBindPhone)
    {
        NSLog(@"绑定手机号...");
        if (receiveData->suc == 0) {
            [self makeReturnMessage:0 forOperateType:NewPycUerRemoteOperateTypeBindPhone];
            return;
        }
        [self makeReturnMessage:receiveData->suc forOperateType:NewPycUerRemoteOperateTypeBindPhone];
    }
}

#pragma mark - 制作
#pragma mark pbb文件
-(BOOL)makePycFilePath: (NSString * )filePath
             fileOwner:(NSString *)fileowner
              startDay:(NSString *)startDay
                endDay:(NSString *)endday
            maxOpenNum:(NSInteger) openNumMax
                remark:(NSString *)theRemark
               version:(NSString *)theVersion
              duration:(NSInteger)duration
                    qq:(NSString *)theQQ
                 email:(NSString *)theEmail
                 phone:(NSString *)thePhone
            maxOpenday:(NSInteger )theOpenDay
           maxOpenyear:(NSInteger )theOpenYear
              makeType:(NSInteger)theMakeType

{
    NSInteger openTimeLone = duration;
    self.remark = theRemark;
    
    //add by lry 2014-05-05
    self.openTimeLong = openTimeLone;
    self.versionStr = theVersion;
    self.QQ = theQQ;
    self.email = theEmail;
    self.phone = thePhone;
    self.openDay = theOpenDay;
    self.openYear = theOpenYear;
    self.Random = arc4random() % ARC4RANDOM_MAX;
    self.makeType = theMakeType;
    //add end
    
    return [self makePycFilePath:filePath fileOwner:fileowner startDay:startDay endDay:endday maxOpenNum:openNumMax foruser:fileowner];
}
-(BOOL)makePycFilePath: (NSString * )filePath
             fileOwner:(NSString *)fileowner
              startDay:(NSString *)startDay
                endDay:(NSString *)endday
            maxOpenNum:(NSInteger)openNumMax
               foruser:(NSString *)logname
{
    if (logname == nil) {
        return NO;
    }
    BOOL bReturn = NO;
    NSError *err;
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:filePath]) {
        return bReturn;
    }
    NSDictionary *fileAttributes = [manager attributesOfItemAtPath:filePath error:&err];
    if (!fileAttributes) {
        
        NSLog(@"file size is nil");
        return bReturn;//--------
    }
    NSInteger fileSizeOriginal = [[fileAttributes objectForKey:NSFileSize] integerValue];
    if (fileSizeOriginal <= 0) {
        return bReturn;
    }

    self.fileName = filePath;
    self.filePycName = [self getNotExistPycName:self.fileName forUser:logname];
    if (self.filePycName == nil) {
        return  NO;
    }
    self.filePycNameFromServer = [self.filePycName lastPathComponent];
    self.fileOwner = fileowner;
    self.startDay = startDay;
    self.endDay = endday;
    self.AllowOpenmaxNum = openNumMax;
    
    
    
    self.pycsocket = [[PycSocket alloc] init];
    self.pycsocket.delegate = self;
    self.pycsocket.connectType = TYPE_FILE_OUT;
    fileOperateType = TYPE_FILE_OUT;
    if (![self.pycsocket connectToServer:IP_ADDRESS_FILE port:PORT_OUTFILE]) {
        NSLog(@"connect err");
        return bReturn;
    }
    
    //    NSLog(@"will send");
    
    
    bReturn = YES;
    
    return bReturn;
}
//封装制作文件请求包
-(void)MakeFileOutPackage:(SENDDATA_NEW_NEW *)data
{
    NSLog(@"*****************%s******************", __func__);
    
    memset(data, 0, sizeof(SENDDATA_NEW_NEW));
    NSString *strFileOutName = [self.filePycName lastPathComponent];
    NSLog(@"file out pyc %@", strFileOutName);
    
    //modified by lry 2014-05-05;0:手动激活；1：自由传播
    if(self.makeType == 0)
    {
        data->type = TYPE_FILE_OUT_SALER_APPLY;
    }
    else
    {
        data->type = TYPE_FILE_OUT;
    }
    //modified end
    
    memcpy(&(data->userData.logName[0]), [self.fileOwner UTF8String] , MIN([self.fileOwner lengthOfBytesUsingEncoding:NSUTF8StringEncoding], USERNAME_LEN));
    memcpy(&(data->userData.fileoutName[0]), [strFileOutName UTF8String], MIN([strFileOutName lengthOfBytesUsingEncoding:NSUTF8StringEncoding], FILENAME_LEN));
    memcpy(&(data->userData.startTime[0]), [self.startDay UTF8String], MIN([self.startDay lengthOfBytesUsingEncoding:NSUTF8StringEncoding], TIME_LEN));
    memcpy(&(data->userData.endTime[0]), [self.endDay UTF8String], MIN([self.endDay lengthOfBytesUsingEncoding:NSUTF8StringEncoding], TIME_LEN));
    memcpy(&(data->userData.remark[0]), [self.remark UTF8String], MIN([self.remark lengthOfBytesUsingEncoding:NSUTF8StringEncoding], REMARK_LEN));
    memcpy(&(data->userData.versionStr[0]), [self.versionStr UTF8String], MIN([self.versionStr lengthOfBytesUsingEncoding:NSUTF8StringEncoding], VERSION_LEN));
    
    //add by lry 2014-05-05
    memcpy(&(data->userData.QQ[0]), [self.QQ UTF8String] , MIN([self.QQ lengthOfBytesUsingEncoding:NSUTF8StringEncoding], QQ_LEN));
    memcpy(&(data->userData.email[0]), [self.email UTF8String] , MIN([self.email lengthOfBytesUsingEncoding:NSUTF8StringEncoding], EMAIL_LEN));
    memcpy(&(data->userData.phone[0]), [self.phone UTF8String] , MIN([self.phone lengthOfBytesUsingEncoding:NSUTF8StringEncoding], PHONE_LEN));
    //memcpy(&(data->userData.nick[0]), [self.nickname UTF8String], [self.nickname length]);
    data->userData.appType = CURRENTAPPTYPE;
    data->userData.random = self.Random;
    data->userData.version = VERSION;
    data->userData.dayNum = (int)self.openDay;
    data->userData.yearNum = (int)self.openYear;
    //add end
    
    data->userData.fileOpenNum = (int)self.AllowOpenmaxNum;
    data->userData.iOpenTimeLong = (int)self.openTimeLong;
    //add by lry 2014-9-17
    data->userData.fileversion = 1;
    //add end
    PycCode *coder = [[PycCode alloc] init];
    [coder codeBuffer:(Byte *)&(data->userData) length:sizeof(STRUCTDATA_NEW_NEW)];
}
//制作pbb文件
-(BOOL)makePycFile
{
    NSError * err;
    BOOL bReturn;
    
    Byte r1[SECRET_KEY_LEN];
    Byte r1new[SECRET_KEY_LEN];
    Byte r2[SECRET_KEY_LEN];
    PycCode *coder = [[PycCode alloc] init];
    [coder generateSecretKey: r1 length:SECRET_KEY_LEN];
    [coder generateSecretKey:r2 length:SECRET_KEY_LEN];
    
    self.fileSecretkeyOrigianlR1 = [[NSData alloc] initWithBytes:r1 length:SECRET_KEY_LEN];
    self.fileSessionkeyOrigianlRR2 = [[NSData alloc] initWithBytes:r2 length:SECRET_KEY_LEN];
    
    [coder getSecretKeyFromOriginalKey:(Byte *)[self.fileSecretkeyOrigianlR1 bytes] to:r1new];
    self.fileSecretkeyR1 = [[NSData alloc] initWithBytes:r1new length:SECRET_KEY_LEN];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    //判断是否移动-------
    if ([manager copyItemAtPath:self.fileName toPath:self.filePycName error:&err] != YES)
    {
        NSLog(@"Unable to move file: %@", [err localizedDescription]);
        
        return NO;
    }
    //得到文件大小 补齐16位
    NSNumber *fileSizeOriginal ;
    NSDictionary *fileAttributes = [manager attributesOfItemAtPath:self.filePycName error:&err];
    if (!fileAttributes) {
        
        NSLog(@"file size is nil");
        return NO;//--------
    }
    fileSizeOriginal = [fileAttributes objectForKey:NSFileSize];
    
    PYCFILEHEADER fileHead;
    memset(&fileHead, 0, sizeof(PYCFILEHEADER));
    NSLog(@"pychead size is   %ld",  sizeof(PYCFILEHEADER));
    fileHead.uTag = PycTag0;
    fileHead.fileSize =fileSizeOriginal.longValue;
    
    //补齐文件长度
    long fileToAdd = [fileSizeOriginal longValue];
    long a = (fileToAdd%16);
    if (a != 0) {
        
        NSLog(@"00 need to add %ld", 16-a);
        Byte byteAdd[16 - a];
        memset(byteAdd, 0, 16 - a);
        NSData *dataAdd = [[NSData alloc] initWithBytes:byteAdd length:16-a];
        NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:self.filePycName];
        [handle seekToEndOfFile];
        [handle writeData: dataAdd];//-----------------write 0
        fileHead.encryptSize = 16 - a;
        [handle closeFile];
    }
    else
    {
        NSLog(@"000 need not");
    }
    
    
    //code file
    fileHead.encryptSize = [self codePycFile:self.filePycName filetype:[self getFileType:self.fileName]];
    //添加文件头
    Byte *fileHeader = (Byte *)&fileHead;
    NSData *dataFileheader = [[NSData alloc] initWithBytes:fileHeader length:sizeof(PYCFILEHEADER)];
    NSFileHandle *filehandle = [NSFileHandle fileHandleForUpdatingAtPath:self.filePycName];
    [filehandle seekToEndOfFile];
    [filehandle writeData: dataFileheader];//-------------------write file head
    
    NSLog(@"pychead size is   %lu",  sizeof(PYCFILEHEADER));
    //添加离线机构
    OUTLINE_STRUCT fileOutLineStruction;
    memset(&fileOutLineStruction,0,sizeof(OUTLINE_STRUCT));
    fileOutLineStruction.structflag = PycTag0;
    //用sessionKey加密离线机构
    [coder codeBufferOfFile:(Byte*)&fileOutLineStruction length:sizeof(fileOutLineStruction) withKey:(Byte *)[self.fileSessionkeyOrigianlRR2 bytes]];
    NSData *dataFileOutLineHeader = [[NSData alloc] initWithBytes:&fileOutLineStruction length:sizeof(OUTLINE_STRUCT)];
    [filehandle seekToEndOfFile];
    [filehandle writeData: dataFileOutLineHeader];
    
    //添加扩展头
    PYCFILEEXT fileExtension;
    memset(&fileExtension, 0, sizeof(PYCFILEEXT));
    fileExtension.uTag= PycTag1;
    fileExtension.nFileId = (int)self.fileID;
    [coder getSessionKeyFromOriginalKey:(Byte *)[self.fileSessionkeyOrigianlRR2 bytes] to:(Byte *)fileExtension.szSessionKey];
    self.fileSessionkeyR2 = [[NSData alloc] initWithBytes:(Byte *)fileExtension.szSessionKey length:SESSION_KEY_LEN];
    fileExtension.dwCrcValue = 0;
    [coder codeFileExtension:&fileExtension];
    
    NSData *dataFileExtentionHeader = [[NSData alloc] initWithBytes:&fileExtension length:sizeof(PYCFILEEXT)];
    [filehandle seekToEndOfFile];
    [filehandle writeData: dataFileExtentionHeader];
    [filehandle closeFile];
    
    Byte hashValue[HASH_LEN];
    memset(hashValue, 0, HASH_LEN);
    //    [coder CalculateHashValue:&&fileExtension datalen:sizeof(PYCFILEEXT) hashValue:hashValue];
    //   if (![self generateHash:self.filePycName outHash:hashValue length:HASH_LEN]) {
    if (![coder CalculateHashValue:(Byte*)&fileExtension datalen:sizeof(PYCFILEEXT) hashValue:hashValue]) {
        
        NSLog(@"generate hash err");
        self.fileHash = nil;
        return NO;//-----------
    }else
    {
        self.fileHash = [[NSData alloc] initWithBytes:hashValue length:HASH_LEN];
        [self printHash:(Byte *)[self.fileHash bytes]];
    }
    
    bReturn = YES;
    
_ALL_END:
    return bReturn;
}
#pragma mark 加密方法
-(NSInteger)codeFile:(NSString *)filePath length:(NSInteger) codeLen
{
    //get file len
    NSInteger readReallen = 0;
    NSInteger preReadMaxLen = 1024 ;
    NSInteger filePos = 0;
    NSInteger encodelen = 0;
    BOOL bFinish = NO;
    
    NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    if (handle == nil) {
        return -1;
    }
    
    while (!bFinish) {
        
        NSData *data = [handle readDataOfLength:preReadMaxLen];
        
        readReallen += [data length];
        if ([data length] == 0) {
            NSLog(@"finish code %ld", (long)readReallen); //-------
            break;
        }
        
        
        if (readReallen >= codeLen) {
            encodelen = [data length] - (readReallen -codeLen);
            NSLog(@"last encrypt len %ld", (long)encodelen);
            readReallen = codeLen;//-------
            bFinish = YES;
        }else
        {
            encodelen = [data length];
        }
        
        
        PycCode *coder = [[PycCode alloc] init];
        [coder codeBufferOfFile:(Byte *)[data bytes] length:(int)encodelen withKey:(Byte *)[self.fileSecretkeyR1  bytes]];
        
        [handle seekToFileOffset:filePos];
        [handle writeData:data];
        filePos += encodelen;
    }
    
    [handle closeFile];
    
    return readReallen;
}

-(NSInteger)codePycFile:(NSString *)filePath filetype:(NSInteger)fileType;
{
    if ([self isFileEncode:filePath]) {
        [self decodeFile:filePath];
    }
    
    int codeLen = 0;
    switch(fileType)
    {
        case FILE_TYPE_MOVIE:
            
            codeLen = LEN_MOVIE;
            break;
        case FILE_TYPE_PDF:
            codeLen = LEN_PDF;
            break;
        case FILE_TYPE_PIC:
            codeLen = LEN_PIC;
            break;
        case FILE_TYPE_UNKOWN:
            //#warning test just
            codeLen = LEN_UNKOWN;// to do ......
            break;
        default:
            NSLog(@"something err");
    }
    return [self codeFile:filePath length:codeLen];
}

-(BOOL)isFileEncode:(NSString *)filePath
{
    return NO;
}

-(NSInteger)decodeFile:(NSString *)filePath
{
    return 1;
}
#pragma mark 加密制作后上传服务器
-(void)uploadMakePycFile
{
    //.pbb文件制作成功后，pbb信息上传到服务器
    if (![self.pycsocket connectToServer:IP_ADDRESS_FILE port:PORT_OUTFILE])
    {
        NSLog(@"connect err when send file out");
        [self makeReturnMessage:0 forOperateType:TYPE_FILE_OUT];
    }
    self.pycsocket.delegate = self;
    self.pycsocket.connectType = TYEP_FILE_SAVE_HASH_ENCRYPT;
}
//封装上传制作后的pbb信息请求包
-(void)MakeSaveHashAndSecretPackage:(SENDDATA_NEW_NEW *)data
{
    memset(data, 0, sizeof(SENDDATA_NEW_NEW));
    
    (*data).type = TYEP_FILE_SAVE_HASH_ENCRYPT;
    
    PycCode *coder = [[PycCode alloc] init];
    
    memcpy((Byte *)(data->userData.EncodeKey), [self.fileSecretkeyOrigianlR1 bytes], SECRET_KEY_LEN);
    memcpy((Byte *)(data->userData.SessionKey), [self.fileSessionkeyOrigianlRR2 bytes], SECRET_KEY_LEN);
    memcpy((Byte *)(data->userData.HashValue ), [self.fileHash bytes], HASH_LEN);
    
    //add by lry 2014-05-05
    data->userData.random = self.Random;
    data->userData.version = VERSION;
    //add end
    
    [coder codeBuffer:(Byte *)&((*data).userData) length:sizeof(SENDDATA_NEW_NEW)];
    
}

//解析响应包
#pragma mark - 修改pbb文件阅读条件
-(BOOL)changePycFileReadCondition:(NSInteger ) theOpenCondition
                        forFileId:(NSInteger )theFileId
                          forUser:(NSString *)theFileowner
{
    BOOL bReturn = NO;
    if ((theOpenCondition != FILE_READ_CONDITION_CANOPEN && theOpenCondition != FILE_READ_CONDITION_CANNOTOPEN)
        ||
        theFileId < 0
        ||
        theFileowner == nil)
    {
        return bReturn;
    }
    
    self.fileOwner = theFileowner;
    self.pycsocket = [[PycSocket alloc] initWithDelegate:self];
    self.pycsocket.connectType = TYPE_FILE_CHANGE_READ_CONDITION;
    fileOperateType = TYPE_FILE_CHANGE_READ_CONDITION;
    self.fileID = theFileId;
    self.iCanOpen = theOpenCondition;
    
    //add by lry 2014-05-05
    self.Random = arc4random() % ARC4RANDOM_MAX;
    //add end
    
    if (![self.pycsocket connectToServer:IP_ADDRESS_FILE port:PORT_FILE]) {
        NSLog(@"connect err");
        return bReturn;
    }
    bReturn = YES;
    return bReturn;
}
//封装修改条件请求数据包
-(void)makePycFileReadConditionPackage:(SENDDATA_NEW_NEW *)data
{
    memset(data, 0, sizeof(SENDDATA_NEW_NEW));
    
    data->type = TYPE_FILE_CHANGE_READ_CONDITION;
    
    //add by lry 2014-05-05
    data->userData.random = self.Random;
    data->userData.version = VERSION;
    data->userData.appType = 33; //MAC版本
    //add end
    
    
    data->userData.iCanOpen = (int)self.iCanOpen;
    data->userData.ID = (int)self.fileID;
    memcpy(&(data->userData.logName[0]), [self.fileOwner UTF8String] , MIN([self.fileOwner lengthOfBytesUsingEncoding:NSUTF8StringEncoding], USERNAME_LEN));
    
    PycCode *coder = [[PycCode alloc] init];
    [coder codeBuffer:(Byte *)&(data->userData) length:sizeof(STRUCTDATA_NEW_NEW)];
    
}

#pragma mark 禁止阅读／取消禁止
-(BOOL)changePycFileStartDay:(NSString *)theStartDay endDay:(NSString *)theEndDay allowOpenedMaxNum:(NSInteger )theAllowOpenMaxNum openTimeLong:(NSInteger)theOpenTimeLong remark:(NSString *)theRemark forFileId:(NSInteger )theFileId forUser:(NSString *)theFileowner duration:(NSInteger)duration  qq:(NSString *)theQQ email:(NSString *)theEmail phone:(NSString *)thePhone
{
    
    NSInteger iOpenTime = duration;
    
    BOOL bReturn = NO;
    if ( theAllowOpenMaxNum < 0 || theOpenTimeLong < 0)
    {
        return bReturn;
    }
    
    self.fileOwner = theFileowner;
    self.pycsocket = [[PycSocket alloc] initWithDelegate:self];
    self.pycsocket.connectType = TYPE_FILE_CHANGE_FILE_CONTROLL;
    fileOperateType = TYPE_FILE_CHANGE_FILE_CONTROLL;
    self.fileID = theFileId;
    self.startDay = theStartDay;
    self.endDay = theEndDay;
    self.AllowOpenmaxNum =theAllowOpenMaxNum;
    self.openTimeLong = theOpenTimeLong;
    self.remark = theRemark;
    self.openTimeLong = iOpenTime;
    
    //add by lry 2014-05-07
    self.QQ = theQQ;
    self.email = theEmail;
    self.phone = thePhone;
    //add end
    //add by lry 2014-05-05
    self.Random = arc4random() % ARC4RANDOM_MAX;
    //add end
    
    if (![self.pycsocket connectToServer:IP_ADDRESS_FILE port:PORT_FILE]) {
        NSLog(@"connect err");
        return bReturn;
    }
    bReturn = YES;
    return bReturn;
}
//封装取消／禁止请求数据包
-(void)makePycFileChangeControllPackage:(SENDDATA_NEW_NEW *)data
{
    memset(data, 0, sizeof(SENDDATA_NEW_NEW));
    
    data->type = TYPE_FILE_CHANGE_FILE_CONTROLL;
    
    //add by lry 2014-05-05
    data->userData.random = self.Random;
    data->userData.version = VERSION;
    data->userData.appType = CURRENTAPPTYPE;
    //add end
    
    //add by lry 2014-05-07
    memcpy(&(data->userData.QQ[0]), [self.QQ UTF8String] , MIN([self.QQ lengthOfBytesUsingEncoding:NSUTF8StringEncoding], QQ_LEN));
    memcpy(&(data->userData.email[0]), [self.email UTF8String] , MIN([self.email lengthOfBytesUsingEncoding:NSUTF8StringEncoding], EMAIL_LEN));
    memcpy(&(data->userData.phone[0]), [self.phone UTF8String] , MIN([self.phone lengthOfBytesUsingEncoding:NSUTF8StringEncoding], PHONE_LEN));
    //add end
    memcpy(&(data->userData.logName[0]), [self.fileOwner UTF8String] , MIN([self.fileOwner lengthOfBytesUsingEncoding:NSUTF8StringEncoding], USERNAME_LEN));
    
    memcpy(&(data->userData.startTime[0]), [self.startDay UTF8String], MIN([self.startDay lengthOfBytesUsingEncoding:NSUTF8StringEncoding], TIME_LEN));
    memcpy(&(data->userData.endTime[0]), [self.endDay UTF8String], MIN([self.endDay lengthOfBytesUsingEncoding:NSUTF8StringEncoding], TIME_LEN));
    data->userData.fileOpenNum = (int)self.AllowOpenmaxNum;
    memcpy(&(data->userData.remark[0]), [self.remark UTF8String], MIN([self.remark lengthOfBytesUsingEncoding:NSUTF8StringEncoding], REMARK_LEN));
    data->userData.iOpenTimeLong = (int)self.openTimeLong;
    data->userData.ID = (int)self.fileID;
    
    PycCode *coder = [[PycCode alloc] init];
    [coder codeBuffer:(Byte *)&(data->userData) length:sizeof(STRUCTDATA_NEW_NEW)];
}

#pragma mark - 解密
#pragma mark 文件并浏览
-(BOOL)seePycFile:(NSString *)pycFileName
          forUser:(NSString *)logname
          pbbFile:(NSString *)pbbFileName
          phoneNo:(NSString *)phoneNo
        messageID:(NSString *)messageID
        isOffLine:(BOOL*)bIsOFFLine
    FileOpenedNum:(NSInteger)openedNum
{
    NSLog(@"查看业务时间点：%@",[NSDate date]);
    // seefileForuser = YES;
    *bIsOFFLine = FALSE;
    BOOL bReturn = NO;
    self.iResultIsOffLine = FALSE;
    self.fileSeeLogname = logname;
    self.filePycName = pycFileName;
    self.bindingPhone = phoneNo;
    self.verificationCodeID = messageID;
    self.haveOpenedNum = openedNum;
    if ([pbbFileName isEqualToString:@""]) {
        pbbFileName = [pycFileName lastPathComponent];
    }
    if ([pbbFileName isEqualToString:@""] || pbbFileName == nil )
    {
        self.filePycNameFromServer = [self.filePycName lastPathComponent];
    }
    else
    {
        self.filePycNameFromServer = pbbFileName;
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:pycFileName])
    {
        NSLog(@"no file");
        return bReturn;
    }
    
    if (logname == nil) {
        return  NO;
    }
    
    //step 1 get hash value fileHash
    Byte hashValue[HASH_LEN];
    NSInteger haveOutStru = 0;
    memset(hashValue, 0, HASH_LEN);
    
    //生成文件hash
    if (![self generateHash:self.filePycName
                    outHash:hashValue
                     length:HASH_LEN
                haveOutStru:&haveOutStru]) {
        NSLog(@"file hash err");
        return bReturn;
    }
    
    //文件hash
    self.fileHash = [[NSData alloc] initWithBytes:hashValue length:HASH_LEN];
    
    //step 2 get file ext head fileID
    b_needNet = TRUE;
    __block int i_canSeeForOutline = 0;
    NSNumber *fileSize ;
    NSError *err;
    //得到文件大小
    NSDictionary *fileAttributes = [manager attributesOfItemAtPath:self.filePycName error:&err];
    if (fileAttributes != nil) {
        
        fileSize = [fileAttributes objectForKey:NSFileSize];
        NSLog(@"%ld", fileSize.longValue);
    }
    
    long structsize =  sizeof(PYCFILEEXT);
    long fileheadoffset = (fileSize.longValue > structsize)? (fileSize.longValue - structsize):0;
    if(fileheadoffset == 0)
    {
        NSLog(@"nothing in in");
        return bReturn;
    }
    //    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:self.filePycName];
    NSRange range = [_filePycName rangeOfString:@"Inbox"];
    //     if (haveOutStru == 1 && range.length>0) {
    if (range.length>0) {
        //取得接收目录，把源pbb文件拷贝到接收目录中，
        NSLog(@"把源文件拷贝到接收目录中");
        self.filePycName = [self getNotExistRecievePycName:pycFileName forUser:logname];
        NSFileManager *manager = [NSFileManager defaultManager];
        //重命名
        //判断是否移动-------
        if ([manager copyItemAtPath:pycFileName toPath:self.filePycName error:&err] != YES)
        {
            NSLog(@"Unable to move file: %@", [err localizedDescription]);
            
            return NO;
        }
        //删除inbox下的文件
        NSString *ducomentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *inboxPath = [ducomentPath stringByAppendingString:@"/Inbox/"];
        NSArray *fileArray = [manager subpathsAtPath:inboxPath];
        for (NSString *fileName in fileArray) {
            NSString *filePath = [inboxPath stringByAppendingString:fileName];
            if ([manager fileExistsAtPath:filePath]) {
                [manager removeItemAtPath:filePath error:nil];
            }
        }
    }
    
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:self.filePycName];
    [handle seekToFileOffset:fileheadoffset];
    //读取扩展结构
    NSData *dataExt = [handle readDataOfLength:sizeof(PYCFILEEXT)];
    PYCFILEEXT *fileExtHeader = (PYCFILEEXT *)[dataExt bytes];
    PycCode *coder = [[PycCode alloc] init];
    [coder decodeFileExtension:fileExtHeader];
    self.fileID = fileExtHeader->nFileId;
    NSInteger applyID = 0;
    [handle closeFile];
    
    fileOperateType = TYPE_FILE_OPEN;
    //网络状况，决定是否执行离线文件
    /**
     *  b_needNet
     *   YES时:说明需要联网，即离线文件的阅读权限失效，或新的文件，此时直接废弃离线结构，联网即可
     *    NO时:说明不必联网，即离线文件还有阅读权限，先将离线结构体数据另存到数据库中，再同步到服务器端
     *  对旧的离线文件，先把离线文件属性已到本地数据库中
     *  对新的离线文件，必须联网，以前的离线属性结构废弃
     */
    
    //如果本地数据库中，没有该文件记录，就执行如下代码
    
    //数据库中都存在
    
    //离线问题
    if (_receiveFile == nil) {
        _receiveFile = [[ReceiveFileDao sharedReceiveFileDao] fetchReceiveFileCellByFileId:_fileID
                                                                                   LogName:[[userDao shareduserDao] getLogName]];
    }
    
    //支持广告离线阅读
    *bIsOFFLine = TRUE;
    if(_receiveFile!=nil && _receiveFile.fileMakeType == 0)
    {
        
        //手动激活
        //需要联网:支持离线新文件和在线文件
        if(_receiveFile.EncodeKey == nil){
            
            //是否需要联网
            b_needNet = [self isFileNeedNet:self.filePycName applyID:&applyID];
            self.applyId = applyID;
            
            //查看旧版离线文件修改属性
            if(!b_needNet)
            {
                NSLog(@"查看离线文件....");
                //不需要联网时
                i_canSeeForOutline = [self isOutLineFileCanSee:self.filePycName remainDay:nil remainYear:nil] ;
                //根据返回值处理文件，解析离线文件结构体，对self赋值
                //                [self modifySourceFileByOutlineValue:i_canSeeForOutline filename:self.filePycName];
                //根据返回值返回给回调函数，结束本次处理
                if(i_canSeeForOutline == ERR_OUTLINE_OK)
                {
                    //解析离线文件并赋值self的属性
                    if(![self setSeeInfoFromOutLineStru:self.filePycName])
                    {
                        i_canSeeForOutline = ERR_OUTLINE_OTHER_ERR;
                    }
                    else{
                        i_canSeeForOutline |= ERR_OK_IS_FEE;
                    }
                }
                self.iResultIsOffLine = TRUE;
                
                _receiveFile.canSeeForOutline = i_canSeeForOutline;
                
                /**
                 *  网络异常时，直接回调查看的协议方法
                 *  网络正常时，访问服务器，同步数据，根据返回值判断是否能读，
                 *  如果返回值是 “网络不给力”，此时采用离线阅读流程，并将离线结构体中的数据移动到本地数据库
                 */
                if(![ToolString isConnectionAvailable])
                {
                    NSLog(@"查看文件时，网络异常...开始离线阅读1");
                    //主线程中，回调协议的方法
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //离线阅读
                        [self makeReturnMessage:i_canSeeForOutline forOperateType:TYPE_FILE_OPEN];
                    });
                    
                    return TRUE;
                }
                
            }
            
        }else {
            //数据库已经保存有encodekey
            
            
            if (_receiveFile.status)
            {
                b_needNet = NO;
            }
            
            
            
            if(![ToolString isConnectionAvailable]){
                //网络异常
                NSLog(@"查看文件时，网络异常...开始离线阅读2");
                if (_receiveFile.status) {
                    //旧版本手动激活文件，可读时
                    //解析离线文件，并给self赋值,获取明文文件
                    [self setValueOfSelfByNewFile:_receiveFile];
                }
                
                //离线阅读手动激活文件
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self makeReturnMessage:_receiveFile.canSeeForOutline forOperateType:TYPE_FILE_OPEN];
                });
                
                return YES;
            }
            
        }
        
    }
    
    //add by lry 2014-05-05
    self.Random = arc4random() % ARC4RANDOM_MAX;
    //add end
    
    // int temp = 0;
    //    __unsafe_unretained PycFile *pf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //访问网络
        self.pycsocket = [[PycSocket alloc] init];
        self.pycsocket.delegate = self;
        self.pycsocket.connectType = TYPE_FILE_OPEN;
        
        if (![self.pycsocket connectToServer:IP_ADDRESS_FILE port:PORT_FILE]) {
            NSLog(@"connect file server err");
        }
        
    });
    
    bReturn = YES;
    return bReturn;
}
/**
 1:no file
 2:no logname
 3:file hash err
 4:nothing in file
 5:Unable to move file
 0:正常
 **/
-(NSString *)seePycFile2:(NSString *)pycFileName
                 forUser:(NSString *)logname
                 pbbFile:(NSString *)pbbFileName
                 phoneNo:(NSString *)phoneNo
               messageID:(NSString *)messageID
               isOffLine:(BOOL*)bIsOFFLine
           FileOpenedNum:(NSInteger)openedNum
{
    NSLog(@"查看业务时间点：%@",[NSDate date]);
    // seefileForuser = YES;
    *bIsOFFLine = FALSE;
    NSString *bReturn = @"0";
    self.iResultIsOffLine = FALSE;
    self.fileSeeLogname = logname;
    self.filePycName = pycFileName;
    self.bindingPhone = phoneNo;
    self.verificationCodeID = messageID;
    self.haveOpenedNum = openedNum;
    if ([pbbFileName isEqualToString:@""])
    {
        pbbFileName = [pycFileName lastPathComponent];
    }
    if ([pbbFileName isEqualToString:@""] || pbbFileName == nil )
    {
        self.filePycNameFromServer = [self.filePycName lastPathComponent];
    }
    else
    {
        self.filePycNameFromServer = pbbFileName;
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:pycFileName])
    {
        NSLog(@"no file");
        bReturn=@"1";
        return  bReturn;
    }
    
    if (logname == nil) {
        bReturn=@"2";
        return  bReturn;
    }
    
    //step 1 get hash value fileHash
    Byte hashValue[HASH_LEN];
    NSInteger haveOutStru = 0;
    memset(hashValue, 0, HASH_LEN);
    
    //生成文件hash
    if (![self generateHash:self.filePycName
                    outHash:hashValue
                     length:HASH_LEN
                haveOutStru:&haveOutStru]) {
        NSLog(@"file hash err");
        bReturn=@"3";
        return  bReturn;
    }
    
    //文件hash
    self.fileHash = [[NSData alloc] initWithBytes:hashValue length:HASH_LEN];
    
    //step 2 get file ext head fileID
    
    b_needNet = TRUE;
    __block int i_canSeeForOutline = 0;
    NSNumber *fileSize ;
    NSError *err;
    //得到文件大小
    NSDictionary *fileAttributes = [manager attributesOfItemAtPath:self.filePycName error:&err];
    if (fileAttributes != nil)
    {
        fileSize = [fileAttributes objectForKey:NSFileSize];
        NSLog(@"%ld", fileSize.longValue);
    }
    
    long structsize =  sizeof(PYCFILEEXT);
    long fileheadoffset = (fileSize.longValue > structsize)? (fileSize.longValue - structsize):0;
    if(fileheadoffset == 0)
    {
        NSLog(@"nothing in in");
        bReturn=@"4";
        return  bReturn;
    }

    //沙盒环境下，先移动到自定义目录中再进一步操作
    NSRange range = [_filePycName rangeOfString:@"Inbox"];
    if (range.length>0)
    {
        //取得接收目录，把源pbb文件拷贝到接收目录中，
        NSLog(@"把源文件拷贝到接收目录中");
        self.filePycName = [self getNotExistRecievePycName:pycFileName forUser:logname];
        NSFileManager *manager = [NSFileManager defaultManager];
        //重命名
        //判断是否移动-------
        if ([manager copyItemAtPath:pycFileName toPath:self.filePycName error:&err] != YES)
        {
            NSLog(@"Unable to move file: %@", [err localizedDescription]);
            bReturn=@"5";
            return  bReturn;
        }
        //删除inbox下的文件
        NSString *ducomentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *inboxPath = [ducomentPath stringByAppendingString:@"/Inbox/"];
        NSArray *fileArray = [manager subpathsAtPath:inboxPath];
        for (NSString *fileName in fileArray) {
            NSString *filePath = [inboxPath stringByAppendingString:fileName];
            if ([manager fileExistsAtPath:filePath]) {
                [manager removeItemAtPath:filePath error:nil];
            }
        }
    }
    
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:self.filePycName];
    [handle seekToFileOffset:fileheadoffset];
    //读取扩展结构
    NSData *dataExt = [handle readDataOfLength:sizeof(PYCFILEEXT)];
    PYCFILEEXT *fileExtHeader = (PYCFILEEXT *)[dataExt bytes];
    PycCode *coder = [[PycCode alloc] init];
    [coder decodeFileExtension:fileExtHeader];
    self.fileID = fileExtHeader->nFileId;
    NSInteger applyID = 0;
    [handle closeFile];
    
    fileOperateType = TYPE_FILE_OPEN;
    //网络状况，决定是否执行离线文件
    /**
     *  b_needNet
     *   YES时:说明需要联网，即离线文件的阅读权限失效，或新的文件，此时直接废弃离线结构，联网即可
     *    NO时:说明不必联网，即离线文件还有阅读权限，先将离线结构体数据另存到数据库中，再同步到服务器端
     *  对旧的离线文件，先把离线文件属性已到本地数据库中
     *  对新的离线文件，必须联网，以前的离线属性结构废弃
     */
    
    //如果本地数据库中，没有该文件记录，就执行如下代码
    
    //数据库中都存在
    
    //离线问题
    if (_receiveFile == nil)
    {
        _receiveFile = [[ReceiveFileDao sharedReceiveFileDao] fetchReceiveFileCellByFileId:_fileID
                                                                                   LogName:[[userDao shareduserDao] getLogName]];
    }
    
    //支持广告离线阅读
    *bIsOFFLine = TRUE;
    if(_receiveFile!=nil && _receiveFile.fileMakeType == 0)
    {
        //手动激活
        //需要联网:支持离线新文件和在线文件
        if(_receiveFile.EncodeKey == nil){
            
            //是否需要联网
            b_needNet = [self isFileNeedNet:self.filePycName applyID:&applyID];
            self.applyId = applyID;
            
            //查看旧版离线文件修改属性
            if(!b_needNet)
            {
                NSLog(@"查看离线文件....");
                //不需要联网时
                i_canSeeForOutline = [self isOutLineFileCanSee:self.filePycName remainDay:nil remainYear:nil] ;
                //根据返回值处理文件，解析离线文件结构体，对self赋值
                //                [self modifySourceFileByOutlineValue:i_canSeeForOutline filename:self.filePycName];
                //根据返回值返回给回调函数，结束本次处理
                if(i_canSeeForOutline == ERR_OUTLINE_OK)
                {
                    //解析离线文件并赋值self的属性
                    if(![self setSeeInfoFromOutLineStru:self.filePycName])
                    {
                        i_canSeeForOutline = ERR_OUTLINE_OTHER_ERR;
                    }
                    else{
                        i_canSeeForOutline |= ERR_OK_IS_FEE;
                    }
                }
                self.iResultIsOffLine = TRUE;
                
                _receiveFile.canSeeForOutline = i_canSeeForOutline;
                
                /**
                 *  网络异常时，直接回调查看的协议方法
                 *  网络正常时，访问服务器，同步数据，根据返回值判断是否能读，
                 *  如果返回值是 “网络不给力”，此时采用离线阅读流程，并将离线结构体中的数据移动到本地数据库
                 */
                if(![ToolString isConnectionAvailable])
                {
                    NSLog(@"查看文件时，网络异常...开始离线阅读1");
                    //主线程中，回调协议的方法
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //离线阅读
                        [self makeReturnMessage:i_canSeeForOutline forOperateType:TYPE_FILE_OPEN];
                    });
                    
                    bReturn=@"0";
                    return  bReturn;
                }
                
            }else{
                if(![ToolString isConnectionAvailable])
                {
                    //需要连网，并且网络异常
                    bReturn=@"6";
                    return  bReturn;
                }
            }
            
        }else {
            //数据库已经保存有encodekey
            if (_receiveFile.status)
            {
                b_needNet = NO;
            }
            
            if(![ToolString isConnectionAvailable])
            {
                //网络异常
                if (b_needNet) {
                    //此过程需要连网
                    bReturn=@"6";
                    return  bReturn;
                }else{
                    NSLog(@"查看文件时，网络异常...开始离线阅读2");
                    if (_receiveFile.status)
                    {
                        //旧版本手动激活文件，可读时
                        //解析离线文件，并给self赋值,获取明文文件
                        [self setValueOfSelfByNewFile:_receiveFile];
                    }
                    self.iResultIsOffLine = TRUE;
                    //根据本地数据库中的纪录判断文件是否可阅读
                    i_canSeeForOutline=[[ReceiveFileDao sharedReceiveFileDao] verifyOutFileCurrent:_receiveFile.fileid];
                    //离线阅读手动激活文件
                    if (i_canSeeForOutline&ERR_OK_OR_CANOPEN)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self makeReturnMessage:_receiveFile.canSeeForOutline forOperateType:TYPE_FILE_OPEN];
                            //                            [self makeReturnMessage:i_canSeeForOutline forOperateType:TYPE_FILE_OPEN];
                        });
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //                            [self makeReturnMessage:_receiveFile.canSeeForOutline forOperateType:TYPE_FILE_OPEN];
                            [self makeReturnMessage:i_canSeeForOutline forOperateType:TYPE_FILE_OPEN];
                        });
                    }
                    bReturn=@"0";
                    return  bReturn;
                }
            }
        }
        
    }
    else
    {
        if(![ToolString isConnectionAvailable])
        {
            bReturn=@"6";
            return bReturn;
        }
    }
    
    //add by lry 2014-05-05
    self.Random = arc4random() % ARC4RANDOM_MAX;
    //add end
    
    // int temp = 0;
    //    __unsafe_unretained PycFile *pf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //访问网络
        self.pycsocket = [[PycSocket alloc] init];
        self.pycsocket.delegate = self;
        self.pycsocket.connectType = TYPE_FILE_OPEN;
        
        if (![self.pycsocket connectToServer:IP_ADDRESS_FILE port:PORT_FILE]) {
            NSLog(@"connect file server err");
        }
    });
    
    bReturn = @"0";
    return bReturn;
}
//辅助方法：获取文件哈希值
-(BOOL)generateHash:(NSString *)filePath
            outHash:(Byte *)hashValueTodo
             length:(int)len
        haveOutStru:(NSInteger *)haveOutLine
{
    NSInteger fileSizeTodo = 0;
    Byte *fileContentTodo;
    BOOL allFileContent = NO;
    //  unsigned char hashvalue[HASH_STRUCT_LEN];
    memset(hashValueTodo, 0, len);
    //  unsigned char *hashValueTodo = hashvalue;
    
    //读文件
    NSError *err;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [manager attributesOfItemAtPath:filePath error:&err];
    NSNumber *fileSize;
    if (fileAttributes != nil) {
        fileSize = [fileAttributes objectForKey:NSFileSize];
        NSLog(@"file size is %@", fileSize);
    }
    
    //判断是否是PBB文件
    long structsize =  sizeof(PYCFILEEXT);
    long fileheadoffset = (fileSize.longValue > structsize)? (fileSize.longValue - structsize):0;
    if(fileheadoffset == 0)
    {
        NSLog(@"nothing in in");
        return FALSE;
    }
    
    if (fileSize.longValue >= HASH_FILE_SIZE_TODO) {
        fileSizeTodo = HASH_FILE_SIZE_TODO;
    }
    else{
        fileSizeTodo = fileSize.longValue;
        allFileContent = YES;
    }
    
    //文件柄
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    
    //将当前文件的操作位置设定为offset
    [handle seekToFileOffset:fileheadoffset];
    /*  NSData *data = [handle readDataOfLength:sizeof(PYCFILEHEADER)];
     
     PYCFILEHEADER *header = (PYCFILEHEADER *)[data bytes];
     NSLog(@"file original size really %lld", header->fileSize);
     */
    
    NSData *dataExt = [handle readDataOfLength:sizeof(PYCFILEEXT)];
    PYCFILEEXT *fileExtHeader = (PYCFILEEXT *)[dataExt bytes];
    PYCFILEEXT decodedData;
    memcpy(&decodedData, fileExtHeader, sizeof(PYCFILEEXT));
    PycCode *coder = [[PycCode alloc] init];
    [coder decodeFileExtension:&decodedData];
    if(decodedData.uTag == PycTag0)
    {
        NSInteger fileOffest = 0;
        
        if (!allFileContent)
        {
            fileOffest = fileSize.longValue - HASH_FILE_SIZE_TODO;
            
        }
        
        [handle seekToFileOffset:fileOffest];
        NSData *data = [handle readDataToEndOfFile];
        [handle closeFile];
        
        fileContentTodo = (Byte *)[data bytes];
    }
    else
    {
        *haveOutLine = 1;
        [handle closeFile];
        
        fileContentTodo = (Byte *)[dataExt bytes];
        fileSizeTodo = sizeof(PYCFILEEXT);
    }
    
    if (![coder CalculateHashValue:fileContentTodo datalen:(int)fileSizeTodo hashValue:hashValueTodo])
    {
        return NO;
    }
    return YES;
}
//封装浏览文件请求包
-(void)MakeOpenFilePackage:(SENDDATA_NEW_NEW *)data
{
    memset(data, 0, sizeof(SENDDATA_NEW_NEW));
    (*data).type = TYPE_FILE_OPEN;
    PycCode *coder = [[PycCode alloc] init];
    memcpy((Byte *)(data->userData.HashValue ), [self.fileHash bytes], HASH_LEN);
    memcpy((Byte *)(data->userData.phone ), [_bindingPhone UTF8String], PHONE_LEN);
    memcpy((Byte *)(data->userData.messageId ), [_verificationCodeID UTF8String], MESSAGE_ID_LEN);
    data->userData.ID = (int)self.fileID;
    //离线文件申请标识
    data->userData.applyId = (int)self.applyId;
    //为了客户端与服务器同步，传输已打开次数
    data->userData.fileOpenedNum = (int)self.haveOpenedNum;
    //add by lry 2014-05-05
    data->userData.random = self.Random;
    NSLog(@"random = %d", data->userData.random);
    data->userData.version = VERSION;
    data->userData.appType = CURRENTAPPTYPE;
    memcpy((Byte *)(data->userData.hardno ), [_OpenUUID UTF8String], HARDNO_LEN);  //例子:vindor
    memcpy((Byte *)(data->userData.sysinfo ), [_sysInfoVersion UTF8String], SYSINFO_LEN);//例子:IOS7.0
    memcpy(&(data->userData.logName[0]), [self.fileSeeLogname UTF8String] , MIN([self.fileSeeLogname lengthOfBytesUsingEncoding:NSUTF8StringEncoding], USERNAME_LEN));
    //add end
    [coder codeBuffer:(Byte *)&((*data).userData) length:sizeof(STRUCTDATA_NEW_NEW)];
}
//解析阅读文件的响应包
- (void)ReceiveOpenFileByFidPackage:(RECEIVEDATA_NEW_NEW *)receiveData
{
    self.hardno = _OpenUUID;
    self.fileSecretkeyOrigianlR1 = [[NSData alloc] initWithBytes:receiveData->userData.EncodeKey length: ENCRYPKEY_LEN];
    
    [self printByte:receiveData->userData.EncodeKey len:ENCRYPKEY_LEN description:@"miyao r1 "];
    /* //test because of server return 0
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString *documentsDirectory = [paths objectAtIndex:0];
     NSString *strFile = [NSString stringWithFormat:@"%@", [documentsDirectory stringByAppendingPathComponent:@"save.txt"]];
     self.fileSecretkeyOrigianlR1 = [NSData dataWithContentsOfFile:strFile];
     */
    Byte fileScreateR1[ENCRYPKEY_LEN];
    PycCode *coder = [[PycCode alloc] init];
    [coder getSecretKeyFromOriginalKey:(Byte *)[self.fileSecretkeyOrigianlR1 bytes]  to:fileScreateR1];
    
    //密钥
    self.fileSecretkeyR1 = [[NSData alloc] initWithBytes:fileScreateR1 length: ENCRYPKEY_LEN];
    [self printByte:fileScreateR1 len:ENCRYPKEY_LEN description:@"miyao r1' "];
    self.fileOwner = [[NSString alloc] initWithBytes:receiveData->userData.logName length:USERNAME_LEN encoding:NSUTF8StringEncoding];
    self.filePycNameFromServer = [[NSString alloc]initWithBytes:receiveData->userData.fileoutName length:FILENAME_LEN encoding:NSUTF8StringEncoding];
    self.startDay =  [[NSString alloc]initWithBytes:receiveData->userData.startTime  length:TIME_LEN encoding:NSUTF8StringEncoding];
    self.endDay = [[NSString alloc]initWithBytes:receiveData->userData.endTime  length:TIME_LEN encoding:NSUTF8StringEncoding];
    self.AllowOpenmaxNum = receiveData->userData.fileOpenNum;
    self.haveOpenedNum = receiveData->userData.fileOpenedNum;
    self.bCanprint = receiveData->userData.bCanPrint;
    self.iCanOpen = receiveData->userData.iCanOpen;
    self.bNeedBinding = receiveData->userData.otherset&8;
    self.nickname = [[NSString alloc]initWithBytes:receiveData->userData.nick length:NICK_LEN encoding:NSUTF8StringEncoding];
    self.remark = [[NSString alloc]initWithBytes:receiveData->userData.remark length:REMARK_LEN encoding:NSUTF8StringEncoding];
    
    //添加接收系列ID字段
    //       fileversion:查看文件时返回该文件所属系列ID
    // 系列id改为apptype
    //        self.seriesID = receiveData->userData.fileversion;
    self.seriesID = receiveData->userData.appType;
    //       |查看文件时，返回系列中文件总数
    self.seriesFileNums = receiveData->userData.tableid;
    /*!
     系列名称
     */
    self.seriesName = [[NSString alloc] initWithBytes:receiveData->userData.seriesname length:SERIESNAME_LEN encoding:NSUTF8StringEncoding];
    self.seriesName = [self.seriesName stringByReplacingOccurrencesOfString:@"\0" withString:@""];
    //fileversion＝＝4:是否采用时间范围限制
    self.timeType=receiveData->userData.fileversion;
    NSLog(@"result is %d", receiveData->suc);
    
    //add by lry 2014-05-05
    if (strlen(receiveData->userData.QQ) == 0)
    {
        self.QQ = @"";
    }
    else
    {
        self.QQ = [[NSString alloc] initWithUTF8String:receiveData->userData.QQ];
    }
    
    if (strlen(receiveData->userData.phone) == 0)
    {
        self.phone = @"";
    }
    else
    {
        self.phone = [[NSString alloc] initWithUTF8String:receiveData->userData.phone];
    }
    
    if (strlen(receiveData->userData.email) == 0) {
        self.email = @"";
    }
    else
    {
        self.email = [[NSString alloc] initWithUTF8String:receiveData->userData.email];
    }
    
    self.dayRemain = receiveData->userData.dayRemain;
    self.yearRemain = receiveData->userData.yearRemain;
    self.orderID = receiveData->userData.ooid;
    self.makeFrom = receiveData->userData.appType;
    self.openDay = receiveData->userData.dayNum;
    self.openYear = receiveData->userData.yearNum;
    if (strlen(receiveData->userData.outTime)>0) {
        self.makeTime = [[NSString alloc] initWithUTF8String:(receiveData->userData.outTime)];
    }else
    {
        self.makeTime = @"";
    }
    
    if (strlen(receiveData->userData.firstSeeTime)>0) {
        self.firstSeeTime = [[NSString alloc] initWithUTF8String:(receiveData->userData.firstSeeTime)];
    }else{
        self.firstSeeTime = @"";
    }
    
    //        self.makeTime = [[NSString alloc]initWithBytes:receiveData->userData.outTime length:FIRST_SEE_TIME_LEN encoding:NSUTF8StringEncoding];
    //        self.firstSeeTime = [[NSString alloc]initWithBytes:receiveData->userData.firstSeeTime length:FIRST_SEE_TIME_LEN encoding:NSUTF8StringEncoding];
    //add end
    //add by lry 2014-7-14
    self.canseeCondition = receiveData->userData.otherset;
    if (strlen(receiveData->userData.field1) == 0) {
        self.field1 = @"";
    }
    else
    {
        self.field1 = [[NSString alloc] initWithUTF8String:(receiveData->userData.field1)];
    }
    if (strlen(receiveData->userData.field2) == 0) {
        self.field2 = @"";
    }
    else
    {
        NSLog(@"%s length = %lu", receiveData->userData.field2, strlen(receiveData->userData.field2));
        self.field2 = [[NSString alloc] initWithUTF8String:(receiveData->userData.field2)];
    }
    if (strlen(receiveData->userData.hardno) == 0) {
        self.fild1name = @"";
    }
    else
    {
        self.fild1name = [[NSString alloc] initWithUTF8String:(receiveData->userData.hardno)];
    }
    
    if (strlen(receiveData->userData.logName) == 0) {
        self.fild2name = @"";
    }
    else
    {
        self.fild2name = [[NSString alloc] initWithUTF8String:(receiveData->userData.logName)];
    }
    self.openinfoid = receiveData->userData.version;      //添加结束逻辑，所需的参数值
    self.definechecked = receiveData->userData.bindNum;   //服务器端对联系方式的勾选，根据勾选条件，申请激活，或显示水印
    self.selffieldnum = receiveData->userData.activeNum;  //自定义字段的个数
    self.field1needprotect = receiveData->userData.ID&1?1:0;  //1:保密
    self.field2needprotect = receiveData->userData.ID&2?1:0;  //1:保密
    self.applyId = receiveData->userData.applyId;
    self.showInfo = [[NSString alloc] initWithUTF8String:(receiveData->userData.showInfo)];
    //        self.showInfo = [[NSString alloc]initWithBytes:receiveData->userData.showInfo length:SHOW_INFO_LEN encoding:NSUTF8StringEncoding];
    self.iCanClient = receiveData->userData.iCanClient;
    self.needReapply = receiveData->userData.need_reapply;
    self.needShowDiff = receiveData->userData.need_showdiff;
    
    //add end
    self.openTimeLong = receiveData->userData.iOpenTimeLong;
    
    //文件类型
    self.fileType = [self getFileType:self.filePycNameFromServer];
    
    if (receiveData->suc & ERR_OK_OR_CANOPEN)
    {
        //离线机构，第一次查看需要设置离线结构
        if(receiveData->userData.iCanClient)
        {
            /**
             *  申请/重新申请成功过后，第一次阅读离线文件,写入离线文件属性值
             *  该步骤，将服务器返回的数据同步到本地数据库
             */
            
            [self setOutLineStructData:self.filePycName
                            isFirstSee:1
                            isSetFirst:0
                                 isSee:0
                            isVerifyOk:0
                       isTimeIsChanged:0
                         isApplySucess:0
                                  data:receiveData];
        }
        if([self getReceiveFileINfo])
        {
            [self makeOpenFile];
            
        }else{
            receiveData->suc = 0;
        }
    }
    else if(receiveData->suc & ERR_APPLIED)
    {
        /**
         *  申请/重新申请成功，但还不能读，离线结构体所有值都设为false
         *  该步骤在以后版本将不用
         */
        if(receiveData->userData.iCanClient)
        {
            self.applyId = receiveData->userData.applyId;
            [self setOutLineStructData:self.filePycName
                            isFirstSee:FALSE
                            isSetFirst:FALSE
                                 isSee:FALSE
                            isVerifyOk:FALSE
                       isTimeIsChanged:FALSE
                         isApplySucess:TRUE
                                  data:NULL];
        }
    }
}


#pragma mark 明文解密到本地辅助方法
-(BOOL) makeOpenFile
{
    long structsize = 0;
    long fileheadoffset = 0;
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSNumber *fileSize;
    NSError *err;
    //得到文件大小
    NSDictionary *fileAttributes = [manager attributesOfItemAtPath:self.filePycName error:&err];
    if (fileAttributes != nil)
    {
        fileSize = [fileAttributes objectForKey:NSFileSize];
        NSLog(@"%ld", fileSize.longValue);
    }
    
    structsize =  sizeof(PYCFILEEXT);
    fileheadoffset = (fileSize.longValue > structsize)? (fileSize.longValue - structsize):0;
    if(fileheadoffset == 0)
    {
        return FALSE;
    }
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:self.filePycName];
    if (!handle)
    {
        return FALSE;
    }
    //读取文件头扩展结构：PYCFILEEXT
    [handle seekToFileOffset:fileheadoffset];  //偏移量
    NSData *dataExt = [handle readDataOfLength:sizeof(PYCFILEEXT)];
    PYCFILEEXT *fileExtHeader = (PYCFILEEXT *)[dataExt bytes];
    //解密
    PycCode *coder = [[PycCode alloc] init];
    [coder decodeFileExtension:fileExtHeader];
    //文件头结构
    fileheadoffset -= sizeof(PYCFILEHEADER);
    if(fileExtHeader->uTag == PycTag1)
    {
        fileheadoffset -= sizeof(OUTLINE_STRUCT);
 
    }
    
    //读取文件头结构：PYCFILEHEADER：包括源文件大小，加密长度
    [handle seekToFileOffset:fileheadoffset];
    NSData *data = [handle readDataOfLength:sizeof(PYCFILEHEADER)];
    PYCFILEHEADER *header = (PYCFILEHEADER *)[data bytes];
    PycCode *coderheader = [[PycCode alloc] init];
    if (header->uTag!=PycTag1&&header->uTag!=PycTag0)
    {
        [coderheader decodeHeader:header];
    }
    NSLog(@"file original size really %lld", header->fileSize);
    [handle closeFile];
    
    //加密长度
    if(header->encryptSize != -1)
    {
        self.encryptedLen = header->encryptSize;
    }else
    {
        self.encryptedLen = header->fileSize;
    }
    
    //计算开始解密的位置
    long long decodebegin = 0;
    long long fileToAdd =  header->fileSize;  //源文件大小
    int a = (fileToAdd%16);
    if (a != 0) {
        
        NSLog(@"00 need to add %d", 16-a);
        decodebegin = fileToAdd+16-a;
    }
    else
    {
        decodebegin = fileToAdd;
        NSLog(@"000 need not");
        
    }
    
    self.fileSize = header->fileSize;
    self.offset =fileheadoffset-decodebegin;// decodebegin;
    
    //扩展名
    NSString *pathExt = [self.fileExtentionWithOutDot lowercaseString];
    if(pathExt.length ==0 || pathExt == nil)
    {
        return NO;
    }
    //如果是视频，使用bilibili浏览
    if([self fileIsTypeOfVideo:pathExt])
    {
        return NO;
    }
    //如果是pdf，不释放明文到本地，使用PDFKit查看
    if([pathExt isEqualToString:@"pdf"])
    {
        return NO;
    }
    
    //释放明文的路径
    NSString *toDestination = [self getNotExistFileNameFromPycFile:self.filePycNameFromServer
                                                     withExtention:[self.filePycNameFromServer pathExtension]
                                                           forUser:@"not use"];
    
    return [self moveFileAndDecodeFromAndBeginpos:self.filePycName
                                    partOfContent:self.fileSize
                                       decodeSize:self.encryptedLen
                                    toDestination:toDestination
                                         beginpos:self.offset];
}
//明文浏览时：解密文件到指定的目录中
-(BOOL)moveFileAndDecodeFromAndBeginpos:(NSString *)strFileName
                          partOfContent:(NSInteger)originalFileLen
                             decodeSize:(NSInteger)encryptLen
                          toDestination:(NSString *)strDestination
                               beginpos:(NSInteger)beginpos
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSLog(@"destnatin file is %@", strDestination);
    NSLog(@"strFileName file is %@", strFileName);
    if (![manager createFileAtPath:strDestination contents:nil attributes:nil])
    {
        NSLog(@"err");
        return NO;
    }
    
    NSError *error;
    if([manager fileExistsAtPath:strDestination])
    {
        //删除老文件
        [manager removeItemAtPath:strDestination error:&error];
    }
    //拷贝到目标地址
    if(![manager copyItemAtPath:strFileName toPath:strDestination error:&error])
    {
        NSLog(@"err");
        return NO;
    }

    //get file len
    NSInteger readReallen = 0;
    NSInteger preReadMaxLen = 1024*1024;
    NSInteger encodelen = 0;
    //    int readlen = 0;
    //    BOOL bDecodeFinish = NO;
    //    BOOL bCopyFinish = NO;
    BOOL bFinish = NO;
    NSInteger filePos = beginpos;
    
    //处理文件
    NSFileHandle *handleDestination = [NSFileHandle fileHandleForUpdatingAtPath:strDestination];
    if (!handleDestination ) {
        NSLog(@"file handle move err");
        return NO;
    }
    
    //_imageData = [[NSMutableData alloc] init];
    //解密完成
    while (!bFinish)
    {
        NSData *data = [[NSData alloc] init];
        
        data = [handleDestination readDataOfLength:preReadMaxLen];
        //NSData *data = [handleDestination readDataOfLength:preReadMaxLen];
        
        readReallen += [data length];
        if ([data length] == 0) {
            NSLog(@"finish code %ld", (long)readReallen);
            break;
        }
        
        if ((readReallen >= encryptLen) || (encryptLen == -1))
        {
            if(encryptLen == -1)
            {
                if(readReallen >= originalFileLen)
                {
                    if((readReallen-originalFileLen)%16 > 0)
                    {
                        encodelen = [data length] - (readReallen-originalFileLen) + 16 - (readReallen-originalFileLen)%16;
                    }
                    else
                    {
                        encodelen = [data length] - (readReallen-originalFileLen);
                    }
                    bFinish = YES;
                }
                else{
                    encodelen = [data length];
                }
            }
            else
            {
                encodelen = [data length] - (readReallen -encryptLen);
                NSLog(@"last encrypt len %ld", (long)encodelen);
                readReallen = encryptLen;
                bFinish = YES;
            }
        }else
        {
            encodelen = [data length];
        }
        
        PycCode *coder = [[PycCode alloc] init];
        [coder decodeBufferOfFile:(Byte *)[data bytes]
                           length:(int)encodelen
                          withKey:(Byte *)[self.fileSecretkeyR1 bytes]];
        
        //缓存图片到内存
        //        [_imageData appendData:data];
        
        [handleDestination seekToFileOffset:filePos];
        [handleDestination writeData:data];
        filePos += encodelen;
    }
    filePos = originalFileLen;
    [handleDestination seekToFileOffset:filePos];
    [handleDestination truncateFileAtOffset:filePos];
    [handleDestination closeFile];
    //明文释放成功复制给明文地址属性变量
    self.fileName = strDestination;
    return YES;
}

#pragma mark - 查看离线验证
-(BOOL)ClientFileById:(NSInteger )applyID fileOpenedNum:(NSInteger) fileOpenedNum
{
    BOOL bReturn = NO;
    self.Random = arc4random() % ARC4RANDOM_MAX;
    self.applyId = applyID;
    self.haveOpenedNum = fileOpenedNum;
    
    self.pycsocket = [[PycSocket alloc] init];
    self.pycsocket.delegate = self;
    self.pycsocket.connectType = TYPE_FILE_CLIENT;
    fileOperateType = TYPE_FILE_CLIENT;
    if (![self.pycsocket connectToServer:IP_ADDRESS_FILE port:PORT_FILE]) {
        return bReturn;
    }
    
    bReturn = YES;
    return bReturn;
}
- (void)MakeGetFileClientByFidAndOrderIdPackage:(SENDDATA_NEW_NEW *)data
{
    memset(data, 0, sizeof(SENDDATA_NEW_NEW));
    (*data).type = TYPE_FILE_CLIENT;
    PycCode *coder = [[PycCode alloc] init];
    
    data->userData.random = self.Random;
    memcpy((Byte *)(data->userData.hardno ), [_OpenUUID UTF8String], HARDNO_LEN);
    data->userData.fileOpenedNum = (int)self.haveOpenedNum;
    data->userData.applyId = (int)self.applyId;
    
    data->userData.appType = CURRENTAPPTYPE;
    
    
    [coder codeBuffer:(Byte *)&((*data).userData) length:sizeof(STRUCTDATA_NEW_NEW)];
}
- (void)ReceiveGetFileClientByFidAndOrderIdPackage:(RECEIVEDATA_NEW_NEW *)receiveData
{
    self.dayRemain = receiveData->userData.dayRemain;
    self.yearRemain = receiveData->userData.yearRemain;
}

#pragma mark - 刷新
#pragma mark 刷新文件列表
-(BOOL)refreshListInfoByFileId:(NSArray *)theFileIdsArray  listType:(NSInteger) theListType
{
    //从服务器得到ID
    //int temp = 0;
    if (theFileIdsArray == nil) {
        return NO;
    }
    BOOL bReturn = NO;
    
    fileIDs = [theFileIdsArray componentsJoinedByString:@","];
    
    self.pycsocket = [[PycSocket alloc] initWithDelegate:self];
    self.pycsocket.connectType = TYPE_FILE_REFRESH;
    fileOperateType = TYPE_FILE_REFRESH;
    self.refreshType = theListType;
    if (![self.pycsocket connectToServer:IP_ADDRESS_FILE port:PORT_FILE]) {
        NSLog(@"connect err");
        return bReturn;
    }
    
    //    NSLog(@"will send");
    
    
    bReturn = YES;
    
    return bReturn;
}
-(void)MakerefreshListInfoPackage:(SENDDATA_NEW_NEW *)data
{
    memset(data, 0, sizeof(SENDDATA_NEW_NEW));
    
    (*data).type = TYPE_FILE_REFRESH;
    if(self.refreshType == 1)
    {
        //接收列表
        memcpy((Byte *)(data->userData.hardno ), [_OpenUUID UTF8String], HARDNO_LEN);
    }
    PycCode *coder = [[PycCode alloc] init];
    
    memcpy((Byte *)&(data->userData), [fileIDs UTF8String], [fileIDs lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    
    
    [coder codeBuffer:(Byte *)&((*data).userData) length:sizeof(STRUCTDATA_NEW_NEW)];
    
}
-(void)receiveRefreshListInfoPackage:(RECEIVEDATA_NEW_NEW *)receiveData
{
    int iLen = 0;
    Byte *receiveDataIinfo = (Byte *)&(receiveData->userData);
    while (receiveDataIinfo[iLen] != 0) {
        iLen++;
    }
    
    
    
    //#warning test nil and err format
    //    memset(receiveDataIinfo, 0, sizeof(STRUCTDATA));
    //    memcpy(receiveDataIinfo, [@"1234567" UTF8String], [@"1234567" length]);
    //iLen = 0;
    if (iLen == 0) {
        receiveData->suc = 0;
        return;
    }
    
    
    [self printByte:receiveDataIinfo len:sizeof(STRUCTDATA_NEW_NEW) description:@"the receive refresh info"];
    NSString *stringInfo = [[NSString alloc] initWithBytes:receiveDataIinfo length:iLen encoding:NSUTF8StringEncoding];
    NSLog(@"string info %@ len %lu", stringInfo, (unsigned long)[stringInfo length]);
    NSRange range = [stringInfo rangeOfString:@","];
    if (range.location == NSNotFound) {
        receiveData->suc = 0;;
    }
    NSArray *arrayInfo = [stringInfo componentsSeparatedByString:@";"];
    NSLog(@"arrayInfo %@", arrayInfo);
    if ([arrayInfo[0] length] < 1) {
        receiveData->suc = 0;
    }
    
    self.fileRefreshInfo = nil;
    
    for (NSString *string1 in arrayInfo) {
        
        RefreshDataModel *refreshInfo =  [[RefreshDataModel alloc] init];
        NSArray *arrayPreDataInfo = [string1 componentsSeparatedByString:@","];
        NSLog(@"pre info %@ len:%@", arrayPreDataInfo, [arrayPreDataInfo lastObject]);
        if (string1 == nil) {
            return;
        }
        for (id info in arrayPreDataInfo) {
            
            if (refreshInfo.fileId == nil) {
                refreshInfo.fileId = info;
            }
            else if(refreshInfo.isClient == nil)
            {
                refreshInfo.isClient = info;
            }
            else if(refreshInfo.makeType == nil)
            {
                refreshInfo.makeType = info;
            }
            else if(refreshInfo.canseeCondition == nil)
            {
                refreshInfo.canseeCondition = info;
            }
            else if (refreshInfo.AllowOpenmaxNum == nil)
            {
                refreshInfo.AllowOpenmaxNum = info;
            }
            else if(refreshInfo.haveOpenedNum == nil)
            {
                refreshInfo.haveOpenedNum = info;
            }
            else if(refreshInfo.startDay == nil)
            {
                refreshInfo.startDay = info;
            }
            else if(refreshInfo.endDay == nil)
            {
                refreshInfo.endDay = info;
            }
            else if(refreshInfo.openTimeLength == nil)
            {
                refreshInfo.openTimeLength = info;
            }
            else if(refreshInfo.iCanOpen == nil)
            {
                refreshInfo.iCanOpen = info;
            }
            else if(refreshInfo.makeTime == nil)
            {
                refreshInfo.makeTime = info;
            }
            else if(refreshInfo.bandNum == nil)
            {
                refreshInfo.bandNum = info;
            }
            else if(refreshInfo.activeNum == nil)
            {
                refreshInfo.activeNum = info;
            }
            else if(refreshInfo.openDay == nil)
            {
                refreshInfo.openDay = info;
            }
            else if(refreshInfo.remanDay == nil)
            {
                refreshInfo.remanDay = info;
            }
            else if(refreshInfo.openYear == nil)
            {
                refreshInfo.openYear = info;
            }
            else if(refreshInfo.remainYear == nil)
            {
                refreshInfo.remainYear = info;
            }
            else if(refreshInfo.firstReadTime == nil)
            {
                refreshInfo.firstReadTime = info;
            }
            
        }
        
        if (self.fileRefreshInfo == nil) {
            self.fileRefreshInfo = [[NSMutableArray alloc] initWithCapacity:10];
        }
        
        [self.fileRefreshInfo addObject:refreshInfo];
        NSLog(@"file info count %lu",(unsigned long)[self.fileRefreshInfo count]);
    }
    
}

#pragma mark 刷新文件详情
-(BOOL)getFileInfoById:(NSInteger )theFileId pbbFile:(NSString *)pbbFileName PycFile:(NSString *)pycFileName fileType:(NSInteger) theFileType
{
    //从服务器得到ID
    BOOL bReturn = NO;
    self.iResultIsOffLine = FALSE;
    self.fileID = theFileId;
    self.filePycNameFromServer = pbbFileName;
    self.filePycName = pycFileName;
    self.fileType = theFileType;
    
    int i_canSeeForOutline = 0;
    NSNumber *fileSize ;
    NSError *err;
    //得到文件大小
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:pycFileName]) {
        return bReturn;
    }
    
    NSDictionary *fileAttributes = [manager attributesOfItemAtPath:self.filePycName error:&err];
    if (fileAttributes != nil) {
        fileSize = [fileAttributes objectForKey:NSFileSize];
    }
    
    long structsize =  sizeof(PYCFILEEXT);
    long fileheadoffset = (fileSize.longValue > structsize)? (fileSize.longValue - structsize):0;
    if(fileheadoffset == 0)
    {
        return bReturn;
    }
    
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:self.filePycName];
    [handle seekToFileOffset:fileheadoffset];
    
    //读取扩展结构
    NSData *dataExt = [handle readDataOfLength:sizeof(PYCFILEEXT)];
    PYCFILEEXT *fileExtHeader = (PYCFILEEXT *)[dataExt bytes];
    PycCode *coder = [[PycCode alloc] init];
    [coder decodeFileExtension:fileExtHeader];
    self.fileID = fileExtHeader->nFileId;
    NSInteger applyID = 0;
    [handle closeFile];
    fileOperateType = TYPE_FILE_INFO;
    //离线问题
    if (_receiveFile == nil) {
        _receiveFile = [[ReceiveFileDao sharedReceiveFileDao] fetchReceiveFileCellByFileId:_fileID
                                                                                   LogName:[[userDao shareduserDao] getLogName]];
    }
    
    if(_receiveFile!=nil && _receiveFile.fileMakeType == 0)
    {
        
        //手动激活
        //需要联网:支持离线新文件和在线文件
        if(_receiveFile.EncodeKey == nil){
            
            //是否需要联网
            b_needNet = [self isFileNeedNet:self.filePycName applyID:&applyID];
            self.applyId = applyID;
            
            //查看旧版离线文件修改属性
            if(!b_needNet)
            {
                NSLog(@"更新离线文件....");
                //不需要联网时
                i_canSeeForOutline = [self isOutLineFileCanSee:self.filePycName remainDay:nil remainYear:nil] ;
                //根据返回值处理文件，解析离线文件结构体，对self赋值
                //                [self modifySourceFileByOutlineValue:i_canSeeForOutline filename:self.filePycName];
                //根据返回值返回给回调函数，结束本次处理
                if(i_canSeeForOutline == ERR_OUTLINE_OK)
                {
                    //解析离线文件并赋值self的属性
                    if(![self setSeeInfoFromOutLineStru:self.filePycName])
                    {
                        i_canSeeForOutline = ERR_OUTLINE_OTHER_ERR;
                    }
                    else{
                        i_canSeeForOutline |= ERR_OK_IS_FEE;
                    }
                }
                self.iResultIsOffLine = TRUE;
                
                _receiveFile.canSeeForOutline = i_canSeeForOutline;
                
                /**
                 *  网络异常时，直接回调查看的协议方法
                 *  网络正常时，访问服务器，同步数据，根据返回值判断是否能读，
                 *  如果返回值是 “网络不给力”，此时采用离线阅读流程，并将离线结构体中的数据移动到本地数据库
                 */
                if(![ToolString isConnectionAvailable])
                {
                    //主线程中，回调协议的方法
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //离线阅读
                        [self makeReturnMessage:i_canSeeForOutline forOperateType:TYPE_FILE_INFO];
                    });
                    
                    return TRUE;
                }
                
            }
            
        }else {
            //数据库已经保存有encodekey
            if (_receiveFile.status)
            {
                b_needNet = NO;
            }
            
            if(![ToolString isConnectionAvailable]){
                //网络异常
                
                if (_receiveFile.status) {
                    //旧版本手动激活文件，可读时
                    //解析离线文件，并给self赋值,获取明文文件
                    [self setValueOfSelfByNewFile:_receiveFile];
                }
                
                //离线阅读手动激活文件
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self makeReturnMessage:_receiveFile.canSeeForOutline forOperateType:TYPE_FILE_INFO];
                });
                
                return YES;
            }
            
        }
        
    }
    
    //add by lry 2014-05-05
    self.Random = arc4random() % ARC4RANDOM_MAX;
    //add end
    
    // int temp = 0;
    //    __unsafe_unretained PycFile *pf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //访问网络
        self.pycsocket = [[PycSocket alloc] init];
        self.pycsocket.delegate = self;
        self.pycsocket.connectType = TYPE_FILE_INFO;
        self.refreshType = theFileType;
        
        if (![self.pycsocket connectToServer:IP_ADDRESS_FILE port:PORT_FILE]) {
            NSLog(@"connect file server err");
        }
        
    });
    return YES;
    
}
-(void)MakeGetFileInfoByIdPackage:(SENDDATA_NEW_NEW *)data
{
    memset(data, 0, sizeof(SENDDATA_NEW_NEW));
    
    (*data).type = TYPE_FILE_INFO;
    
    PycCode *coder = [[PycCode alloc] init];
    
    //add by lry 2014-05-05
    data->userData.random = self.Random;
    
    data->userData.version = VERSION;
    data->userData.appType = CURRENTAPPTYPE;
    //add end
    if(self.refreshType == 1)
    {
        //接收文件
        memcpy((Byte *)(data->userData.hardno ), [_OpenUUID UTF8String], HARDNO_LEN);
    }
    
    
    data->userData.ID = (int)self.fileID;
    
    
    [coder codeBuffer:(Byte *)&((*data).userData) length:sizeof(STRUCTDATA_NEW_NEW)];
    
}
-(void)receiveGetFileInfoByIdPackage:(RECEIVEDATA_NEW_NEW *)receiveData
{
    self.fileOwner = [[NSString alloc] initWithBytes:receiveData->userData.logName length:USERNAME_LEN encoding:NSUTF8StringEncoding];
    self.filePycNameFromServer = [[NSString alloc]initWithBytes:receiveData->userData.fileoutName length:FILENAME_LEN encoding:NSUTF8StringEncoding];
    self.startDay =  [[NSString alloc]initWithBytes:receiveData->userData.startTime  length:TIME_LEN encoding:NSUTF8StringEncoding];
    self.endDay = [[NSString alloc]initWithBytes:receiveData->userData.endTime  length:TIME_LEN encoding:NSUTF8StringEncoding];
    self.AllowOpenmaxNum = receiveData->userData.fileOpenNum;
    self.haveOpenedNum = receiveData->userData.fileOpenedNum;
    self.bCanprint = receiveData->userData.bCanPrint;
    self.iCanOpen = receiveData->userData.iCanOpen;
    self.nickname = [[NSString alloc]initWithBytes:receiveData->userData.nick length:NICK_LEN encoding:NSUTF8StringEncoding];
    self.remark = [[NSString alloc]initWithBytes:receiveData->userData.remark length:REMARK_LEN encoding:NSUTF8StringEncoding];
    self.openTimeLong = receiveData->userData.iOpenTimeLong;
    self.openDay = receiveData->userData.dayNum;
    self.dayRemain = receiveData->userData.dayRemain;
    self.openYear = receiveData->userData.yearNum;
    self.yearRemain = receiveData->userData.yearRemain;
    self.makeTime = [[NSString alloc]initWithBytes:receiveData->userData.outTime length:FIRST_SEE_TIME_LEN encoding:NSUTF8StringEncoding];
    self.firstSeeTime = [[NSString alloc]initWithBytes:receiveData->userData.firstSeeTime length:FIRST_SEE_TIME_LEN encoding:NSUTF8StringEncoding];
    self.QQ = [[NSString alloc]initWithBytes:receiveData->userData.QQ length:QQ_LEN encoding:NSUTF8StringEncoding];
    self.email = [[NSString alloc]initWithBytes:receiveData->userData.email length:EMAIL_LEN encoding:NSUTF8StringEncoding];
    self.phone = [[NSString alloc]initWithBytes:receiveData->userData.phone length:PHONE_LEN encoding:NSUTF8StringEncoding];
    self.isClient = receiveData->userData.iCanClient;
    self.makeFrom = receiveData->userData.appType;
    self.orderNo =  [[NSString alloc]initWithBytes:receiveData->userData.orderno  length:ORDERNO_LEN encoding:NSUTF8StringEncoding];
    self.bindNum = receiveData->userData.bindNum;
    self.activeNum = receiveData->userData.activeNum;
    //是否能看到约束条件
    self.canseeCondition = receiveData->userData.otherset;
    //保存联网返回数据，该文件是否为离线文件，如果是离线文件，那么界面回调中只关注总次数，总天数，总时间，是否能看不关注
    self.iCanClient = receiveData->userData.iCanClient;
    
    //TODO:添加接收系列ID字段
    //       fileversion:查看文件时返回该文件所属系列ID
    self.seriesID = receiveData->userData.appType;
    //       |查看文件时，返回系列中文件总数
    self.seriesFileNums = receiveData->userData.tableid;
    /*!
     系列名称
     */
    self.seriesName = [[NSString alloc] initWithBytes:receiveData->userData.seriesname length:SERIESNAME_LEN encoding:NSUTF8StringEncoding];
    self.seriesName = [self.seriesName stringByReplacingOccurrencesOfString:@"\0" withString:@""];
    //文件类型
    self.fileType = [self getFileType:self.filePycNameFromServer];
}
#pragma mark - 申请
#pragma mark 查看申请提交申请<信息>
-(BOOL)getApplyFileInfoByApplyId:(NSInteger)applyId FileID:(NSInteger)fileID
{
    BOOL bReturn = NO;
    self.applyId = applyId;
    self.fileID = fileID;
    self.Random = arc4random() % ARC4RANDOM_MAX;
    
    self.pycsocket = [[PycSocket alloc] initWithDelegate:self];
    self.pycsocket.connectType = TYPE_FILE_APPLYINFO;
    fileOperateType = TYPE_FILE_APPLYINFO;
    
    if (![self.pycsocket connectToServer:IP_ADDRESS_FILE port:PORT_FILE]) {
        return bReturn;
    }
    bReturn = YES;
    return bReturn;
}
//封装请求包
- (void)MakeGetApplyFileInfoByIdPackage:(SENDDATA_NEW_NEW *)data
{
    memset(data, 0, sizeof(SENDDATA_NEW_NEW));
    (*data).type = TYPE_FILE_APPLYINFO;
    PycCode *coder = [[PycCode alloc] init];
    
    data->userData.random = self.Random;
    memcpy((Byte *)(data->userData.hardno ), [_OpenUUID UTF8String], HARDNO_LEN);
    data->userData.appType = CURRENTAPPTYPE;
    data->userData.applyId = (int)self.applyId;
    data->userData.ID = (int)self.fileID;
    
    [coder codeBuffer:(Byte *)&((*data).userData) length:sizeof(STRUCTDATA_NEW_NEW)];
}
//解析响应包
- (void)receiveApplyFileInfoByIdPackage:(RECEIVEDATA_NEW_NEW *)receiveData
{
    if (strlen(receiveData->userData.QQ) == 0) {
        self.QQ = @"";
    }
    else
    {
        self.QQ = [[NSString alloc] initWithUTF8String:receiveData->userData.QQ];
//        memset(receiveData->userData.QQ+strlen(receiveData->userData.QQ), 0, QQ_LEN-strlen(receiveData->userData.QQ));
//        self.QQ = [[NSString alloc]initWithBytes:receiveData->userData.QQ length:strlen(receiveData->userData.QQ) encoding:NSUTF8StringEncoding];
    }
    
    if (strlen(receiveData->userData.email) == 0) {
        self.email = @"";
    }
    else
    {
         self.email = [[NSString alloc] initWithUTF8String:receiveData->userData.email];
//        memset(receiveData->userData.email+strlen(receiveData->userData.email), 0, EMAIL_LEN-strlen(receiveData->userData.email));
//        self.email = [[NSString alloc]initWithBytes:receiveData->userData.email length:strlen(receiveData->userData.email) encoding:NSUTF8StringEncoding];
    }
    
    if (strlen(receiveData->userData.phone) == 0) {
        self.phone = @"";
    }
    else
    {
         self.phone = [[NSString alloc] initWithUTF8String:receiveData->userData.phone];
//           memset(receiveData->userData.phone+strlen(receiveData->userData.phone), 0, PHONE_LEN-strlen(receiveData->userData.phone));
//        self.phone = [[NSString alloc]initWithBytes:receiveData->userData.phone length:strlen(receiveData->userData.phone) encoding:NSUTF8StringEncoding];
    }
    
    if (strlen(receiveData->userData.field1) == 0) {
        self.field1 = @"";
    }
    else
    {
         self.field1 = [[NSString alloc] initWithUTF8String:receiveData->userData.field1];
//           memset(receiveData->userData.field1+strlen(receiveData->userData.field1), 0, FIELD_LEN-strlen(receiveData->userData.field1));
//        self.field1 = [[NSString alloc]initWithBytes:receiveData->userData.field1 length:strlen(receiveData->userData.field1) encoding:NSUTF8StringEncoding];
    }
    
    if (strlen(receiveData->userData.field2) == 0) {
        self.field2 = @"";
    }
    else
    {
         self.field2 = [[NSString alloc] initWithUTF8String:receiveData->userData.field2];
//        memset(receiveData->userData.field2+strlen(receiveData->userData.field2), 0, FIELD_LEN-strlen(receiveData->userData.field2));
//        self.field2 = [[NSString alloc]initWithBytes:receiveData->userData.field2 length:strlen(receiveData->userData.field2) encoding:NSUTF8StringEncoding];
    }
    
    if (strlen(receiveData->userData.hardno) == 0) {
        self.fild1name = @"";
    }
    else
    {
         self.self.fild1name = [[NSString alloc] initWithUTF8String:receiveData->userData.hardno];
//        memset(receiveData->userData.hardno+strlen(receiveData->userData.hardno), 0, HARDNO_LEN-strlen(receiveData->userData.hardno));
//        self.fild1name = [[NSString alloc]initWithBytes:receiveData->userData.hardno length:FIELD_LEN encoding:NSUTF8StringEncoding];
    }
    if (strlen(receiveData->userData.logName) == 0) {
        self.fild2name = @"";
    }
    else
    {
//        memset(receiveData->userData.logName+strlen(receiveData->userData.logName), 0, USERNAME_LEN-strlen(receiveData->userData.logName));
//        self.fild2name = [[NSString alloc]initWithBytes:receiveData->userData.logName length:FIELD_LEN encoding:NSUTF8StringEncoding];
         self.fild2name = [[NSString alloc] initWithUTF8String:(receiveData->userData.logName)];
    }
    
    self.definechecked = receiveData->userData.bindNum;
    self.selffieldnum = receiveData->userData.activeNum;
    self.field1needprotect = receiveData->userData.ID&1?1:0;  //1:保密
    self.field2needprotect = receiveData->userData.ID&2?1:0;  //1:保密
    //添加接收系列ID字段
    //       fileversion:查看文件时返回该文件所属系列ID
    self.seriesID = receiveData->userData.appType;
    //       |查看文件时，返回系列中文件总数
    self.seriesFileNums = receiveData->userData.tableid;
    /*!
     系列名称
     */
    self.seriesName = [[NSString alloc] initWithBytes:receiveData->userData.seriesname length:SERIESNAME_LEN encoding:NSUTF8StringEncoding];
    self.seriesName = [self.seriesName stringByReplacingOccurrencesOfString:@"\0" withString:@""];
}

#pragma mark - 申请手动激活
- (NSString *)applyFileByFidAndOrderId:(NSInteger )fileId
                               orderId:(NSInteger )thOrderId
                                    qq:(NSString *)theQQ
                                 email:(NSString *)theEmail
                                 phone:(NSString *)thePhone
                                field1:(NSString *)theField1
                                field2:(NSString *)theField2
                            seeLogName:(NSString *)theSeeLogName
                              fileName:(NSString*)theFileName
{
    NSLog(@"*****************%s******************", __func__);
    //add by lry 2014-05-05
    NSString *bReturn = @"0";
    if (![ToolString isConnectionAvailable]) {
        bReturn=@"1";
        return bReturn;
    }
    self.filePycNameFromServer = theFileName;
    self.QQ = theQQ;
    self.email = theEmail;
    self.phone = thePhone;
    self.field1 = theField1;
    self.field2 = theField2;
    self.Random = arc4random() % ARC4RANDOM_MAX;
    self.orderID = thOrderId;
    self.fileID = fileId;
    self.fileSeeLogname = theSeeLogName;
    self.pycsocket = [[PycSocket alloc] init];
    self.pycsocket.delegate = self;
    self.pycsocket.connectType = TYPE_APPLY;
    fileOperateType = TYPE_APPLY;
    if (![self.pycsocket connectToServer:IP_ADDRESS_FILE port:PORT_FILE]) {
        NSLog(@"connect file server err");
        bReturn=@"2";
        return bReturn;
    }
    return bReturn;
}
//封装请求包
-(void)MakeapplyFileByFidAndOrderIdPackage:(SENDDATA_NEW_NEW *)data
{
    memset(data, 0, sizeof(SENDDATA_NEW_NEW));
    
    (*data).type = TYPE_APPLY;
    
    PycCode *coder = [[PycCode alloc] init];
    
    data->userData.random = self.Random;
    data->userData.version = VERSION;
    memcpy((Byte *)(data->userData.hardno ), [_OpenUUID UTF8String], HARDNO_LEN);
    memcpy((Byte *)(data->userData.sysinfo ), [_sysInfoVersion UTF8String], SYSINFO_LEN);
    memcpy(&(data->userData.logName[0]), [self.fileSeeLogname UTF8String] , MIN([self.fileSeeLogname lengthOfBytesUsingEncoding:NSUTF8StringEncoding], USERNAME_LEN));
    memcpy(&(data->userData.QQ[0] ), [self.QQ UTF8String], QQ_LEN);
    memcpy(&(data->userData.email[0] ), [self.email UTF8String], EMAIL_LEN);
    memcpy(&(data->userData.phone[0] ), [self.phone UTF8String], PHONE_LEN);
    
    if (self.field1 != nil) {
        memcpy(&(data->userData.field1[0] ), [self.field1 UTF8String], FIELD_LEN);
    }
    
    if (self.field2 != nil) {
        memcpy(&(data->userData.field2[0] ), [self.field2 UTF8String], FIELD_LEN);
    }
    
    data->userData.ID = (int) self.fileID;
    data->userData.ooid = (int)self.orderID;
    data->userData.appType = CURRENTAPPTYPE;
    
    [coder codeBuffer:(Byte *)&((*data).userData) length:sizeof(STRUCTDATA_NEW_NEW)];
    
}
//解析响应包
- (void)receiveApplyFileByFidAndOrderIdPackage:(RECEIVEDATA_NEW_NEW *)receiveData
{
    if (strlen(receiveData->userData.QQ) == 0) {
        self.QQ = @"";
    }
    else
    {
        self.QQ = [[NSString alloc]initWithBytes:receiveData->userData.QQ length:QQ_LEN encoding:NSUTF8StringEncoding];
    }
    if (strlen(receiveData->userData.phone) == 0) {
        self.phone = @"";
    }
    else
    {
        self.phone = [[NSString alloc]initWithBytes:receiveData->userData.phone length:PHONE_LEN encoding:NSUTF8StringEncoding];
    }
    if (strlen(receiveData->userData.email) == 0) {
        self.email = @"";
    }
    else
    {
        self.email = [[NSString alloc]initWithBytes:receiveData->userData.email length:EMAIL_LEN encoding:NSUTF8StringEncoding];
    }
    if (strlen(receiveData->userData.showInfo) == 0) {
        self.showInfo = @"";
    }
    else
    {
        self.showInfo = [[NSString alloc]initWithBytes:receiveData->userData.showInfo length:SHOW_INFO_LEN encoding:NSUTF8StringEncoding];
    }
    
    self.iCanClient = receiveData->userData.iCanClient;
    self.needShowDiff = receiveData->userData.need_showdiff;
    //add end
    //如果离线，需要修改文件中的离线结构
    if(receiveData->suc & ERR_OK_OR_CANOPEN)
    {
        if(receiveData->userData.iCanClient)
        {
            self.applyId = receiveData->userData.applyId;
            [self setOutLineStructData:self.filePycNameFromServer
                            isFirstSee:FALSE
                            isSetFirst:FALSE
                                 isSee:FALSE
                            isVerifyOk:FALSE
                       isTimeIsChanged:FALSE
                         isApplySucess:TRUE
                                  data:NULL];
            //修改文件离线结构中的applyid
            
        }
    }
}
#pragma mark 重新申请手动激活
- (NSString *)reapplyFileByFidAndOrderId:(NSInteger )fileId
                                 orderId:(NSInteger )thOrderId
                                 applyId:(NSInteger)applyId
                                      qq:(NSString *)theQQ
                                   email:(NSString *)theEmail
                                   phone:(NSString *)thePhone
                                  field1:(NSString *)theField1
                                  field2:(NSString *)theField2
{
    NSString *bReturn = @"0";
    if (![ToolString isConnectionAvailable]) {
        bReturn=@"1";
        return bReturn;
    }
    self.QQ = theQQ;
    self.email = theEmail;
    self.phone = thePhone;
    self.field1 = theField1;
    self.field2 = theField2;
    self.Random = arc4random() % ARC4RANDOM_MAX;
    self.orderID = thOrderId;
    self.fileID = fileId;
    self.applyId = applyId;
    self.pycsocket = [[PycSocket alloc] init];
    self.pycsocket.delegate = self;
    self.pycsocket.connectType = TYPE_REAPPLY;
    fileOperateType = TYPE_REAPPLY;
    if (![self.pycsocket connectToServer:IP_ADDRESS_FILE port:PORT_FILE]) {
        bReturn=@"2";
        return bReturn;
    }
    return bReturn;
}
//封装请求包
-(void)MakeReapplyFileByFidAndOrderIdPackage:(SENDDATA_NEW_NEW *)data
{
    memset(data, 0, sizeof(SENDDATA_NEW_NEW));
    
    (*data).type = TYPE_REAPPLY;
    
    PycCode *coder = [[PycCode alloc] init];
    
    data->userData.random = self.Random;
    data->userData.version = VERSION;
    memcpy((Byte *)(data->userData.hardno ), [_OpenUUID UTF8String], HARDNO_LEN);
    memcpy(&(data->userData.QQ[0] ), [self.QQ UTF8String], QQ_LEN);
    memcpy(&(data->userData.email[0] ), [self.email UTF8String], EMAIL_LEN);
    memcpy(&(data->userData.phone[0] ), [self.phone UTF8String], PHONE_LEN);
    
    if (self.field1 != nil) {
        memcpy(&(data->userData.field1[0] ), [self.field1 UTF8String], FIELD_LEN);
    }
    
    if (self.field2 != nil) {
        memcpy(&(data->userData.field2[0] ), [self.field2 UTF8String], FIELD_LEN);
    }
    
    data->userData.ID = (int)self.fileID;
    data->userData.ooid = (int)self.orderID;
    data->userData.appType = CURRENTAPPTYPE;
    data->userData.applyId = (int)self.applyId;
    
    [coder codeBuffer:(Byte *)&((*data).userData) length:sizeof(STRUCTDATA_NEW_NEW)];
}
//解析响应包
- (void)receiveReapplyFileInfoByIdPackage:(RECEIVEDATA_NEW_NEW *)receiveData
{
    if (strlen(receiveData->userData.QQ) == 0) {
        self.QQ = @"";
    }
    else
    {
        self.QQ = [[NSString alloc]initWithBytes:receiveData->userData.QQ length:QQ_LEN encoding:NSUTF8StringEncoding];
    }
    if (strlen(receiveData->userData.phone) == 0) {
        self.phone = @"";
    }
    else
    {
        self.phone = [[NSString alloc]initWithBytes:receiveData->userData.phone length:PHONE_LEN encoding:NSUTF8StringEncoding];
    }
    if (strlen(receiveData->userData.email) == 0) {
        self.email = @"";
    }
    else
    {
        self.email = [[NSString alloc]initWithBytes:receiveData->userData.email length:EMAIL_LEN encoding:NSUTF8StringEncoding];
    }
    if (strlen(receiveData->userData.showInfo) == 0) {
        self.showInfo = @"";
    }
    else
    {
        self.showInfo = [[NSString alloc]initWithBytes:receiveData->userData.showInfo length:SHOW_INFO_LEN encoding:NSUTF8StringEncoding];
    }
    if (strlen(receiveData->userData.remark) == 0) {
        self.remark = @"";
    }
    else
    {
        self.remark = [[NSString alloc]initWithBytes:receiveData->userData.remark length:REMARK_LEN encoding:NSUTF8StringEncoding];
    }
    self.needReapply = receiveData->userData.need_reapply;
    self.needShowDiff = receiveData->userData.need_showdiff;
    self.applyId = receiveData->userData.applyId;
    self.iCanClient = receiveData->userData.iCanClient;
    
}

#pragma mark - 获取手机验证码
-(BOOL)getVerificationCodeByPhone:(NSString *)phone userPhone:(BOOL)userPhone
{
    BOOL bReturn = NO;
    self.bindingPhone = phone;
    self.Random = arc4random() % ARC4RANDOM_MAX;
    
    self.pycsocket = [[PycSocket alloc] init];
    self.pycsocket.delegate = self;
    if(!userPhone){
        self.pycsocket.connectType = TYPE_FILE_VERIFICATIONCODE;
        fileOperateType = TYPE_FILE_VERIFICATIONCODE;
    }else{
        self.pycsocket.connectType = NewPycUerRemoteOperateTypeGetConfirm;
        fileOperateType = NewPycUerRemoteOperateTypeGetConfirm;
    }
    
    
    if (![self.pycsocket connectToServer:IP_ADDRESS_FILE port:PORT_FILE]) {
        return bReturn;
    }
    bReturn = YES;
    return bReturn;
}
//封装获取手机验证码的请求包
-(void)MakeVerificationCodeByFidPackage:(SENDDATA_NEW_NEW *)data
{
    memset(data, 0, sizeof(SENDDATA_NEW_NEW));
    
    (*data).type = fileOperateType;
    
    PycCode *coder = [[PycCode alloc] init];
    data->userData.random = self.Random;
    data->userData.version = VERSION;
    memcpy(&(data->userData.phone[0] ), [self.bindingPhone UTF8String], PHONE_LEN);

    [coder codeBuffer:(Byte *)&((*data).userData) length:sizeof(STRUCTDATA_NEW_NEW)];
}
//解析手机验证码的响应数据包
- (void)receiveVerificationCodeInfoByIdPackage:(RECEIVEDATA_NEW_NEW *)receiveData
{
    if (strlen(receiveData->userData.phone) == 0) {
        self.verificationCode = @"";
    }
    else
    {
        self.verificationCode = [[NSString alloc] initWithUTF8String:receiveData->userData.phone];
    }
    if (strlen(receiveData->userData.messageId) == 0) {
        self.verificationCodeID = @"";
    }
    else
    {
        self.verificationCodeID = [[NSString alloc] initWithUTF8String:receiveData->userData.messageId];
    }
    NSLog(@"verificationCode = %@,len = %lu", _verificationCode, (unsigned long)[_verificationCode length]);
    NSLog(@"verificationCodeID = %@,len = %lu", _verificationCodeID, (unsigned long)[_verificationCodeID length]);
}

#pragma mark - 当文件阅读结束时告知服务器
- (void)sendSeeOverTime:(NSInteger )fileId
             openInfoID:(NSInteger) theOpenInfoID
{
    self.fileID = fileId;
    self.openinfoid = theOpenInfoID;
    self.pycsocket = [[PycSocket alloc] init];
    self.pycsocket.delegate = self;
    self.pycsocket.connectType = TYPE_SEE_FILE_OVER;
    fileOperateType = TYPE_SEE_FILE_OVER;
    if (![self.pycsocket connectToServer:IP_ADDRESS_FILE port:PORT_FILE]) {
        NSLog(@"connect err");
        return ;
    }
    return;
}

//封装文件阅读结束请求包
-(void)MakeSeeFileOVerPackage:(SENDDATA_NEW_NEW *)data
{
    memset(data, 0, sizeof(SENDDATA_NEW_NEW));
    
    (*data).type = TYPE_SEE_FILE_OVER;
    
    PycCode *coder = [[PycCode alloc] init];
    

    data->userData.version = (int)self.openinfoid;
    
    data->userData.ID = (int)self.fileID;

    data->userData.appType = CURRENTAPPTYPE;
    
    
    [coder codeBuffer:(Byte *)&((*data).userData) length:sizeof(STRUCTDATA_NEW_NEW)];
    
}


#pragma mark - 绑定手机号
-(BOOL)bindPhoneByVerificationCode:(NSString *)verificationCode logname:(NSString *)logname messageId:(NSString *)messageId
{
    BOOL bReturn = false;
    
    self.Random = arc4random() % ARC4RANDOM_MAX;
    self.verificationCodeID = messageId;
    self.fileSeeLogname = logname;
    self.phone = verificationCode;
    fileOperateType = NewPycUerRemoteOperateTypeBindPhone;
    self.pycsocket.connectType = NewPycUerRemoteOperateTypeBindPhone;
    if (![self.pycsocket connectToServer:IP_ADDRESS_FILE port:PORT_FILE]) {
        return bReturn;
    }
    bReturn = YES;
    return bReturn;
}
//封装绑定手机号请求包
-(void)makeSendPackageForBindPhone:(SENDDATA_NEW_NEW *)pSendData
{
    MyLog(@"getReceivePackageForGetUserInfo");
    pSendData->userData.random = self.Random;
    
    pSendData->type = NewPycUerRemoteOperateTypeBindPhone;
    pSendData->userData.version = VERSION;
    memcpy(&(pSendData->userData.phone), [self.phone UTF8String], MIN([self.phone lengthOfBytesUsingEncoding:NSUTF8StringEncoding],PHONE_LEN));
    //    memcpy(&(pSendData->userData.versionStr), [self.versionStr UTF8String], MIN([self.versionStr lengthOfBytesUsingEncoding:NSUTF8StringEncoding],VERSION_LEN));
    memcpy(&(pSendData->userData.messageId), [self.verificationCodeID UTF8String], MIN([self.verificationCodeID lengthOfBytesUsingEncoding:NSUTF8StringEncoding],MESSAGE_ID_LEN));
    memcpy(&(pSendData->userData.logName), [self.fileSeeLogname UTF8String], MIN([self.fileSeeLogname lengthOfBytesUsingEncoding:NSUTF8StringEncoding],USERNAME_LEN));
    PycCode *coder = [[PycCode alloc] init];
    [coder codeBuffer:(Byte *)&((*pSendData).userData) length:sizeof(STRUCTDATA_NEW_NEW)];
}

#pragma mark - 未知功能快
-(void)codeUrl:(NSString *)sUrl dUrl:(void (^)(NSString *))dUrl
{
    NSData* sUrlbytes = [sUrl dataUsingEncoding:NSUTF8StringEncoding];
    PycCodeUrl *coderurl = [[PycCodeUrl alloc] init];
    Byte * myByte = (Byte *)[sUrlbytes bytes];
    Byte dUrlbyte[1000];
    int retLen = 0;
    [coderurl codeUrl:myByte length:(int)[sUrl length ] to:dUrlbyte retlen:(&retLen)];
    NSData *adata = [[NSData alloc] initWithBytes:dUrlbyte length:2*retLen ];
    NSString *url =[[NSString alloc]initWithData:adata encoding:NSUTF8StringEncoding];
    dUrl(url);

}

-(void)codeUrlnew:(NSString *)sUrl dUrl:(void (^)(NSString *))dUrl
{
    NSData* sUrlbytes = [sUrl dataUsingEncoding:NSUTF8StringEncoding];
    PycCodeUrl *coderurl = [[PycCodeUrl alloc] init];
    Byte * myByte = (Byte *)[sUrlbytes bytes];
    Byte dUrlbyte[1000];
    int retLen = 0;
    [coderurl codeUrlnew:myByte length:(int)[sUrl length ] to:dUrlbyte retlen:(&retLen)];
    NSData *adata = [[NSData alloc] initWithBytes:dUrlbyte length:2*retLen ];
    NSString *url =[[NSString alloc]initWithData:adata encoding:NSUTF8StringEncoding];
    dUrl(url);
    
}

#pragma mark 查看激活用完记录
- (BOOL)seeAppliedAndOverListByFid:(NSInteger )fileId;
{
    BOOL bReturn = NO;
    self.fileID = fileId;
    self.pycsocket.delegate = self;
    self.Random = arc4random() % ARC4RANDOM_MAX;
    self.pycsocket.connectType = TYPE_SEE_ACTIVE_OVERLIST;
    fileOperateType = TYPE_SEE_ACTIVE_OVERLIST;
    if (![self.pycsocket connectToServer:IP_ADDRESS_FILE port:PORT_FILE]) {
        NSLog(@"connect file server err");
        return bReturn;
    }
    bReturn = YES;
    return bReturn;
}


-(void)MakeseeAppliedAndOverListByFidPackage:(SENDDATA_NEW_NEW *)data
{
    memset(data, 0, sizeof(SENDDATA_NEW_NEW));
    (*data).type = TYPE_APPLY;
    PycCode *coder = [[PycCode alloc] init];
    
    data->userData.random = self.Random;
    data->userData.version = VERSION;
    memcpy((Byte *)(data->userData.hardno ), [_OpenUUID UTF8String], HARDNO_LEN);
    memcpy((Byte *)(data->userData.sysinfo ), [_sysInfoVersion UTF8String], SYSINFO_LEN);
    memcpy(&(data->userData.logName[0]), [self.fileSeeLogname UTF8String] , MIN([self.fileSeeLogname lengthOfBytesUsingEncoding:NSUTF8StringEncoding], USERNAME_LEN));
    
    data->userData.ID = (int)self.fileID;
    data->userData.ooid = (int)self.orderID;
    data->userData.appType = CURRENTAPPTYPE;
    
    [coder codeBuffer:(Byte *)&((*data).userData) length:sizeof(STRUCTDATA_NEW_NEW)];
    
}
-(void)receiveseeAppliedAndOverListByFidPackage:(RECEIVEDATA_NEW_NEW *)receiveData
{
    int itemCount = 0;
    int iLen = 0;
    Byte *receiveDataIinfo = (Byte *)&(receiveData->userData);
    while (receiveDataIinfo[iLen] != 0) {
        iLen++;
    }
    
    
    
    //#warning test nil and err format
    //    memset(receiveDataIinfo, 0, sizeof(STRUCTDATA));
    //    memcpy(receiveDataIinfo, [@"1234567" UTF8String], [@"1234567" length]);
    //iLen = 0;
    if (iLen == 0) {
        receiveData->suc = 0;
        return;
    }
    
    
    [self printByte:receiveDataIinfo len:sizeof(STRUCTDATA_NEW_NEW) description:@"the receive refresh info"];
    NSString *stringInfo = [[NSString alloc] initWithBytes:receiveDataIinfo length:iLen encoding:NSUTF8StringEncoding];
    NSLog(@"string info %@ len %lu", stringInfo, (unsigned long)[stringInfo length]);
    NSRange range = [stringInfo rangeOfString:@","];
    if (range.location == NSNotFound) {
        receiveData->suc = 0;
    }
    NSArray *arrayInfo = [stringInfo componentsSeparatedByString:@";"];
    NSLog(@"arrayInfo %@", arrayInfo);
    if ([arrayInfo[0] length] < 1) {
        receiveData->suc = 0;
    }
    
    self.fileRefreshInfo = nil;
    
    if (self.fileRefreshInfo == nil) {
        self.fileRefreshInfo = [[NSMutableArray alloc] initWithCapacity:5];
    }
    
    for (NSString *string1 in arrayInfo) {
        
        SeeApplyEndListDataModel *listInfo =  [[SeeApplyEndListDataModel alloc] init];
        NSArray *arrayPreDataInfo = [string1 componentsSeparatedByString:@","];
        NSLog(@"pre info %@ len:%@", arrayPreDataInfo, [arrayPreDataInfo lastObject]);
        if (string1 == nil) {
            return;
        }
        itemCount++;
        for (id info in arrayPreDataInfo) {
            
            if (listInfo.fileOpenNum == nil) {
                listInfo.fileOpenNum = info;
            }
            else if (listInfo.dayNum == nil)
            {
                listInfo.dayNum = info;
            }
            else if(listInfo.dayRemain == nil)
            {
                listInfo.dayRemain = info;
            }
            else if(listInfo.yearNum == nil)
            {
                listInfo.yearNum = info;
            }
            else if(listInfo.yearRemain == nil)
            {
                listInfo.yearRemain = info;
            }
            else if(listInfo.firstSeeTime == nil)
            {
                listInfo.firstSeeTime = info;
            }
            
        }
        if (itemCount <= 5)
        {
            [self.fileRefreshInfo addObject:listInfo];
        }
        NSLog(@"file info count %lu",(unsigned long)[self.fileRefreshInfo count]);
    }
    
}


#pragma mark - 解读离线文件，将文件属性值传入pycFile属性中
-(BOOL)setSeeInfoFromOutLineStru:(NSString*)filename
{
    //取离线机构的数据赋值给self中变量
    BOOL bReturn = FALSE;
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:filename]) {
        NSLog(@"no file");
        return bReturn;
        
    }
    NSNumber *fileSize ;
    NSError *err;
    Byte sessionKey[SECRET_KEY_LEN];
    //得到文件大小
    NSDictionary *fileAttributes = [manager attributesOfItemAtPath:filename error:&err];
    if (fileAttributes != nil) {
        
        fileSize = [fileAttributes objectForKey:NSFileSize];
        NSLog(@"%ld", fileSize.longValue);
    }
    
    long structsize =  sizeof(PYCFILEEXT);
    long fileheadoffset = (fileSize.longValue > structsize)? (fileSize.longValue - structsize):0;
    if(fileheadoffset == 0)
    {
        NSLog(@"nothing in in");
        return bReturn;
    }
    NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:filename];
    if (!handle ) {
        NSLog(@"file handle move err");
        return NO;
    }
    
    [handle seekToFileOffset:fileheadoffset];
    /*  NSData *data = [handle readDataOfLength:sizeof(PYCFILEHEADER)];
     
     PYCFILEHEADER *header = (PYCFILEHEADER *)[data bytes];
     NSLog(@"file original size really %lld", header->fileSize);
     */
    
    NSData *dataExt = [handle readDataOfLength:sizeof(PYCFILEEXT)];
    PYCFILEEXT *fileExtHeader = (PYCFILEEXT *)[dataExt bytes];
    PycCode *coder = [[PycCode alloc] init];
    [coder decodeFileExtension:fileExtHeader];
    if(fileExtHeader->uTag == PycTag1)
    {
        [coder getSessionKeyFormFileSessionKey:fileExtHeader->szSessionKey to:sessionKey];
        
        //读取离线结构
        fileheadoffset -= sizeof(OUTLINE_STRUCT);
        [handle seekToFileOffset:fileheadoffset];
        NSData *outLine = [handle readDataOfLength:sizeof(OUTLINE_STRUCT)];
        [handle closeFile];
        OUTLINE_STRUCT *fileOutLineStru = (OUTLINE_STRUCT *)[outLine bytes];
        [coder decodeBufferOfFile:(Byte*)fileOutLineStru length:sizeof(OUTLINE_STRUCT) withKey:sessionKey];
        if(fileOutLineStru->structflag == PycTag0)
        {
            self.fileSecretkeyOrigianlR1 = [[NSData alloc] initWithBytes:fileOutLineStru->EncodeKey length: ENCRYPKEY_LEN];
            Byte fileScreateR1[ENCRYPKEY_LEN];
            [coder getSecretKeyFromOriginalKey:(Byte *)[self.fileSecretkeyOrigianlR1 bytes]  to:fileScreateR1];
            self.fileSecretkeyR1 = [[NSData alloc] initWithBytes:fileScreateR1 length: ENCRYPKEY_LEN];
            self.AllowOpenmaxNum = fileOutLineStru->fileopennum;
            self.haveOpenedNum = fileOutLineStru->fileopenednum - 1;
            self.bCanprint = fileOutLineStru->bCanPrint;
            self.canseeCondition = fileOutLineStru->iCanSeeCondition;
            self.iCanOpen = 1;
            //add by lry 2014-05-05
            if (strlen(fileOutLineStru->QQ) == 0) {
                self.QQ = @"";
            }
            else
            {
                self.QQ = [[NSString alloc] initWithUTF8String:fileOutLineStru->QQ];
            }
            if (strlen(fileOutLineStru->phone) == 0) {
                self.phone = @"";
            }
            else
            {
                self.phone = [[NSString alloc] initWithUTF8String:fileOutLineStru->phone];
            }
            if (strlen(fileOutLineStru->email) == 0) {
                self.email = @"";
            }
            else
            {
                self.email = [[NSString alloc] initWithUTF8String:fileOutLineStru->email];
            }
            //计算剩余年和天
            //取得当前时间
            struct tm when;
            time_t now;
            time(&now);
            gmtime_r(&now,&when);
            
            //把记录中的结束时间转换为时间
            if (strlen(fileOutLineStru->endTime) > 0) {
                NSString *endTimestr = [NSString stringWithFormat:@"%s",fileOutLineStru->endTime];
                NSDate *endtime = [NSDate dateWithString:endTimestr];
                NSDate *nowTime = [NSDate getNowDateFromatAnDate:[NSDate date]];
                //取得时间差
                NSInteger allDays = [NSDate OffLineFileOfLastdayFromDate:nowTime ToDate:endtime];
                
                self.dayRemain = allDays % 365;
                self.yearRemain = allDays / 365;
            }
            self.openDay = fileOutLineStru->daynum;
            self.openYear = fileOutLineStru->yearnum;
            //add by lry 2014-7-14
            if (strlen(fileOutLineStru->field1) == 0)
            {
                self.field1 = @"";
            }
            else
            {
                self.field1 = [[NSString alloc] initWithUTF8String:fileOutLineStru->field1];
            }
            if (strlen(fileOutLineStru->field2) == 0) {
                self.field2 = @"";
            }
            else
            {
                 self.field2 = [[NSString alloc] initWithUTF8String:fileOutLineStru->field2];
            }
            if (strlen(fileOutLineStru->field1name) == 0) {
                self.fild1name = @"";
            }
            else
            {
                 self.fild1name = [[NSString alloc] initWithUTF8String:fileOutLineStru->field1name];
             }
            if (strlen(fileOutLineStru->field2name) == 0) {
                self.fild2name = @"";
            }
            else
            {
                 self.fild2name = [[NSString alloc] initWithUTF8String:fileOutLineStru->field2name];
            }
            //                self.openinfoid = receiveData->userData.version;      //添加结束逻辑，所需的参数值
            self.definechecked = fileOutLineStru->chosenum;   //服务器端对联系方式的勾选，根据勾选条件，申请激活，或显示水印
            self.selffieldnum = fileOutLineStru->fieldnum;  //自定义字段的个数
            self.field1needprotect = fileOutLineStru->fieldprotect&1?1:0;  //1:保密
            self.field2needprotect = fileOutLineStru->fieldprotect&2?1:0;  //1:保密
            //文件类型
            self.fileType = [self getFileType:self.filePycNameFromServer];
            
            if (strlen(fileOutLineStru->firstseeTime)>0)
            {
                self.firstSeeTime = [[NSString alloc]initWithBytes:fileOutLineStru->firstseeTime length:LONGTIME_LEN encoding:NSUTF8StringEncoding];
            }
            else
            {
                self.firstSeeTime = @"";
            }
            
            if(bReturn)
            {
                if([self getReceiveFileINfo])
                {
                    [self makeOpenFile];
                    
                }else{
                    bReturn = FALSE;
                }
            }
        }
    }
    else
    {
        [handle closeFile];
    }
    return bReturn;
}

#pragma mark - 更新离线结构体中的属性值
/**
 *  新版本需求
 *  将更新离线结构体的步骤，修改为同步到本地书库的步骤
 *
 *  @param filename
 *  @param bFirstSee
 *  @param bSetFirst      #bSetFirst description#>
 *  @param bSee           #bSee description#>
 *  @param bVerifyOk      #bVerifyOk description#>
 *  @param bTimeIsChanged #bTimeIsChanged description#>
 *  @param bApplySucess   #bApplySucess description#>
 *  @param theData        #theData description#>
 *
 *  @return <#return value
 */
-(BOOL)setOutLineStructData:(NSString *)filename
                 isFirstSee:(NSInteger) bFirstSee
                 isSetFirst:(NSInteger)bSetFirst
                      isSee:(NSInteger)bSee
                 isVerifyOk:(NSInteger)bVerifyOk
            isTimeIsChanged:(NSInteger)bTimeIsChanged
              isApplySucess:(NSInteger)bApplySucess
                       data:(RECEIVEDATA_NEW_NEW *)theData
{
    /**
     *  新文件
     */
    BOOL bReturn = FALSE;
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:filename])
    {
        NSLog(@"no file");
        return bReturn;
    }
    NSNumber *fileSize ;
    NSError *err;
    Byte sessionKey[SECRET_KEY_LEN];
    //得到文件大小
    NSDictionary *fileAttributes = [manager attributesOfItemAtPath:filename error:&err];
    if (fileAttributes != nil) {
        
        fileSize = [fileAttributes objectForKey:NSFileSize];
        NSLog(@"%ld", fileSize.longValue);
    }
    
    long structsize =  sizeof(PYCFILEEXT);
    long fileheadoffset = (fileSize.longValue > structsize)? (fileSize.longValue - structsize):0;
    if(fileheadoffset == 0)
    {
        NSLog(@"nothing in in");
        return bReturn;
    }
    NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:filename];
    if (!handle ) {
        NSLog(@"file handle move err");
        return NO;
    }
    
    [handle seekToFileOffset:fileheadoffset];
    /*  NSData *data = [handle readDataOfLength:sizeof(PYCFILEHEADER)];
     
     PYCFILEHEADER *header = (PYCFILEHEADER *)[data bytes];
     NSLog(@"file original size really %lld", header->fileSize);
     */
    
    NSData *dataExt = [handle readDataOfLength:sizeof(PYCFILEEXT)];
    PYCFILEEXT *fileExtHeader = (PYCFILEEXT *)[dataExt bytes];
    PycCode *coder = [[PycCode alloc] init];
    [coder decodeFileExtension:fileExtHeader];
    if(fileExtHeader->uTag == PycTag1)
    {
        [coder getSessionKeyFormFileSessionKey:fileExtHeader->szSessionKey to:sessionKey];

        //读取离线结构
        fileheadoffset -= sizeof(OUTLINE_STRUCT);
        [handle seekToFileOffset:fileheadoffset];
        NSData *outLine = [handle readDataOfLength:sizeof(OUTLINE_STRUCT)];
        OUTLINE_STRUCT *fileOutLineStru = (OUTLINE_STRUCT *)[outLine bytes];
        [coder decodeBufferOfFile:(Byte*)fileOutLineStru length:sizeof(OUTLINE_STRUCT) withKey:sessionKey];
        if(fileOutLineStru->structflag == PycTag0)
        {
            if(bApplySucess)
            {
                fileOutLineStru->applyid = (int)self.applyId;
            }
            else if(bFirstSee)
            {
                //取得文件的创建时间
                fileOutLineStru->actived = 1;
                fileOutLineStru->isClent = 1;
                fileOutLineStru->fileopenednum = fileOutLineStru->fileopenednum + 1;
                fileOutLineStru->iCanSeeCondition = theData->userData.otherset;
                fileOutLineStru->bCanPrint = theData->userData.bCanPrint;
                fileOutLineStru->daynum = theData->userData.dayNum;
                fileOutLineStru->yearnum = theData->userData.yearNum;
                fileOutLineStru->fileopennum = theData->userData.fileOpenNum;
                fileOutLineStru->chosenum = theData->userData.bindNum;
                fileOutLineStru->fieldnum = theData->userData.activeNum;
                fileOutLineStru->fieldprotect = theData->userData.ID;
                strcpy(fileOutLineStru->email,theData->userData.email);
                strcpy(fileOutLineStru->QQ,theData->userData.QQ);
                strcpy(fileOutLineStru->phone,theData->userData.phone);
                strcpy(fileOutLineStru->email,theData->userData.email);
                strcpy(fileOutLineStru->field1,theData->userData.field1);
                strcpy(fileOutLineStru->field2,theData->userData.field2);
                strcpy(fileOutLineStru->field1name,theData->userData.hardno);
                strcpy(fileOutLineStru->field2name,theData->userData.logName);
                
                memcpy((Byte *)(fileOutLineStru->hardno ), [_OpenUUID UTF8String], HARDNO_LEN);
                memcpy(fileOutLineStru->EncodeKey, theData->userData.EncodeKey,ENCRYPKEY_LEN);
            }
            else if(bSetFirst)
            {
                memset(fileOutLineStru,0,sizeof(OUTLINE_STRUCT));
               fileOutLineStru->structflag = 0x00435950;
            }
            else if(bSee)
            {
                fileOutLineStru->fileopenednum = fileOutLineStru->fileopenednum + 1;
            }
                
            if(bTimeIsChanged)
            {
                fileOutLineStru->timeismodified = 1;
            }
            else
            {
               fileOutLineStru->timeismodified = 0;
            }
            if(bFirstSee || bVerifyOk || bSee)
            {
                if((fileOutLineStru->daynum > 0) || (fileOutLineStru->yearnum > 0))
                {
                    struct tm when,when1;
                    time_t now;
                    time(&now);
                    gmtime_r(&now,&when);
                    sprintf(fileOutLineStru->lastSeeTime,"%4d-%d%d-%d%d %d%d:%d%d:%d%d", when.tm_year+1900,(when.tm_mon+1)/10,(when.tm_mon+1)%10,when.tm_mday/10,when.tm_mday%10,when.tm_hour/10,when.tm_hour%10,when.tm_min/10,when.tm_min%10,when.tm_sec/10,when.tm_sec%10);
                    if (bFirstSee) {
                        localtime_r(&now,&when1);
                        sprintf(fileOutLineStru->firstseeTime,"%4d-%d%d-%d%d %d%d:%d%d:%d%d", when1.tm_year+1900,(when1.tm_mon+1)/10,(when1.tm_mon+1)%10,when1.tm_mday/10,when1.tm_mday%10,when1.tm_hour/10,when1.tm_hour%10,when1.tm_min/10,when1.tm_min%10,when1.tm_sec/10,when1.tm_sec%10);
                        strcpy(theData->userData.firstSeeTime,fileOutLineStru->firstseeTime);
                    }
                    if (bFirstSee || bVerifyOk) {
                        when.tm_mday = when.tm_mday + theData->userData.dayRemain;
                        when.tm_year = when.tm_year + theData->userData.yearRemain;
                        if((mktime(&when)) != ((time_t)-1))
                        {
                            sprintf(fileOutLineStru->endTime,"%4d-%d%d-%d%d %d%d:%d%d:%d%d", when.tm_year+1900,(when.tm_mon+1)/10,(when.tm_mon+1)%10,when.tm_mday/10,when.tm_mday%10,when.tm_hour/10,when.tm_hour%10,when.tm_min/10,when.tm_min%10,when.tm_sec/10,when.tm_sec%10);
                        }

                    }
                }
            }
      //用seesionKey加密离线结构
            [coder codeBufferOfFile:(Byte*)fileOutLineStru length:sizeof(OUTLINE_STRUCT) withKey:sessionKey];
            //写入文件
            [handle seekToFileOffset:fileheadoffset];
            NSData *data = [[NSData alloc] initWithBytes:fileOutLineStru length:sizeof(OUTLINE_STRUCT)];
         
             [handle writeData:data];
        }
    }
  
    [handle closeFile];
    return TRUE;
}


/**
 *  是否是老文件，true:新文件，false：老文件
 *
 *  @param fileName
 *  @param theApplyID d
 *
 *  @return d
 */
-(BOOL)isFileNeedNet:(NSString*)fileName applyID:(NSInteger *)theApplyID
{
    BOOL bRet = YES;
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:fileName]) {
        NSLog(@"no file");
        return bRet;
        
    }
    NSNumber *fileSize ;
    NSError *err;
    Byte sessionKey[SECRET_KEY_LEN];
    //得到文件大小
    NSDictionary *fileAttributes = [manager attributesOfItemAtPath:fileName error:&err];
    if (fileAttributes != nil) {
        
        fileSize = [fileAttributes objectForKey:NSFileSize];
        NSLog(@"%ld", fileSize.longValue);
    }
    
    long structsize =  sizeof(PYCFILEEXT);
    long fileheadoffset = (fileSize.longValue > structsize)? (fileSize.longValue - structsize):0;
    if(fileheadoffset == 0)
    {
        NSLog(@"nothing in in");
        return bRet;
    }
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:fileName];
    if (!handle ) {
        NSLog(@"file handle move err");
        return bRet;
    }
    
    [handle seekToFileOffset:fileheadoffset];
    /*  NSData *data = [handle readDataOfLength:sizeof(PYCFILEHEADER)];
     
     PYCFILEHEADER *header = (PYCFILEHEADER *)[data bytes];
     NSLog(@"file original size really %lld", header->fileSize);
     */
    
    NSData *dataExt = [handle readDataOfLength:sizeof(PYCFILEEXT)];
    PYCFILEEXT *fileExtHeader = (PYCFILEEXT *)[dataExt bytes];
    PycCode *coder = [[PycCode alloc] init];
    [coder decodeFileExtension:fileExtHeader];
    if(fileExtHeader->uTag == PycTag1)
    {
        //解密扩展结构
        [coder getSessionKeyFormFileSessionKey:fileExtHeader->szSessionKey to:sessionKey];
        //取得离线结构内容
        fileheadoffset -= sizeof(OUTLINE_STRUCT);
        [handle seekToFileOffset:fileheadoffset];
        NSData *outLine = [handle readDataOfLength:sizeof(OUTLINE_STRUCT)];
        OUTLINE_STRUCT *fileOutLineStru = (OUTLINE_STRUCT *)[outLine bytes];
        [coder decodeBufferOfFile:(Byte*)fileOutLineStru length:sizeof(OUTLINE_STRUCT) withKey:sessionKey];
        if(fileOutLineStru->structflag == PycTag0)
        {
            *theApplyID = fileOutLineStru->applyid;
            if(fileOutLineStru->applyid != 0 && fileOutLineStru->actived == 1)
            {
                bRet = NO;
            }
        }
    }
    [handle closeFile];
    return bRet;
}
//根据离线返回值，处理离线文件：设置离线结构，能看时要读取离线结构的数据返回给回调函数
-(BOOL)modifySourceFileByOutlineValue:(NSInteger)value filename:(NSString*) theFileName
{

    int i_SetFirst = 0;
    int i_Seeing = 0;
    int i_TimeIsChanged = 0;
    if(value == ERR_OUTLINE_IS_OTHER_ERR)
    {
        return TRUE;
    }
    if(value == ERR_OUTLINE_DAY_ERR || value == ERR_OUTLINE_NUM_ERR )
    {
        i_SetFirst = 1;
    }
    if(value == ERR_OUTLINE_OK)
    {
        i_Seeing = 1;
    }
    if(value == ERR_OUTLINE_TIME_CHANGED_ERR)
    {
        i_TimeIsChanged = 1;
    }
    [self setOutLineStructData:theFileName isFirstSee:0 isSetFirst:i_SetFirst isSee:i_Seeing isVerifyOk:0 isTimeIsChanged:i_TimeIsChanged isApplySucess:0 data:NULL];
    return TRUE;
}

#pragma mark 离线阅读从数据库中获取文件信息
/**
 *  将可读文件的属性值，赋值给self的相关属性
 *
 *  @param newFile 数据库记录对象
 */
-(void)setValueOfSelfByNewFile:(OutFile *)newFile
{
    //离线查看文件需要更新的数据
    self.filePycNameFromServer = [newFile.filename stringByAppendingString:@".pbb"];
    self.fileType = [self getFileType:self.filePycNameFromServer];
    self.fileOwner = newFile.fileowner;
    self.nickname = newFile.fileOwnerNick;
    self.AllowOpenmaxNum = newFile.limitnum;
    self.haveOpenedNum = newFile.readnum;
    
    self.startDay = [newFile.starttime dateStringByDay];
    self.endDay = [newFile.endtime dateStringByDay];
    self.openTimeLong = newFile.limittime;
    self.remark = newFile.note;
    if (newFile.fileMakeType == 1)
    {
        self.iCanOpen = newFile.forbid;
    }
    self.canseeCondition = newFile.isEye;
    self.QQ = newFile.waterMarkQQ;
    self.phone = newFile.waterMarkPhone;
    self.email = newFile.waterMarkEmail;
    self.dayRemain = newFile.fileDayRemain;
    self.yearRemain = newFile.fileYearRemain;
    self.field1 = newFile.field1;
    self.field2 = newFile.field2;
    self.fild1name = newFile.field1name;
    self.fild2name = newFile.field2name;
    self.fileSecretkeyR1 = newFile.EncodeKey;
    self.selffieldnum = newFile.selffieldnum;
    self.definechecked = newFile.definechecked;
    //获取离线明文文件
    if (newFile.status && fileOperateType == TYPE_FILE_OPEN)
    {
        [self makeOpenFile];
    }
    
}

/**
 *  可读的旧文件，用新版本第一次阅读时，需将扩展结构的属性值，移动到本地数据库中。
 *
 *  @param filename 文件路径
 *
 *  @return OutFile对象
 */
-(OutFile *)copyDataToSqlite:(NSString *)filename
{
    
    OutFile *newFile = [[OutFile alloc] init];
    
    //取离线机构的数据赋值给self中变量
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:filename]) {
        NSLog(@"no file");
        return nil;
        
    }
    NSNumber *fileSize ;
    NSError *err;
    Byte sessionKey[SECRET_KEY_LEN];
    //得到文件大小
    NSDictionary *fileAttributes = [manager attributesOfItemAtPath:filename error:&err];
    if (fileAttributes != nil) {
        
        fileSize = [fileAttributes objectForKey:NSFileSize];
        NSLog(@"%ld", fileSize.longValue);
    }
    
    long structsize =  sizeof(PYCFILEEXT);
    long fileheadoffset = (fileSize.longValue > structsize)? (fileSize.longValue - structsize):0;
    if(fileheadoffset == 0)
    {
        NSLog(@"nothing in in");
        return nil;
    }
    NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:filename];
    if (!handle ) {
        NSLog(@"file handle move err");
        return nil;
    }
    
    [handle seekToFileOffset:fileheadoffset];
    
    NSData *dataExt = [handle readDataOfLength:sizeof(PYCFILEEXT)];
    PYCFILEEXT *fileExtHeader = (PYCFILEEXT *)[dataExt bytes];
    PycCode *coder = [[PycCode alloc] init];
    [coder decodeFileExtension:fileExtHeader];
    if(fileExtHeader->uTag == PycTag1)
    {
        [coder getSessionKeyFormFileSessionKey:fileExtHeader->szSessionKey to:sessionKey];
        
        //读取离线结构
        fileheadoffset -= sizeof(OUTLINE_STRUCT);
        [handle seekToFileOffset:fileheadoffset];
        NSData *outLine = [handle readDataOfLength:sizeof(OUTLINE_STRUCT)];
        [handle closeFile];
        OUTLINE_STRUCT *fileOutLineStru = (OUTLINE_STRUCT *)[outLine bytes];
        [coder decodeBufferOfFile:(Byte*)fileOutLineStru length:sizeof(OUTLINE_STRUCT) withKey:sessionKey];
        if(fileOutLineStru->structflag == PycTag0)
        {
            
            
            self.fileSecretkeyOrigianlR1 = [[NSData alloc] initWithBytes:fileOutLineStru->EncodeKey length: ENCRYPKEY_LEN];
            
            
            Byte fileScreateR1[ENCRYPKEY_LEN];
            [coder getSecretKeyFromOriginalKey:(Byte *)[self.fileSecretkeyOrigianlR1 bytes]  to:fileScreateR1];
            self.fileSecretkeyR1 = [[NSData alloc] initWithBytes:fileScreateR1 length: ENCRYPKEY_LEN];
            
            if (strlen(fileOutLineStru->field1) == 0) {
                newFile.field1 = @"";
            }
            else
            {
                newFile.field1 = [[NSString alloc] initWithUTF8String:fileOutLineStru->field1];
            }
            if (strlen(fileOutLineStru->field2) == 0) {
                newFile.field2 = @"";
            }
            else
            {
                newFile.field2 = [[NSString alloc] initWithUTF8String:fileOutLineStru->field2];
            }
            if (strlen(fileOutLineStru->field1name) == 0) {
                newFile.field1name = @"";
            }
            else
            {
                newFile.field1name = [[NSString alloc] initWithUTF8String:fileOutLineStru->field1name];
            }
            if (strlen(fileOutLineStru->field2name) == 0) {
                newFile.field2name = @"";
            }
            else
            {
                newFile.field2name = [[NSString alloc] initWithUTF8String:fileOutLineStru->field2name];
            }
            
            newFile.hardno = _OpenUUID;
            /**
             *  将旧版离线文件中的数据拷贝到本地数据库中
             */
            [[ReceiveFileDao sharedReceiveFileDao] updateByFileIdReceiveFile:newFile];
        }
    }
    else
    {
        [handle closeFile];
    }
    return newFile;
}
#pragma mark - 根据限制条件（天数，次数），判断离线文件是否可以浏览
-(int)isOutLineFileCanSee:(NSString*)fileName remainDay:(NSInteger*)theRemainDay remainYear:(NSInteger *)theRemainYear
{
    int iReturn = ERR_OUTLINE_OTHER_ERR;
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:fileName]) {
        NSLog(@"no file");
        return iReturn;
        
    }
    NSNumber *fileSize ;
    NSError *err;
    Byte sessionKey[SECRET_KEY_LEN];
    //得到文件大小
    NSDictionary *fileAttributes = [manager attributesOfItemAtPath:fileName error:&err];
    if (fileAttributes != nil) {
        
        fileSize = [fileAttributes objectForKey:NSFileSize];
        NSLog(@"离线文件size=%ld", fileSize.longValue);
    }
    
    long structsize =  sizeof(PYCFILEEXT);
    long fileheadoffset = (fileSize.longValue > structsize)? (fileSize.longValue - structsize):0;
    if(fileheadoffset == 0)
    {
        return iReturn;
    }
    NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    if (!handle ) {
        NSLog(@"file handle move err");
        return iReturn;
    }
    
    [handle seekToFileOffset:fileheadoffset];
    /*  NSData *data = [handle readDataOfLength:sizeof(PYCFILEHEADER)];
     
     PYCFILEHEADER *header = (PYCFILEHEADER *)[data bytes];
     NSLog(@"file original size really %lld", header->fileSize);
     */
    
    NSData *dataExt = [handle readDataOfLength:sizeof(PYCFILEEXT)];
    PYCFILEEXT *fileExtHeader = (PYCFILEEXT *)[dataExt bytes];
    PycCode *coder = [[PycCode alloc] init];
    [coder decodeFileExtension:fileExtHeader];
    if(fileExtHeader->uTag == PycTag1)
    {
        [coder getSessionKeyFormFileSessionKey:fileExtHeader->szSessionKey to:sessionKey];
        //取得离线结构内容
        fileheadoffset -= sizeof(OUTLINE_STRUCT);
        [handle seekToFileOffset:fileheadoffset];
        NSData *outLine = [handle readDataOfLength:sizeof(OUTLINE_STRUCT)];
        OUTLINE_STRUCT *fileOutLineStru = (OUTLINE_STRUCT *)[outLine bytes];
        [coder decodeBufferOfFile:(Byte*)fileOutLineStru length:sizeof(OUTLINE_STRUCT) withKey:sessionKey];
        struct tm when;
        time_t now;
        char strTime[LONGTIME_LEN+1] = "";
        time(&now);
        gmtime_r(&now,&when);
        sprintf(strTime,"%4d-%d%d-%d%d %d%d:%d%d:%d%d", when.tm_year+1900,(when.tm_mon+1)/10,(when.tm_mon+1)%10,when.tm_mday/10,when.tm_mday%10,when.tm_hour/10,when.tm_hour%10,when.tm_min/10,when.tm_min%10,when.tm_sec/10,when.tm_sec%10);
        
        if(fileOutLineStru->structflag != PycTag0)
        {
              iReturn = ERR_OUTLINE_STRUCTION_ERR;
        }
        else if(strcmp(fileOutLineStru->hardno,[_OpenUUID UTF8String]))
        {
            iReturn = ERR_OUTLINE_HDID_ERR;
        }
        else if((fileOutLineStru->daynum ==0) && (fileOutLineStru->yearnum == 0) && (fileOutLineStru->fileopennum == 0))
        {
            iReturn = ERR_OUTLINE_OK;
        }
        else if((fileOutLineStru->fileopennum>0) && (fileOutLineStru->fileopenednum >= fileOutLineStru->fileopennum))
        {
            iReturn = ERR_OUTLINE_NUM_ERR;
        }
        else
        {
            //取得本地时间
            if( strlen(fileOutLineStru->endTime) > 0 && strcmp(strTime, fileOutLineStru->endTime) >= 0)
            {
                iReturn = ERR_OUTLINE_DAY_ERR;
            }
            else if (fileOutLineStru->timeismodified)
            {
                iReturn = ERR_OUTLINE_TIME_CHANGED_ALREADY_ERR;
            }
            else if (strcmp(strTime, fileOutLineStru->lastSeeTime) < 0)
            {
                iReturn = ERR_OUTLINE_TIME_CHANGED_ERR;
            }
            else{
                iReturn = ERR_OUTLINE_OK;
            }

         
        }
        //把记录中的结束时间转换为时间
        if (iReturn == ERR_OUTLINE_DAY_ERR)
        {
            if(theRemainDay != nil)
            {
                *theRemainDay = 0;
            }
            if (theRemainYear != nil) {
                *theRemainYear = 0;
            }
            
        }
        else if (strlen(fileOutLineStru->endTime) > 0) {
            NSString *endTimestr = [NSString stringWithFormat:@"%s",fileOutLineStru->endTime];
            NSDate *endtime = [NSDate dateWithString:endTimestr];
            NSDate *nowTime = [NSDate getNowDateFromatAnDate:[NSDate date]];
            //取得时间差
            NSInteger allDays = [NSDate OffLineFileOfLastdayFromDate:nowTime ToDate:endtime];
            if(theRemainDay != nil)
            {
                *theRemainDay = allDays % 365; 
            }
            if (theRemainYear != nil) {
                *theRemainYear = allDays / 365;
            }
            //当前时间在第一次看之前
            if(strcmp(strTime, fileOutLineStru->firstseeTime) <= 0)
            {
                if(theRemainDay != nil)
                {
                    *theRemainDay = fileOutLineStru->daynum;
                }
                if (theRemainYear != nil) {
                     *theRemainDay = fileOutLineStru->yearnum;
                }
                
            }
        }

    }
    [handle closeFile];
    return iReturn;
    
}


@end
