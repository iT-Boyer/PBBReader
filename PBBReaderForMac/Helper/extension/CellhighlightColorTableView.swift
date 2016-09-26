//
//  CellhighlightColorTableView.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 16/9/1.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Cocoa

//控件ID设置：必须在storyboard中添加NSView控件，用该类代替实现，并且必须设置控件固定ID:NSTableViewRowViewKey
class CellhighlightColorTableView: NSTableRowView {
    
    
    @IBOutlet weak var ibaLeftLineImageView: NSImageView!
    
    override func drawSelectionInRect(dirtyRect:NSRect) {
        //
//        let primaryColor = NSColor.alternateSelectedControlColor().colorWithAlphaComponent(0.5)
        //选中时cell的背景色
        let primaryColor = NSColor.init(red: 225/255, green: 225/255, blue: 225/255, alpha: 1.0)
        let secondarySelectedControlColor = NSColor.secondarySelectedControlColor().colorWithAlphaComponent(0.5)
        //选中时的字体颜色
         
        
        // Implement our own custom alpha drawing
        switch self.selectionHighlightStyle {
        
        case .Regular:
            if self.selected {
                
//                ibaLeftLineImageView.hidden = false
                
                if self.emphasized
                {
                    primaryColor.set()
                }
                else
                {
                    secondarySelectedControlColor.set()
                }
                
                let bounds = self.bounds
                //http://stackoverflow.com/questions/32536855/using-getrectsbeingdrawn-with-swift
                var rects = UnsafePointer<NSRect>()
                var count = 0
                self.getRectsBeingDrawn(&rects, count: &count)
                for i in 0...count {
                    //
                    let rect = NSIntersectionRect(bounds, rects[i])
                    NSRectFillUsingOperation(rect, .CompositeSourceOver)
                }
            }
            
        default:
                // Do super's drawing
                super.drawSelectionInRect(dirtyRect)
        }
    }
    //单元格分割线
    override func drawSeparatorInRect(dirtyRect: NSRect) {
        var sepRect = self.bounds
        sepRect.origin.y = NSMaxY(sepRect) - 1
        sepRect.size.height = 1
        sepRect = NSIntersectionRect(sepRect, dirtyRect)
        if (!NSIsEmptyRect(sepRect)) {
//            NSColor.gridColor().set()
            NSColor.redColor().set()
            NSRectFill(sepRect)
        }
    }
}
