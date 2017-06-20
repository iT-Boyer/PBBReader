//
//  PycPrivateFile.m
//  PBB
//
//  Created by Fairy on 14-3-20.
//  Copyright (c) 2014年 pyc.com.cn. All rights reserved.
//

#import "PycPrivateFile.h"
#import "SandboxFile.h"
#import "PycFileOperateCommon.h"
#import "PycCode.h"
#import "NewUserPublic.h"
#import "PycFolder.h"


@interface PycPrivateFile ()
{
    NSString *fileSourcePath;
    NSString *fileModifyTmpPath;
    NSString *fileDestinationPath;
    NSData   *uidForFile;
    
    int64_t fileLength;

}



@end

@implementation PycPrivateFile
singleton_implementation(PycPrivateFile)

-(BOOL)createCodeFolder
{
    BOOL isDir;
    NSError *err;
    NSString *codedFolderPath = [[SandboxFile GetDocumentPath] stringByAppendingPathComponent:@"coded"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:codedFolderPath isDirectory:&isDir]) {
        
        if(![manager createDirectoryAtPath:codedFolderPath withIntermediateDirectories:YES attributes:nil error:&err])
        {
            NSLog(@"create dir err %@", err);
            return NO;
        }
    }
    else
    {
        NSLog(@"send folder exist");
    }
    
    return YES;
}
//流加密
-(void)codeFile:(NSString *)fileFullPath byUid:(NSData *)uid completion:(void (^)(NSString *))completion
{
    PycPrivateFileOperateResult iReturn = PycPrivateFileOperateOK;
    NSError *err;
    
    MyLog(@"uid===%@", uid);
    fileSourcePath = fileFullPath;
    uidForFile = uid;
    
    MyLog(@"slx----source %@",fileSourcePath);
    if(![self createCodeFolder])
    {
        iReturn = PycPrivateFileOperateLimitedAuthority;
        goto ALL_END;
        
    }
    //判断文件合法性
    if(![SandboxFile IsFileExists:fileSourcePath])
    {
        MyLog(@"slx----source not exist %@",fileSourcePath);
        iReturn = PycPrivateFileOperateParamErr;
        goto ALL_END;
    }
    EncodeTail tail;
    memset(&tail, 0, sizeof(EncodeTail));
    tail.mark = (int64_t)37968208;//37968208
//    memccpy(&tail.uid, sizeof(int64_t), size_t)[uidForFile bytes];
    memcpy(&tail.uid, [uidForFile bytes], [uidForFile length]);
    //创建临时文件并修改文件
    if(![self makeTmpFileToModify])
    {
        iReturn = PycPrivateFileOperateLimitedAuthority;
        goto ALL_END;
    }
    
    MyLog(@"slx----tmp %@",fileModifyTmpPath);
    //得到文件大小
    tail.fileLength = [SandboxFile GetFileSize:fileModifyTmpPath];
    //补齐文件
    [self modifyFileToStandard];
    //得到文件类型
    NSInteger codeLen = [self getEncodeLenBYType:[PycFileOperateCommon GetFileType:fileSourcePath]];
    //边读边加密
    tail.encryptLength  = [self codeFileByLen:codeLen];
  
    //添加文件尾
    [self fileAddTail:&tail];
    
    //得到最终文件
   // [SandboxFile DeleteFile:fileSourcePath];
    fileDestinationPath = [self getNotExistDestinationPath];
    if(![[NSFileManager defaultManager] moveItemAtPath:fileModifyTmpPath toPath:fileDestinationPath error:&err])
    {
        MyLog(@"err = %@",err);
        iReturn = PycPrivateFileOperateLimitedAuthority;
    }
    MyLog(@"slx----destination path %@",fileDestinationPath);
    
ALL_END:
    if (iReturn != PycPrivateFileOperateOK) {
        
        [SandboxFile DeleteFile:fileModifyTmpPath];
        NSLog(@"errcode = %d err = %@", iReturn, err);
        completion(nil);
    }else
    {

        completion(fileDestinationPath);
        MyLog(@"ok");
    }
    return;
}


-(void)decodeFile:(NSString *)fileFullPath byUid:(NSData *)uid completion:(void (^)(NSString *))completion
{
    PycPrivateFileOperateResult iReturn = PycPrivateFileOperateOK;
    fileSourcePath = fileFullPath;
    uidForFile = uid;
    int64_t byteUid;
    memcpy(&byteUid, [uidForFile bytes], [uidForFile length]);
    fileDestinationPath = [[SandboxFile GetTmpPath] stringByAppendingPathComponent:[fileSourcePath lastPathComponent]];
    if ([SandboxFile IsFileExists:fileDestinationPath]) {
        [SandboxFile DeleteFile:fileDestinationPath];
    }
    //读取文件尾巴
    NSData *fileTail = [self readlastSizeLen];
    EncodeTail *encryptTail = (EncodeTail *)[fileTail bytes];
    
    //判断标识
    if ((encryptTail == nil ) ||  (encryptTail->mark != (int64_t)37968208))
    {
        iReturn = PycPrivateFileOperateParamErr;
        completion(nil);
        return;
    }
    
    //解密
    Byte byteKey[17];
    memset(byteKey, 0, 17);
//    NSData *uidForFile2  = [[NSData alloc] initWithBytes:&(encryptTail->uid) length:17];
    [PycCode getSecretKeyFromUid:(Byte *)[uidForFile bytes] to:byteKey];
    NSData *byteKeyData = [[NSData alloc] initWithBytes:&byteKey length:16];
//    NSLog(@"data %@",byteKeyData);
    [self moveFileAndDecodeFrom:fileSourcePath partOfContent:encryptTail->fileLength decodeSize:encryptTail->encryptLength toDestination:fileDestinationPath key:byteKeyData];
    

    if (iReturn != PycPrivateFileOperateOK) {
        [SandboxFile DeleteFile:fileDestinationPath];
        completion(nil);
    }else{
        completion(fileDestinationPath);
    }
    
    
}


-(BOOL)moveFileAndDecodeFrom:(NSString *)strFileName partOfContent:(long)originalFileLen decodeSize:(NSInteger)encryptLen toDestination:(NSString *)strDestination key:(NSData *)key
{
////    //#warning .....
//    NSString *realDestinationPath  = strDestination;//= [self getNotExistName:strDestination];
//    NSFileManager *manager = [NSFileManager defaultManager];
////    if (![manager createFileAtPath:realDestinationPath contents:nil attributes:nil]) {
////        NSLog(@"err");
////        
////        return NO;
////    }
//    NSError *error;
//    if(![manager copyItemAtPath:strFileName toPath:realDestinationPath error:&error]) {
//        NSLog(@"err");
//        
//        return NO;
//    }
// 
//    NSLog(@"destnatin file is %@", realDestinationPath);
//    
//
//    //get file len
//    long readReallen = 0;
//    int preReadMaxLen = 1024*1024 ;
//    int encodelen = 0;
//    int readlen = 0;
//    BOOL bDecodeFinish = NO;
//    BOOL bCopyFinish = NO;
//    
//    
//    NSFileHandle *handleDestination = [NSFileHandle fileHandleForWritingAtPath:realDestinationPath];
//    if (!handleDestination ) {
//        NSLog(@"file handle move err");
//        return NO;
//    }
//    
//    
//    NSFileHandle *handleSource = [NSFileHandle fileHandleForReadingAtPath:strFileName];
//    if (handleSource == nil) {
//        return NO;
//    }
//    NSLog(@"originalFileLen %ld", originalFileLen); //-------
//   while (YES) {
//           NSData *data = [[NSData alloc] init];
//
//        data = [handleSource readDataOfLength:preReadMaxLen];
//        readReallen += [data length];
////        NSLog(@"readReallen %ld", readReallen); //-------
//        if ([data length] == 0) {
////            NSLog(@"finish code %ld", readReallen); //-------
//            break;
//        }
//        
//        if (!bDecodeFinish) {
//            if (readReallen >= encryptLen) {
//                encodelen = [data length] - (readReallen - encryptLen);
//                bDecodeFinish = YES;
//            }else
//            {
//                encodelen = [data length];
//            }
//            
//            PycCode *coder = [[PycCode alloc] init];
//            [coder decodeBufferOfFile:(Byte *)[data bytes] length:encodelen withKey:(Byte *)[key bytes]];
//      
//        }
//        if (!bCopyFinish) {
//            if (readReallen >= originalFileLen) {
//                readlen = [data length] - (readReallen - originalFileLen);
//                NSData *theLastData = [[NSData alloc] initWithBytes:[data bytes] length:readlen];
//                [handleDestination writeData:theLastData];
//                 bCopyFinish = YES;
//            }
//            else
//            {
////                NSLog(@"copy %d", readlen); //-------
//
//                readlen = [data length];
//                [handleDestination writeData:data];
//            }
//        }
//        // 释放内存
//       
//        if (bCopyFinish && bDecodeFinish) {
//            
//            break;
//        }
////        else{
////            [data  dealloc];
////        }
//       
//    }
//    
//    [handleSource closeFile];
//    [handleDestination closeFile];
//    
//    return YES;
//    //    //#warning .....
//    //    NSString *realDestinationPath  = strDestination;//= [self getNotExistName:strDestination];
//    //    NSFileManager *manager = [NSFileManager defaultManager];
//    //    if (![manager createFileAtPath:realDestinationPath contents:nil attributes:nil]) {
//    //        NSLog(@"err");
//    //
//    //        return NO;
//    //    }
//    //
//    //    NSLog(@"destnatin file is %@", realDestinationPath);
//    //
//    //
//    //    //get file len
//    //    long readReallen = 0;
//    //    int preReadMaxLen = 1024*1024 ;
//    //    int encodelen = 0;
//    //    int readlen = 0;
//    //    BOOL bDecodeFinish = NO;
//    //    BOOL bCopyFinish = NO;
//    //
//    //
//    //    NSFileHandle *handleDestination = [NSFileHandle fileHandleForWritingAtPath:realDestinationPath];
//    //    if (!handleDestination ) {
//    //        NSLog(@"file handle move err");
//    //        return NO;
//    //    }
//    //
//    //
//    //    NSFileHandle *handleSource = [NSFileHandle fileHandleForReadingAtPath:strFileName];
//    //    if (handleSource == nil) {
//    //        return NO;
//    //    }
//    //    NSLog(@"originalFileLen %ld", originalFileLen); //-------
//    //   while (YES) {
//    //           NSData *data = [[NSData alloc] init];
//    //
//    //        data = [handleSource readDataOfLength:preReadMaxLen];
//    //        readReallen += [data length];
//    ////        NSLog(@"readReallen %ld", readReallen); //-------
//    //        if ([data length] == 0) {
//    ////            NSLog(@"finish code %ld", readReallen); //-------
//    //            break;
//    //        }
//    //
//    //        if (!bDecodeFinish) {
//    //            if (readReallen >= encryptLen) {
//    //                encodelen = [data length] - (readReallen - encryptLen);
//    //                bDecodeFinish = YES;
//    //            }else
//    //            {
//    //                encodelen = [data length];
//    //            }
//    //
//    //            PycCode *coder = [[PycCode alloc] init];
//    //            [coder decodeBufferOfFile:(Byte *)[data bytes] length:encodelen withKey:(Byte *)[key bytes]];
//    //
//    //        }
//    //        if (!bCopyFinish) {
//    //            if (readReallen >= originalFileLen) {
//    //                readlen = [data length] - (readReallen - originalFileLen);
//    //                NSData *theLastData = [[NSData alloc] initWithBytes:[data bytes] length:readlen];
//    //                [handleDestination writeData:theLastData];
//    //                 bCopyFinish = YES;
//    //            }
//    //            else
//    //            {
//    ////                NSLog(@"copy %d", readlen); //-------
//    //
//    //                readlen = [data length];
//    //                [handleDestination writeData:data];
//    //            }
//    //        }
//    //        // 释放内存
//    //       
//    //        if (bCopyFinish && bDecodeFinish) {
//    //            
//    //            break;
//    //        }
//    ////        else{
//    ////            [data  dealloc];
//    ////        }
//    //       
//    //    }
//    //    
//    //    [handleSource closeFile];
//    //    [handleDestination closeFile];
//    //    
//    //    return YES;
//    
//    //#warning .....
    NSString *realDestinationPath  = strDestination;//= [self getNotExistName:strDestination];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSLog(@"destnatin file is %@", realDestinationPath);
    NSLog(@"strFileName file is %@", strFileName);
   //    if (![manager createFileAtPath:realDestinationPath contents:nil attributes:nil]) {
    //        NSLog(@"err");
    //
    //        return NO;
    //    }
    //
    NSError *error;
    if(![manager copyItemAtPath:strFileName toPath:realDestinationPath error:&error]) {
               NSLog(@"err");
    
                return NO;
    }
    
    
    
    //get file len
    NSInteger readReallen = 0;
    NSInteger preReadMaxLen = 1024*1024 ;
    NSInteger encodelen = 0;
    //    int readlen = 0;
    //    BOOL bDecodeFinish = NO;
    //    BOOL bCopyFinish = NO;
    BOOL bFinish = NO;
    NSInteger filePos = 0;
    NSFileHandle *handleDestination = [NSFileHandle fileHandleForUpdatingAtPath:realDestinationPath];
    if (!handleDestination ) {
        NSLog(@"file handle move err");
        return NO;
    }
    //解密完成
    while (!bFinish) {
        NSData *data = [[NSData alloc] init];
        
        data = [handleDestination readDataOfLength:preReadMaxLen];
        //NSData *data = [handleDestination readDataOfLength:preReadMaxLen];
        
        readReallen += [data length];
        if ([data length] == 0) {
            NSLog(@"finish code %ld", (long)readReallen); //-------
            break;
        }
        
        
        if (readReallen >= encryptLen) {
            encodelen = [data length] - (readReallen -encryptLen);
            NSLog(@"last encrypt len %ld", (long)encodelen);
            readReallen = encryptLen;//-------
            bFinish = YES;
        }else
        {
            encodelen = [data length];
        }
        
        PycCode *coder = [[PycCode alloc] init];
        [coder decodeBufferOfFile:(Byte *)[data bytes] length:(int)encodelen withKey:(Byte *)[key bytes]];
        
        
        [handleDestination seekToFileOffset:filePos];
        [handleDestination writeData:data];
        filePos += encodelen;
    }
    filePos = originalFileLen;
    [handleDestination seekToFileOffset:filePos];
    [handleDestination truncateFileAtOffset:filePos];
    [handleDestination closeFile];
    //
    return YES;
}
-(NSData *)readlastSizeLen
{
    //得到文件大小
    NSError *err;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSNumber *fileSize = 0;
    NSDictionary *fileAttributes = [manager attributesOfItemAtPath:fileSourcePath error:&err];
    if (fileAttributes != nil) {
        
        fileSize = [fileAttributes objectForKey:NSFileSize];
        NSLog(@"%d", fileSize.intValue);
    }
    
    int structsize = sizeof(EncodeTail);
    int64_t fileheadoffset = (fileSize.longLongValue > structsize)? (fileSize.longLongValue - structsize):0;
    if(fileheadoffset == 0)
    {
        NSLog(@"nothing in im");
        return  nil;
    }
    
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:fileSourcePath];
    [handle seekToFileOffset:fileheadoffset];
    NSData *data = [handle readDataOfLength:sizeof(EncodeTail)];
    [handle closeFile];
    
    return data;
}
-(NSString *)getNotExistDestinationPath
{
    NSString *fileDestinationPathReturn =[[PycFolder documentDirectoryForCode] stringByAppendingPathComponent:[fileSourcePath lastPathComponent]] ;

    
    int i = 1;
    if(![SandboxFile IsFileExists:fileDestinationPathReturn])
        return fileDestinationPathReturn;
 
   
    NSString *originalPath = fileDestinationPathReturn;
    fileDestinationPathReturn = [fileDestinationPathReturn fileNameAppend:@"_1"];
    while (1) {
        
        if([SandboxFile IsFileExists:fileDestinationPathReturn])
        {
            fileDestinationPathReturn =  [originalPath fileNameAppend:[[NSString alloc] initWithFormat:@"_%d",++i]];
        }else{
            break;
        }
    }
    
    return fileDestinationPathReturn;
   
}
-(NSInteger)getEncodeLenBYType:(NSInteger)fileType
{
    NSInteger codelen = LEN_UNKOWN;
    switch(fileType)
    {
        case FILE_TYPE_MOVIE:
            
            codelen = LEN_MOVIE;
            break;
        case FILE_TYPE_PDF:
            codelen = LEN_PDF;
            break;
        case FILE_TYPE_PIC:
            codelen = LEN_PIC;
            break;
        case FILE_TYPE_UNKOWN:
            //#warning test just
            codelen = LEN_UNKOWN;// to do ......
            break;
        default:
            codelen = LEN_UNKOWN;
    }

    return codelen;
}
-(NSInteger )codeFileByLen:(NSInteger )codelen
{
    
   
    Byte byteKey[17];
    memset(byteKey, 0, 17);
   
    [PycCode getSecretKeyFromUid:(Byte *)[uidForFile bytes] to:byteKey];
    NSData *byteKeyData = [[NSData alloc] initWithBytes:&byteKey length:16];
    
     NSLog(@"data %@",byteKeyData);
    return [PycFileOperateCommon codeFile:fileModifyTmpPath length:codelen byKey:byteKeyData];
}
-(NSInteger)modifyFileToStandard
{
    NSError *err;
    //得到文件大小
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileModifyTmpPath error:&err];
    if (!fileAttributes) {
        return -1;
    }
    int64_t fileSize  = [[fileAttributes objectForKey:NSFileSize] longLongValue];
    
    //不够加密长度则补齐
    int remainder = (fileSize%16);
    if (remainder != 0) {
        
        NSLog(@"00 need to add %d", 16-remainder);
        Byte byteAdd[16 - remainder];
        memset(byteAdd, 0, 16 - remainder);
        NSData *dataAdd = [[NSData alloc] initWithBytes:byteAdd length:16-remainder];
        NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:fileModifyTmpPath];
        [handle seekToEndOfFile];
        [handle writeData: dataAdd];//-----------------write 0
        [handle closeFile];
    }
    else
    {
        NSLog(@"000 need not");
    }

    return remainder;
}

-(BOOL)makeTmpFileToModify
{
    NSError *err;
    fileModifyTmpPath = [[SandboxFile GetTmpPath] stringByAppendingFormat:@"%@.tmp", [fileSourcePath lastPathComponent]];
    MyLog(@"tmp file path %@", fileModifyTmpPath);
    [SandboxFile DeleteFile:fileModifyTmpPath];
    if(![[NSFileManager defaultManager] copyItemAtPath:fileSourcePath toPath:fileModifyTmpPath error:&err])
    {
        
        return NO;
    }
    return YES;
    

}


-(void)fileAddTail:(EncodeTail *)tail
{
    NSFileHandle *filehandle = [NSFileHandle fileHandleForUpdatingAtPath:fileModifyTmpPath];
    NSData *tailData = [[NSData alloc] initWithBytes:tail length:sizeof(EncodeTail)];
    [filehandle seekToEndOfFile];
    [filehandle writeData: tailData];
    [filehandle closeFile];
}


@end
