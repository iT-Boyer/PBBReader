//
//  MasterViewController.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 16/5/23.
//  Copyright © 2016年 recomend. All rights reserved.
//

import AppKit
import EDStarRating
import Quartz

class MasterViewController: NSViewController,NSTableViewDelegate,NSTableViewDataSource,EDStarRatingProtocol {

    var bugs:Array<ScaryBugDoc>!

    
    @IBOutlet weak var bugsTableView: NSTableView!
    
    @IBOutlet weak var bugTitleView: NSTextField!
    
    @IBOutlet weak var bugImageView: NSImageView!
    
    @IBOutlet weak var bugRating: EDStarRating!
    
    
    @IBOutlet weak var ibAddBug: NSButton!
    
    @IBOutlet weak var ibDeleteBug: NSButton!
    
    @IBOutlet weak var ibChagePicture: NSButton!
    
    //MARK: 生命周期
    override func viewDidLoad() {
        
        //获取数据
        bugs = ScaryBugDoc.getSampleData()
        
        
    }
    
    
    override func loadView() {
        //
        super.loadView()
        
        self.bugRating.starImage = NSImage.init(named: "star")
        self.bugRating.starHighlightedImage = NSImage.init(named: "shockedface2_full")
        self.bugRating.starImage = NSImage.init(named: "shockedface2_empty")
        self.bugRating.maxRating = 5
        self.bugRating.delegate = self as EDStarRatingProtocol
        self.bugRating.horizontalMargin = 12
        self.bugRating.displayMode = UInt(EDStarRatingDisplayFull)
        //rating能否编辑控制属性,等同于View属性User Interaction Enabled
        self.bugRating.editable = true
        
        self.bugRating.rating = 0.0
    }
    
    //MARK: - tableView
    //MARK:DataSource
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return bugs.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Get a new ViewCell
        let cellView = tableView.make(withIdentifier: (tableColumn?.identifier)!, owner: self) as! NSTableCellView
        
        // Since this is a single-column table view, this would not be necessary.
        // But it's a good practice to do it in order by remember it when a table is multicolumn.
        if tableColumn?.identifier == "BugColumn" {
            //
            let bugDoc = self.bugs[row]
            cellView.imageView?.image = bugDoc.thumbImage
            cellView.textField?.stringValue = bugDoc.data.title
            return cellView
        }
        
        return cellView
    }
    
    //MARK: Delegate
    func tableViewSelectionDidChange(notification: Notification) {
        //
        if let bugDoc = selectedBugDoc(){
            setDetailInfo(bugDoc: bugDoc)
            // Enable/Disable buttons based on selection
            ibAddBug.isEnabled = true
            ibDeleteBug.isEnabled = true
            ibChagePicture.isEnabled = true
            bugTitleView.isEnabled = true
        }
    }
    
    //MARK: - Helper
    //MARK:  Row
    func selectedBugDoc() -> ScaryBugDoc? {
        //
        let selectedRow = bugsTableView.selectedRow
        if(selectedRow >= 0 && bugs.count > selectedRow){
        
            return bugs[selectedRow]
        }
        return nil
    }
    //MARK: update Detail Info
    func setDetailInfo(bugDoc:ScaryBugDoc!) {
        //
        var title = ""
        var image:NSImage = NSImage.init()
        var rating:Float = 0
        if(bugDoc != nil){
            //
            title = bugDoc.data.title
            image = bugDoc.fullImage
            rating = bugDoc.data.rating
        }
        bugTitleView.stringValue = title
        bugImageView.image = image
        bugRating.rating = rating
    }
    
    //MARK: - EDStrarRating delegate
    //前提bugRating.editablerating = true 必须设置为true
    func starsSelectionChanged(control: EDStarRating!, rating: Float) {
        
        if let selectedBug = selectedBugDoc(){
            selectedBug.data.rating = self.bugRating.rating
        }
    }
    
    //MARK: - IBAction
    //MARK: TextField action
    @IBAction func bugTitleDidEndEdit(sender: AnyObject) {
        
        // 1. Get selected bug
        if let selectedBug = selectedBugDoc(){
            
            // 2. Get the new name from the text field
            selectedBug.data.title = bugTitleView.stringValue
            
            // 3. Update the cell
            let index = (bugs as NSArray).index(of: selectedBug)
            let indexSet = NSIndexSet.init(index: index)
            let columnIndexSet = NSIndexSet.init(index: 0)
            bugsTableView.reloadData(forRowIndexes: indexSet as IndexSet, columnIndexes: columnIndexSet as IndexSet)
        }
    }
    //MARK: add Button
    @IBAction func addBug(sender: AnyObject) {
        //
        // 1. Create a new ScaryBugDoc object with a default name
        let bugDoc = ScaryBugDoc.init(title: "", rating: 2, thumbImage: NSImage.init(named: "centipedeThumb")!, fullImage: NSImage.init(named: "centipede")!)
        
        // 2. Add the new bug object to our model (insert into the array)
        bugs.append(bugDoc)
        let newRowIndex = bugs.count - 1
        // 3. Insert new row in the table view
        bugsTableView.insertRows(at: NSIndexSet.init(index: newRowIndex) as IndexSet, withAnimation: .slideRight)
        
        // 4. Select the new bug and scroll to make sure it's visible
        bugsTableView.selectRowIndexes(NSIndexSet.init(index: newRowIndex) as IndexSet, byExtendingSelection: false)
        bugsTableView.scrollRowToVisible(newRowIndex)
    }
    //MARK: delete Button
    @IBAction func deleteBug(sender: AnyObject) {
        
        // 1. Get selected doc
        let selectedBug = selectedBugDoc()
        
        // 2. Remove the bug from the model
        if(selectedBug != nil){
            
            // let index = try! bugs.index
            bugs.removeObject(selectedBug!)
        }
        
        // 3. Remove the selected row from the table view.
        bugsTableView.removeRows(at: NSIndexSet.init(index: bugsTableView.selectedRow) as IndexSet, withAnimation: .slideRight)
        
        // Clear detail info
        setDetailInfo(bugDoc: nil)
        
    }
    
    //MARK: Change Picture Button
    @IBAction func ChangePicture(sender: AnyObject) {
        //create a shared instance by calling the pictureTaker method of the IKPictureTaker class
        let pictureTaker = IKPictureTaker.pictureTaker()
        
        //launch the picture taker as a standalone window using this method
        pictureTaker?.beginPictureTakerSheetForWindow(self.view.window,
                                                     withDelegate: self,
                                                     didEndSelector: #selector(MasterViewController.pictureTakerDidEnd(_:returnCode:contextInfo:)),
                                                     contextInfo: nil)
        
        //
    }
    
    //MARK: - Picture Taker Action
    func pictureTakerDidEnd(sheet:IKPictureTaker,returnCode:Int,contextInfo:UnsafeMutablePointer<Void>) {
        //
        guard let image = sheet.outputImage()
        else{
            return
        }
        if returnCode == NSModalResponseOK {
            //
            bugImageView.image = image
            //更新cell缩略图
            if let selectedBug = selectedBugDoc(){
                selectedBug.fullImage = image
                selectedBug.thumbImage = image.scalingAndCropping(for: CGSizeMake(44, 44))
                let index = (bugs as NSArray).index(of: selectedBug)
                let indexSet = NSIndexSet.init(index: index)
                let columset = NSIndexSet.init(index: 0)
                bugsTableView.reloadDataForRowIndexes(indexSet, columnIndexes: columset)
            }
            
        }
        
    }
    
}


