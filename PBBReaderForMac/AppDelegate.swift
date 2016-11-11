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

//全局变量
 let KDataBasePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate{

    //必须声明为全局属性，否则在声明PycFile调用delegate时，delegate = nil
    //还出现第一次启动执行两次openFiles方法
    let appHelper = AppDelegateHelper()
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
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
//                alert.addButtonWithTitle("稍后提醒")
                alert.messageText = UpdateContent as! String
                if alert.runModal() == NSAlertFirstButtonReturn {
                    //打开safari下载安装包
                    NSWorkspace.shared().open(URL.init(string: InstallerPackage as! String)!)
                    //版本升级过程中，更新数据库
//                    ReceiveFileDao.sharedReceiveFileDao().updateTable()
//                    ReceiveFileDao.sharedReceiveFileDao().updateReceiveFileForVersionPBB()
//                    userDao.shareduserDao().updateTable()
                    if FileManager.default.fileExists(atPath: KDataBasePath.appending("PBB.db")) && !FileManager.default.fileExists(atPath: KDataBasePath.appending(".PBB.db"))
                    {
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
        
        //问题；NSApplicationCrashOnExceptions is not set. This will result in poor top-level uncaught exception reporting
        //https://twittercommunity.com/t/fabric-failed-to-download-settings-unknown-host/75443
        //macOS Support:https://docs.fabric.io/apple/crashlytics/os-x.html#macos-support
        //[[NSUserDefaults standardUserDefaults] registerDefaults:@{ @"NSApplicationCrashOnExceptions": @YES }];
        UserDefaults.standard.register(defaults: ["NSApplicationCrashOnExceptions" : true])
        //及时写入
        UserDefaults.standard.synchronize()
        Fabric.with([Crashlytics.self])
        //TODO: Move this to where you establish a user session
        self.logUser()
    }

    //Log user information when your app crashes
    func logUser()
    {
        //TODO: Use the current user`s information
        //you can call any combination of these three methods
        Crashlytics.sharedInstance().setUserName("boyers")
        Crashlytics.sharedInstance().setUserEmail("724987481@qq.com")
        Crashlytics.sharedInstance().setUserIdentifier("724987481")
    }
    func applicationWillTerminate(_ aNotification: Notification) {
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
                    UserDefaults.standard.set(false, forKey: fileID)
                    UserDefaults.standard.synchronize()
                }
            }
        })
    }

    
    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        //
        appHelper.phoneNo = ""
        appHelper.messageID = ""
//        appHelper.openURLOfPycFileByLaunchedApp(filenames[0])
        appHelper.loadVideo(withLocalFiles: filenames[0])
        
    }

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
    
}

