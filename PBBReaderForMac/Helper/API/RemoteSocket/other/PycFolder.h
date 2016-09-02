//
//  PycFolder.h
//  PycSocket
//
//  Created by Fairy on 13-11-7.
//  Copyright (c) 2013年 Fairy. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PycFolder : NSObject

//-(NSString *)documentDirectory;
//-(NSString *)DocmentFilepath:(NSString *) fileName;
//-(NSString *)DocmentFilePycpath:(NSString *) fileName;

+(NSString *)documentSendFolderWithUserID:(NSString *)logname;
+(NSString *)documentReceiveFolderWithUserID:(NSString *)logname;
+(NSString *)documentWxFolderWithUserID:(NSString *)logname;
+(NSString *)documentViewFolderWithUserID:(NSString *)logname;
//-(void) GetHashValue:(NSString *) fileFullName hashValue: (unsigned char *)hashValue;
+(NSString *)documentDirectory;
+(NSString *)documentDirectoryForCode;

@end
