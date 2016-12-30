//
//  AppDelegate.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 16/5/23.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Cocoa
import Fabric
import Crashlytics
import PBBLogSDK
//全局变量
 let KDataBasePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{

    //必须声明为全局属性，否则在声明PycFile调用delegate时，delegate = nil
    //还出现第一次启动执行两次openFiles方法
    let appHelper = AppDelegateHelper()
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        //设置日志序列号
        UserDefaults.standard.setValue(OpenUDID.value(), forKey: "equip_serial")
        UserDefaults.standard.synchronize()
        // Insert code here to initialize your application
        
        
        //问题；NSApplicationCrashOnExceptions is not set. This will result in poor top-level uncaught exception reporting
        //https://twittercommunity.com/t/fabric-failed-to-download-settings-unknown-host/75443
        //macOS Support:https://docs.fabric.io/apple/crashlytics/os-x.html#macos-support
        //[[NSUserDefaults standardUserDefaults] registerDefaults:@{ @"NSApplicationCrashOnExceptions": @YES }];
        //Crashlytics日志工具
        UserDefaults.standard.register(defaults: ["NSApplicationCrashOnExceptions" : true])
        //及时写入
        UserDefaults.standard.synchronize()
        Fabric.with([Crashlytics.self])
        //TODO: Move this to where you establish a user session
        self.logUser()
        
        //30s之后执行升级检测
        self.perform(#selector(AppDelegate.checkAPPUpdate), with: nil, afterDelay: 30.0)
        
        
        //添加查看打开PDF的通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AppDelegate.openPDFFileByLaunchedApp(_:)),
                                                   name: NSNotification.Name("openURLOfPycFileByLaunchedApp"),
                                                 object: nil)

    }
    
    //MARK: mupdf播放器创建成功后，开始访问网络加载PDF
    func openPDFFileByLaunchedApp(_ notification:Notification)
    {
        //
        let openfilepath = notification.userInfo?["openfilepath"] as! String
        appHelper.openURLOfPycFile(byLaunchedApp: openfilepath)
        
//        //测试
//        let keycode:[CChar16] = [CChar16]() //[175,193,147,120,110,140,91,230,18,28,131,46,58,222,207,210]
//        let keylength:CLongLong = 0//9206048
//        let offset:CLongLong = 2097164
//        let filesize:CLongLong = 9206038
//        var dic = [String:Any]()
//        
//        dic.updateValue(NSNumber.init(value: keylength), forKey: "EncryptedLen")
//        dic.updateValue(NSNumber.init(value: offset), forKey: "offset")
//        dic.updateValue(NSNumber.init(value: filesize), forKey: "filesize")
//        dic.updateValue(NSData.init(bytes: keycode, length: 16), forKey: "fileSecretkeyR1")
//        
//        dic.updateValue(NSNumber.init(value: 10), forKey: "CountDownTime")
//        dic.updateValue("waterMarkwaterMarkwaterMark", forKey: "waterMark")
//        
//        NotificationCenter.default.post(name: NSNotification.Name("set_key_info_PDF"),
//                                      object: nil,
//                                    userInfo: dic)
    }
    
    

    //MARK: app将要退出时
    func applicationWillTerminate(_ aNotification: Notification)
    {
        // Insert code here to tear down your application
        //
        let filesArray = ReceiveFileDao.shared().selectReceiveFileAll(userDao.shareduser().getLogName())
//        (obj, idx, stop) in
        filesArray?.enumerateObjects({ (outObj, idx, stop) in
            //
            //取消所有刷新状态
            if let outFile = (outObj as? OutFile)
            {
                let fileID = "\(outFile.fileid)"
                if UserDefaults.standard.bool(forKey: fileID)
                {
                    PBBLogModel(.INFO, in: .ReaderMac, desc: "app将要退出时，取消所有刷新状态").sendTo()
                    UserDefaults.standard.set(false, forKey: fileID)
                    UserDefaults.standard.synchronize()
                }
            }
        })
    }

    //MARK: app双击启动入口
    func application(_ sender: NSApplication, openFiles filenames: [String])
    {
        //
        appHelper.phoneNo = ""
        appHelper.messageID = ""
        appHelper.loadVideo(withLocalFiles: filenames[0])
        PBBLogModel(.INFO, in: .ReaderMac, desc: "使用次数+1").sendTo()
    }

    //MARK: 点击dock图标跳出APP
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        //dock点击图标显示主页面
        if let mainWindow:NSWindow? = sender.windows[0]
        {
            mainWindow!.makeKeyAndOrderFront(nil)
            return true
        }else
        {
            return false
        }
        
    }
    
//    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
//        //
//        ReceiveFileDao.sharedReceiveFileDao().selectReceiveFileAll(userDao.shareduserDao().getLogName()).enumerateObjectsUsingBlock { (outFile, index, stop) in
//            //取消所有刷新状态
//            let fileID = "\((outFile as! OutFile).fileid)"
//            if NSUserDefaults.standardUserDefaults().boolForKey(fileID){
//                NSUserDefaults.standardUserDefaults().setBool(false, forKey: fileID)
//                NSUserDefaults.standardUserDefaults().synchronize()
//            }
//        }
//        return .TerminateNow
//    }
    
    
    //MARK: APP检查更新
    func checkAPPUpdate()
    {
        //监测升级
        let infoFileURL = URL.init(string: "http://www.pyc.com.cn/appupdate/pbbreader_mac/updateinfo.plist")
        
        if let updateInfo = NSDictionary.init(contentsOf: infoFileURL!)
            //        if let updateInfo = NSDictionary.init(contentsOfFile: NSBundle.mainBundle().pathForResource("updateinfo", ofType: "plist")!)
        {
            //            let versionString = updateInfo.objectForKey("CFBundleShortVersionString")!
            let version = updateInfo.object(forKey: "CFBundleVersion") as! Double
            let InstallerPackage = updateInfo.object(forKey: "InstallerPackage")!
            let UpdateContent = updateInfo.object(forKey: "UpdateContent")!
            //或当前运行程序版本号
            let currentVersionCode = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! NSString
            if version > currentVersionCode.doubleValue {
                //提示下载更新安装包
                let alert = NSAlert.init()
                alert.addButton(withTitle: "下载")
                alert.addButton(withTitle: "取消")
                alert.messageText = UpdateContent as! String
                if alert.runModal() == NSAlertFirstButtonReturn
                {
                    //打开safari下载安装包
                    PBBLogModel(.INFO, in: .ReaderMac, desc: "用户下载包+1").sendTo()
                    NSWorkspace.shared().open(URL.init(string: InstallerPackage as! String)!)
                    //版本升级过程中，更新数据库
                    //                    ReceiveFileDao.sharedReceiveFileDao().updateTable()
                    //                    ReceiveFileDao.sharedReceiveFileDao().updateReceiveFileForVersionPBB()
                    //                    userDao.shareduserDao().updateTable()
                    if FileManager.default.fileExists(atPath: KDataBasePath.appending("PBB.db")) && !FileManager.default.fileExists(atPath: KDataBasePath.appending(".PBB.db"))
                    {   //版本升级过程中，更新数据库
                        PBBLogModel(.INFO, in: .ReaderMac, desc: "版本升级过程中，更新数据库").sendTo()
                        try! FileManager.default.copyItem(atPath: KDataBasePath.appending("PBB.db"), toPath: KDataBasePath.appending(".PBB.db"))
                    }
                }
                //                if alert.runModal() == NSAlertSecondButtonReturn
                //                {
                //                    //稍后提醒
                //
                //                }
            }
        }
    }
    
    //MARK: Log user information when your app crashes
    func logUser()
    {
        //TODO: Use the current user`s information
        //you can call any combination of these three methods
        Crashlytics.sharedInstance().setUserName("boyers")
        Crashlytics.sharedInstance().setUserEmail("724987481@qq.com")
        Crashlytics.sharedInstance().setUserIdentifier("724987481")
    }
    
    
}

