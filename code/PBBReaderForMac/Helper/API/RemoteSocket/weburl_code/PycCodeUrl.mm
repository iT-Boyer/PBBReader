//
//  PycCode.m
//  PycSocket
//
//  Created by Fairy on 13-11-7.
//  Copyright (c) 2013年 Fairy. All rights reserved.
//

#import "PycCodeUrl.h"
#import "HttpDes.h"



@interface PycCodeUrl ()
{
    NSData *secretKey;
    
}

@end

@implementation PycCodeUrl

-(BOOL)codeUrl:(Byte *)sUrl length:(int)len to:(Byte *)dUrl  retlen:(int *)retLen
{
    CHttpDes httpDes;
    httpDes.GetEntryText((char *)sUrl, len, (char *)dUrl ,retLen);
    return TRUE;
}
-(BOOL)codeUrlnew:(Byte *)sUrl length:(int)len to:(Byte *)dUrl  retlen:(int *)retLen
{
    CHttpDes httpDes;
    httpDes.GetEntryTextnew((char *)sUrl, len, (char *)dUrl ,retLen);
    return TRUE;
}
@end
