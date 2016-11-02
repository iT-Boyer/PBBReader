import Foundation
import Cocoa

class subNSTableCell: NSCell {
    
    var cellBKColor:NSColor!
    var cellFontColor:NSColor!
    var cellAttributedString:NSAttributedString{
        let attributes = NSDictionary.init(dictionary: [NSForegroundColorAttributeName:cellFontColor])
        let cellString = self.stringValue
        
        return  NSAttributedString.init(string: cellString,attributes: attributes as? [String : AnyObject])
    }
    
    //
//    override func highlightColorWithFrame(cellFrame: NSRect, inView controlView: NSView) -> NSColor {
//        //
//        var newRect = NSMakeRect(cellFrame.origin.x - 1, cellFrame.origin.y, cellFrame.size.width + 5, cellFrame.size.height)
//        if ((cellBKColor) != nil)
//        {
//            cellBKColor.set()
//            NSRectFill(newRect)
//        }
//        return NSColor.blueColor()
//    }
}
