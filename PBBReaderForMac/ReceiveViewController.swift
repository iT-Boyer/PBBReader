//
//  ReceiveViewController.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 16/7/11.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Cocoa
import Toasty

let kGreen = NSColor.init(colorLiteralRed: 37.0 / 255.0, green: 170.0 / 255, blue: 70.0 / 255, alpha: 1.0)
let kGray =  NSColor.init(red: 58/255, green: 58/255, blue: 58/255, alpha: 1.0)
class ReceiveViewController: NSViewController{

    var receiveArray:NSMutableArray!
    var receiveFile:OutFile!
    var loginName = ""
    
    @IBOutlet weak var rootView: NSView!
    @IBOutlet weak var ibSeriesNameLabel: NSTextField!
    @IBOutlet weak var ibSeriesLabel: NSTextField!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var makerLabel: NSTextField!
    @IBOutlet weak var ibMakeTime: NSTextField!
     @IBOutlet weak var makerSayLabel: NSTextField!
    @IBOutlet weak var qqLabel: NSTextField!
    @IBOutlet weak var phoneLabel: NSTextField!
    @IBOutlet weak var emailLabel: NSTextField!
    @IBOutlet weak var ibNote: NSTextField!

    @IBOutlet weak var lastNumLabel: NSTextField!
    @IBOutlet weak var lastNumProgressView: NSProgressIndicator!
    
    @IBOutlet weak var lastDayLabel: NSTextField!
    @IBOutlet weak var lastDayProgressView: NSProgressIndicator!
    
    @IBOutlet weak var onceTimeNumLabel: NSTextField!
    @IBOutlet weak var onceTimeLabel: NSTextField!
    @IBOutlet weak var canTimeDateLabel: NSTextField!
    
    @IBOutlet weak var fileFlageImage: NSImageView!
    
    
    @IBOutlet weak var ReceiveTableView: NSTableView!
    

    @IBOutlet weak var readBtn: NSButton!
    @IBOutlet weak var ibOnceLong: NSView!
    @IBOutlet weak var ibOpenInLocalFileButtion: NSButton!
    
    @IBOutlet weak var ibRefreshFileButton: CustomRotateButton!
    
    @IBOutlet weak var makeTimeToTitleConstraint: NSLayoutConstraint!
    
    //必须声明为全局属性，否则在声明PycFile调用delegate时，delegate = nil
    //还出现第一次启动执行两次openFiles方法
    let appHelper = AppDelegateHelper.sharedAppDelegateHelper()
    
    //右击菜单
    @IBOutlet var cntxMnuTableView: NSMenu!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        loginName = userDao.shareduserDao().getLogName()
        receiveArray = ReceiveFileDao.sharedReceiveFileDao().selectReceiveFileAll(loginName)
        //设置浏览按钮字体颜色
        let attributedString = NSMutableAttributedString.init(attributedString: ibOpenInLocalFileButtion.attributedTitle)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: NSColor.whiteColor(), range: NSRange.init(location: 0, length: 12))
        ibOpenInLocalFileButtion.attributedTitle = attributedString
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ReceiveViewController.openInPBBFile(_:)), name: "RefreshOpenInFile", object: nil)
        
        ReceiveTableView.setDraggingSourceOperationMask(.Every, forLocal: false)
     
        //取消行与行之间蓝白交替显示的背景
//        ReceiveTableView.usesAlternatingRowBackgroundColors = false
        //显示背景色
        //ReceiveTableView.selectionHighlightStyle = .None //显示背景色 //.SourceList//去除背景色 //.Regular 显示背景色
        
        
        //更新列表选择第一条cell
        rootView.hidden = true
        performSelector(#selector(ReceiveViewController.refreshReceiveTableView(_:)), withObject:nil, afterDelay: 0.5)
//        refreshReceiveTableView(1)
    }
    
    override func viewDidAppear()
    {
        
    }
    
    //阅读按钮
    @IBAction func readBtn(sender: AnyObject) {
        if !NSFileManager.defaultManager().fileExistsAtPath(receiveFile.fileurl) {
            return
        }
        appHelper.phoneNo = ""
        appHelper.messageID = ""
        appHelper.loadVideoWithLocalFiles({receiveFile.fileurl}())
    }
    

    //浏览按钮
    @IBAction func ibaBrowseFinder(sender: AnyObject) {
        let panel = NSOpenPanel()
        panel.message = ""
        panel.prompt = "打开"
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        var path_all = ""
        let result = panel.runModal()
        if result == NSFileHandlingPanelOKButton {
            //
            path_all = (panel.URL?.path!)!
            print("文件路径：\(path_all)")
            appHelper.phoneNo = ""
            appHelper.messageID = ""
            appHelper.loadVideoWithLocalFiles({path_all}())
        }
        
    }
    
    //删除该文件
    @IBAction func ibaDeleteFileData(sender: AnyObject) {
        mnuRemoveRowSelected(sender)
    }
    
    //刷新该文件
    @IBAction func ibaRefreshFileData(sender: AnyObject) {
        
        if NSUserDefaults.standardUserDefaults().boolForKey("\(receiveFile.fileid)")
        {
            //当前处于刷新状态
            return
        }
        appHelper.phoneNo = ""
        appHelper.messageID = ""
        appHelper.getFileInfoById(receiveFile.fileid, pbbFile: "\(receiveFile.filename).pbb", pycFile: receiveFile.fileurl, fileType: 1)
        
        //开始刷新动画
        ibRefreshFileButton.addGroupRotateAnimation(receiveFile.fileid)
    }
    
    //MARK: 通知处理事件 更新主页
    func openInPBBFile(notification:NSNotification){
        
        let fileID = notification.userInfo!["pycFileID"] as! Int
        
        //停止刷新动画
        ibRefreshFileButton.layer?.removeAllAnimations()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "\(fileID)")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        // Make a copy of default style.
        var style = Toasty.defaultStyle
        
        // Navigation bar is translucent so the view starts from under the bars. Set margin accordingly.
        style.margin.top = 0
        style.backgroundColor = NSColor.whiteColor()
        style.textColor = NSColor.blackColor()
        // Show our toast.
        rootView.showToastWithText("加载完成！", usingStyle: style)
        
        if receiveFile != nil && receiveFile.fileid == fileID
        {
            //当打开的文件是当前显示的文件，直接刷新详情
            receiveFile = ReceiveFileDao.sharedReceiveFileDao().fetchReceiveFileCellByFileId(fileID, logName: loginName)
            initThisView()
        }
        else
        {
            var isInset = true
            for pycFile in receiveArray as! Array<OutFile>
            {
                if(pycFile.fileid == fileID)
                {
                    //如果文件已在列表中，显示该文件的详情信息
                    isInset = false
                    let theRow = receiveArray.indexOfObject(pycFile)
                    //选中cell事件
                    ReceiveTableView.selectRowIndexes(NSIndexSet.init(index: theRow), byExtendingSelection: false)
                }
            }
            //新增文件
            if isInset
            {
                receiveFile = ReceiveFileDao.sharedReceiveFileDao().fetchReceiveFileCellByFileId(fileID, logName: loginName)
                insertNewRow(receiveFile)
            }
        }
    }
}

//MARK: UI
extension ReceiveViewController
{
    func initThisView()
    {
        rootView.hidden = false
        readBtn.enabled = true
        //refresh:YES 刷新
        let seriesName = SeriesDao.sharedSeriesDao().fetchSeriesNameFromSeriesId(receiveFile.seriesID)
        if ((seriesName as NSString).length == 0 || seriesName == "未分组文件")
        {
            ibSeriesNameLabel.hidden = true
            ibSeriesLabel.hidden = true
            makeTimeToTitleConstraint.constant = 10
        }
        else
        {
            ibSeriesNameLabel.hidden = true
            ibSeriesLabel.hidden = false
            makeTimeToTitleConstraint.constant = 41
//            ibSeriesNameLabel.stringValue = seriesName
            ibSeriesLabel.stringValue = "所属系列：\(seriesName)"
        }
        
        makerLabel.stringValue = "作者对你说："
        if (receiveFile.fileOwnerNick != "" && receiveFile.fileOwnerNick != nil)
        {
            makerLabel.stringValue = "作者 \(receiveFile.fileOwnerNick) 对你说："
        }
        
        ibMakeTime.stringValue = "制作时间：\(receiveFile.sendtime.dateString())"
        titleLabel.stringValue = receiveFile.filename
        
        if let qq = receiveFile.fileQQ
        {
            qqLabel.stringValue = qq
        }
        if let email = receiveFile.fileEmail
        {
            emailLabel.stringValue = email
        }
        if let phone = receiveFile.filePhone
        {
            phoneLabel.stringValue = phone
        }
        
        
        if (receiveFile.fileQQ == nil || receiveFile.fileQQ == "")
        {
            qqLabel.stringValue = "无"
        }
        
        if (receiveFile.fileEmail == nil || receiveFile.fileEmail == "")
        {
            emailLabel.stringValue = "无"
        }
        
        if (receiveFile.filePhone == nil || receiveFile.filePhone == "")
        {
            phoneLabel.stringValue = "无"
        }
        
        ibNote.stringValue = receiveFile.note
        
        //次数限制
        if (receiveFile.limitnum == 0)
        {
            self.lastNumProgressView.hidden = true
            lastNumLabel.stringValue = "不限制"
            lastNumLabel.textColor = kGreen
        }
        else
        {
            
            self.lastNumProgressView.hidden = false
            let lastNum = "\(receiveFile.lastnum)"
            let limitnum = "\(receiveFile.limitnum)"
            
            if (receiveFile.fileTimeType == 4)
            {
                lastNumLabel.attributedStringValue = NSMutableAttributedString.init(attributedString: NSAttributedString.init(string: "剩余\(lastNum)次，共 \(limitnum) 次"))
                lastNumLabel.AddColorText("剩余", AColor: kGray, AFont: nil)
                lastNumLabel.AddColorText("次，共", AColor: kGray, AFont: nil)
                lastNumLabel.AddColorText(" 次", AColor: kGray, AFont: nil)
                lastNumProgressView.doubleValue = (Double(receiveFile.lastnum) * 1.0) / Double(receiveFile.limitnum)
            }
            else
            {
                
                if (receiveFile.fileMakeType == 1)
                {
                    lastNumLabel.attributedStringValue = NSMutableAttributedString.init(attributedString: NSAttributedString.init(string: "剩余\(lastNum)次，共 \(limitnum) 次"))
                    lastNumLabel.AddColorText("剩余", AColor: kGray, AFont: nil)
                    lastNumLabel.AddColorText("次，共", AColor: kGray, AFont: nil)
                    lastNumLabel.AddColorText(" 次", AColor: kGray, AFont: nil)
                    lastNumProgressView.doubleValue = (Double(receiveFile.lastnum) * 1.0) / Double(receiveFile.limitnum)
                }else
                {
                    self.lastNumLabel.attributedStringValue = NSMutableAttributedString.init(attributedString: NSAttributedString.init(string: "共 \(limitnum) 次"))
                    lastNumLabel.AddColorText("共", AColor: kGray, AFont: nil)
                    lastNumLabel.AddColorText(" 次", AColor: kGray, AFont: nil)
                    lastNumProgressView.hidden = true
                }
            }
        }
        
        
        //每次能看
        if (receiveFile.limittime == 0) {
            
            if (receiveFile.fileMakeType == 0) {
                //hsg
                ibOnceLong.hidden = true
            }
            
        }else{
            let mm = receiveFile.limittime / 60;
            let ss = receiveFile.limittime % 60;
            if (mm == 0) {
                onceTimeLabel.attributedStringValue = NSMutableAttributedString.init(attributedString: NSAttributedString.init(string: "\(ss) 秒"))
                onceTimeLabel.AddColorText("秒", AColor: NSColor.blackColor(), AFont: nil)
            } else {
                if (ss == 0) {
                    onceTimeLabel.attributedStringValue =  NSMutableAttributedString.init(attributedString: NSAttributedString.init(string: "\(mm) 分钟"))
                    onceTimeLabel.AddColorText("分钟", AColor: NSColor.blackColor(), AFont: nil)
                }else{
                    onceTimeLabel.attributedStringValue = NSMutableAttributedString.init(attributedString: NSAttributedString.init(string: "\(mm)分\(ss)秒"))
                    onceTimeLabel.AddColorText("分", AColor: NSColor.blackColor(), AFont: nil)
                    onceTimeLabel.AddColorText("秒", AColor: NSColor.blackColor(), AFont: nil)
                }
            }
        }
        
        //天数限制
        if (!receiveFile.freetime){
            
            lastDayProgressView.hidden = true
            canTimeDateLabel.hidden = true
            lastDayLabel.stringValue = "不限制"
            lastDayLabel.AddColorText("不限制", AColor: kGreen, AFont: nil)
        }else {
            lastDayProgressView.hidden = false
            canTimeDateLabel.hidden = false
            let lastday = "\(receiveFile.lastday)"
            let allday = "\(receiveFile.allday)"
            lastDayLabel.attributedStringValue =  NSMutableAttributedString.init(attributedString: NSAttributedString.init(string: "剩余\(lastday)天，共 \(allday) 天"))
            lastDayLabel.AddColorText("剩余", AColor: kGray, AFont: nil)
            lastDayLabel.AddColorText("天，共", AColor: kGray, AFont: nil)
            lastDayLabel.AddColorText(" 天", AColor: kGray, AFont: nil)
            lastDayProgressView.doubleValue = (Double(receiveFile.lastday) * 1.0) / Double(receiveFile.allday)
            
            if let starttime = receiveFile.starttime,let endtime = receiveFile.endtime{
                canTimeDateLabel.stringValue = "从\(starttime.dateStringByDay())到\(endtime.dateStringByDay())"
            }
        }
        
        var str = ""
        if (receiveFile.fileMakeType == 0) {
            
            //手动激活
            makerSayLabel.hidden = true
            lastDayLabel.hidden = false
            //    nolimitDay.hidden = true
            
            receiveFile.firstOpenTime = ReceiveFileDao.sharedReceiveFileDao().selectReceiveFileFistOpenTimeByFileId(receiveFile.fileid)
            
            //首次阅读
            if (receiveFile.firstOpenTime == "" || receiveFile.firstOpenTime == nil) {
                onceTimeNumLabel.hidden = true
                onceTimeLabel.hidden = true
                ibOnceLong.hidden = true
            } else {
                onceTimeNumLabel.stringValue = "首次阅读:"
                onceTimeLabel.stringValue = receiveFile.firstOpenTime
            }
            
            let yearRemain = "\(receiveFile.fileYearRemain)"
            let dayRemain = "\(receiveFile.fileDayRemain)"
            let openYear = "\(receiveFile.fileOpenYear)"
            let openDay = "\(receiveFile.fileOpenDay)"
            
            
            let b_CanOpen = isCanOpen(receiveFile)
            if (b_CanOpen) {
                
                if (receiveFile.limitnum != 0)
                {
                    let lastNum = "\(receiveFile.lastnum)"
                    let limitnum = "\(receiveFile.limitnum)"
                    lastNumLabel.attributedStringValue = NSMutableAttributedString.init(string: "剩余\(lastNum)次，共 \(limitnum) 次")
                    lastNumLabel.AddColorText("剩余", AColor: kGray, AFont: nil)
                    lastNumLabel.AddColorText("次，共", AColor: kGray, AFont: nil)
                    lastNumLabel.AddColorText(" 次", AColor: kGray, AFont: nil)
                }
            }
            else
            {
                if (receiveFile.limitnum != 0){
                    
                    let lastNum = "\(receiveFile.lastnum)"
                    let limitnum = "\(receiveFile.limitnum)"
                    if (receiveFile.fileTimeType==4) {
                        lastNumLabel.attributedStringValue = NSMutableAttributedString.init(string: "剩余\(lastNum)次，共 \(limitnum) 次")
                    }else{
                        lastNumLabel.attributedStringValue = NSMutableAttributedString.init(string: "共 \(limitnum) 次")
                    }
                    lastNumLabel.AddColorText("剩余", AColor: kGray, AFont: nil)
                    lastNumLabel.AddColorText("次，共", AColor: kGray, AFont: nil)
                    lastNumLabel.AddColorText(" 次", AColor: kGray, AFont: nil)
                    lastNumLabel.AddColorText("共 ", AColor: kGray, AFont: nil)
                    
                }
            }
            
            if (receiveFile.fileTimeType==4) {
                lastDayProgressView.hidden = false
                canTimeDateLabel.hidden = false
                lastNumProgressView.hidden = false
            }else{
                if (receiveFile.fileOpenDay > 0){
                    if(b_CanOpen)//能打开
                    {
                        //当天数大于0
                        if(receiveFile.fileYearRemain > 0 && receiveFile.fileDayRemain>0)
                        {
                            lastDayLabel.attributedStringValue = NSMutableAttributedString.init(string: "剩余\(yearRemain)年\(dayRemain)天，共 \(openDay) 天")
                            lastDayLabel.AddColorText("剩余", AColor: kGray, AFont: nil)
                            lastDayLabel.AddColorText("天，共", AColor: kGray, AFont: nil)
                            lastDayLabel.AddColorText("年", AColor: kGray, AFont: nil)
                            lastDayLabel.AddColorText(" 天", AColor: kGray, AFont: nil)
                        }
                        else if(receiveFile.fileYearRemain > 0)
                        {
                            lastDayLabel.attributedStringValue = NSMutableAttributedString.init(string: "剩余\(yearRemain)年，共 \(openDay) 天")
                            lastDayLabel.AddColorText("剩余", AColor: kGray, AFont: nil)
                            lastDayLabel.AddColorText("年，共 ", AColor: kGray, AFont: nil)
                            lastDayLabel.AddColorText(" 天", AColor: kGray, AFont: nil)

                        }
                        else if(receiveFile.fileDayRemain > 0)
                        {
                            lastDayLabel.attributedStringValue = NSMutableAttributedString.init(string: "剩余\(dayRemain)天，共\(openDay) 天")
                            lastDayLabel.AddColorText("剩余", AColor: kGray, AFont: nil)
                            lastDayLabel.AddColorText("天，共", AColor: kGray, AFont: nil)
                            lastDayLabel.AddColorText(" 天", AColor: kGray, AFont: nil)
                            
                        }
                    }else{
                        //未激活
                        lastDayLabel.attributedStringValue = NSMutableAttributedString.init(string: "共\(openDay)天")
                        lastDayLabel.AddColorText("共", AColor: kGray, AFont: nil)
                        lastDayLabel.AddColorText("天", AColor: kGray, AFont: nil)
                        
                    }
                }else if(receiveFile.fileOpenYear > 0) {
                    
                    if(b_CanOpen)//能打开
                    {
                        //当年数大于0
                        if(receiveFile.fileYearRemain > 0 && receiveFile.fileDayRemain>0)
                        {
                            lastDayLabel.attributedStringValue = NSMutableAttributedString.init(string: "剩余\(yearRemain)年\(dayRemain)天，共 \(openYear) 年")
                            lastDayLabel.AddColorText("剩余", AColor: kGray, AFont: nil)
                            lastDayLabel.AddColorText("年", AColor: kGray, AFont: nil)
                            lastDayLabel.AddColorText("天，共 ", AColor: kGray, AFont: nil)
                            lastDayLabel.AddColorText(" 年", AColor: kGray, AFont: nil)
                        }
                        else if(receiveFile.fileYearRemain > 0)
                        {
                            lastDayLabel.attributedStringValue = NSMutableAttributedString.init(string: "剩余\(yearRemain)年，共 \(openYear) 年")
                            lastDayLabel.AddColorText("剩余", AColor: kGray, AFont: nil)
                            lastDayLabel.AddColorText("年，共 ", AColor: kGray, AFont: nil)
                            lastDayLabel.AddColorText(" 年", AColor: kGray, AFont: nil)
                        }
                        else if(receiveFile.fileDayRemain > 0)
                        {
                            lastDayLabel.attributedStringValue = NSMutableAttributedString.init(string: "剩余\(dayRemain)天，共 \(openYear) 年")
                            lastDayLabel.AddColorText("剩余", AColor: kGray, AFont: nil)
                            lastDayLabel.AddColorText("天，共 ", AColor: kGray, AFont: nil)
                            lastDayLabel.AddColorText(" 年", AColor: kGray, AFont: nil)
                        }
                    }
                    else{
                        //未激活
                        lastDayLabel.attributedStringValue = NSMutableAttributedString.init(string: "共 \(openYear) 年")
                        lastDayLabel.AddColorText("共 ", AColor: kGray, AFont: nil)
                        lastDayLabel.AddColorText(" 年", AColor: kGray, AFont: nil)
                    }
                }else{
                    lastDayLabel.attributedStringValue = NSMutableAttributedString.init(string: "不限制")
                }
                
                lastDayProgressView.hidden = true
                canTimeDateLabel.hidden = true
                lastNumProgressView.hidden = true
            }
            
            if(receiveFile.forbid == 1)  //已经激活
            {
                if (b_CanOpen)
                {
                    str = "send_icon_Detail";
                    if (receiveFile.readnum > 0) {
                        str = "send_icon_already_Detail"
                    }
                }else{
                    
                    if (receiveFile.readnum > 0) {
                        str = "send_after_file_Detail"
                    }else {
                        str = "send_icon_stop_Detail"
                    }
                }
            }else{
                str = "send_icon_stop_Detail"
            }
            
            if(b_CanOpen)//能读
            {
                readBtn.image = NSImage.init(named: "send_read")
            }else{
                readBtn.image = NSImage.init(named: "send_read_active")
            }
            
        }else{
            //自由传播刷新界面
            var str = ""
            if (receiveFile.open == 2) {
                
                str = "send_icon_stop_Detail";
                if (receiveFile.readnum > 0) {
                    str = "send_after_file_Detail";
                }
                readBtn.enabled = false
                readBtn.image = NSImage.init(named: "send_read_no")
                
            } else if (receiveFile.open == 1) {
                
                str = "send_icon_already_Detail";
                readBtn.enabled = true
                readBtn.image = NSImage.init(named: "send_read")
                
            } else if (receiveFile.open == 0) {
                
                str = "send_icon_Detail";
                readBtn.enabled = true
                readBtn.image = NSImage.init(named: "send_read")
                
            }
            if (receiveFile.forbid == 1) {
                //forbid: 1开放
                makerSayLabel.hidden = true
            }else{
                makerSayLabel.hidden = false
            }
            fileFlageImage.image = NSImage.init(named: str)
        }
        
        //限制条件是否可见
        if (!receiveFile.isEye) {
            //ibisEyeView.hidden = true
            readBtn.frame = CGRectMake(readBtn.frame.origin.x, 274, readBtn.frame.size.width, readBtn.frame.size.height);
        }
        
        if !NSFileManager.defaultManager().fileExistsAtPath(receiveFile.fileurl)
            || !appHelper.fileIsTypeOfVideo(receiveFile.filetype)
        {
            readBtn.image = NSImage.init(named: "send_read_no")
            readBtn.enabled = false
        }
        
        //刷新按钮根据阅读按钮状态保持一直
//        ibRefreshFileButton.enabled = readBtn.enabled
    }
    
    func isCanOpen(outFile:OutFile) -> Bool {
        var b_CanOpen = false
        if(outFile.forbid == 1){
            
            if(outFile.limitnum == 0 || outFile.readnum < outFile.limitnum)
            {
                b_CanOpen = true
            }
            
            if (b_CanOpen && ((outFile.fileOpenDay == 0 && outFile.fileOpenYear == 0) || outFile.fileDayRemain > 0 || outFile.fileYearRemain > 0))
            {
            }
            else
            {
                b_CanOpen = false
            }
        }
        return b_CanOpen
    }
}

extension ReceiveViewController:NSSplitViewDelegate
{
    //分屏大小变化
    func splitView(splitView: NSSplitView, constrainMaxCoordinate proposedMaximumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat
    {
        // Make sure the view on the right has at least 200 px wide
        return splitView.bounds.size.width - 240
    }
    
    func splitView(splitView: NSSplitView, constrainMinCoordinate proposedMinimumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat
    {
        return 240
    }
}


extension ReceiveViewController:NSTableViewDelegate,NSTableViewDataSource
{
    //MARK: tableView Delegate
    //单击单元格，显示详情信息
    func tableViewSelectionDidChange(notification: NSNotification) {
        
        if let receiveFile = selectedFileList(){
            self.receiveFile = ReceiveFileDao.sharedReceiveFileDao().fetchReceiveFileCellByFileId(receiveFile.fileid, logName: loginName)
            
            //刷新详情
            initThisView()
            
            //改变选中状态
            ChangeCellBySelectedStatus()
        }
    }
    
    //MARK: - Helper
    func selectedFileList() -> OutFile? {
        //
        let selectedRow = ReceiveTableView.selectedRow
        if(selectedRow >= 0 && receiveArray.count > selectedRow){
            return receiveArray[selectedRow] as? OutFile
        }
        return nil
    }
    
    //自定义单元格选中样式
    func ChangeCellBySelectedStatus() {
        //被选中的单元格
        guard let cellView = self.ReceiveTableView.viewAtColumn(0, row: ReceiveTableView.selectedRow, makeIfNecessary: true) as? CustomTableCellView
            else {
                return
            }
        
        //刷新按钮状态
        if NSUserDefaults.standardUserDefaults().boolForKey("\(receiveFile.fileid)")
        {
            //当前处于刷新状态
            ibRefreshFileButton.addGroupRotateAnimation(receiveFile.fileid)
        }
        else
        {
            //停止刷新动画
            ibRefreshFileButton.layer?.removeAllAnimations()
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "\(receiveFile.fileid)")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        // 判断本地文件ID是否和数据库中的id一致，否则更新状态
        //设置单元格字体样式
        if NSFileManager.defaultManager().fileExistsAtPath(receiveFile.fileurl)
        {
            ibRefreshFileButton.enabled = true
            
            let fileID = PycFile().getAttributePycFileId(receiveFile.fileurl)
            if fileID != Int32(receiveFile.fileid)
            {
                //
                //
                readBtn.image = NSImage.init(named: "send_read_no")
                readBtn.enabled = false
                cellView.textField?.textColor = NSColor.redColor()
                
                //提示本地文件错误
                // Make a copy of default style.
                var style = Toasty.defaultStyle
                // Navigation bar is translucent so the view starts from under the bars. Set margin accordingly.
                style.margin.top = 0
                style.backgroundColor = NSColor.whiteColor()
                style.textColor = NSColor.blackColor()
                // Show our toast.
                rootView.showToastWithText("信息与本地文件不符，建议删除该条无效信息！", usingStyle: style)
            }
        }
        else
        {
            ibRefreshFileButton.enabled = false
        }
        
        //发送通知，更新其他cell的状态
        cellView.SendBySelecedNotification(false)
        
    }
    
    //拖动鼠标多选响应事件
    func tableView(tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAtPoint screenPoint: NSPoint, forRowIndexes rowIndexes: NSIndexSet) {
        //
        
    }
    
    //MARK: tableDataSource
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        //
        if receiveArray != nil
        {
            return receiveArray.count
        }
        return 0
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        //http://blog.csdn.net/fengsh998/article/details/18809355
        let column = tableView.tableColumns[0]
        let dycell = tableView.preparedCellAtColumn(0, row: row)
        var cellBounds = NSZeroRect
        cellBounds.size.width = column.width
        cellBounds.size.height = CGFloat.max
        let cellSize = dycell!.cellSizeForBounds(cellBounds)
//        return cellSize.height
        return 30
    }
    
    func tableView(tableView: NSTableView, willDisplayCell cell: AnyObject, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        //        let cellw = cell as! SelectedRowHighlightCell
        //        cellw.setSelectionBKColor(NSColor.lightGrayColor())
//        if ([cell isKindOfClass:[FSCustomCell class]]) {
//            FSCustomCell *acell = cell;
//            acell.displayName.stringValue = @"kkkkk";
//            [acell setSelectionBKColor:[NSColor lightGrayColor]];
//            [acell setSelectionFontColor:[NSColor redColor]];
//            //NSLog(@"调用顺序3");
//            //[tableColumn setDataCell:acell];
//        }
        
//        if (cell as? FSCustomCell) != nil
//        {
//           let customcell = cell as! FSCustomCell
//            customcell.setSelectionBKColor(NSColor.lightGrayColor())
//            customcell.setSelectionFontColor(NSColor.blackColor())
//        }
        
    }
    
    //初始化单元格状态信息
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        //
        // Get a new ViewCell
        let cellView = tableView.makeViewWithIdentifier((tableColumn?.identifier)!, owner: self) as! CustomTableCellView
        
        // Since this is a single-column table view, this would not be necessary.
        // But it's a good practice to do it in order by remember it when a table is multicolumn.
        if tableColumn?.identifier == "ReceiveColumn" {
            
            let ReceiveColumn = self.receiveArray[row] as! OutFile
            cellView.cellID = ReceiveColumn.fileid
            cellView.textField?.stringValue = ReceiveColumn.filename
            
            //设置单元格字体样式
            if NSFileManager.defaultManager().fileExistsAtPath(ReceiveColumn.fileurl)
            {
                //原文件存在
                cellView.textField?.textColor = kGray
                //不支持文件格式
                if !appHelper.fileIsTypeOfVideo(ReceiveColumn.filetype)
                {
//                    cellView.textField?.textColor = NSColor.grayColor()
                }
                
                //不能看
                if !isCanOpen(ReceiveColumn)
                {
//                    cellView.textField?.textColor = NSColor.grayColor()
                }
            }
            else
            {
                //原文件不存在
                cellView.textField?.textColor = NSColor.redColor()
            }
            return cellView
        }
        return cellView
    }
    
    //MARK: 右击事件
    //https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/TableView/RowSelection/RowSelection.html#//apple_ref/doc/uid/10000026i-CH6-SW1
    func indexesToProcessForContextMenu() -> NSIndexSet {
        // If the clicked row was in the selectedIndexes, then we process all selectedIndexes. Otherwise, we process just the clickedRow
        var selectedIndexes = ReceiveTableView.selectedRowIndexes
        if (ReceiveTableView.clickedRow != -1 && !selectedIndexes.containsIndex(ReceiveTableView.clickedRow)) {
            //
            selectedIndexes = NSIndexSet.init(index:ReceiveTableView.clickedRow)
        }
        selectedIndexes.enumerateIndexesUsingBlock { (row, stop) in
            //
            guard let cellView = self.ReceiveTableView.viewAtColumn(0, row: row, makeIfNecessary: false) as? CustomTableCellView
                else{
                    return
                }
            
            cellView.SendBySelecedNotification(true)
            
        }
        
        return selectedIndexes
    }
    
    //右击菜单在Finder中显示功能
    @IBAction func mnuRevealInFinderSelected(sender: AnyObject) {
        let selectedIndexes = indexesToProcessForContextMenu()
        selectedIndexes.enumerateIndexesUsingBlock { (row, stop) in
            //
            let ReceiveColumn = self.receiveArray[row] as! OutFile
            NSWorkspace.sharedWorkspace().selectFile(ReceiveColumn.fileurl, inFileViewerRootedAtPath: "")
        }
    }
    
    //右击菜单删除功能
    @IBAction func mnuRemoveRowSelected(sender: AnyObject) {
        
        let selectedIndexes = indexesToProcessForContextMenu()
        selectedIndexes.enumerateIndexesUsingBlock { (row, stop) in
            //
            let ReceiveColumn = self.receiveArray[row] as! OutFile
            ReceiveFileDao.sharedReceiveFileDao().deleteReceiveFile(ReceiveColumn.fileid, logName: self.loginName)
            
            //删除文件
            //try! NSFileManager.defaultManager().removeItemAtPath(ReceiveColumn.fileurl)
            //删除广告
            let uid = ReceiveFileDao.sharedReceiveFileDao().fetchUid(ReceiveColumn.fileid)
            if(ReceiveFileDao.sharedReceiveFileDao().fetchCountOfUid(ReceiveColumn.fileid) == 0)
            {
                let fileDir = SandboxFile.CreateList(SandboxFile.GetDocumentPath(), listName: "advert")
                let pre = NSPredicate.init(format: "SELF contains[cd] '\(uid)'", argumentArray: nil)
                let filesNames = SandboxFile.GetSubpathsAtPath(fileDir)
                let oldFiles = (filesNames as NSArray).filteredArrayUsingPredicate(pre) as NSArray
                oldFiles.enumerateObjectsUsingBlock({ (obj, idx, stop) in
                    //
                    let oldfile = "\(fileDir)/\(obj))"
                    if(SandboxFile.IsFileExists(oldfile)){
                        //                        try! NSFileManager.defaultManager().removeItemAtPath(oldfile)
                    }
                })
            }
        }
        //从列表中移除所选项
        self.ReceiveTableView.beginUpdates()
        self.receiveArray.removeObjectsAtIndexes(selectedIndexes)
        self.ReceiveTableView.removeRowsAtIndexes(selectedIndexes, withAnimation: .EffectFade)
        self.ReceiveTableView.endUpdates()
        //显示下一个文件详情
        self.selectRowStartingAtRow(selectedIndexes.firstIndex - 1)
        self.initThisView()
    }
    
    //右击刷新功能
    @IBAction @objc func refreshReceiveTableView(sender:AnyObject){
        receiveArray = nil
        receiveArray = ReceiveFileDao.sharedReceiveFileDao().selectReceiveFileAll(loginName)
        ReceiveTableView.reloadData()
    }
    
    //移动单元格 从 - 到 -
    @IBAction func btnMoveRowClick(sender:AnyObject) {
        //
        let fromRow = 1
        let toRow = 3
        ReceiveTableView.beginUpdates()
        ReceiveTableView.moveRowAtIndex(fromRow, toIndex: toRow)
        let object = receiveArray[fromRow]
        receiveArray.removeObjectAtIndex(fromRow)
        receiveArray.insertObject(object, atIndex: toRow)
        ReceiveTableView.endUpdates()
    }
    
    //双击打开文件
    @IBAction func tblvwDoubleClick(sender:AnyObject)
    {
        if(!readBtn.enabled)
        {
            //提示本地文件错误
            // Make a copy of default style.
            var style = Toasty.defaultStyle
            // Navigation bar is translucent so the view starts from under the bars. Set margin accordingly.
            style.margin.top = 0
            style.backgroundColor = NSColor.whiteColor()
            style.textColor = NSColor.blackColor()
            // Show our toast.
            rootView.showToastWithText("该文件无法阅读！", usingStyle: style)
            return
        }
        let row = ReceiveTableView.selectedRow
        if row != -1 {
            //
            let ReceiveColumn = self.receiveArray[row] as! OutFile
            
            if !NSFileManager.defaultManager().fileExistsAtPath(ReceiveColumn.fileurl)
            {
                //提示本地文件错误
                // Make a copy of default style.
                var style = Toasty.defaultStyle
                // Navigation bar is translucent so the view starts from under the bars. Set margin accordingly.
                style.margin.top = 0
                style.backgroundColor = NSColor.whiteColor()
                style.textColor = NSColor.blackColor()
                // Show our toast.
                rootView.showToastWithText("该文件无法阅读！", usingStyle: style)
                return;
            }
            //            NSWorkspace.sharedWorkspace().selectFile(ReceiveColumn.fileurl, inFileViewerRootedAtPath: "")
            appHelper.phoneNo = ""
            appHelper.messageID = ""
            appHelper.loadVideoWithLocalFiles({ReceiveColumn.fileurl}())
            
        }
    }
    
    //删除后，显示相邻的下一行
    func selectRowStartingAtRow(row:Int)
    {
        var theRow = row
        if ReceiveTableView.selectedRow == -1 {
            //
            if theRow == -1{
                theRow = 0
            }
            // Select the same or next row (if possible) but skip group rows
            while theRow < ReceiveTableView.numberOfRows {
                //
                if !self.tableView(ReceiveTableView, isGroupRow:theRow) {
                    //
                    ReceiveTableView.selectRowIndexes(NSIndexSet.init(index: theRow), byExtendingSelection: false)
                    return
                }
                theRow += 1
            }
            
            theRow = ReceiveTableView.numberOfRows - 1
            while theRow >= 0 {
                //
                if !tableView(ReceiveTableView, isGroupRow: theRow) {
                    //
                    ReceiveTableView.selectRowIndexes(NSIndexSet.init(index: theRow), byExtendingSelection: false)
                    return
                }
                theRow -= 1
            }
        }
    }
    
    // We want to make "group rows" for the folders
    func tableView(tableView: NSTableView, isGroupRow row: Int) -> Bool {
        //
        if receiveArray[row] is SeriesModel{
            return true
        }else{
            return false
        }
    }
    
    //插入新cell
    func insertNewRow(file:OutFile){
        var index = ReceiveTableView.selectedRow
        if index == -1 {
            //
            if ReceiveTableView.numberOfRows == 0 {
                //
                index = 0
            }else{
                index = 1
            }
        }
        //更新列表
        receiveArray.insertObject(file, atIndex: index)
        ReceiveTableView.beginUpdates()
        ReceiveTableView.insertRowsAtIndexes(NSIndexSet.init(index: index), withAnimation: .EffectFade)
        ReceiveTableView.scrollRowToVisible(index)
        ReceiveTableView.endUpdates()
        //更新详情页面
        ReceiveTableView.selectRowIndexes(NSIndexSet.init(index: index), byExtendingSelection: false)
    }
}