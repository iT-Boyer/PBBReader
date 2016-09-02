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



@interface PycCodeUrl : NSObject
-(BOOL)codeUrl:(Byte *)sUrl length:(int)len to:(Byte *)dUrl retlen:(int *)retLen;
-(BOOL)codeUrlnew:(Byte *)sUrl length:(int)len to:(Byte *)dUrl retlen:(int *)retLen;
@end
