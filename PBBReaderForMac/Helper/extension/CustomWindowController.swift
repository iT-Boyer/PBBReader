//
//  CustomWindowController.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 16/8/30.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Cocoa
//import SnapKit

class CustomWindowController: NSWindowController {

    override func awakeFromNib() {
        //参看：http://aigudao.net/archives/314.html
        self.window!.titlebarAppearsTransparent = true // 标题栏透明，重要
        self.window!.contentView!.wantsLayer = true // 设置整个内容view都有layer
        
        // 使用图片生成颜色
//        let bannerColor = NSColor.init(patternImage: NSImage.init(named: "liulan")!)
        //R:246.0/255.0.G:246.0/255.0.B:246.0/255.0   #f6f6f6
        let bannerColor = NSColor.init(red:246.0/255.0, green:246.0/255.0, blue:246.0/255.0, alpha:1.0)
        // 自定义一个view
        let topBannerView = NSView.init(frame: NSZeroRect)
        topBannerView.wantsLayer = true
        topBannerView.layer!.backgroundColor = bannerColor.cgColor
        self.window?.contentView?.addSubview(topBannerView)
//        topBannerView.snp_makeConstraints { (make) in
//            //
//            make.top.equalTo((self.window?.contentView)!).offset(0)
//            make.left.equalTo((self.window?.contentView)!).offset(0)
//            make.right.equalTo((self.window?.contentView)!).offset(0)
//            make.height.equalTo(40)
//        }
        
        topBannerView.translatesAutoresizingMaskIntoConstraints = false
        let topBannerViewV = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[topBannerView(==40)]",
                                                        options: [],
                                                        metrics: nil,
                                                        views: ["topBannerView":topBannerView])
        let topBannerViewH = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[topBannerView]-0-|",
                                                        options: [],
                                                        metrics: nil,
                                                        views: ["topBannerView":topBannerView])
        
        (self.window?.contentView)!.addConstraints(topBannerViewV)
        (self.window?.contentView)!.addConstraints(topBannerViewH)
        
        
        //自定义一个label
        let titleLabel = NSTextField()
        titleLabel.stringValue = "PBB Reader"
        titleLabel.alignment = .center
        titleLabel.font = NSFont.systemFont(ofSize: 25)
        titleLabel.isEditable = false
        titleLabel.isBordered = false //设置无边框
        titleLabel.textColor = NSColor.white
        titleLabel.backgroundColor = bannerColor
        topBannerView.addSubview(titleLabel)
        titleLabel.sizeToFit()
//        titleLabel.snp_makeConstraints { (make) in
//            //居顶部5 ，水平居中topBanerView
//            make.centerX.equalTo(topBannerView)
//            make.left.right.equalTo(0)
//            make.top.equalTo(3)
//            
//        }
//        let titleLabelV = NSLayoutConstraint.constraints(withVisualFormat: "V:|-3-[titleLabel]",
//                                                            options: [],
//                                                            metrics: nil,
//                                                            views: ["titleLabel":titleLabel])
//        let titleLabelH = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleLabel]-|",
//                                                            options: [],
//                                                            metrics: nil,
//                                                            views: ["titleLabel":titleLabel])
//        
//        topBannerView.addConstraints(titleLabelV)
//        topBannerView.addConstraints(titleLabelH)
        
        //文字版标题已废弃
        titleLabel.isHidden = true
        
        //标题图片镂空文字
        let titleImageView = NSImageView()
        titleImageView.image = NSImage.init(named: "titlePBBReader")
        topBannerView.addSubview(titleImageView)
//        titleImageView.snp_makeConstraints { (make) in
//            make.centerX.equalTo(topBannerView)
//            make.top.equalTo(3)
//        }
        
        //居顶部3
        titleImageView.translatesAutoresizingMaskIntoConstraints = false
        let titleImageViewV = NSLayoutConstraint.constraints(withVisualFormat: "V:|-3-[titleImageView]",
                                                         options: [],
                                                         metrics: nil,
                                                         views: ["titleImageView":titleImageView])
        //水平居中
        let titleImageViewH = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleImageView]-|",
                                                         options: [],
                                                         metrics: nil,
                                                         views: ["titleImageView":titleImageView])
        
        topBannerView.addConstraints(titleImageViewV)
        topBannerView.addConstraints(titleImageViewH)
        
        // 取出标题栏的view并且改变背景色
        var views = self.window!.contentView!.superview!.subviews
        let titlebarContainerView = views[1]
        let titlebarView = titlebarContainerView.subviews[0]
        titlebarView.layer!.backgroundColor = bannerColor.cgColor
        //        CGColorRelease(bannerColor)
//        self.window?.contentView?.superview?.addSubview(titlebarView,positioned: .Below,relativeTo: topBannerView)

    }
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        // Insert code here to initialize your application
        
        }

}
