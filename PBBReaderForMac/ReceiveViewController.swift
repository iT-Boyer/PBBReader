//
//  ReceiveViewController.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 16/7/11.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Cocoa
import Toasty
import Crashlytics

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
    let appHelper = AppDelegateHelper.shared()
    
    //右击菜单
    @IBOutlet var cntxMnuTableView: NSMenu!

    override func viewDidLoad() {
        super.viewDidLoad()
        CLSLogv("Log awesomeness %d %d %@", getVaList([1, 2, "three"]))
        // Do view setup here.
        loginName = userDao.shareduser().getLogName()
        receiveArray = ReceiveFileDao.shared().selectReceiveFileAll(loginName)
        //设置浏览按钮字体颜色
        let attributedString = NSMutableAttributedString.init(attributedString: ibOpenInLocalFileButtion.attributedTitle)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: NSColor.white, range: NSRange.init(location: 0, length: ibOpenInLocalFileButtion.title.utf16.count))
        ibOpenInLocalFileButtion.attributedTitle = attributedString
        //阅读按钮设置字体颜色
        let readtext = NSMutableAttributedString.init(attributedString:readBtn.attributedTitle)
        readtext.addAttribute(NSForegroundColorAttributeName, value: NSColor.white, range: NSRange(location:0,length:readBtn.title.utf16.count))
        readBtn.attributedTitle = readtext
        
        NotificationCenter.default.addObserver(self, selector: #selector(ReceiveViewController.openInPBBFile(_:)), name: NSNotification.Name("RefreshOpenInFile"), object: nil)
        
        ReceiveTableView.setDraggingSourceOperationMask(.every, forLocal: false)
     
        //取消行与行之间蓝白交替显示的背景
//        ReceiveTableView.usesAlternatingRowBackgroundColors = false
        //显示背景色
        //ReceiveTableView.selectionHighlightStyle = .None //显示背景色 //.SourceList//去除背景色 //.Regular 显示背景色
        
        
        //更新列表选择第一条cell
        rootView.isHidden = true
        perform(#selector(ReceiveViewController.refreshReceiveTableView(_:)), with:nil, afterDelay: 0.5)
//        refreshReceiveTableView(1)
    }
    
    override func viewDidAppear()
    {
        let KDataBasePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        if !FileManager.default.fileExists(atPath: KDataBasePath.appending("PBB.db"))
        {
            refreshReceiveTableView(1 as AnyObject)
        }
        
        ReceiveTableView.backgroundColor = NSColor.init(patternImage: NSImage(named:"tablebackground")!)
    }
    
    //阅读按钮
    @IBAction func readBtn(_ sender: AnyObject) {
        if !FileManager.default.fileExists(atPath: receiveFile.fileurl)
        {
            return
        }
        appHelper?.phoneNo = ""
        appHelper?.messageID = ""
        appHelper?.loadVideo(withLocalFiles: {receiveFile.fileurl}())
    }
    

    //浏览按钮
    @IBAction func ibaBrowseFinder(_ sender: AnyObject) {
//        Crashlytics.sharedInstance().crash()
        
        let panel = NSOpenPanel()
        
        panel.message = ""
        panel.prompt = "打开"
        panel.canChooseDirectories = true
        //文件可选
        panel.canChooseFiles = true
        //文件可以多选
        panel.allowsMultipleSelection = false
        //可选文件类型
        panel.allowedFileTypes = ["pbb"]
        
        var path_all = ""
        let result = panel.runModal()
        if result == NSFileHandlingPanelOKButton {
            //
            path_all = (panel.url?.path)!
            appHelper?.phoneNo = ""
            appHelper?.messageID = ""
            appHelper?.loadVideo(withLocalFiles: {path_all}())
        }
    }
    
    //删除该文件
    @IBAction func ibaDeleteFileData(_ sender: AnyObject) {
        mnuRemoveRowSelected(sender)
    }
    
    //刷新该文件
    @IBAction func ibaRefreshFileData(_ sender: AnyObject) {
        
        if UserDefaults.standard.bool(forKey: "\(receiveFile.fileid)")
        {
            //当前处于刷新状态
            return
        }
        appHelper?.phoneNo = ""
        appHelper?.messageID = ""
        appHelper?.getFileInfo(byId: receiveFile.fileid, pbbFile: "\(receiveFile.filename).pbb", pycFile: receiveFile.fileurl, fileType: 1)
        
        //开始刷新动画
        ibRefreshFileButton.addGroupRotateAnimation(receiveFile.fileid)
    }
    
    //MARK: 通知处理事件 更新主页
    func openInPBBFile(_ notification:Notification){
        
        let fileID = (notification as NSNotification).userInfo!["pycFileID"] as! Int
        
        //停止刷新动画
        ibRefreshFileButton.layer?.removeAllAnimations()
        UserDefaults.standard.set(false, forKey: "\(fileID)")
        UserDefaults.standard.synchronize()
        
        // Make a copy of default style.
        var style = Toasty.defaultStyle
        
        // Navigation bar is translucent so the view starts from under the bars. Set margin accordingly.
        style.margin.top = 0
        style.backgroundColor = NSColor.white
        style.textColor = NSColor.black
        // Show our toast.
        rootView.showToastWithText("加载完成！", usingStyle: style)
        
        if receiveFile != nil && receiveFile.fileid == fileID
        {
            //当打开的文件是当前显示的文件，直接刷新详情
            receiveFile = ReceiveFileDao.shared().fetchReceiveFileCell(byFileId: fileID, logName: loginName)
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
                    let theRow = receiveArray.index(of: pycFile)
                    //选中cell事件
                    ReceiveTableView.selectRowIndexes(IndexSet.init(integer: theRow), byExtendingSelection: false)
                }
            }
            //新增文件
            if isInset
            {
                receiveFile = ReceiveFileDao.shared().fetchReceiveFileCell(byFileId: fileID, logName: loginName)
                if(receiveFile != nil)
                {
                    insertNewRow(receiveFile)
                }
                
            }
        }
    }
}

//MARK: UI
extension ReceiveViewController
{
    func initThisView()
    {
        if receiveFile == nil
        {
            rootView.isHidden = true
            return
        }
        rootView.isHidden = false
        readBtn.isEnabled = true
        //refresh:YES 刷新
        let seriesName = SeriesDao.shared().fetchSeriesName(fromSeriesId: receiveFile.seriesID)
        if ((seriesName! as NSString).length == 0 || seriesName == "未分组文件")
        {
            ibSeriesNameLabel.isHidden = true
            ibSeriesLabel.isHidden = true
            makeTimeToTitleConstraint.constant = 10
        }
        else
        {
            ibSeriesNameLabel.isHidden = true
            ibSeriesLabel.isHidden = false
            makeTimeToTitleConstraint.constant = 41
//            ibSeriesNameLabel.stringValue = seriesName
            ibSeriesLabel.stringValue = "所属系列：\(seriesName!)"
        }
        
        makerLabel.stringValue = "作者对你说："
        if (receiveFile.fileOwnerNick != "" && receiveFile.fileOwnerNick != nil)
        {
            makerLabel.stringValue = "作者 \(receiveFile.fileOwnerNick!) 对你说："
        }
        
        ibMakeTime.stringValue = "制作时间：\((receiveFile.sendtime as NSDate).dateString()!)"
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
            self.lastNumProgressView.isHidden = true
            lastNumLabel.stringValue = "不限制"
            lastNumLabel.textColor = kGreen
        }
        else
        {
            
            self.lastNumProgressView.isHidden = false
            let lastNum = "\(receiveFile.lastnum)"
            let limitnum = "\(receiveFile.limitnum)"
            
            if (receiveFile.fileTimeType == 4)
            {
                lastNumLabel.attributedStringValue = NSMutableAttributedString.init(attributedString: NSAttributedString.init(string: "剩余\(lastNum)次，共 \(limitnum) 次"))
                lastNumLabel.addColorText("剩余", aColor: kGray, aFont: nil)
                lastNumLabel.addColorText("次，共", aColor: kGray, aFont: nil)
                lastNumLabel.addColorText(" 次", aColor: kGray, aFont: nil)
                lastNumProgressView.doubleValue = (Double(receiveFile.lastnum) * 1.0) / Double(receiveFile.limitnum)
            }
            else
            {
                
                if (receiveFile.fileMakeType == 1)
                {
                    lastNumLabel.attributedStringValue = NSMutableAttributedString.init(attributedString: NSAttributedString.init(string: "剩余\(lastNum)次，共 \(limitnum) 次"))
                    lastNumLabel.addColorText("剩余", aColor: kGray, aFont: nil)
                    lastNumLabel.addColorText("次，共", aColor: kGray, aFont: nil)
                    lastNumLabel.addColorText(" 次", aColor: kGray, aFont: nil)
                    lastNumProgressView.doubleValue = (Double(receiveFile.lastnum) * 1.0) / Double(receiveFile.limitnum)
                }else
                {
                    self.lastNumLabel.attributedStringValue = NSMutableAttributedString.init(attributedString: NSAttributedString.init(string: "共 \(limitnum) 次"))
                    lastNumLabel.addColorText("共", aColor: kGray, aFont: nil)
                    lastNumLabel.addColorText(" 次", aColor: kGray, aFont: nil)
                    lastNumProgressView.isHidden = true
                }
            }
        }
        
        
        //每次能看
        if (receiveFile.limittime == 0) {
            
            if (receiveFile.fileMakeType == 0) {
                //hsg
                ibOnceLong.isHidden = true
            }
            
        }else{
            let mm = receiveFile.limittime / 60;
            let ss = receiveFile.limittime % 60;
            if (mm == 0) {
                onceTimeLabel.attributedStringValue = NSMutableAttributedString.init(attributedString: NSAttributedString.init(string: "\(ss) 秒"))
                onceTimeLabel.addColorText("秒", aColor: NSColor.black, aFont: nil)
            } else {
                if (ss == 0) {
                    onceTimeLabel.attributedStringValue =  NSMutableAttributedString.init(attributedString: NSAttributedString.init(string: "\(mm) 分钟"))
                    onceTimeLabel.addColorText("分钟", aColor: NSColor.black, aFont: nil)
                }else{
                    onceTimeLabel.attributedStringValue = NSMutableAttributedString.init(attributedString: NSAttributedString.init(string: "\(mm)分\(ss)秒"))
                    onceTimeLabel.addColorText("分", aColor: NSColor.black, aFont: nil)
                    onceTimeLabel.addColorText("秒", aColor: NSColor.black, aFont: nil)
                }
            }
        }
        
        //天数限制
        if (!receiveFile.freetime){
            
            lastDayProgressView.isHidden = true
            canTimeDateLabel.isHidden = true
            lastDayLabel.stringValue = "不限制"
            lastDayLabel.addColorText("不限制", aColor: kGreen, aFont: nil)
        }else {
            lastDayProgressView.isHidden = false
            canTimeDateLabel.isHidden = false
            let lastday = "\(receiveFile.lastday)"
            let allday = "\(receiveFile.allday)"
            lastDayLabel.attributedStringValue =  NSMutableAttributedString.init(attributedString: NSAttributedString.init(string: "剩余\(lastday)天，共 \(allday) 天"))
            lastDayLabel.addColorText("剩余", aColor: kGray, aFont: nil)
            lastDayLabel.addColorText("天，共", aColor: kGray, aFont: nil)
            lastDayLabel.addColorText(" 天", aColor: kGray, aFont: nil)
            lastDayProgressView.doubleValue = (Double(receiveFile.lastday) * 1.0) / Double(receiveFile.allday)
            
            if let starttime = receiveFile.starttime,let endtime = receiveFile.endtime{
                canTimeDateLabel.stringValue = "从\((starttime as NSDate).dateStringByDay()!)到\((endtime as NSDate).dateStringByDay()!)"
            }
        }
        
        var str = ""
        if (receiveFile.fileMakeType == 0) {
            
            //手动激活
            makerSayLabel.isHidden = true
            lastDayLabel.isHidden = false
            //    nolimitDay.hidden = true
            
            receiveFile.firstOpenTime = ReceiveFileDao.shared().selectReceiveFileFistOpenTime(byFileId: receiveFile.fileid)
            
            //首次阅读
            if (receiveFile.firstOpenTime == nil || receiveFile.firstOpenTime == "") {
                onceTimeNumLabel.isHidden = true
                onceTimeLabel.isHidden = true
                ibOnceLong.isHidden = true
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
                    lastNumLabel.addColorText("剩余", aColor: kGray, aFont: nil)
                    lastNumLabel.addColorText("次，共", aColor: kGray, aFont: nil)
                    lastNumLabel.addColorText(" 次", aColor: kGray, aFont: nil)
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
                    lastNumLabel.addColorText("剩余", aColor: kGray, aFont: nil)
                    lastNumLabel.addColorText("次，共", aColor: kGray, aFont: nil)
                    lastNumLabel.addColorText(" 次", aColor: kGray, aFont: nil)
                    lastNumLabel.addColorText("共 ", aColor: kGray, aFont: nil)
                    
                }
            }
            
            if (receiveFile.fileTimeType==4) {
                lastDayProgressView.isHidden = false
                canTimeDateLabel.isHidden = false
                lastNumProgressView.isHidden = false
            }else{
                if (receiveFile.fileOpenDay > 0){
                    if(b_CanOpen)//能打开
                    {
                        //当天数大于0
                        if(receiveFile.fileYearRemain > 0 && receiveFile.fileDayRemain>0)
                        {
                            lastDayLabel.attributedStringValue = NSMutableAttributedString.init(string: "剩余\(yearRemain)年\(dayRemain)天，共 \(openDay) 天")
                            lastDayLabel.addColorText("剩余", aColor: kGray, aFont: nil)
                            lastDayLabel.addColorText("天，共", aColor: kGray, aFont: nil)
                            lastDayLabel.addColorText("年", aColor: kGray, aFont: nil)
                            lastDayLabel.addColorText(" 天", aColor: kGray, aFont: nil)
                        }
                        else if(receiveFile.fileYearRemain > 0)
                        {
                            lastDayLabel.attributedStringValue = NSMutableAttributedString.init(string: "剩余\(yearRemain)年，共 \(openDay) 天")
                            lastDayLabel.addColorText("剩余", aColor: kGray, aFont: nil)
                            lastDayLabel.addColorText("年，共 ", aColor: kGray, aFont: nil)
                            lastDayLabel.addColorText(" 天", aColor: kGray, aFont: nil)

                        }
                        else if(receiveFile.fileDayRemain > 0)
                        {
                            lastDayLabel.attributedStringValue = NSMutableAttributedString.init(string: "剩余\(dayRemain)天，共\(openDay) 天")
                            lastDayLabel.addColorText("剩余", aColor: kGray, aFont: nil)
                            lastDayLabel.addColorText("天，共", aColor: kGray, aFont: nil)
                            lastDayLabel.addColorText(" 天", aColor: kGray, aFont: nil)
                            
                        }
                    }else{
                        //未激活
                        lastDayLabel.attributedStringValue = NSMutableAttributedString.init(string: "共\(openDay)天")
                        lastDayLabel.addColorText("共", aColor: kGray, aFont: nil)
                        lastDayLabel.addColorText("天", aColor: kGray, aFont: nil)
                        
                    }
                }else if(receiveFile.fileOpenYear > 0) {
                    
                    if(b_CanOpen)//能打开
                    {
                        //当年数大于0
                        if(receiveFile.fileYearRemain > 0 && receiveFile.fileDayRemain>0)
                        {
                            lastDayLabel.attributedStringValue = NSMutableAttributedString.init(string: "剩余\(yearRemain)年\(dayRemain)天，共 \(openYear) 年")
                            lastDayLabel.addColorText("剩余", aColor: kGray, aFont: nil)
                            lastDayLabel.addColorText("年", aColor: kGray, aFont: nil)
                            lastDayLabel.addColorText("天，共 ", aColor: kGray, aFont: nil)
                            lastDayLabel.addColorText(" 年", aColor: kGray, aFont: nil)
                        }
                        else if(receiveFile.fileYearRemain > 0)
                        {
                            lastDayLabel.attributedStringValue = NSMutableAttributedString.init(string: "剩余\(yearRemain)年，共 \(openYear) 年")
                            lastDayLabel.addColorText("剩余", aColor: kGray, aFont: nil)
                            lastDayLabel.addColorText("年，共 ", aColor: kGray, aFont: nil)
                            lastDayLabel.addColorText(" 年", aColor: kGray, aFont: nil)
                        }
                        else if(receiveFile.fileDayRemain > 0)
                        {
                            lastDayLabel.attributedStringValue = NSMutableAttributedString.init(string: "剩余\(dayRemain)天，共 \(openYear) 年")
                            lastDayLabel.addColorText("剩余", aColor: kGray, aFont: nil)
                            lastDayLabel.addColorText("天，共 ", aColor: kGray, aFont: nil)
                            lastDayLabel.addColorText(" 年", aColor: kGray, aFont: nil)
                        }
                    }
                    else{
                        //未激活
                        lastDayLabel.attributedStringValue = NSMutableAttributedString.init(string: "共 \(openYear) 年")
                        lastDayLabel.addColorText("共 ", aColor: kGray, aFont: nil)
                        lastDayLabel.addColorText(" 年", aColor: kGray, aFont: nil)
                    }
                }else{
                    lastDayLabel.attributedStringValue = NSMutableAttributedString.init(string: "不限制")
                }
                
                lastDayProgressView.isHidden = true
                canTimeDateLabel.isHidden = true
                lastNumProgressView.isHidden = true
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
                readBtn.image = NSImage.init(named: "send_recover1")
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
                readBtn.isEnabled = false
                readBtn.image = NSImage.init(named: "send_read_no")
                
            } else if (receiveFile.open == 1) {
                
                str = "send_icon_already_Detail";
                readBtn.isEnabled = true
                readBtn.image = NSImage.init(named: "send_recover1")
                
            } else if (receiveFile.open == 0) {
                
                str = "send_icon_Detail";
                readBtn.isEnabled = true
                readBtn.image = NSImage.init(named: "send_recover1")
                
            }
            if (receiveFile.forbid == 1) {
                //forbid: 1开放
                makerSayLabel.isHidden = true
            }else{
                makerSayLabel.isHidden = false
            }
            fileFlageImage.image = NSImage.init(named: str)
        }
        
        //限制条件是否可见
        if (!receiveFile.isEye) {
            //ibisEyeView.hidden = true
            readBtn.frame = CGRect(x: readBtn.frame.origin.x, y: 274, width: readBtn.frame.size.width, height: readBtn.frame.size.height);
        }
        
        if !FileManager.default.fileExists(atPath: receiveFile.fileurl)
            || !(appHelper?.fileIsType(ofVideo: receiveFile.filetype))!
        {
            readBtn.image = NSImage.init(named: "send_read_no")
            readBtn.isEnabled = false
        }
    
        readBtn.isEnabled = true
        //刷新按钮根据阅读按钮状态保持一直
//        ibRefreshFileButton.enabled = readBtn.enabled
    }
    
    func isCanOpen(_ outFile:OutFile) -> Bool {
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
    func splitView(_ splitView: NSSplitView, constrainMaxCoordinate proposedMaximumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat
    {
        // Make sure the view on the right has at least 200 px wide
        return splitView.bounds.size.width - 240
    }
    
    func splitView(_ splitView: NSSplitView, constrainMinCoordinate proposedMinimumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat
    {
        return 240
    }
}


extension ReceiveViewController:NSTableViewDelegate,NSTableViewDataSource
{
    //MARK: tableView Delegate
    //单击单元格，显示详情信息
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        if let receiveFile = selectedFileList()
        {
            self.receiveFile = ReceiveFileDao.shared().fetchReceiveFileCell(byFileId: receiveFile.fileid, logName: loginName)
            
            if self.receiveFile != nil
            {
                //改变选中状态
                ChangeCellBySelectedStatus()
            }
            //刷新详情
            initThisView()
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
        guard let cellView = self.ReceiveTableView.view(atColumn: 0, row: ReceiveTableView.selectedRow, makeIfNecessary: true) as? CustomTableCellView
            else {
                return
            }
        
        //刷新按钮状态
        if UserDefaults.standard.bool(forKey: "\(receiveFile.fileid)")
        {
            //当前处于刷新状态
            ibRefreshFileButton.addGroupRotateAnimation(receiveFile.fileid)
        }
        else
        {
            //停止刷新动画
            ibRefreshFileButton.layer?.removeAllAnimations()
            UserDefaults.standard.set(false, forKey: "\(receiveFile.fileid)")
            UserDefaults.standard.synchronize()
        }
        
        // 判断本地文件ID是否和数据库中的id一致，否则更新状态
        //设置单元格字体样式
        if FileManager.default.fileExists(atPath: receiveFile.fileurl!)
        {
            ibRefreshFileButton.isEnabled = true
            
            let fileID = PycFile().getAttributePycFileId(receiveFile.fileurl!)
            if fileID != Int32(receiveFile.fileid)
            {
                readBtn.image = NSImage.init(named: "send_read_no")
                readBtn.isEnabled = false
                ibRefreshFileButton.isEnabled = false
                cellView.textField?.textColor = NSColor.red
                
                //提示本地文件错误
                // Make a copy of default style.
                var style = Toasty.defaultStyle
                // Navigation bar is translucent so the view starts from under the bars. Set margin accordingly.
                style.margin.top = 0
                style.backgroundColor = NSColor.white
                style.textColor = NSColor.black
                var message = "信息与本地文件不符，建议删除该条无效信息！"
                if(fileID==3)
                {
                    message = "应用开启沙盒保护机制，无权限阅读该目录文件，请移动到下载目录重新查看！"
                }
                // Show our toast.
                rootView.showToastWithText(message, usingStyle: style)
            }
        }
        else
        {
            ibRefreshFileButton.isEnabled = false
        }
        
        //发送通知，更新其他cell的状态
        cellView.SendBySelecedNotification(false)
        
    }
    
    //拖动鼠标多选响应事件
    func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forRowIndexes rowIndexes: IndexSet) {
        //
        
    }
    
    //MARK: tableDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        //
        if receiveArray != nil
        {
            return receiveArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        //http://blog.csdn.net/fengsh998/article/details/18809355
//        let column = tableView.tableColumns[0]
//        let dycell = tableView.preparedCell(atColumn: 0, row: row)
//        var cellBounds = NSZeroRect
//        cellBounds.size.width = column.width
//        cellBounds.size.height = CGFloat.greatestFiniteMagnitude
//        _ = dycell!.cellSize(forBounds: cellBounds)
//        return cellSize.height
        return 30
    }
    
    private func tableView(_ tableView: NSTableView, willDisplayCell cell: AnyObject, for tableColumn: NSTableColumn?, row: Int) {
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
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        //
        // Get a new ViewCell
        let cellView = tableView.make(withIdentifier: (tableColumn?.identifier)!, owner: self) as! CustomTableCellView
        
        // Since this is a single-column table view, this would not be necessary.
        // But it's a good practice to do it in order by remember it when a table is multicolumn.
        if tableColumn?.identifier == "ReceiveColumn" {
            
            let ReceiveColumn = self.receiveArray[row] as! OutFile
            cellView.cellID = ReceiveColumn.fileid
            cellView.textField?.stringValue = ReceiveColumn.filename
            
            //设置单元格字体样式
            if FileManager.default.fileExists(atPath: ReceiveColumn.fileurl)
            {
                //原文件存在
                cellView.textField?.textColor = kGray
                //不支持文件格式
                if !(appHelper?.fileIsType(ofVideo: ReceiveColumn.filetype))!
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
                cellView.textField?.textColor = NSColor.red
            }
            return cellView
        }
        return cellView
    }
    
    //MARK: 右击事件
    //https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/TableView/RowSelection/RowSelection.html#//apple_ref/doc/uid/10000026i-CH6-SW1
    func indexesToProcessForContextMenu() -> IndexSet {
        // If the clicked row was in the selectedIndexes, then we process all selectedIndexes. Otherwise, we process just the clickedRow
        var selectedIndexes = ReceiveTableView.selectedRowIndexes
        if (ReceiveTableView.clickedRow != -1 && !selectedIndexes.contains(ReceiveTableView.clickedRow))
        {
            //
            selectedIndexes = IndexSet.init(integer:ReceiveTableView.clickedRow)
        }
//        selectedIndexes.enumer
//        http://stackoverflow.com/questions/39638538/swift-3-0-value-of-type-indexset-has-no-member-enumerateindexesusingblock
//        selectedIndexes.enumerated()
        for (_, row) in selectedIndexes.enumerated() {
            guard let cellView = self.ReceiveTableView.view(atColumn: 0, row: row, makeIfNecessary: false) as? CustomTableCellView
                else{
                    break
            }
            
            cellView.SendBySelecedNotification(true)
        }
        
        return selectedIndexes
    }
    
    //右击菜单在Finder中显示功能
    @IBAction func mnuRevealInFinderSelected(_ sender: AnyObject) {
        let selectedIndexes = indexesToProcessForContextMenu()
        for (_, row) in selectedIndexes.enumerated() {
            //
            let ReceiveColumn = self.receiveArray[row] as! OutFile
            NSWorkspace.shared().selectFile(ReceiveColumn.fileurl, inFileViewerRootedAtPath: "")
        }
    }
    
    //右击菜单删除功能
    @IBAction func mnuRemoveRowSelected(_ sender: AnyObject) {
        
        let selectedIndexes = indexesToProcessForContextMenu()
        if selectedIndexes.first == nil {
            //
            return
        }
        for (_, row) in selectedIndexes.enumerated() {
            //
            let ReceiveColumn = self.receiveArray[row] as! OutFile
            ReceiveFileDao.shared().deleteReceiveFile(ReceiveColumn.fileid, logName: self.loginName)
            
            //删除文件
            //try! NSFileManager.defaultManager().removeItemAtPath(ReceiveColumn.fileurl)
            //删除广告
            let uid = ReceiveFileDao.shared().fetchUid(ReceiveColumn.fileid)
            if(ReceiveFileDao.shared().fetchCount(ofUid: ReceiveColumn.fileid) == 0)
            {
                let fileDir = SandboxFile.createList(SandboxFile.getDocumentPath(), listName: "advert")
                let pre = NSPredicate.init(format: "SELF contains[cd] '\(uid)'", argumentArray: nil)
                let filesNames = SandboxFile.getSubpathsAtPath(fileDir)
                let oldFiles = (filesNames! as NSArray).filtered(using: pre) as NSArray
                oldFiles.enumerateObjects({ (obj, idx, stop) in
                    //
                    let oldfile = "\(fileDir)/\(obj))"
                    if(SandboxFile.isFileExists(oldfile)){
                        //                        try! NSFileManager.defaultManager().removeItemAtPath(oldfile)
                    }
                })
            }
        }
        //从列表中移除所选项
        self.ReceiveTableView.beginUpdates()
        self.receiveArray.removeObjects(at: selectedIndexes)
        self.ReceiveTableView.removeRows(at: selectedIndexes, withAnimation: .effectFade)
        self.ReceiveTableView.endUpdates()
        //显示下一个文件详情
        self.selectRowStartingAtRow(selectedIndexes.first! - 1)
    }
    
    //右击刷新功能
    @IBAction @objc func refreshReceiveTableView(_ sender:AnyObject){
        receiveArray = nil
        receiveArray = ReceiveFileDao.shared().selectReceiveFileAll(loginName)
        ReceiveTableView.reloadData()
    }
    
    //移动单元格 从 - 到 -
    @IBAction func btnMoveRowClick(_ sender:AnyObject) {
        //
        let fromRow = 1
        let toRow = 3
        ReceiveTableView.beginUpdates()
        ReceiveTableView.moveRow(at: fromRow, to: toRow)
        let object = receiveArray[fromRow]
        receiveArray.removeObject(at: fromRow)
        receiveArray.insert(object, at: toRow)
        ReceiveTableView.endUpdates()
    }
    
    //双击打开文件
    @IBAction func tblvwDoubleClick(_ sender:AnyObject)
    {
        if(!readBtn.isEnabled)
        {
            //提示本地文件错误
            // Make a copy of default style.
            var style = Toasty.defaultStyle
            // Navigation bar is translucent so the view starts from under the bars. Set margin accordingly.
            style.margin.top = 0
            style.backgroundColor = NSColor.white
            style.textColor = NSColor.black
            // Show our toast.
            rootView.showToastWithText("该文件无法阅读！", usingStyle: style)
            return
        }
        let row = ReceiveTableView.selectedRow
        if row != -1 {
            //
            let ReceiveColumn = self.receiveArray[row] as! OutFile
            
            if !FileManager.default.fileExists(atPath: ReceiveColumn.fileurl)
            {
                //提示本地文件错误
                // Make a copy of default style.
                var style = Toasty.defaultStyle
                // Navigation bar is translucent so the view starts from under the bars. Set margin accordingly.
                style.margin.top = 0
                style.backgroundColor = NSColor.white
                style.textColor = NSColor.black
                // Show our toast.
                rootView.showToastWithText("该文件无法阅读！", usingStyle: style)
                return;
            }
            //            NSWorkspace.sharedWorkspace().selectFile(ReceiveColumn.fileurl, inFileViewerRootedAtPath: "")
            appHelper?.phoneNo = ""
            appHelper?.messageID = ""
            appHelper?.loadVideo(withLocalFiles: {ReceiveColumn.fileurl}())
            
        }
    }
    
    //删除后，显示相邻的下一行
    func selectRowStartingAtRow(_ row:Int)
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
                    ReceiveTableView.selectRowIndexes(IndexSet.init(integer: theRow), byExtendingSelection: false)
                    return
                }
                theRow += 1
            }
            
            theRow = ReceiveTableView.numberOfRows - 1
            while theRow >= 0 {
                //
                if !tableView(ReceiveTableView, isGroupRow: theRow) {
                    //
                    ReceiveTableView.selectRowIndexes(IndexSet.init(integer: theRow), byExtendingSelection: false)
                    return
                }
                theRow -= 1
            }
        }
        //当数组中是空
        if receiveArray.count <= 0
        {
            receiveFile = nil
            
        }
        self.initThisView()
        
    }
    
    // We want to make "group rows" for the folders
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        //
        if receiveArray[row] is SeriesModel{
            return true
        }else{
            return false
        }
    }
    
    //插入新cell
    func insertNewRow(_ file:OutFile){
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
        receiveArray.insert(file, at: index)
        ReceiveTableView.beginUpdates()
        ReceiveTableView.insertRows(at: IndexSet.init(integer: index), withAnimation: .effectFade)
        ReceiveTableView.scrollRowToVisible(index)
        ReceiveTableView.endUpdates()
        //更新详情页面
        ReceiveTableView.selectRowIndexes(IndexSet.init(integer: index), byExtendingSelection: false)
    }
}
