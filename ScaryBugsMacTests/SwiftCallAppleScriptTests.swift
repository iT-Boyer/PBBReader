//
//  SwiftCallAppleScriptTests.swift
//  ScaryBugsMac
//
//  Created by pengyucheng on 16/6/16.
//  Copyright © 2016年 recomend. All rights reserved.
//

import XCTest

class SwiftCallAppleScriptTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    /**
     oc调用AppleScript
     http://stackoverflow.com/questions/25163433/can-you-execute-an-applescript-script-from-a-swift-application
     */
    func testCallAppleScript(){
        let task = NSTask()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["~/Desktop/main.scpt"]
        task.launch()
    }
    
    func testCall() {
        //OC，AppleScript，shell相互调用 http://blog.csdn.net/xiao562994291/article/details/18221517
//        let bundle = NSBundle.init(forClass: self.dynamicType)
        let bundle = NSBundle.mainBundle()
        if let scriptPath = bundle.pathForResource("main", ofType: "scpt")
        {
            let paths = [scriptPath]
             NSTask.launchedTaskWithLaunchPath("/usr/bin/osascript", arguments: paths)
        }
    }

    func testCall2() {
        let bundle = NSBundle.mainBundle()
        let videoPath = bundle.pathForResource("BigBuck", ofType: "m4v")
        //https://developer.apple.com/library/mac/technotes/tn2084/_index.html
        //open -na /Applications/mpv.app命令行必须是 -na 才能调用当前指定的播放器，否则会调用系统默认播发器
        let myAppleScript = "on run\ndo shell script \"open -na /Applications/mpv.app \(videoPath!)\"\ntell application \"mpv\" to activate\n end run"
        print(myAppleScript)
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: myAppleScript) {
            if let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(
                &error) {
                print(output.stringValue)
            } else if (error != nil) {
                print("error: \(error)")
            }
        }
    }
}
