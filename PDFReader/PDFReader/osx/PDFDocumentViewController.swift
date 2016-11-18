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
    var searchResults:NSMutableArray!
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
        
        //当pdfview页面发生变化，会发送更新ouline目录的通知
        NotificationCenter.default.addObserver(self, selector: #selector(PDFDocumentViewController.pageChanged(_:)), name: NSNotification.Name.PDFViewPageChanged, object: nil)
        
        //支持搜索
        ibPDFView.document?.delegate = self
        
    }
    
    @IBAction func takeDestinationFromOutline(_ sender: Any) {
        //TODO:未知对象
        let destination = ((sender as AnyObject).item(atRow: ibPDFOutLineView.selectedRow) as! PDFOutline).destination
        NSLog("选择目录跳转：\(destination)")
        
        ibPDFView.go(to: destination!)
    }
    
    
    //    func funt() {
    //        //
    //        ibPDFView.document?.findString(<#T##string: String##String#>, from: <#T##PDFSelection?#>, withOptions: <#T##Int#>)
    //    }
    
    func doFind(sender:Any)
    {
        //Cancels any current searches.
        if (ibPDFView.document?.isFinding)!
        {
            ibPDFView.document?.cancelFindString()
        }
        //Allocates a mutable array to hold the search results if one does not already exist.
        if searchResults == nil
        {
            //
            searchResults = NSMutableArray.init(capacity: 10)
        }
        //Calls the PDFDocument method beginFindString:withOptions: with the desired search string.
//        ibPDFView.document?.beginFind((sender as! NSTextField).stringValue, withOptions: NSFindPanelCaseInsensitiveSearch)
        
    }
    
    
    override func didMatchString(_ instance: PDFSelection) {
        //
        // Add page label to our array.
//        [_searchResults addObject: [instance copy]];
        searchResults.add(instance.copy())
        
        // Force a reload.
//        [_searchTable reloadData];
        
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
//        NSLog("目录名:\((item as! PDFOutline).label!)")
        return (item as! PDFOutline).label!
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification)
    {
//        ibPDFOutLineView.item(atRow: i) as! PDFOutline!
        let destination = (ibPDFOutLineView.item(atRow: ibPDFOutLineView.selectedRow) as! PDFOutline).destination
//        NSLog("选择目录跳转：\(destination)")
        
        ibPDFView.go(to: destination!)
    }
    
//    scroll
    
    //NSNotification.Name.PDFViewPageChanged 
    //Updating the outline when the page changes
    func pageChanged(_ notification:Notification)
    {
        var newPageIndex = 0
        var numRows = 0
        var newlySelectedRow = 0
        //1. Checks to see if a root outline exists. If not, then there is no outline to update, so simply return.
        if outline == nil {
            return
        }
        //2. Obtains the index value for the current page.
        //The PDFView method currentPage returns the PDFPage object, and the PDFDocument method indexForPage returns the actual index for that page. This index value is zero-based, so it doesn’t necessarily correspond to a page number.
        newPageIndex = (ibPDFView.document?.index(for: ibPDFView.currentPage!))!
        newlySelectedRow = -1
        numRows = ibPDFOutLineView.numberOfRows
        //3. Iterate through each visible element in the outline, checking to see if one of the following occurs:
        for i in 0...numRows {
            //
            var outlineItem:PDFOutline!
            outlineItem = ibPDFOutLineView.item(atRow: i) as! PDFOutline!
            if outlineItem == nil {
                //
                break
            }
            let destinnationPageIndex = ibPDFView.document?.index(for: (outlineItem.destination?.page)!)
            if destinnationPageIndex == newPageIndex
            {
                //The index of an outline element matches the index of the new page. 
                //If so, highlight this element (using the NSTableView method selectRow:byExtendingSelection).
                newlySelectedRow = i
                ibPDFOutLineView.selectRowIndexes(IndexSet.init(integer: newlySelectedRow), byExtendingSelection: false)
                break
            }
            else if destinnationPageIndex! > newPageIndex
            {
                //The index of the outline element is larger than the index of the page. If so, a match was not possible as the index corresponds to a hidden child of a visible element. In this case, use selectRow to highlight the parent outline element (the current row -1 ).
                newlySelectedRow = i - 1
                ibPDFOutLineView.selectRowIndexes(IndexSet.init(integer: newlySelectedRow), byExtendingSelection: false)
                break
            }
        }
        if newlySelectedRow != -1 {
            //4. Call the NSTableView method scrollRowToVisible to adjust the outline view (if necessary) to make the highlighted element visible.
            ibPDFOutLineView.scrollRowToVisible(newlySelectedRow)
        }
    }
    
}

