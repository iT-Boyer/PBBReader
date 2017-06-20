//
//  NewPycUserRemote.m
//  PBB
//
//  Created by Fairy on 14-3-19.
//  Copyright (c) 2014年 pyc.com.cn. All rights reserved.
//

#import "NewPycUserRemote.h"
#import "PycSocket.h"
#import "UserPublic.h"
#import "PycCode.h"
#import "ToolString.h"



@implementation NewPycUserRemote

@synthesize pycSocket;
-(id)initWithDelegate:(id)theDelegate
{
    if(self = [super init])
    {
        self.delegate = theDelegate;
    }
    
    return self;
}

-(NSString *)description
{
    NSString *str1 = [[NSString alloc] initWithFormat:@"nickname-%@ openid-%@ versionstr-%@;logname-%@;",
                      ([_nickname length] == 0 )?@"(NULL)":_nickname,
                      ([_openId length] == 0) ?@"（NULL）":_openId,
                      ([_versionStr length] == 0)?@"(NULL)":_versionStr,
                      ([_logname length] == 0)?@"(NULL)":_logname
                     ];
    

    NSString *str2 = [[NSString alloc] initWithFormat:@"passwordss-%@;email-%@;phone-%@;uid-%@",
                      ([_password length] == 0 )?@"(NULL)":_password,
                      ([_email length] == 0)?@"(NULL)":_email,
                      ([_phone length] == 0 )?@"(NULL)":_phone,
                      ([_uid length] == 0)?@"(NULL)":_uid];
    
    
    
    return [str1 stringByAppendingString:str2];
}
#pragma mark 注册
-(void) registerForQQByNickname:(NSString *)qqnick openId:(NSString *)openId
{
    [self registerForQQByNickname:qqnick openId:openId version:[ToolString getVersionCode]];
}
-(void)registerForQQByNickname:(NSString *)qqnick openId:(NSString *)openId version:(NSString *)versionStr
{
    [self registerForQQByNickname:qqnick openId:openId version:versionStr appType:(NewPycUerRemoteAppTypeIos)];
}
-(void) registerForQQByNickname:(NSString *)qqnick openId:(NSString *)openId version:(NSString *)versionStr appType:(NewPycUerRemoteAppType)appType
{
    if (0 == [openId length] || 0 == [versionStr length] || 0 == [qqnick length]) {
        if (self.delegate) {
            [self.delegate newPycUserRemote:self finishOperateType:(NewPycUerRemoteOperateTypeRegister) didFinishWithResult:(PycUserRemoteErrParam)];
            return;
        }
    }
    
    self.nickname = qqnick;
    self.openId = openId;
    self.versionStr = versionStr;
    self.appType = appType;//must be 30
    //add by lry 2014-05-06
    self.Random = arc4random() % ARC4RANDOM_MAX;
    //add end
   
    pycSocket = [[PycSocket alloc] initWithDelegate:self];
    pycSocket.connectType = NewPycUerRemoteOperateTypeRegister;
    if (![pycSocket connectToServer:IP_ADDRESS_USER port:PORT_USER])
        [self.delegate newPycUserRemote:self finishOperateType:(NewPycUerRemoteOperateTypeRegister) didFinishWithResult:(PycUserRemoteErrSocket)];
   
}

-(void)makeSendPackageForRegister:(USER_SEND_DATA *)pSendData
{
    MyLog(@"new send register content");
    pSendData->user_data.random = self.Random;

    pSendData->type = NewPycUerRemoteOperateTypeRegister;
    memcpy(&(pSendData->user_data.nick), [self.nickname UTF8String], MIN([self.nickname lengthOfBytesUsingEncoding:NSUTF8StringEncoding],NICK_LEN));
    memcpy(&(pSendData->user_data.openid), [self.openId UTF8String], MIN([self.openId lengthOfBytesUsingEncoding:NSUTF8StringEncoding],OPENID_LEN));
    memcpy(&(pSendData->user_data.versionStr), [self.versionStr UTF8String], MIN([self.versionStr lengthOfBytesUsingEncoding:NSUTF8StringEncoding],VERSION_LEN));
    pSendData->user_data.random = self.Random;
    pSendData->user_data.apptype = self.appType;

}

-(void)getReceivePackageForRegister:(RECIEVE_DATA_NEW_MOV *)pReceiveData
{
    MyLog(@"getReceivePackageForRegister");
    /*
    self.logname = [[NSString alloc] initWithBytes:pReceiveData->user_data.logname length:NEW_USERNAME_LEN encoding:NSUTF8StringEncoding];
    self.password = [[NSString alloc] initWithBytes:pReceiveData->user_data.password length:NEW_PASS_LEN encoding:NSUTF8StringEncoding];
    self.email = [[NSString alloc] initWithBytes:pReceiveData->user_data.email length:NEW_EMAIL_LEN encoding:NSUTF8StringEncoding];
    self.phone = [[NSString alloc] initWithBytes:pReceiveData->user_data.phone length:NEW_PHONE_LEN encoding:NSUTF8StringEncoding];
    self.uid= [[NSString alloc] initWithBytes:pReceiveData->user_data.uid length:NEW_UID_LEN encoding:NSUTF8StringEncoding];
    */
    self.logname = [[NSString alloc] initWithCString:pReceiveData->uid_type.logname  encoding:NSUTF8StringEncoding];
    self.password = [[NSString alloc] initWithCString:pReceiveData->uid_type.password  encoding:NSUTF8StringEncoding];
    self.email = [[NSString alloc] initWithCString:pReceiveData->uid_type.email  encoding:NSUTF8StringEncoding];
    self.phone = [[NSString alloc] initWithCString:pReceiveData->uid_type.phone encoding:NSUTF8StringEncoding];
    self.uid= [[NSString alloc] initWithCString:pReceiveData->uid_type.uid  encoding:NSUTF8StringEncoding];
    
}
#pragma mark --
#pragma  mark 领回钥匙
-(void) getKeyForQQByOpenId:(NSString*)openId
{
    if (0 == [openId length]) {
        [self.delegate newPycUserRemote:self finishOperateType:(NewPycUerRemoteOperateTypeRetrieve) didFinishWithResult:(PycUserRemoteErrParam)];
        return;
    }
    
    self.openId = openId;
    //add by lry 2014-05-06
    self.Random = arc4random() % ARC4RANDOM_MAX;
    //add end
    
    pycSocket = [[PycSocket alloc] initWithDelegate:self];
    pycSocket.connectType = NewPycUerRemoteOperateTypeRetrieve;
    if (![pycSocket connectToServer:IP_ADDRESS_USER port:PORT_USER])
        [self.delegate newPycUserRemote:self finishOperateType:(NewPycUerRemoteOperateTypeRetrieve) didFinishWithResult:(PycUserRemoteErrSocket)];
    

}

-(void)makeSendPackageForRetrieve:(USER_SEND_DATA *)pSendData
{
    MyLog(@"new send register content");
    //add by lry 2014-05-06
    pSendData->user_data.random = self.Random;

    //add end
    
    pSendData->type = NewPycUerRemoteOperateTypeRetrieve;
    memcpy(&(pSendData->user_data.openid), [self.openId UTF8String], MIN([self.openId lengthOfBytesUsingEncoding:NSUTF8StringEncoding],EMAIL_LEN));
}

-(void)getReceivePackageForRetrieve:(RECIEVE_DATA_NEW_MOV *)pReceiveData
{
    MyLog(@"getReceivePackageForRetrieve");
    
    self.logname = [[NSString alloc] initWithCString:pReceiveData->uid_type.logname  encoding:NSUTF8StringEncoding];
    self.password = [[NSString alloc] initWithCString:pReceiveData->uid_type.password  encoding:NSUTF8StringEncoding];
    self.email = [[NSString alloc] initWithCString:pReceiveData->uid_type.email  encoding:NSUTF8StringEncoding];
    self.phone = [[NSString alloc] initWithCString:pReceiveData->uid_type.phone encoding:NSUTF8StringEncoding];
    self.uid= [[NSString alloc] initWithCString:pReceiveData->uid_type.uid  encoding:NSUTF8StringEncoding];
    /*
    self.logname = [[NSString alloc] initWithBytes:pReceiveData->user_data.logname length:NEW_USERNAME_LEN encoding:NSUTF8StringEncoding];
    self.password = [[NSString alloc] initWithBytes:pReceiveData->user_data.password length:NEW_PASS_LEN encoding:NSUTF8StringEncoding];
    self.email = [[NSString alloc] initWithBytes:pReceiveData->user_data.email length:NEW_EMAIL_LEN encoding:NSUTF8StringEncoding];
    self.phone = [[NSString alloc] initWithBytes:pReceiveData->user_data.phone length:NEW_PHONE_LEN encoding:NSUTF8StringEncoding];
    self.uid= [[NSString alloc] initWithBytes:pReceiveData->user_data.uid length:NEW_UID_LEN encoding:NSUTF8StringEncoding];
    */
}
#pragma mark --
#pragma mark 绑定用户和qq
-(void)bindKeyForQQByNickName:(NSString *)qqnick openId:(NSString *)openId logname:(NSString *)logname
{
    if (0 == [qqnick length] || 0 == [openId length] || 0 == [logname length]) {
        [self.delegate newPycUserRemote:self finishOperateType:(NewPycUerRemoteOperateTypeBind) didFinishWithResult:(PycUserRemoteErrParam)];
        return;
    }
    
    self.nickname = qqnick;
    self.openId = openId;
    self.logname = logname;
    //add by lry 2014-05-06
    self.Random = arc4random() % ARC4RANDOM_MAX;
    //add end
    
    pycSocket = [[PycSocket alloc] initWithDelegate:self];
    pycSocket.connectType = NewPycUerRemoteOperateTypeBind;
    if (![pycSocket connectToServer:IP_ADDRESS_USER port:PORT_USER])
        [self.delegate newPycUserRemote:self finishOperateType:(NewPycUerRemoteOperateTypeBind) didFinishWithResult:(PycUserRemoteErrSocket)];
    

}


-(void)makeSendPackageForBind:(USER_SEND_DATA *)pSendData
{
    MyLog(@"makeSendPackageForBind");
    pSendData->user_data.random = self.Random;

    pSendData->type = NewPycUerRemoteOperateTypeBind;
    memcpy(&(pSendData->user_data.openid), [self.openId UTF8String], MIN([self.openId lengthOfBytesUsingEncoding:NSUTF8StringEncoding],OPENID_LEN));
    memcpy(&(pSendData->user_data.nick), [self.nickname UTF8String], MIN([self.nickname lengthOfBytesUsingEncoding:NSUTF8StringEncoding],NICK_LEN));
    memcpy(&(pSendData->user_data.logname), [self.logname UTF8String], MIN([self.logname lengthOfBytesUsingEncoding:NSUTF8StringEncoding],USERNAME_LEN));
}

-(void)getReceivePackageForBind:(RECIEVE_DATA_NEW_MOV *)pReceiveData
{
    MyLog(@"getReceivePackageForBind");
    
   
    
}
#pragma mark --

#pragma mark 找回
-(void)getPassword:(NSString *)theLogname
{
    if (0 == [theLogname length]) {
        [self.delegate newPycUserRemote:self finishOperateType:(NewPycUerRemoteOperateTypeBind) didFinishWithResult:(PycUserRemoteErrParam)];
        return;
    }
    //add by lry 2014-05-06
    self.Random = arc4random() % ARC4RANDOM_MAX;
    //add end
   
    self.logname = theLogname;
    pycSocket = [[PycSocket alloc] initWithDelegate:self];
    pycSocket.connectType = NewPycUerRemoteOperateTypeGetPassword;
    if (![pycSocket connectToServer:IP_ADDRESS_USER port:PORT_USER])
        [self.delegate newPycUserRemote:self finishOperateType:(NewPycUerRemoteOperateTypeGetPassword) didFinishWithResult:(PycUserRemoteErrSocket)];
    
}

-(void)makeSendPackageForGetPassword:(USER_SEND_DATA *)pSendData
{
    MyLog(@"v");
    pSendData->user_data.random = self.Random;
   
    pSendData->type = NewPycUerRemoteOperateTypeGetPassword;
    memcpy(&(pSendData->user_data.logname), [self.logname UTF8String], MIN([self.logname lengthOfBytesUsingEncoding:NSUTF8StringEncoding],USERNAME_LEN));
}

-(void)getReceivePackageForGetPassword:(RECIEVE_DATA_NEW_MOV *)pReceiveData
{
    MyLog(@"getReceivePackageForGetPassword");
    self.password = [[NSString alloc] initWithUTF8String:pReceiveData->uid_type.password];
}

#pragma mark --
#pragma mark 得到用户信息
-(void) getUserInfo:(NSString*)theLogname
{
    if (0 == [theLogname length]) {
        [self.delegate newPycUserRemote:self finishOperateType:(NewPycUerRemoteOperateTypeGetUserInfo) didFinishWithResult:(PycUserRemoteErrParam)];
        return;
    }
    
    self.logname = theLogname;
    //add by lry 2014-05-06
    self.Random = arc4random() % ARC4RANDOM_MAX;
    //add end
   
    pycSocket = [[PycSocket alloc] initWithDelegate:self];
    pycSocket.connectType = NewPycUerRemoteOperateTypeGetUserInfo;
    if (![pycSocket connectToServer:IP_ADDRESS_USER port:PORT_USER])
        [self.delegate newPycUserRemote:self finishOperateType:(NewPycUerRemoteOperateTypeGetUserInfo) didFinishWithResult:(PycUserRemoteErrSocket)];
    
    
}

-(void)makeSendPackageForGetUserInfo:(USER_SEND_DATA *)pSendData
{
    MyLog(@"getReceivePackageForGetUserInfo");
    pSendData->user_data.random = self.Random;

    pSendData->type = NewPycUerRemoteOperateTypeGetUserInfo;
    memcpy(&(pSendData->user_data.logname), [self.logname UTF8String], MIN([self.logname lengthOfBytesUsingEncoding:NSUTF8StringEncoding],USERNAME_LEN));
}

-(void)getReceivePackageForGetUserInfo:(RECIEVE_DATA_NEW_MOV *)pReceiveData
{
    MyLog(@"getReceivePackageForGetUserInfo");
    /*
    self.logname = [[NSString alloc] initWithBytes:pReceiveData->user_data.logname length:NEW_USERNAME_LEN encoding:NSUTF8StringEncoding];
    self.password = [[NSString alloc] initWithBytes:pReceiveData->user_data.password length:NEW_PASS_LEN encoding:NSUTF8StringEncoding];
    self.email = [[NSString alloc] initWithBytes:pReceiveData->user_data.email length:NEW_EMAIL_LEN encoding:NSUTF8StringEncoding];
    self.phone = [[NSString alloc] initWithBytes:pReceiveData->user_data.phone length:NEW_PHONE_LEN encoding:NSUTF8StringEncoding];
    self.uid= [[NSString alloc] initWithBytes:pReceiveData->user_data.uid length:NEW_UID_LEN encoding:NSUTF8StringEncoding];
    self.nickname = [[NSString alloc] initWithBytes:pReceiveData->user_data.nick length:NEW_NICK_LEN encoding:NSUTF8StringEncoding];
    */
    
    self.logname = [[NSString alloc] initWithCString:pReceiveData->uid_type.logname  encoding:NSUTF8StringEncoding];
    self.password = [[NSString alloc] initWithCString:pReceiveData->uid_type.password  encoding:NSUTF8StringEncoding];
    self.email = [[NSString alloc] initWithCString:pReceiveData->uid_type.email  encoding:NSUTF8StringEncoding];
    self.phone = [[NSString alloc] initWithCString:pReceiveData->uid_type.phone encoding:NSUTF8StringEncoding];
    self.uid= [[NSString alloc] initWithCString:pReceiveData->uid_type.uid  encoding:NSUTF8StringEncoding];
    self.nickname = [[NSString alloc] initWithCString:pReceiveData->uid_type.nick  encoding:NSUTF8StringEncoding];
}

#pragma mark --
#pragma mark socket代理实现
-(void)PycSocket: (PycSocket *)fileObject didFinishConnect: (Byte *)receiveData
{
    //可以开始发数据了NSLog(@"connect ok ---");
//    USER_SEND_DATA sendData;
//    memset(&sendData, 0, sizeof(USER_SEND_DATA));
    
    USER_SEND_DATA senddata;
    memset(&senddata, 0, sizeof(USER_SEND_DATA));
    
    switch (fileObject.connectType) {
        case NewPycUerRemoteOperateTypeRegister:
            [self makeSendPackageForRegister:&senddata];
            break;
        case NewPycUerRemoteOperateTypeRetrieve:
            [self makeSendPackageForRetrieve:&senddata];
            break;
        case NewPycUerRemoteOperateTypeBind:
            [self makeSendPackageForBind:&senddata];
            break;
        case NewPycUerRemoteOperateTypeGetPassword:
            [self makeSendPackageForGetPassword:&senddata];
            break;
        case NewPycUerRemoteOperateTypeGetUserInfo:
            [self makeSendPackageForGetUserInfo:&senddata];
            break;
        default:
            NSLog(@"err occur");
            break;
    }
    
    //加密发送
    PycCode *coder = [[PycCode alloc] init];
    [coder codeBuffer:(Byte *)&(senddata.user_data) length:sizeof(USER_DATA)];
    
     if(0 == [pycSocket SocketWrite:(Byte *)&senddata length:sizeof(USER_SEND_DATA) receiveDataLength:sizeof(RECIEVE_DATA_NEW_MOV)])
     {
         [self.delegate newPycUserRemote:self finishOperateType:fileObject.connectType didFinishWithResult:PycUserRemoteErrSocket];
     }
    
}
-(void)PycSocket: (PycSocket *)fileObject didFinishSend: (Byte *)receiveData
{
    RECIEVE_DATA_NEW_MOV *receive = (RECIEVE_DATA_NEW_MOV *)receiveData;
    //[pycSocket SocketClose];
    
    if (receive == nil){
        NSLog(@"用户信息: nil");
        [self.delegate newPycUserRemote:self finishOperateType:fileObject.connectType didFinishWithResult:0];
        return;
    }else if(receive->suc < PycUserRemoteOk)
    {
        NSLog(@"receive suc not succuss");
        [self.delegate newPycUserRemote:self finishOperateType:fileObject.connectType didFinishWithResult:receive->suc];
        return;
    }
    
    PycCode *coder = [[PycCode alloc] init];
    [coder decodeBuffer:(Byte *)&(receive->uid_type) length:sizeof(USER_DATA)];
    //随机因子不同
    if (receive->uid_type.random != self.Random)
    {
        receive->suc = -1;
    }
    //add by lry 2014-05-06
    self.noticeNum = receive->uid_type.noticenum;
    self.MoneyFree = [[NSString alloc] initWithBytes:(receive->uid_type.money) length:MONEY_LEN encoding:NSUTF8StringEncoding];
    //add end

    
    switch (fileObject.connectType) {
        case NewPycUerRemoteOperateTypeRegister:
            [self getReceivePackageForRegister:receive];
            break;
        case NewPycUerRemoteOperateTypeRetrieve:
            [self getReceivePackageForRetrieve:receive];
            break;
        case NewPycUerRemoteOperateTypeBind:
            [self getReceivePackageForBind:receive];
            break;
        case NewPycUerRemoteOperateTypeGetPassword:
            [self getReceivePackageForGetPassword:receive];
            break;
        case NewPycUerRemoteOperateTypeGetUserInfo:
            [self getReceivePackageForGetUserInfo:receive];
            break;
        default:
            break;
    }
    
   
    [self.delegate newPycUserRemote:self finishOperateType:fileObject.connectType didFinishWithResult:receive->suc];
}



@end
