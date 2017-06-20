//
//  PycFolder.m
//  PycSocket
//
//  Created by Fairy on 13-11-7.
//  Copyright (c) 2013年 Fairy. All rights reserved.
//

#import "PycFolder.h"
#import "FileOutPublic.h"
#import "PycCode.h"

@implementation PycFolder

+(NSString *)tmpDirctory
{
  return  NSTemporaryDirectory();
}

-(NSString *)documentDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
    
}

-(NSString *)DocmentFilepath:(NSString *) fileName
{
    return [[self documentDirectory] stringByAppendingPathComponent:fileName];
}

//-(NSString *)DocmentFilePycpath:(NSString *) fileName
//{
//    NSString *filenNameOriginal = [self DocmentFilepath:fileName];
//  
//    return  [filenNameOriginal stringByAppendingString:@".pyc"];
//}


+(NSString *)documentDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
    
}
+(NSString *)DocmentFilepath:(NSString *) fileName
{
    return [[self documentDirectory] stringByAppendingPathComponent:fileName];
}

//+(NSString *)DocmentFilePycpath:(NSString *) fileName
//{
//    NSString *filenNameOriginal = [self DocmentFilepath:fileName];
//    return  [filenNameOriginal stringByAppendingString:@".pyc"];
//}
+(NSString *)documentForUser:(NSString *)logname
{
    return [[self documentDirectory] stringByAppendingPathComponent:logname];
}
+(NSString *)documentSendFolderWithUserID:(NSString *)logname
{
    if (logname == nil) {
        return nil;
    }
    
    return [[self documentForUser:logname] stringByAppendingPathComponent:@"send"];
    
}
+(NSString *)documentReceiveFolderWithUserID:(NSString *)logname
{
    if (logname == nil) {
        return nil;
    }
    
    return [[self documentForUser:logname] stringByAppendingPathComponent:@"receive"];
    
}

+(NSString *)documentViewFolderWithUserID:(NSString *)logname
{
    if (logname == nil) {
        return nil;
    }
    return [self tmpDirctory];
}
+(NSString *)documentWxFolderWithUserID:(NSString *)logname
{
    
    if (logname == nil) {
        return nil;
    }
    return [[self documentDirectory] stringByAppendingPathComponent:logname];
}

+(NSString *)documentDirectoryForCode
{
     return [[self documentDirectory] stringByAppendingPathComponent:@"coded"];
}
//+(NSString *)documentReceiveFolderWithUserID:(NSString *)logname
//{
//    if (logname == nil) {
//        return nil;
//    }
//    
//    return [[self documentForUser:logname] stringByAppendingPathComponent:@"receive"];
//}

//-(void) GetHashValue:(NSString *) fileFullName hashValue: (unsigned char *)hashValue
//{
//    NSInteger fileSizeTodo = 0;
//    Byte *fileContentTodo;
//    BOOL allFileContent = NO;
//    unsigned char *hashValueTodo = hashValue;
//    memset(hashValue, 0, HASH_LEN);
//    
//    //读文件
//    NSError *err;
//    NSFileManager *manager = [NSFileManager defaultManager];
//    if (![manager fileExistsAtPath:fileFullName]) {
//       
//        NSLog(@"hash full file name not exit");
//    }
//    
//    NSNumber *fileSize;
//    NSDictionary *fileAttributes = [manager attributesOfItemAtPath:fileFullName error:&err];
//       if (fileAttributes != nil) {
//            fileSize = [fileAttributes objectForKey:NSFileSize];
//     }
//    
//    //fileSizeTodo = (fileSize.intValue >= HASH_FILE_SIZE_TODO) ? HASH_FILE_SIZE_TODO:fileSize.intValue;
//    
//    if (fileSize.intValue >= HASH_FILE_SIZE_TODO) {
//        fileSizeTodo = HASH_FILE_SIZE_TODO;
//        
//        
//    }
//    else{
//        fileSizeTodo = fileSize.intValue;
//        allFileContent = YES;
//    }
//    
//    if (allFileContent) {
//        
//        NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:fileFullName];
//        NSData *data = [handle readDataToEndOfFile];
//        fileContentTodo = (Byte *)[data bytes];
//    }
//    else
//    {
//        //todo 
//    }
//    
//        
//    PycCode *coder = [[PycCode alloc] init];
//[coder CalculateHashValue:fileContentTodo datalen:fileSizeTodo hashValue:hashValue];
//
//
//
//    
//}
@end
