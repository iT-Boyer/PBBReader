//
//  TestViewController.h
//  sssssssssss
//
//  Created by liujun on 16/11/18.
//  Copyright © 2016年 liujun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "MuDialogCreator.h"
#import "MuUpdater.h"
@interface MuPDFViewController : NSViewController < NSTableViewDelegate, MuDialogCreator, MuUpdater>
- (IBAction)ibBack:(id)sender;
@property(nonatomic,strong)NSString *openfilepath;
@property(nonatomic,strong)NSString *filename;
@property (strong) IBOutlet NSView *canvas;
@property (unsafe_unretained) IBOutlet NSButton *btnback;
@property (unsafe_unretained) IBOutlet PDFView *PDFview;

@property (assign) IBOutlet NSSplitView *mysplit;
- (IBAction)prepage:(id)sender;
- (IBAction)nextpage:(id)sender;
- (IBAction)search:(id)sender;
- (IBAction)presearch:(id)sender;
- (IBAction)nextsearch:(id)sender;
@property (strong) IBOutlet NSSearchField *mysearchfield;
@property (strong) IBOutlet NSScrollView *myscroll;
- (IBAction)bigger:(id)sender;
- (IBAction)smaller:(id)sender;

@property (strong) IBOutlet NSTableView *mytableview;
@property (assign) IBOutlet NSButton *btnshowoutline;
@property (assign) IBOutlet NSSegmentedControl *myseg;
- (IBAction)segclick:(id)sender;

- (IBAction)showoutline:(id)sender;

- (IBAction)changeScale:(id)sender;
@property (assign) IBOutlet NSPopUpButton *popup;

-(void)loadpdf;
@end
