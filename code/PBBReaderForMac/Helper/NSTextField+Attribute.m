//
//  UILabel+Attribute.m
//  PBB
//
//  Created by pengyucheng on 14-5-26.
//  Copyright (c) 2014年 pyc.com.cn. All rights reserved.
//

#import "NSTextField+Attribute.h"

@implementation NSTextField (Attribute)


- (void)AddColorText:(NSString*)actxt AColor:(NSColor*)acolor AFont:(NSFont*)afont
{
    NSFont *nfont = afont;
    if (afont == nil) {
        nfont = self.font;
    }
    NSString *text = [self attributedStringValue].string;
    NSMutableAttributedString *nattrStr = [[NSMutableAttributedString alloc] initWithAttributedString:[self attributedStringValue]];
    NSRange crange = [text rangeOfString:actxt];
    [nattrStr addAttribute:NSForegroundColorAttributeName value:acolor range:crange];
    [nattrStr addAttribute:NSFontAttributeName value:nfont range:crange];
    self.attributedStringValue = nattrStr;
}


- (void)appendText:(NSString *)text AColorText:(NSString*)actxt AColor:(NSColor*)acolor AFont:(NSFont*)afont
{
    NSFont *lbfont = self.font;
    NSFont *nfont = afont;
    if (afont == nil) {
        nfont = self.font;
    }
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithAttributedString:[self attributedStringValue]];
    NSDictionary *attrdic = [NSDictionary dictionaryWithObject:lbfont forKey:NSFontAttributeName];
    
    NSMutableAttributedString *nattrStr = [[NSMutableAttributedString alloc]initWithString: text attributes:attrdic];
    NSRange crange = [text rangeOfString:actxt];
    
    [nattrStr addAttribute:NSForegroundColorAttributeName value:acolor range:crange];
    [nattrStr addAttribute:NSFontAttributeName value:nfont range:crange];
    [attrStr appendAttributedString:nattrStr];
    self.attributedStringValue = attrStr;
}


- (void)setText:(NSString *)text AColorText:(NSString*)actxt AColor:(NSColor*)acolor AFont:(NSFont*)afont
{
    NSFont *lbfont = self.font;
    NSFont *nfont = afont;
    if (afont == nil) {
        nfont = self.font;
    }
    NSDictionary *attrdic = [NSDictionary dictionaryWithObject:lbfont forKey:NSFontAttributeName];
    NSMutableAttributedString *nattrStr = [[NSMutableAttributedString alloc]initWithString: text attributes:attrdic];
    NSRange crange = [text rangeOfString:actxt];
    [nattrStr addAttribute:NSForegroundColorAttributeName value:acolor range:crange];
    [nattrStr addAttribute:NSFontAttributeName value:nfont range:crange];
    
    self.attributedStringValue = nattrStr;
}
@end
