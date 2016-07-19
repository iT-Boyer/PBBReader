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
@interface AdvertisingView : NSView

@property (weak, nonatomic) IBOutlet NSImageView *ibImageView;

@property(strong,nonatomic)AdvertisingImgCache *imgCache;

@property(assign,nonatomic)BOOL finish;

@property(assign,nonatomic)NSInteger uid;

@property(assign,nonatomic)NSInteger advertime;
@property(strong,nonatomic)NSTimer *adverTimer;

-(void)startLoading:(NSInteger)fileID isOutLine:(BOOL)isOutLine;

@end
