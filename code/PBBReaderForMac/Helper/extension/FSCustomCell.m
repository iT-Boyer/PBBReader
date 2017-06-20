//
//  FSCustomCell.m
//  NSTableViewDemo
//
//  Created by fengsh on 13-11-18.
//  Copyright (c) 2013年 fengsh. All rights reserved.
//
//          自定义cell

#import "FSCustomCell.h"

@implementation FSCustomCell
@synthesize displayName;
@synthesize avatar;

- (id)init
{
    self = [super init];
    if (self)
    {
        avatar = [[NSImageView alloc]initWithFrame:NSMakeRect(10, 10, 60, 60)];
        avatar.image = [NSImage imageNamed:@"1"];
        displayName = [[NSTextField alloc]initWithFrame:NSMakeRect(80,10,100,20)];

    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    FSCustomCell *cellCopy = [super copyWithZone:zone];
    cellCopy.avatar = [self.avatar retain];
    cellCopy.displayName = [self.displayName retain];

    return cellCopy;
}

- (void)dealloc
{
    [avatar release];
    [displayName release];
    [super dealloc];
}

//自个画，，，，，
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    BOOL elementDisabled = NO;
    NSColor* primaryColor   = [self isHighlighted] ? [NSColor alternateSelectedControlTextColor] : (elementDisabled? [NSColor disabledControlTextColor] : [NSColor textColor]);
    
	NSDictionary* primaryTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys: primaryColor, NSForegroundColorAttributeName,
                                           [NSFont systemFontOfSize:13], NSFontAttributeName, nil];
	[self.displayName.stringValue drawAtPoint:NSMakePoint(cellFrame.origin.x+cellFrame.size.height+10, cellFrame.origin.y) withAttributes:primaryTextAttributes];
    //画图
    [[NSGraphicsContext currentContext] saveGraphicsState];
    float yOffset = cellFrame.origin.y;
	if ([controlView isFlipped]) {
		NSAffineTransform* xform = [NSAffineTransform transform];
		[xform translateXBy:0.0 yBy: cellFrame.size.height];
		[xform scaleXBy:1.0 yBy:-1.0];
		[xform concat];
		yOffset = 0-cellFrame.origin.y;
	}
    
    NSImageInterpolation interpolation = [[NSGraphicsContext currentContext] imageInterpolation];
	[[NSGraphicsContext currentContext] setImageInterpolation: NSImageInterpolationHigh];
    
    [avatar.image drawInRect:NSMakeRect(cellFrame.origin.x+5,yOffset+3,cellFrame.size.height-6, cellFrame.size.height-6)
			fromRect:NSMakeRect(0,0,[avatar.image size].width, [avatar.image size].height)
		   operation:NSCompositeSourceOver
			fraction:1.0];
    
    [[NSGraphicsContext currentContext] setImageInterpolation: interpolation];
	
	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (NSAttributedString*)getCellAttributes
{
    NSDictionary*  _attributes = [NSDictionary dictionaryWithObjectsAndKeys:_cellFontColor,NSForegroundColorAttributeName,nil];
    NSString* _cellString = [self stringValue];
    
    _cellAttributedString = [[[NSAttributedString alloc]
                              initWithString:_cellString attributes:_attributes] autorelease];
    
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

- (void)setSelectionBKColor:(NSColor*)cellColor
{
    [_cellBKColor release];
    _cellBKColor = nil;
    _cellBKColor = [cellColor retain];
}

- (void)setSelectionFontColor:(NSColor*)cellFontColor
{
    [_cellFontColor release];
    _cellFontColor = nil;
    _cellFontColor = [cellFontColor retain];
}

@end
