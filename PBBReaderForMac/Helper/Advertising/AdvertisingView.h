//
//  AdvertisingView.h
//  PBB
//
//  Created by pengyucheng on 14-11-19.
//  Copyright (c) 2014年 pyc.com.cn. All rights reserved.
//

//@import AppKit;
#import <Cocoa/Cocoa.h>
#import "AdvertisingImgCache.h"

IB_DESIGNABLE
@interface AdvertisingView : NSView

@property (weak, nonatomic) IBOutlet NSImageView *ibImageView;
@property (weak) IBOutlet NSView *ibLogoView;

@property (weak) IBOutlet NSProgressIndicator *ibIndicator;

@property(strong,nonatomic)AdvertisingImgCache *imgCache;

@property(assign,nonatomic)BOOL finish;

@property(assign,nonatomic)NSInteger uid;

@property(assign,nonatomic)NSInteger advertime;
@property(strong,nonatomic)NSTimer *adverTimer;

@property (nonatomic, assign) IBInspectable NSColor *backgroundColor;
@property (nonatomic, assign) IBInspectable NSImage *backgroundImage;

-(void)startLoadingWindow:(NSWindow *)keywindow fileID:(NSInteger)fileID isOutLine:(BOOL)isOutLine;

@end
