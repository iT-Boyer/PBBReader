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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
//        _pdfDocument = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"Manual1.pdf"];
        let path = Bundle.main.resourcePath?.appending("/Manual1.pdf")
        //必须使用fileURL
        let pdfUrl = URL.init(fileURLWithPath: path!)
        let doc = PDFDocument.init(url:pdfUrl)!
        ibPDFView.document = doc
    }
}
