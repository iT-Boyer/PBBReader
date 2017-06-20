//
//  PycCode.h
//  PycSocket
//
//  Created by Fairy on 13-11-7.
//  Copyright (c) 2013年 Fairy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/SecRandom.h>
#import "FileOutPublic.h"



@interface PycCode : NSObject


-(void) generateSecretKey:(Byte *) key length:(int ) len;
//-(void) generateSecretKeyR1:(Byte *)key length:(int) len;
-(BOOL)CalculateHashValue:(Byte *)pdata datalen:(int) datalen hashValue:(unsigned char *) phashValue;

-(BOOL)codeBufferOfFile:(Byte *)data length:(int)len withKey:(Byte *)key;
- (BOOL) decodeBufferOfFile: (Byte *) data length: (int ) len withKey:(Byte *)key;
- (BOOL) codeBuffer: (Byte *) data length: (int ) len;
- (BOOL) decodeBuffer: (Byte *) data length: (int ) len;
- (BOOL) codeFileExtension: (PYCFILEEXT *)fileExt;
- (BOOL) decodeFileExtension: (PYCFILEEXT *)fileExt;
-(BOOL) codeHeader:(PYCFILEHEADER *)fileHeader;
-(BOOL) decodeHeader:(PYCFILEHEADER *)fileHeader;
-(BOOL)getSessionKeyFormFileSessionKey:(Byte*)fileSessionKey to:(Byte*)outKey;
-(BOOL)getSessionKeyFromOriginalKey:(Byte *)inkey to:(Byte *)outKey;
-(BOOL)getSecretKeyFromOriginalKey:(Byte *)inkey to:(Byte *)outKey;
+(BOOL)getSecretKeyFromUid:(Byte *)_uid to:(Byte *)key;



@end
