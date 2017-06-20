//
//  CustomView.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 16/9/6.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Cocoa

@IBDesignable
class CustomView: NSView {

    @IBInspectable var backgroundColor:NSColor!
    @IBInspectable var backgroundImage:NSImage!
    
    override func awakeFromNib() {
        
        wantsLayer = true
        if backgroundImage != nil
        {
            let bannerColor = NSColor.init(patternImage: backgroundImage)
            layer?.backgroundColor = bannerColor.cgColor
            //偏转30度
            boundsRotation = 30
        }
        else if backgroundColor != nil
        {
            layer?.backgroundColor = backgroundColor.cgColor
        }
//
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    
}
