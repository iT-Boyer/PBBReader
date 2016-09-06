//
//  CustomWindowController.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 16/8/30.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Cocoa
import SnapKit

class CustomWindowController: NSWindowController {

    override func awakeFromNib() {
        //参看：http://aigudao.net/archives/314.html
        self.window!.titlebarAppearsTransparent = true // 标题栏透明，重要
        self.window!.contentView!.wantsLayer = true // 设置整个内容view都有layer
        
        // 使用图片生成颜色
//        let bannerColor = NSColor.init(patternImage: NSImage.init(named: "liulan")!)
        //R:246.G:246.B:246   #f6f6f6
        let bannerColor = NSColor.init(red: 246, green: 246, blue: 246, alpha: 1) // NSColor.lightGrayColor()
        
        // 自定义一个view
        let topBannerView = NSView.init(frame: NSZeroRect)
        topBannerView.wantsLayer = true
        topBannerView.layer!.backgroundColor = bannerColor.CGColor
        self.window?.contentView?.addSubview(topBannerView)
        topBannerView.snp_makeConstraints { (make) in
            //
            make.top.equalTo((self.window?.contentView)!).offset(0)
            make.left.equalTo((self.window?.contentView)!).offset(0)
            make.right.equalTo((self.window?.contentView)!).offset(0)
            make.height.equalTo(40)
        }
        //自定义一个label
        let titleLabel = NSTextField()
        titleLabel.stringValue = "PBB Reader"
        titleLabel.alignment = .Center
        titleLabel.font = NSFont.systemFontOfSize(25)
        titleLabel.editable = false
        titleLabel.bordered = false //设置无边框
        titleLabel.textColor = NSColor.whiteColor()
        titleLabel.backgroundColor = bannerColor
        topBannerView.addSubview(titleLabel)
        titleLabel.sizeToFit()
        titleLabel.snp_makeConstraints { (make) in
            //居顶部5 ，水平居中topBanerView
            make.centerX.equalTo(topBannerView)
            make.left.right.equalTo(0)
            make.top.equalTo(3)
            
        }
        titleLabel.hidden = true
        
        //标题图片镂空文字
        let titleImageView = NSImageView()
        titleImageView.image = NSImage.init(named: "titlePBBReader")
        topBannerView.addSubview(titleImageView)
        titleImageView.snp_makeConstraints { (make) in
            make.centerX.equalTo(topBannerView)
            make.top.equalTo(3)
        }
        
        // 取出标题栏的view并且改变背景色
        var views = self.window!.contentView!.superview!.subviews
        let titlebarContainerView = views[1]
        let titlebarView = titlebarContainerView.subviews[0]
        titlebarView.layer!.backgroundColor = bannerColor.CGColor
        //        CGColorRelease(bannerColor)
//        self.window?.contentView?.superview?.addSubview(titlebarView,positioned: .Below,relativeTo: topBannerView)

    }
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        // Insert code here to initialize your application
        
        }

}
