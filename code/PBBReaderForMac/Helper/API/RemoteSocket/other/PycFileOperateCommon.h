//
//  PycFileOperateCommon.h
//  PBB
//
//  Created by Fairy on 14-3-20.
//  Copyright (c) 2014年 pyc.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PycPrivateFileDefine.h"
#import "FileOutPublic.h"

@interface PycFileOperateCommon : NSObject

+(NSInteger)GetFileType:(NSString *)filePath;
+(int64_t)codeFile:(NSString *)filePath length:(NSInteger) codeLen  byKey:(NSData *)key;
@end
