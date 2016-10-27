//
//  PycPrivateFileDefine.h
//  PBB
//
//  Created by Fairy on 14-3-20.
//  Copyright (c) 2014年 pyc.com.cn. All rights reserved.
//

#ifndef PBB_PycPrivateFileDefine_h
#define PBB_PycPrivateFileDefine_h
#import "FileOutPublic.h"


#define PRIVATE_FILE_TYPE_MOVIE FILE_TYPE_MOVIE
#define PRIVATE_FILE_TYPE_PIC   FILE_TYPE_PIC
#define PRIVATE_FILE_TYPE_PDF   TYPE_PDF
#define PRIVATE_FILE_TYPE_UNKOWN   FILE_TYPE_UNKOWN

#define PRIVATE_LEN_MOVIE   (10 * 1024 *1024)
#define PRIVATE_LEN_PIC     (4096)
#define PRIVATE_LEN_PDF     (4096)
#define PRIVATE_LEN_UNKOWN  (4096)



typedef NS_ENUM(NSInteger, PycPrivateFileOperateResult) {
    PycPrivateFileOperateParamErr   = -1,
    PycPrivateFileOperateCodeErr    = -2,
    PycPrivateFileOperateOK         = 0,
    PycPrivateFileOperateLimitedAuthority = -3,
     PycPrivateFileOperateNotPyc   = -4,
};


typedef struct _ENCODE_TAIL_{
    int64_t mark;                 //"PYC"
    int64_t fileLength;           //原文件大小
    int64_t encryptLength;        //加密长度（包含补齐的大小）
    int64_t unUsed1;              //暂时不用
    int64_t unUsed2;              //暂时不用
    int64_t uid;                  //加密用户的uid
    
}EncodeTail;

#endif
