//
//  selectedRowHighlightCell.m
//  ScaryBugsMac
//
//  Created by huoshuguang on 16/8/31.
//  Copyright © 2016年 recomend. All rights reserved.
//

#import "SelectedRowHighlightCell.h"

@implementation SelectedRowHighlightCell


- (NSAttributedString*)getCellAttributes
{
    NSDictionary*  _attributes = [NSDictionary dictionaryWithObjectsAndKeys:_cellFontColor,NSForegroundColorAttributeName,nil];
    NSString* _cellString = [self stringValue];
    
    _cellAttributedString = [[NSAttributedString alloc]
                              initWithString:_cellString attributes:_attributes];
    
    return _cellAttributedString;
}

- (NSColor*)highlightColorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSRect newRect = NSMakeRect(cellFrame.origin.x - 1, cellFrame.origin.y, cellFrame.size.width + 5, cellFrame.size.height);
    if (_cellBKColor)
    {
        [_cellBKColor set];
        NSRectFill(newRect);
    }
    
    [self setAttributedStringValue:[self getCellAttributes]];
    
    return nil;
}
@end
