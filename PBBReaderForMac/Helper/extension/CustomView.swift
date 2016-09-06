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
    
    override func awakeFromNib() {
        
        wantsLayer = true
        layer?.backgroundColor = backgroundColor.CGColor
        
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}
