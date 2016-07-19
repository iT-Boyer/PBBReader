//
//  UILabel+Attribute.h
//  PBB
//
//  Created by pengyucheng on 14-5-26.
//  Copyright (c) 2014年 pyc.com.cn. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface  NSTextField(Attribute)


- (void)AddColorText:(NSString*)actxt AColor:(NSColor*)acolor AFont:(NSFont*)afont;
- (void)appendText:(NSString *)text AColorText:(NSString*)actxt AColor:(NSColor*)acolor AFont:(NSFont*)afont;
- (void)setText:(NSString *)text AColorText:(NSString*)actxt AColor:(NSColor*)acolor AFont:(NSFont*)afont;
@end
