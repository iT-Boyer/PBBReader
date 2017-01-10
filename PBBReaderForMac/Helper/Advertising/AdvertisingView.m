//
//  AdvertisingView.m
//  PBB
//
//  Created by pengyucheng on 14-11-19.
//  Copyright (c) 2014年 pyc.com.cn. All rights reserved.
//

#import "AdvertisingView.h"
#import "ReceiveFileDao.h"
#import "ToolString.h"
#import <Cocoa/Cocoa.h>
#import "MBProgressHUD.h"
#import "PlayerWindow.h"
#import <SDWebImage/UIImageView+WebCache.h>
#define THERMOMETER_FRAME (20, 5, 25, 5);
@implementation AdvertisingView

-(void)awakeFromNib
{
//    _ibLogoView.wantsLayer = true;
//    _ibImageView.wantsLayer = true;
    NSColor *bannerColor = [NSColor colorWithPatternImage:_backgroundImage];
    _ibLogoView.layer.backgroundColor = bannerColor.CGColor;
//    _ibImageView.layer.backgroundColor = bannerColor.CGColor;
    
    _ibLogoView.boundsRotation = 30;
//    _ibImageView.frameRotation = -30;
    
//    _ibImageView.boundsRotation = -20; //必须设置视频广告的倾向，否则将导致视频画面错位
}

-(BOOL)needsDisplay
{
    return true;
}

-(void)startLoadingWindow:(NSWindow *)keywindow
                   fileID:(NSInteger)fileID
                isOutLine:(BOOL)OutLine
{
    //重置缓存图片
    [_ibImageView setImage:nil];
    if(![keywindow.contentView isKindOfClass:[NSView class]])
    {
        _finish = YES;
        return;
    }

    NSView *keyView = keywindow.contentView;
    keyView.canDrawSubviewsIntoLayer = true;
//    [keyView addSubview:self positioned:NSWindowAbove relativeTo:keyView.subviews[1]];
    [keyView addSubview:self];
    self.wantsLayer = true;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self setEdge:keyView view:self attr:NSLayoutAttributeTop constant:0];
    [self setEdge:keyView view:self attr:NSLayoutAttributeBottom constant:0];
    [self setEdge:keyView view:self attr:NSLayoutAttributeLeft constant:0];
    [self setEdge:keyView view:self attr:NSLayoutAttributeRight constant:0];
    
//    [MBProgressHUD showHUDAddedTo:self animated:YES];
    _adverTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                   target:self
                                                 selector:@selector(timerwithTimesNums1:)
                                                 userInfo:nil
                                                  repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_adverTimer
                                 forMode:NSRunLoopCommonModes];
    
    if(fileID == -1)
    {
        return;
    }
    NSString *UidOrImgUrl = @"";
    NSInteger uid = [[ReceiveFileDao sharedReceiveFileDao] fetchUid:fileID];
    if ([ToolString isConnectionAvailable])
    {
        UidOrImgUrl = [NSString stringWithFormat:@"http://%@/myspace/deployadvertshow.aspx?fid=%ld",IP_ADDRESS_HTML,(long)fileID];
    }
    else
    {
        UidOrImgUrl = [NSString stringWithFormat:@"%ld",(long)uid];
    }
    
//    [_ibImageView sd_setImageWithURL:[NSURL URLWithString:UidOrImgUrl]
//                    placeholderImage:[NSImage imageNamed:@"advitising.jpg"]
//                           completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//
//                               dispatch_async(dispatch_get_main_queue(), ^{
//                                   //当此时，广告已加载完成
//                                   while (!_finish)
//                                   {
//                                       [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//                                   }
//                                   [_adverTimer invalidate];
//                               });
//                           }];
    
    if (!_imgCache)
    {
        _imgCache = [[AdvertisingImgCache alloc] init];
    }
//    [_ibIndicator startAnimation:self];
//    _ibIndicator.layer.backgroundColor = [[NSColor greenColor] CGColor];
    [_imgCache AdvertisingForTerm:UidOrImgUrl
                  completionBlock:^(NSString *imgPath, NSInteger uid,NSError *error) {
        
//        NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:imgPath]];
//        [self.ibWebView loadRequest:requestObj];
        _uid = uid;
        dispatch_async(dispatch_get_main_queue(), ^{

            if (imgPath) {
                //
                [_ibImageView setImage:[[NSImage alloc] initWithContentsOfFile:imgPath]];
            }else{
                //
                [_ibImageView setImage:[NSImage imageNamed:@"advitising.jpg"]];
                
            }
            //当此时，广告已加载完成
            while (!_finish)
            {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
            [_adverTimer invalidate];
        });
        _finish = YES;
    }];
    
}

-(void)timerwithTimesNums1:(id)sender
{
    _advertime++;
}
//设置Autolayout中的边距辅助方法
- (void)setEdge:(NSView*)superview view:(NSView*)view attr:(NSLayoutAttribute)attr constant:(CGFloat)constant
{
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                          attribute:attr
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:superview
                                                          attribute:attr
                                                         multiplier:1.0
                                                           constant:constant]];
}
@end
