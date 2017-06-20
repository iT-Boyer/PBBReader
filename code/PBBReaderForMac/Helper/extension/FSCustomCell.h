//
//  FSCustomCell.h
//  NSTableViewDemo
//
//  Created by apple on 13-11-18.
//  Copyright (c) 2013年 fengsh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FSCustomCell : NSTextFieldCell//*//*NSActionCell
{
    NSImageView             *avatar;
    NSTextField             *displayName;
    NSColor*                _cellBKColor;
    NSColor*                _cellFontColor;
    NSAttributedString*                     _cellAttributedString;
}

@property (nonatomic , retain) NSImageView             *avatar;
@property (nonatomic , retain) NSTextField             *displayName;
- (void)setSelectionBKColor:(NSColor*)cellColor;
- (void)setSelectionFontColor:(NSColor*)cellFontColor;
- (NSAttributedString*)getCellAttributes;

@end
