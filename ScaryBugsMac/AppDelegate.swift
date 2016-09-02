//
//  AppDelegate.swift
//  ScaryBugsMac
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
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
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
}

