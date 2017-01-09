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
#define THERMOMETER_FRAME (20, 5, 25, 5);
@implementation AdvertisingView

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
-(void)startLoadingWindow:(NSWindow *)keywindow
                   fileID:(NSInteger)fileID
                isOutLine:(BOOL)OutLine
{
    //重置缓存图片
    [_ibImageView setImage:nil];
//    [_ibImageView setImage:[NSImage imageNamed:@"advitising.jpg"]];
    if(![keywindow.contentView isKindOfClass:[NSView class]])
    {
        _finish = YES;
        return;
    }
    
    NSView *keyView = keywindow.contentView;
    self.wantsLayer = true;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [keyView addSubview:self];
    [self setEdge:keyView view:self attr:NSLayoutAttributeTop constant:0];
    [self setEdge:keyView view:self attr:NSLayoutAttributeBottom constant:0];
    [self setEdge:keyView view:self attr:NSLayoutAttributeLeft constant:0];
    [self setEdge:keyView view:self attr:NSLayoutAttributeRight constant:0];
    
//    [MBProgressHUD showHUDAddedTo:self animated:YES];
    _adverTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerwithTimesNums1:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_adverTimer forMode:NSRunLoopCommonModes];
    
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
    
    if (!_imgCache)
    {
        _imgCache = [[AdvertisingImgCache alloc] init];
    }
//    [_ibIndicator startAnimation:self];
//    _ibIndicator.layer.backgroundColor = [[NSColor greenColor] CGColor];
    [_imgCache AdvertisingForTerm:UidOrImgUrl completionBlock:^(NSString *imgPath, NSInteger uid,NSError *error) {
        
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
            while (!_finish) {
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

@end
