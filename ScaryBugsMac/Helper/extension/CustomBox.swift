//
//  CustomBox.swift
//  ScaryBugsMac
//
//  Created by pengyucheng on 16/9/1.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Cocoa

@IBDesignable
class CustomBox: NSBox {


    @IBInspectable var theFillColor:NSColor!
    @IBInspectable var theBorderColor:NSColor!
    
    override func awakeFromNib() {
        //
        fillColor = theFillColor
        borderColor = theBorderColor
    }
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
        
    }
    
}
