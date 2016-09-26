//
//  PycPrivateFile.h
//  PBB
//
//  Created by Fairy on 14-3-20.
//  Copyright (c) 2014年 pyc.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PycPrivateFileDefine.h"

@interface PycPrivateFile : NSObject
singleton_interface(PycPrivateFile)

//@property(nonatomic,strong)NSString *fileDestinationFullPath;
//@property(nonatomic,strong)NSString *logname;
//@property(nonatomic,strong)NSString *fileType;

/**
 *	@brief	加密文件，成功则返回加密文件路径，失败则compliment里返回的路径使nil
 *
 *	@param 	fileFullPath 	原文件全路径
 *	@param 	uid 	Uid 见概要
 */
-(void)codeFile:(NSString *)fileFullPath byUid:(NSData *)uid completion:(void (^)(NSString *))completion;

/**
 *	@brief	解密文件，成功则返回文件路径，失败则compliment里返回的路径使nil
 *
 *	@param 	fileFullPath 	原文件全路径
 *	@param 	uid 	uid 见概要
 */
-(void)decodeFile:(NSString *)fileFullPath byUid:(NSData *)uid completion:(void (^)(NSString *))completion;




@end
