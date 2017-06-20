//
//  UserPublic.h
//  PycSocket
//
//  Created by Fairy on 13-11-18.
//  Copyright (c) 2013年 Fairy. All rights reserved.
//

#ifndef PycSocket_UserPublic_h
#define PycSocket_UserPublic_h


#define TYPE_REGISTER_USER          220
#define TYPE_GET_UID                221
#define TYPE_GET_PASSWD             222
#define TYPE_CHANGE_PASSWORD        223
#define TYPE_CHECK_EMAIL            225
#define TYPE_GET_CHECK_STATE        226
#define TYPE_PHONE_NUM_CHECK        227
#define TYPE_VERIFICATION_CHECK     228
#define TYPE_GET_NICK_NAME          233
#define TYPE_CHANGE_NICK_NAME       234



#define TYPE_GET_UID_WITH_NICKNAME  50
//宏定义：
#define MAC_LEN 17
#define VERSION_LEN 31
#define PHONE_LEN 20
#define EMAIL_LEN 50
#define NICK_LEN 50
#define OPENID_LEN 40
#define MONEY_LEN 12
#define NOT_USE_LEN_NEW 420
#define NOT_USE_LEN_RECEIVE 28
#define NOT_USE_LEN_SEND 7

#define USERNAME_LEN 50
#define PASS_LEN 20
#define UID_LEN 4
#define UPDATEURL_LEN 20

#define ERR_NO_ACCOUNT -1                                                                                                                                                                                                                                                                                                      
#define ERR_NOT_VALIDE -2
#define ERR_TRY_END -4
#define ERR_DATA_TYPE -5
#define ERR_NOT_ONLY -9
#define ERR_CHECKED_ALREADY 8
#define ERR_SOCKET 0
#define ERR_FAILE 0
#define ERR_OK 1
#define ERR_OK_NOTCHECKED 0
#define ERR_NOUPDATE 3

#define ERR_OK_NEW 1
#define ERR_NO_ACCOUNT_NEW 2
#define ERR_NOT_VALID_NEW 4
#define ERR_EMAIL_CHECKED_NEW 8
#define ERR_PHONE_CHECKED_NEW 16
#define ERR_QQ_CHECKED_NEW 32
#define ERR_EMAIL_USED_NEW 64
#define ERR_QQ_USED_NEW 128

#define PORT_USER   5004

typedef struct _USER_DATA{
    int apptype;
    int noticenum;
    int random;
    int status;         //用户状态,1:子账户（原为：notuser1）
    int notuse2;
    int notuse3;
    char logname[USERNAME_LEN+1];//昵称
    char password[PASS_LEN+1];
    char MAC[MAC_LEN+1];
    char versionStr[VERSION_LEN+1];
    char phone[PHONE_LEN +1];
    char email[EMAIL_LEN+1];
    char nick[NICK_LEN+1];
    char uid[UID_LEN+1];
    char openid[OPENID_LEN+1];
    char qqnick[NICK_LEN+1];
    char money[MONEY_LEN+1];
    char notuse[NOT_USE_LEN_NEW];
}USER_DATA;

typedef struct _SEND_DATA{
    short type;
    USER_DATA user_data;
}USER_SEND_DATA;

//客户端接收数据结构：RECIEVE_DATA_NEW_MOV
typedef struct _UID_TYPE_DATA_MOV{
    char logname[USERNAME_LEN+1];
    char uid[UID_LEN+1];
    char email[EMAIL_LEN+1];
    char phone[PHONE_LEN+1];
    char notuse[NOT_USE_LEN_SEND];
}UID_TYPE_DATA_MOV;

typedef struct _RECIEVE_DATA_NEW_MOV{
    short type;
    short suc;
    USER_DATA uid_type;
}RECIEVE_DATA_NEW_MOV;

typedef struct _MAKE_RECEIVE_
{
    int iReturn;
    
}MAKERECEIVE;

#endif
