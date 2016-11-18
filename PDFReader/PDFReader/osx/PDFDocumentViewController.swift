//
//  PDFDocumentViewController.swift
//  PDFReader
//
//  Created by pengyucheng on 18/11/2016.
//  Copyright © 2016 PBBReader. All rights reserved.
//

import Cocoa
import AppKit
import Quartz

class PDFDocumentViewController: NSViewController {

    @IBOutlet var ibPDFView:PDFView!
    
    @IBOutlet weak var ibPDFOutLineView: NSOutlineView!
    var outline:PDFOutline!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
//        _pdfDocument = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"Manual1.pdf"];
        let path = Bundle.main.resourcePath?.appending("/Manual1.pdf")
        //必须使用fileURL
        let pdfUrl = URL.init(fileURLWithPath: path!)
        let doc = PDFDocument.init(url:pdfUrl)!
        ibPDFView.document = doc
        //outline即为数据源
        outline = ibPDFView.document?.outlineRoot
    }
    
}

extension PDFDocumentViewController:NSOutlineViewDelegate,NSOutlineViewDataSource
{
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
    {
        if (item == nil)
        {
            if outline != nil {
                return outline.numberOfChildren
            }else
            {
                return 0
            }
        }else
        {
            return (item as! PDFOutline).numberOfChildren
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
    {
        //
        if item == nil
        {
            if outline != nil
            {
                return outline.child(at: index)
            }
            else
            {
                return Any.self
            }
        }
        else
        {
            return (item as! PDFOutline).child(at: index)
        }
    }
    
//    Delegate method for determining if an element has children
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
    {
        if item == nil
        {
            //
            if outline != nil
            {
                return (outline.numberOfChildren > 0)
            }
            else
            {
                return false
            }
        }
        else
        {
            return (item as! PDFOutline).numberOfChildren > 0
        }
    }
    
    //Delegate method for obtaining an element’s contents
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any?
    {
        //目录名
        NSLog("目录名:\((item as! PDFOutline).label!)")
        return (item as! PDFOutline).label!
    }
    

    
    
    
    
    
    
    
    
    
    
    
    
    // Displaying the page associated with an outline element
    @IBAction func takeDestinationFromOutline(sender:Any)
    {
//        [[sender itemAtRow:[sender selectedRow]] destination]
        //TODO:未知对象
        let destination = ibPDFOutLineView.item(atRow: ibPDFOutLineView.selectedRow)
//        ibPDFView.go(to: destination)
    }
    
//     Updating the outline when the page changes
}
