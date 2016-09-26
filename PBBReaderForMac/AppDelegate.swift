//
//  AppDelegate.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 16/5/23.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate{

    //必须声明为全局属性，否则在声明PycFile调用delegate时，delegate = nil
    //还出现第一次启动执行两次openFiles方法
    let appHelper = AppDelegateHelper()
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        //监测升级
        let infoFileURL = NSURL.init(string: "http://www.pyc.com.cn/appupdate/updateinfo.plist")
        
        if let updateInfo = NSDictionary.init(contentsOfURL: infoFileURL!)
//        if let updateInfo = NSDictionary.init(contentsOfFile: NSBundle.mainBundle().pathForResource("updateinfo", ofType: "plist")!)
        {
//            let versionString = updateInfo.objectForKey("CFBundleShortVersionString")!
            let version = updateInfo.objectForKey("CFBundleVersion") as! Double
            let InstallerPackage = updateInfo.objectForKey("InstallerPackage")!
            let UpdateContent = updateInfo.objectForKey("UpdateContent")!
            //或当前运行程序版本号
            let currentVersionCode = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! NSString
            if version > currentVersionCode.doubleValue {
                //提示下载更新安装包
                let alert = NSAlert.init()
                alert.addButtonWithTitle("下载")
//                alert.addButtonWithTitle("稍后提醒")
                alert.messageText = UpdateContent as! String
                if alert.runModal() == NSAlertFirstButtonReturn {
                    //打开safari下载安装包
                    NSWorkspace.sharedWorkspace().openURL(NSURL.init(string: InstallerPackage as! String)!)
                }
//                if alert.runModal() == NSAlertSecondButtonReturn
//                {
//                    //稍后提醒
//                    
//                }
            }
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        //
        ReceiveFileDao.sharedReceiveFileDao().selectReceiveFileAll(userDao.shareduserDao().getLogName()).enumerateObjectsUsingBlock { (outFile, index, stop) in
            //取消所有刷新状态
            let fileID = "\((outFile as! OutFile).fileid)"
            if NSUserDefaults.standardUserDefaults().boolForKey(fileID){
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: fileID)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }

    
    func application(sender: NSApplication, openFiles filenames: [String]) {
        //
        appHelper.phoneNo = ""
        appHelper.messageID = ""
//        appHelper.openURLOfPycFileByLaunchedApp(filenames[0])
        appHelper.loadVideoWithLocalFiles(filenames[0])
        
    }

    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
//       return true
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

