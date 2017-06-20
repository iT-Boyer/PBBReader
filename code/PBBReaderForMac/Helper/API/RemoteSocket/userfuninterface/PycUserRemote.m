//
//  PycUserRemote.m
//  PycSocket
//
//  Created by Fairy on 13-11-18.
//  Copyright (c) 2013年 Fairy. All rights reserved.
//

#import "PycUserRemote.h"
#import "PycSocket.h"
#import "UserPublic.h"
#import "PycCode.h"


@interface PycUserRemote ()
{
    int operateType;
}

@end
@implementation PycUserRemote


//-(BOOL)getNickNameFromLogname:(NSString *)theLogname
//{
//    BOOL bReturn = NO;
//    if (theLogname == nil) {
//        return bReturn;
//    }
//
//    self.pycsocket = [[PycSocket alloc] initWithDelegate:self];
//    self.pycsocket.connectType = TYPE_GET_NICK_NAME;
//   
//    self.logname = theLogname;
//    bReturn = [self.pycsocket connectToServer:IP_ADDRESS_USER port:PORT_USER];
//    if (bReturn == NO) {
//        return bReturn;
//    }
//    else{
//    return bReturn;
//    }
//    
//}
-(void) sendGetNickInfo:(USER_SEND_DATA *)sendData
{
    NSLog(@"sendChangeNickInfo");
    sendData->type = TYPE_GET_NICK_NAME;
    memcpy(&(sendData->user_data.logname), [self.logname UTF8String], MIN([self.logname lengthOfBytesUsingEncoding:NSUTF8StringEncoding],USERNAME_LEN));
}

-(void) receiveGetNickInfo:(RECIEVE_DATA_NEW_MOV *)receiveData receiveReturn: (MAKERECEIVE *)receiveReturn
{
    if (receiveData == nil) {
        receiveReturn->iReturn = 0;
        if (operateType == TYPE_GET_UID_WITH_NICKNAME) {
            [self.delegate PycUserRemote:self didFinishGetUidWithNickName:receiveReturn];
        }else
        {
        [self.delegate PycUserRemote:self didFinishGetNickName:receiveReturn];
        }
        return;
    }
    
    receiveReturn->iReturn = receiveData->suc;
    self.nickName = [[NSString alloc] initWithBytes:(receiveData->uid_type.email) length:EMAIL_LEN encoding:NSUTF8StringEncoding];
    if (operateType == TYPE_GET_UID_WITH_NICKNAME) {
        [self.delegate PycUserRemote:self didFinishGetUidWithNickName:receiveReturn];
    }else
    {
    [self.delegate PycUserRemote:self didFinishGetNickName:receiveReturn];
    }
    
}


-(BOOL) changeNick:(NSString *) theLogName newNick:(NSString *)theNickName
{
    
    BOOL bReturn;
    if (theLogName == nil || theNickName == nil) {
        NSLog(@"changenick param nil");
        bReturn = NO;
        goto ALL_END;
    }
    
    self.pycsocket = [[PycSocket alloc] init];
    self.pycsocket.delegate = self;
    bReturn = [self.pycsocket connectToServer:IP_ADDRESS_USER port:PORT_USER];
    if (bReturn == NO) {
        goto ALL_END;
    }
    
    
    self.pycsocket.connectType = TYPE_CHANGE_NICK_NAME;
    
    self.nickName = theNickName;
    self.logname = theLogName;
    //add by lry 2014-05-06
    self.Random = arc4random() % ARC4RANDOM_MAX;
    //add end

    
    bReturn = YES;
ALL_END:
    return bReturn;
}

-(void) sendChangeNickInfo:(USER_SEND_DATA *)sendData
{
    NSLog(@"sendChangeNickInfo");
    sendData->type = TYPE_CHANGE_NICK_NAME;
    memcpy(&(sendData->user_data.logname), [self.logname UTF8String],  MIN([self.logname lengthOfBytesUsingEncoding:NSUTF8StringEncoding],USERNAME_LEN));
    memcpy(&(sendData->user_data.nick), [self.nickName UTF8String],  MIN([self.nickName lengthOfBytesUsingEncoding:NSUTF8StringEncoding],EMAIL_LEN));
    //add by lry 2014-05-06
    sendData->user_data.random = self.Random;
    //add end
}

-(void) receiveChangeNickInfo:(RECIEVE_DATA_NEW_MOV *)receiveData receiveReturn: (MAKERECEIVE *)receiveReturn
{
    if (receiveData == nil) {
        receiveReturn->iReturn = 0;
        [self.delegate PycUserRemote:self didFinishChangeNick:receiveReturn];
        return;
    }
    //add by lry 2014-05-06
    self.noticeNum = receiveData->uid_type.noticenum;
    self.MoneyFree = [[NSString alloc] initWithBytes:(receiveData->uid_type.money) length:MONEY_LEN encoding:NSUTF8StringEncoding];
    //add end
    
    receiveReturn->iReturn = receiveData->suc;
    [self.delegate PycUserRemote:self didFinishChangeNick:receiveReturn];
    
}


-(BOOL) registerRemote:(NSString *) thePassword nickName: (NSString *) theNickName version: (NSString *) theVersion

{
    BOOL bReturn;
//  || theNickName.length == 0
    if (thePassword.length == 0 && theNickName.length == 0)
    {
        NSLog(@"param err when regist");
        bReturn = NO;
        goto ALL_END;
    }
    
    self.pycsocket = [[PycSocket alloc] init];
    self.pycsocket.delegate = self;
    
    bReturn =  [self.pycsocket connectToServer:IP_ADDRESS_USER   port:PORT_USER];
    if (bReturn == NO) {
        NSLog(@"connect err");
        goto ALL_END;
    }
    
    self.pycsocket.connectType = TYPE_REGISTER_USER;
  
    self.nickName = theNickName;
    self.password = thePassword;
    self.versionStr = theVersion;
    //add by lry 2014-05-06
    self.Random = arc4random() % ARC4RANDOM_MAX;
    //add end
    
    
    
    bReturn = YES;
    
ALL_END:
    
    return bReturn;
}
-(void)sendRegisterInfo: (USER_SEND_DATA *)sendData
{
    NSLog(@"begin send register info");
    sendData->type = TYPE_REGISTER_USER;
    memcpy(&(sendData->user_data.password), [self.password UTF8String], MIN([self.password lengthOfBytesUsingEncoding:NSUTF8StringEncoding],PASS_LEN));
    memcpy(&(sendData->user_data.nick), [self.nickName UTF8String], MIN([self.nickName lengthOfBytesUsingEncoding:NSUTF8StringEncoding],NICK_LEN));
    memcpy(&(sendData->user_data.versionStr), [self.versionStr UTF8String], MIN([self.versionStr lengthOfBytesUsingEncoding:NSUTF8StringEncoding],VERSION_LEN));
    sendData->user_data.apptype = 30;
    sendData->user_data.random = self.Random;
 }
-(void) receiveRegisterInfo:(RECIEVE_DATA_NEW_MOV *)receiveData receiveReturn: (MAKERECEIVE *)receiveReturn
{
  
    
    if (receiveData == nil) {
        receiveReturn->iReturn = 0;
        [self.delegate PycUserRemote:self didFinishRegiste:receiveReturn];
        return;
    }
    
      NSLog(@"have receive register info");
    
    receiveReturn->iReturn = receiveData->suc;
    
    if (receiveData->suc & ERR_OK_NEW) {
        self.uid = [[NSString alloc] initWithBytes:(receiveData->uid_type.uid) length:UID_LEN encoding:NSUTF8StringEncoding];
        self.logname = [[NSString alloc] initWithBytes:(receiveData->uid_type.logname) length:USERNAME_LEN encoding:NSUTF8StringEncoding];
        //add by lry 2014-05-06
        self.noticeNum = receiveData->uid_type.noticenum;
        self.MoneyFree = [[NSString alloc] initWithBytes:(receiveData->uid_type.money) length:MONEY_LEN encoding:NSUTF8StringEncoding];
        //add end
    }
    
    [self.delegate PycUserRemote:self didFinishRegiste:receiveReturn];
    
    return;
    
}


-(BOOL) getStatus:(NSString *) logname
{
    BOOL bReturn;
    
    if (logname.length == 0 )
    {
        NSLog(@"param err when regist");
        bReturn = NO;
        goto ALL_END;
    }
    
    
    self.pycsocket = [[PycSocket alloc] init];
    self.pycsocket.delegate = self;
    
    self.pycsocket.connectType = TYPE_GET_CHECK_STATE;
    self.logname = logname;
    
    //add by lry 2014-05-06
    self.Random = arc4random() % ARC4RANDOM_MAX;
    //add end

    
    bReturn =  [self.pycsocket connectToServer:IP_ADDRESS_USER   port:PORT_USER];
    if (bReturn == NO) {
        NSLog(@"connect err");
        goto ALL_END;
    }
    
        
    
    
    bReturn = YES;
    
ALL_END:
    
    NSLog(@"end");
    return bReturn;
    
}

-(void)sendGetStatus: (USER_SEND_DATA *)sendData
{
    NSLog(@"begin send register info");
    sendData->type = TYPE_GET_CHECK_STATE;
    //add by lry 2014-05-07
    sendData->user_data.apptype = 30;
    sendData->user_data.random = self.Random;
    //add end
    memcpy(&(sendData->user_data.logname), [self.logname UTF8String], MIN([self.logname lengthOfBytesUsingEncoding:NSUTF8StringEncoding],USERNAME_LEN));
    
}
-(void) receiveGetStatus:(RECIEVE_DATA_NEW_MOV *)receiveData receiveReturn: (MAKERECEIVE *)receiveReturn
{

    if (receiveData == nil) {
        receiveReturn->iReturn = 0;
        [self.delegate PycUserRemote:self didFinishGetStatus:receiveReturn];
        return;
    }

    receiveReturn->iReturn = receiveData->suc;
    //add by lry 2014-05-06
    self.noticeNum = receiveData->uid_type.noticenum;
    self.MoneyFree = [[NSString alloc] initWithBytes:(receiveData->uid_type.money) length:MONEY_LEN encoding:NSUTF8StringEncoding];
    //add end

    self.email = [[NSString alloc] initWithBytes:(receiveData->uid_type.email) length:EMAIL_LEN encoding:NSUTF8StringEncoding];
    self.phone = [[NSString alloc] initWithBytes:(receiveData->uid_type.phone) length:PHONE_LEN encoding:NSUTF8StringEncoding];
    
    [self.delegate PycUserRemote:self didFinishGetStatus:receiveReturn];
    
}



-(BOOL) findPassWD:(NSString *)logname email:(NSString *)email
{
    
    BOOL bReturn;
    
    if (logname.length == 0 )
    {
        NSLog(@"param err when regist");
        bReturn = NO;
        goto ALL_END;
    }
    
    //add by lry 2014-05-06
    self.Random = arc4random() % ARC4RANDOM_MAX;
    //add end
    
    self.pycsocket = [[PycSocket alloc] init];
    self.pycsocket.delegate = self;
    
    self.pycsocket.connectType = TYPE_GET_PASSWD;
    self.logname = logname;
    self.email = email;
    
    
    bReturn =  [self.pycsocket connectToServer:IP_ADDRESS_USER   port:PORT_USER];
    if (bReturn == NO) {
        NSLog(@"connect err");
        goto ALL_END;
    }
    
    
    
    
    bReturn = YES;
    
ALL_END:
    
    NSLog(@"end");
    return bReturn;
}


-(BOOL) emailVerify:(NSString *)logname email: (NSString *) email
{
  
    BOOL bReturn;
    
    if (logname.length == 0 || email.length == 0)
    {
        NSLog(@"param err when regist");
        bReturn = NO;
        goto ALL_END;
    }
    
    
    self.pycsocket = [[PycSocket alloc] init];
    self.pycsocket.delegate = self;
    
    self.pycsocket.connectType = TYPE_CHECK_EMAIL;
    self.logname = logname;
    self.email = email;
    //add by lry 2014-05-06
    self.Random = arc4random() % ARC4RANDOM_MAX;
    //add end

    
    bReturn =  [self.pycsocket connectToServer:IP_ADDRESS_USER   port:PORT_USER];
    if (bReturn == NO) {
        NSLog(@"connect err");
        goto ALL_END;
    }
    
    
    
    
    bReturn = YES;
    
ALL_END:
    
    NSLog(@"end");
    return bReturn;
}
-(void)sendGetPassWD: (USER_SEND_DATA *)sendData
{
    NSLog(@"begin sendgetpass");
    sendData->type = TYPE_GET_PASSWD;
    //add by lry 2014-05-07
    sendData->user_data.apptype = 30;
    sendData->user_data.random = self.Random;
    //add end
    memcpy(&(sendData->user_data.logname), [self.logname UTF8String],  MIN([self.logname lengthOfBytesUsingEncoding:NSUTF8StringEncoding],USERNAME_LEN));
    memcpy(&(sendData->user_data.email), [self.email UTF8String],  MIN([self.email lengthOfBytesUsingEncoding:NSUTF8StringEncoding],EMAIL_LEN));
    
}
-(void)sendemailVerify: (USER_SEND_DATA *)sendData
{
    NSLog(@"begin sendemailVerify");
    sendData->type = TYPE_CHECK_EMAIL;
    //add by lry 2014-05-07
    sendData->user_data.apptype = 30;
    sendData->user_data.random = self.Random;
    //add end
    memcpy(&(sendData->user_data.logname), [self.logname UTF8String],  MIN([self.logname lengthOfBytesUsingEncoding:NSUTF8StringEncoding],USERNAME_LEN));
    memcpy(&(sendData->user_data.email), [self.email UTF8String],  MIN([self.email lengthOfBytesUsingEncoding:NSUTF8StringEncoding],EMAIL_LEN));
    
}
-(void) receiveemailVerify:(RECIEVE_DATA_NEW_MOV *)receiveData receiveReturn: (MAKERECEIVE *)receiveReturn
{
    
    if (receiveData == nil) {
        receiveReturn->iReturn = 0;         //may occur err
        [self.delegate PycUserRemote:self didFinishEmailVerify:receiveReturn];
        return;
    }
    //add by lry 2014-05-06
    self.noticeNum = receiveData->uid_type.noticenum;
    self.MoneyFree = [[NSString alloc] initWithBytes:(receiveData->uid_type.money) length:MONEY_LEN encoding:NSUTF8StringEncoding];
    //add end
   
    receiveReturn->iReturn = receiveData->suc;
    
    [self.delegate PycUserRemote:self didFinishEmailVerify:receiveReturn];
    
}

-(void) receiveGetPassWD:(RECIEVE_DATA_NEW_MOV *)receiveData receiveReturn: (MAKERECEIVE *)receiveReturn
{
    
    if (receiveData == nil) {
        receiveReturn->iReturn = 0;         //may occur err
        [self.delegate PycUserRemote:self didFinishGetPassWD:receiveReturn];
        return;
    }
    
    receiveReturn->iReturn = receiveData->suc;
    //add by lry 2014-05-06
    self.noticeNum = receiveData->uid_type.noticenum;
    self.MoneyFree = [[NSString alloc] initWithBytes:(receiveData->uid_type.money) length:MONEY_LEN encoding:NSUTF8StringEncoding];
    //add end
   
    [self.delegate PycUserRemote:self didFinishGetPassWD:receiveReturn];
    
}


-(BOOL) phoneVerify_getVerifyNo:(NSString *)logname phoneNum:(NSString *)phone
{
    
    BOOL bReturn;
    
    if (logname.length == 0 || phone.length == 0)
    {
        NSLog(@"param err when regist");
        bReturn = NO;
        goto ALL_END;
    }
    
    
    self.pycsocket = [[PycSocket alloc] init];
    self.pycsocket.delegate = self;
    
    self.pycsocket.connectType = TYPE_PHONE_NUM_CHECK;
    self.logname = logname;
    self.phone = phone;

    
    bReturn =  [self.pycsocket connectToServer:IP_ADDRESS_USER   port:PORT_USER];
    if (bReturn == NO) {
        NSLog(@"connect err");
        goto ALL_END;
    }
    
    
    
    
    bReturn = YES;
    
ALL_END:
    
    NSLog(@"end");
    return bReturn;
}
-(void)sendPhoneVerify: (USER_SEND_DATA *)sendData
{
    NSLog(@"begin sendPhoneVerify");
    //add by lry 2014-05-07
    sendData->user_data.apptype = 30;
    sendData->user_data.random = self.Random;
    //add end
   sendData->type = TYPE_PHONE_NUM_CHECK;
    memcpy(&(sendData->user_data.logname), [self.logname UTF8String], MIN([self.logname lengthOfBytesUsingEncoding:NSUTF8StringEncoding],USERNAME_LEN));
    memcpy(&(sendData->user_data.phone), [self.phone UTF8String], MIN([self.phone lengthOfBytesUsingEncoding:NSUTF8StringEncoding],PHONE_LEN));
    
}
-(void) receivePhontVerify:(RECIEVE_DATA_NEW_MOV *)receiveData receiveReturn: (MAKERECEIVE *)receiveReturn
{
    NSLog(@"receivePhontVerify");
    
    if (receiveData == nil) {
        receiveReturn->iReturn = 0;         //may occur err
        [self.delegate PycUserRemote:self didFinishPhoneVerify:receiveReturn];
        return;
    }
    //add by lry 2014-05-06
    self.noticeNum = receiveData->uid_type.noticenum;
    self.MoneyFree = [[NSString alloc] initWithBytes:(receiveData->uid_type.money) length:MONEY_LEN encoding:NSUTF8StringEncoding];
    //add end
   
    receiveReturn->iReturn = receiveData->suc;
    
    [self.delegate PycUserRemote:self didFinishPhoneVerify:receiveReturn];
    
}


-(BOOL) phoneVerifyNo_check:(NSString *)logname verifyNum:(NSString *)verifyNum
{
    BOOL bReturn;
    
    if (logname.length == 0 || verifyNum.length == 0)
    {
        NSLog(@"param err when regist");
        bReturn = NO;
        goto ALL_END;
    }
    
    
    self.pycsocket = [[PycSocket alloc] init];
    self.pycsocket.delegate = self;
    
    self.pycsocket.connectType = TYPE_VERIFICATION_CHECK;
    self.logname = logname;
    self.verifyNum = verifyNum;

    
    bReturn =  [self.pycsocket connectToServer:IP_ADDRESS_USER   port:PORT_USER];
    if (bReturn == NO) {
        NSLog(@"connect err");
        goto ALL_END;
    }
    
    
    
    
    bReturn = YES;
    
ALL_END:
    
    NSLog(@"end");
    return bReturn;
}


-(void)sendVerificationVerify: (USER_SEND_DATA *)sendData
{
    NSLog(@"begin sendVerificationVerify");
    sendData->type = TYPE_VERIFICATION_CHECK;
    //add by lry 2014-05-07
    sendData->user_data.apptype = 30;
    sendData->user_data.random = self.Random;
    //add end
    memcpy(&(sendData->user_data.logname), [self.logname UTF8String],  MIN([self.logname lengthOfBytesUsingEncoding:NSUTF8StringEncoding],USERNAME_LEN));
    memcpy(&(sendData->user_data.email), [self.verifyNum UTF8String],  MIN([self.verifyNum lengthOfBytesUsingEncoding:NSUTF8StringEncoding],EMAIL_LEN));
    
}
-(void) receiveVerificationVerify:(RECIEVE_DATA_NEW_MOV *)receiveData receiveReturn: (MAKERECEIVE *)receiveReturn
{
    
    if (receiveData == nil) {
        receiveReturn->iReturn = 0;         //may occur err
        [self.delegate PycUserRemote:self didFinishVerificationVerify:receiveReturn];
        return;
    }
    //add by lry 2014-05-06
    self.noticeNum = receiveData->uid_type.noticenum;
    self.MoneyFree = [[NSString alloc] initWithBytes:(receiveData->uid_type.money) length:MONEY_LEN encoding:NSUTF8StringEncoding];
    //add end
    
    receiveReturn->iReturn = receiveData->suc;
    
    [self.delegate PycUserRemote:self didFinishVerificationVerify:receiveReturn];
    
}

-(BOOL) changPass:(NSString *) logname password:(NSString *)password
{
    BOOL bReturn;
    
    if (logname.length == 0 || password.length == 0)
    {
        NSLog(@"param err when regist");
        bReturn = NO;
        goto ALL_END;
    }
    
    
    self.pycsocket = [[PycSocket alloc] init];
    self.pycsocket.delegate = self;
    
    self.pycsocket.connectType = TYPE_CHANGE_PASSWORD;
    self.logname = logname;
    self.password = password;
    //add by lry 2014-05-06
    self.Random = arc4random() % ARC4RANDOM_MAX;
    //add end

    
    bReturn =  [self.pycsocket connectToServer:IP_ADDRESS_USER   port:PORT_USER];
    if (bReturn == NO) {
        NSLog(@"connect err");
        goto ALL_END;
    }
    
    
    
    
    bReturn = YES;
    
ALL_END:
    
    NSLog(@"end");
    return bReturn;
}

-(void)sendChangPass: (USER_SEND_DATA *)sendData
{
    NSLog(@"begin sendChangPass");
    sendData->type = TYPE_CHANGE_PASSWORD;
    //add by lry 2014-05-07
    sendData->user_data.apptype = 30;
    sendData->user_data.random = self.Random;
    //add end
   memcpy(&(sendData->user_data.logname), [self.logname UTF8String], MIN([self.logname lengthOfBytesUsingEncoding:NSUTF8StringEncoding],USERNAME_LEN));
    memcpy(&(sendData->user_data.password), [self.password UTF8String], MIN([self.password lengthOfBytesUsingEncoding:NSUTF8StringEncoding],PASS_LEN));
    
}
-(void) receiveChangPass:(RECIEVE_DATA_NEW_MOV *)receiveData receiveReturn: (MAKERECEIVE *)receiveReturn
{
    
    if (receiveData == nil) {
        receiveReturn->iReturn = 0;         //may occur err
        [self.delegate PycUserRemote:self didFinishChangPass:receiveReturn];
        return;
    }
    
    receiveReturn->iReturn = receiveData->suc;
    //add by lry 2014-05-06
    self.noticeNum = receiveData->uid_type.noticenum;
    self.MoneyFree = [[NSString alloc] initWithBytes:(receiveData->uid_type.money) length:MONEY_LEN encoding:NSUTF8StringEncoding];
    //add end
    
    [self.delegate PycUserRemote:self didFinishChangPass:receiveReturn];
    
}

-(BOOL) getUid:(NSString *)logname password:(NSString *)password
{
    BOOL bReturn;
    
    if (logname.length == 0 || password.length == 0)
    {
        NSLog(@"param err when regist");
        bReturn = NO;
        goto ALL_END;
    }
    
    
    self.pycsocket = [[PycSocket alloc] init];
    self.pycsocket.delegate = self;
    
    self.pycsocket.connectType = TYPE_GET_UID;
    self.logname = logname;
    self.password= password;
    //add by lry 2014-05-06
    self.Random = arc4random() % ARC4RANDOM_MAX;
    //add end

    
    bReturn =  [self.pycsocket connectToServer:IP_ADDRESS_USER   port:PORT_USER];
    if (bReturn == NO) {
        NSLog(@"connect err");
        goto ALL_END;
    }
    
    
    
    
    bReturn = YES;
    
ALL_END:
    
    NSLog(@"end");
    return bReturn;
}
-(BOOL) getUidWithNickName:(NSString *)logname password:(NSString *)password
{
    operateType = TYPE_GET_UID_WITH_NICKNAME;
    return [self getUid:logname password:password];
    
}
-(void)sendGetUid: (USER_SEND_DATA *)sendData
{
    NSLog(@"begin sendGetUid");
    sendData->type = TYPE_GET_UID;
    //add by lry 2014-05-07
    sendData->user_data.apptype = 30;
    sendData->user_data.random = self.Random;
    //add end
    memcpy(&(sendData->user_data.logname), [self.logname UTF8String], MIN([self.logname lengthOfBytesUsingEncoding:NSUTF8StringEncoding],USERNAME_LEN));
    memcpy(&(sendData->user_data.password), [self.password UTF8String], MIN([self.password lengthOfBytesUsingEncoding:NSUTF8StringEncoding],PASS_LEN));
    
}
-(void) receiveGetUid:(RECIEVE_DATA_NEW_MOV *)receiveData receiveReturn: (MAKERECEIVE *)receiveReturn
{
    
    if (receiveData == nil) {
        receiveReturn->iReturn = 0;         //may occur err
        
        if (operateType == TYPE_GET_UID_WITH_NICKNAME) {
                [self.delegate PycUserRemote:self didFinishGetUidWithNickName:receiveReturn];
        }else
        {
            [self.delegate PycUserRemote:self didFinishGetUid:receiveReturn];
        }
       
        return;
    }
    
    receiveReturn->iReturn = receiveData->suc;
    self.lognameOut = [[NSString alloc] initWithBytes:(receiveData->uid_type.logname) length:USERNAME_LEN encoding:NSUTF8StringEncoding];
    self.email = [[NSString alloc] initWithBytes:(receiveData->uid_type.email) length:EMAIL_LEN encoding:NSUTF8StringEncoding];
    self.phone = [[NSString alloc] initWithBytes:(receiveData->uid_type.phone) length:PHONE_LEN encoding:NSUTF8StringEncoding];
    self.uid = [[NSString alloc] initWithBytes:(receiveData->uid_type.uid) length:UID_LEN encoding:NSUTF8StringEncoding];
    //add by lry 2014-05-06
    self.noticeNum = receiveData->uid_type.noticenum;
    self.MoneyFree = [[NSString alloc] initWithBytes:(receiveData->uid_type.money) length:MONEY_LEN encoding:NSUTF8StringEncoding];
    //add end
    self.nickName =  [[NSString alloc] initWithBytes:(receiveData->uid_type.nick) length:NICK_LEN encoding:NSUTF8StringEncoding];

    //是否为企业子账号
    self.childStatus = receiveData->uid_type.status;
    
    if (operateType == TYPE_GET_UID_WITH_NICKNAME) {
        
        self.logname = self.lognameOut;

        self.pycsocket2 = [[PycSocket alloc] initWithDelegate:self];
        if(![self.pycsocket2 connectToServer:IP_ADDRESS_USER port:PORT_USER])
            [self.delegate PycUserRemote:self didFinishGetUidWithNickName:receiveReturn];

        else
        {
            self.pycsocket2.connectType = TYPE_GET_NICK_NAME;
        }
    }else
    {
        [self.delegate PycUserRemote:self didFinishGetUid:receiveReturn];
    }
    
    
}

-(void)PycSocket: (PycSocket *)sock didFinishConnect: (Byte *)receiveData
{
    NSLog(@"connect ok ---");
    USER_SEND_DATA sendData;
    memset(&sendData, 0, sizeof(USER_SEND_DATA));
 
    
    ///////////////////begin///////////////////
    if (sock.connectType == TYPE_REGISTER_USER)
    {
        [self sendRegisterInfo:&sendData];
    }
//    else if (sock.connectType == TYPE_GET_NICK_NAME)
//    {
//        [self sendGetNickInfo:&sendData];
//    }
    else if (sock.connectType == TYPE_CHANGE_NICK_NAME)
    {
        [self sendChangeNickInfo:&sendData];
    }
    else if (sock.connectType == TYPE_GET_CHECK_STATE)
    {
        [self sendGetStatus:&sendData];
    }
    else if (sock.connectType == TYPE_CHECK_EMAIL)
    {
        [self sendemailVerify:&sendData];
    }
    else if (sock.connectType == TYPE_PHONE_NUM_CHECK)
    {
        [self sendPhoneVerify:&sendData];
    }
    else if(sock.connectType == TYPE_VERIFICATION_CHECK)
    {
        [self sendVerificationVerify:&sendData];
    }
    else if (sock.connectType == TYPE_CHANGE_PASSWORD)
    {
        [self sendChangPass:&sendData];
    }
    else if (sock.connectType == TYPE_GET_UID)
    {
        [self sendGetUid:&sendData];
    }
    else if (sock.connectType == TYPE_GET_PASSWD)
    {
        [self sendGetPassWD:&sendData];
    }
    else
    {
        NSLog(@"donot care connectType");
    }
    
    
    
    ///////////////////end///////////////////// 
    
    PycCode *coder = [[PycCode alloc] init];
    [coder codeBuffer:(Byte *)&(sendData.user_data) length:sizeof(USER_DATA)];
    
    if (operateType == TYPE_GET_UID_WITH_NICKNAME  && sock.connectType == TYPE_GET_NICK_NAME) {
        if (0 == [self.pycsocket2 SocketWrite:(Byte *)&sendData length:sizeof(USER_SEND_DATA) receiveDataLength:sizeof(RECIEVE_DATA_NEW_MOV)]) {
            MAKERECEIVE receiveMake;
            memset(&receiveMake, 0, sizeof(MAKERECEIVE));
            receiveMake.iReturn = ERR_SOCKET;
            [self.delegate PycUserRemote:self didFinishGetUidWithNickName:&receiveMake];
        }
        
    }
    else if(0 == [self.pycsocket SocketWrite:(Byte *)&sendData length:sizeof(USER_SEND_DATA) receiveDataLength:sizeof(RECIEVE_DATA_NEW_MOV)])
    {  
        NSLog(@"err send");
        
        MAKERECEIVE receiveMake;
        memset(&receiveMake, 0, sizeof(MAKERECEIVE));
        receiveMake.iReturn = ERR_SOCKET;
        if (sock.connectType == TYPE_REGISTER_USER) {
            [self.delegate PycUserRemote:self didFinishRegiste:&receiveMake];
        }
         else if (sock.connectType == TYPE_GET_NICK_NAME)
         {
              [self.delegate PycUserRemote:self didFinishGetNickName:&receiveMake];
         }
        else if (sock.connectType == TYPE_CHANGE_NICK_NAME) {
            [self.delegate PycUserRemote:self didFinishChangeNick:&receiveMake];
        }
        else if (sock.connectType == TYPE_GET_CHECK_STATE)
        {
           [self.delegate PycUserRemote:self didFinishGetStatus:&receiveMake];
        }
        else if (sock.connectType == TYPE_CHECK_EMAIL)
        {
            [self.delegate PycUserRemote:self didFinishEmailVerify:&receiveMake];
        }
        else if (sock.connectType == TYPE_PHONE_NUM_CHECK)
        {
            [self.delegate PycUserRemote:self didFinishPhoneVerify:&receiveMake];
        }
        else if(sock.connectType == TYPE_VERIFICATION_CHECK)
        {
            [self.delegate PycUserRemote:self didFinishVerificationVerify:&receiveMake];
        }
        else if (sock.connectType == TYPE_CHANGE_PASSWORD)
        {
            [self.delegate PycUserRemote:self didFinishChangPass:&receiveMake];
        }
        else if (sock.connectType == TYPE_GET_UID)
        {
            if (operateType == TYPE_GET_UID_WITH_NICKNAME) {
                [self.delegate PycUserRemote:self didFinishGetUidWithNickName:&receiveMake];
            }else{
                [self.delegate PycUserRemote:self didFinishGetUid:&receiveMake];
            }
        }
        else if (sock.connectType == TYPE_GET_PASSWD)
        {
            [self.delegate PycUserRemote:self didFinishGetPassWD:&receiveMake];
        }
          
  
    }
    else
    {
        NSLog(@"ok send");
    }
    

    
}



-(void)PycSocket: (PycSocket *)sock didFinishSend: (Byte *)receiveData
{
    NSLog(@"receive data");
    MAKERECEIVE receiveReturn;
    memset(&receiveReturn, 0, sizeof(MAKERECEIVE));
        
    
    RECIEVE_DATA_NEW_MOV *receive = (RECIEVE_DATA_NEW_MOV *)receiveData;

    [self.pycsocket SocketClose];
    if (receive!= nil /*&& receive->suc == ERR_OK*/){
        NSLog(@"decode --");
        PycCode *coder = [[PycCode alloc] init];
        [coder decodeBuffer:(Byte *)&(receive->uid_type) length:sizeof(USER_DATA)];
        //随机因子不同
        if (receive->uid_type.random != self.Random)
        {
            receive->suc = -1;
        }
    }
    if (sock.connectType == TYPE_REGISTER_USER) {
        [self receiveRegisterInfo:receive receiveReturn:&receiveReturn];
        return;
    }
//    else if (sock.connectType == TYPE_GET_NICK_NAME)
//    {
//        [self receiveGetNickInfo:receive receiveReturn:&receiveReturn];
//    }
    else if(sock.connectType == TYPE_CHANGE_NICK_NAME)
    {
         [self receiveChangeNickInfo:receive receiveReturn:&receiveReturn];
        return;
    }
    else if (sock.connectType == TYPE_GET_CHECK_STATE)
    {
         [self receiveGetStatus:receive receiveReturn:&receiveReturn];
        return;
    }
    else if (sock.connectType == TYPE_CHECK_EMAIL)
    {
        [self receiveemailVerify:receive receiveReturn:&receiveReturn];
    }
    else if (sock.connectType == TYPE_PHONE_NUM_CHECK)
    {
        [self receivePhontVerify:receive receiveReturn:&receiveReturn];
    }
    else if (sock.connectType == TYPE_VERIFICATION_CHECK)
    {
        [self receiveVerificationVerify:receive receiveReturn:&receiveReturn];
    }
    else if (sock.connectType == TYPE_CHANGE_PASSWORD)
    {
        [self receiveChangPass:receive receiveReturn:&receiveReturn];
    }
    else if (sock.connectType == TYPE_GET_UID)
    {
        [self receiveGetUid:receive receiveReturn:&receiveReturn];
    }
    else if (sock.connectType == TYPE_GET_PASSWD)
    {
        [self receiveGetPassWD:receive receiveReturn:&receiveReturn];
    }
}



@end
