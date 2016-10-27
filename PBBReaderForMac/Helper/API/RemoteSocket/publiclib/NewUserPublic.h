//
//  NewUserPublic.h
//  PBB
//
//  Created by Fairy on 14-3-19.
//  Copyright (c) 2014年 pyc.com.cn. All rights reserved.
//

#ifndef PBB_NewUserPublic_h
#define PBB_NewUserPublic_h

#define NEW_USERNAME_LEN 50
#define NEW_PASS_LEN 20
#define NEW_MAC_LEN 17
#define NEW_VERSION_LEN 31
#define NEW_PHONE_LEN 20
#define NEW_EMAIL_LEN 50
#define NEW_NICK_LEN 50
#define NEW_UID_LEN 4
#define NEW_OPENID_LEN 32
#define NEW_NOT_USE_LEN 300

typedef struct _NEW_USER_DATA_{
    int apptype;
    char logname[NEW_USERNAME_LEN+1];
    char password[NEW_PASS_LEN+1];
    char MAC[NEW_MAC_LEN+1];
    char versionStr[NEW_VERSION_LEN+1];
    char phone[NEW_PHONE_LEN +1];
    char email[NEW_EMAIL_LEN+1];
    char nick[NEW_NICK_LEN+1];
    char uid[NEW_UID_LEN+1];
    char openid[NEW_OPENID_LEN+1];
    char notuse[NEW_NOT_USE_LEN];
}NEW_USER_DATA;


typedef struct _NEW_SEND_DATA{
    short type;
    NEW_USER_DATA user_data;
}NEW_SEND_DATA;

typedef struct _NEW_RECIEVE_DATA_NEW_MOV{
    short type;
    short suc;
    NEW_USER_DATA user_data;
}NEW_RECIEVE_DATA;


#endif
