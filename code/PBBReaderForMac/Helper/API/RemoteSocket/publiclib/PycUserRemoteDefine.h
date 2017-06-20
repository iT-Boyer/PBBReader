//
//  PycUserRemoteDefine.h
//  PBB
//
//  Created by Fairy on 14-3-19.
//  Copyright (c) 2014年 pyc.com.cn. All rights reserved.
//

#ifndef PBB_PycUserRemoteDefine_h
#define PBB_PycUserRemoteDefine_h

#define Test_Ip @"192.168.86.31"

typedef NS_ENUM(NSInteger, PycUserRemoteResult) {
    PycUserRemoteHaveBand   = -9,
    PycUserRemoteUnBindOrUserNameErr     =-1,
    PycUserRemoteNoUser     =-2,
    PycUserRemoteFailed     = 0,
    PycUserRemoteOk         = 1,
    PycUserRemoteErrSocket  = -100,
    PycUserRemoteErrParam   = -101
};


typedef NS_ENUM(NSInteger, NewPycUerRemoteOperateType){
    NewPycUerRemoteOperateTypeRegister  = 260,
    NewPycUerRemoteOperateTypeBind      = 263,
    NewPycUerRemoteOperateTypeRetrieve  = 265,
    NewPycUerRemoteOperateTypeGetPassword  = 266,
    NewPycUerRemoteOperateTypeGetUserInfo  = 267
};


typedef NS_ENUM(NSInteger, NewPycUerRemoteAppType){
    NewPycUerRemoteAppTypeAndriod   = 28,
    NewPycUerRemoteAppTypeWinPhone  = 29,
    NewPycUerRemoteAppTypeIos       = 30,
    NewPycUerRemoteAppTypePc        = 18
};


#endif
