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
#import "PlayerView.h"
#define THERMOMETER_FRAME (20, 5, 25, 5);
@implementation AdvertisingView
singleton_implementation(AdvertisingView);
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
//UIView构造方法
- (id)initWithFrame:(CGRect)aRect
{
    if ((self = [super initWithFrame:aRect])) {
        [self commonInit];
    }
    return self;
}

//Storyboard用
- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    /* 这里开始初始化 */
    
    //如果需要重新调用drawRect则设置contentMode为UIViewContentModeRedraw
//    self.contentMode = NSViewContentModeRedraw;
    //不允许从Autoresizing转换Autolayout的Constraints
    //貌似Storyboard创建时调用initWithCoder方法时translatesAutoresizingMaskIntoConstraints已经是NO了
    self.translatesAutoresizingMaskIntoConstraints = NO;

}



-(void)startLoading:(NSInteger)fileID isOutLine:(BOOL)OutLine
{
    NSWindow *superWindow = [[NSApplication sharedApplication] keyWindow];//.contentView;
    if(![superWindow.contentView isKindOfClass:[NSView class]]){
        _finish = YES;
        return;
    }
//    superView = [[NSApplication sharedApplication] keyWindow];
////    [superView resignKeyWindow];
////    [superView deminiaturize:self];
//    [superView makeKeyAndOrderFront:NSApp];
//    [superView makeMainWindow];
    NSView *lastView = superWindow.contentView;
    [lastView addSubview:self];
    [self setEdge:lastView view:self attr:NSLayoutAttributeTop constant:0];
    [self setEdge:lastView view:self attr:NSLayoutAttributeBottom constant:0];
    [self setEdge:lastView view:self attr:NSLayoutAttributeLeft constant:0];
    [self setEdge:lastView view:self attr:NSLayoutAttributeRight constant:0];
    
    _adverTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerwithTimesNums1:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_adverTimer forMode:NSRunLoopCommonModes];
    
    NSString *UidOrImgUrl = @"";
    NSInteger uid = [[ReceiveFileDao sharedReceiveFileDao] fetchUid:fileID];
    if ([ToolString isConnectionAvailable]) {
        UidOrImgUrl = [NSString stringWithFormat:@"http://%@/myspace/deployadvertshow.aspx?fid=%ld",IP_ADDRESS_HTML,(long)fileID];
    }else{
        UidOrImgUrl = [NSString stringWithFormat:@"%ld",(long)uid];
    }
    
    if (!_imgCache) {
        _imgCache = [[AdvertisingImgCache alloc] init];
    }
    
    [_ibIndicator setUsesThreadedAnimation:YES];
    [_ibIndicator startAnimation:self];
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
//            [_ibIndicator stopAnimation:self];
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
