//
//  PycCode.m
//  PycSocket
//
//  Created by Fairy on 13-11-7.
//  Copyright (c) 2013年 Fairy. All rights reserved.
//

#import "PycCode.h"
#import "SMS4.h"
#import "SM3.h"
#import "FileOutPublic.h"
#include <string.h>


@interface PycCode ()
{
    NSData *secretKey;
    
}

@end

@implementation PycCode


-(void) generateSecretKey:(Byte *) key length:(int ) len
{
    
    int returnNum= SecRandomCopyBytes(kSecRandomDefault, len, key);
    if (returnNum == -1) {
        NSLog(@"err");
    }
    


}
//-(void) generateSecretKeyR1:(Byte *)key length:(int) len
//{
//    int returnNum= SecRandomCopyBytes(kSecRandomDefault, len, key);
//    if (returnNum == -1) {
//        NSLog(@"err");
//        return;
//    }
//    
//    
//    for (int i = 0; i<16; i++) {
//        key[i] = key[i] - 'O' + 'A';
//    }
//    
//    
//}
-(BOOL)codeBufferOfFile:(Byte *)data length:(int)len withKey:(Byte *)key
{
    if (key == nil) {
        NSLog(@"code file buffer err key is nil");
        return NO;
    }
    NSLog(@"code");
    SMS4SetKey((uint32 *)key, 1);
    SMS4Encrypt((uint32 *) data, len, 1);
    return (YES);
}
- (BOOL) decodeBufferOfFile: (Byte *) data length: (int ) len withKey:(Byte *)key
{
    if (key == nil) {
         NSLog(@"decode file buffer err key is nil");
        return NO;
    }
    
    
    NSLog(@"decode");
    SMS4SetKey((uint32 *)key, 1);
    SMS4Decrypt((uint32 *) data, len);
    
    return (YES);
    
    
//    while (true) {
//    Byte * decrypt = (Byte*)malloc(len);
//    memset(decrypt, 0, len);
//    memcpy(decrypt, data, len);
//    
//    NSLog(@"decode");
//    SMS4SetKey((uint32 *)key, 1);
//    SMS4Decrypt((uint32 *) decrypt, len);
//    
//    Byte * encrypt = (Byte*)malloc(len);
//    memset(encrypt, 0, len);
//    memcpy(encrypt, decrypt, len);
//    SMS4SetKey((uint32 *)key, 1);
//    SMS4Encrypt((uint32 *) encrypt, len, 1);
//        NSLog(@"解密操作--------");
//    if (strcmp((char *)encrypt, (char *)data) == 0){
//        NSLog(@"ok");
//        
//        memcpy(data, decrypt, len);
//        free(decrypt);
//        free(encrypt);
//        return (YES);
//    }
//    free(decrypt);
//    free(encrypt);
//    }
    
}
- (BOOL) codeBuffer: (Byte *) data length: (int ) len
{
    NSLog(@"code");
    SMS4SetKey((uint32 *)"1111111111111111", 1);
    SMS4Encrypt((uint32 *) data, len, 1);
    return (YES);
}
- (BOOL) decodeBuffer: (Byte *) data length: (int ) len
{
    NSLog(@"decode0000");
    SMS4SetKey((uint32 *)"1111111111111111", 1);
    SMS4Decrypt((uint32 *) data, len);
    return (YES);
}
- (BOOL) codeFileExtension: (PYCFILEEXT *)fileExt
{
    NSLog(@"codeFileExtension");
    Byte defaultKey[72] = "PYCAdminabcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ12345!@#$%^&";
    SMS4SetKey((uint32 *)defaultKey, 1);
    SMS4Encrypt((uint32 *) fileExt, sizeof(PYCFILEEXT), 1);
    return (YES);
}
- (BOOL) decodeFileExtension: (PYCFILEEXT *)fileExt
{
    NSLog(@"decodeFileExtension");
    Byte defaultKey[72] = "PYCAdminabcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ12345!@#$%^&";
    SMS4SetKey((uint32 *)defaultKey, 1);
    SMS4Decrypt((uint32 *) fileExt, sizeof(PYCFILEEXT));
    return (YES);
}
-(BOOL) codeHeader:(PYCFILEHEADER *)fileHeader{
    NSLog(@"codeHeader");
    Byte defaultKey[72] = "PYCAdminabcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ12345!@#$%^&";
    SMS4SetKey((uint32 *)defaultKey, 1);
    SMS4Encrypt((uint32 *) fileHeader, sizeof(PYCFILEHEADER), 1);
    return (YES);
}

-(BOOL) decodeHeader:(PYCFILEHEADER *)fileHeader{
    NSLog(@"decodeHeader");
    Byte defaultKey[72] = "PYCAdminabcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ12345!@#$%^&";
    SMS4SetKey((uint32 *)defaultKey, 1);
    SMS4Decrypt((uint32 *) fileHeader, sizeof(PYCFILEHEADER));
    return (YES);
}

-(BOOL) CalculateHashValue:(Byte *)pdata datalen:(int) datalen hashValue:(unsigned char *) phashValue
{

    unsigned char hashValue[32];
    memset(hashValue, 0, 32);
    SM3_CONTEXT *context = (SM3_CONTEXT *)malloc(sizeof(SM3_CONTEXT));
    if (!context) {
        NSLog(@"context is null");
        return NO;
    }
    
    SM3_Init(context);
    SM3_Update(context, pdata, datalen);
    SM3_Final(context, hashValue);
    memcpy(phashValue, hashValue, 32);
    
    free(context);
    return YES;
}

-(BOOL)getSessionKeyFormFileSessionKey:(Byte*)fileSessionKey to:(Byte*)outKey
{
    memset(outKey, 0, SECRET_KEY_LEN);
    for(int i = 0; i<SECRET_KEY_LEN;i++)
    {
        outKey[i] = fileSessionKey[i*16];
    }
    return YES;
}

-(BOOL)getSessionKeyFromOriginalKey:(Byte *)inkey to:(Byte *)outKey
{
    if ((!inkey) || (!outKey))
    {
        NSLog(@"sessionkey in nil");
            return NO;
    }

    memset(outKey, 0, SESSION_KEY_LEN);
    for(int i = 0; i < SECRET_KEY_LEN; i++ )
    {
        outKey[16*i] = inkey[i];
    }
    return YES;
    
}


-(BOOL)getSecretKeyFromOriginalKey:(Byte *)inkey to:(Byte *)outKey
{
    if ((!inkey) || (!outKey))
    {
        NSLog(@"getSecretKeyFromOriginalKey in nil");
        return NO;
    }
    
    memset(outKey, 0, 16);
        for (int i = 0; i<16; i++) {
            outKey[i] = inkey[i] - '0' + 'A';
        }
    return YES;
    
    
    
}
+(BOOL)getSecretKeyFromUid:(Byte *)_uid to:(Byte *)key
{

    int lp1temp = (_uid[2]*128 + _uid[3]) * 128;
    lp1temp = (lp1temp + _uid[0]) * 128 + _uid[1];
    MyLog(@"_uid==%hhu,%hhu,%hhu,%hhu",_uid[0],_uid[1],_uid[2],_uid[3]);
    int i = 0;
    for (i=7; i >= 0; i--)
    {
        key[i] = lp1temp % 16 + 'A' ;
        lp1temp = lp1temp / 16;
    }
    
    //复制key
    for (i = 16-1; i >= 8;i--)
    {
        key[i] = key[16-1-i];
    }
    key[16] = '\0';
    
    return YES;
}
@end
