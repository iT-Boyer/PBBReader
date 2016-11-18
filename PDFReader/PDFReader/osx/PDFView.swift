//
//  PDFView.swift
//  PDFReader
//
//  Created by pengyucheng on 18/11/2016.
//  Copyright © 2016 PBBReader. All rights reserved.
//

import Cocoa
import AppKit
import QuartzCore.CALayer

class PDFView: NSView {

    var pdfPage:CGPDFPage!
    var myScale:CGFloat = 0.0
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        
    }

    

//    override init(frame frameRect: NSRect) {
//        //
//        
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func layer(_ layer: CALayer, shouldInheritContentsScale newScale: CGFloat, from window: NSWindow) -> Bool {
//        //
//    }

    
    func draw(_ layer: CALayer, in context: CGContext)
    {
//        NSLog(@"%s myScale:%f",__PRETTY_FUNCTION__,self.myScale);
        
        // Fill the background with white.
//        CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
        context.setFillColor(red: 1.0,green: 1.0,blue: 1.0,alpha: 1.0)
//        CGContextFillRect(context, self.bounds);
       
        context.fill(self.bounds);
        
        // Print a blank page and return if our page is null.
        if pdfPage == nil
        {
            return
        }
        
        context.saveGState();
        // Flip the context so that the PDF page is rendered right side up.
//        CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
//        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        // Scale the context so that the PDF page is rendered at the correct size for the zoom level.
        context.scaleBy(x: self.myScale, y: self.myScale);
        //    NSLog(@"%s myScale: %f, layer.bounds=%@",__PRETTY_FUNCTION__,self.myScale,NSStringFromCGRect(self.layer.bounds));
        CGContextDrawPDFPage(context, self.pdfPage);
        
        //=========重绘着色的核心代码==========
        if (self.selections)
        {
            CGContextSetFillColorWithColor(context, [[UIColor yellowColor] CGColor]);
            CGContextSetBlendMode(context, kCGBlendModeMultiply);
            for (Selection *s in self.selections)
            {
                CGContextSaveGState(context);
                CGContextConcatCTM(context, s.transform);
                CGContextFillRect(context, s.frame);
                CGContextRestoreGState(context);
            }
        }
        //=========重绘着色的核心代码==========
        CGContextRestoreGState(context);
    }
    
    
}
