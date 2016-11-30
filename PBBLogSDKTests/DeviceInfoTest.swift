//
//  DeviceInfoTest.swift
//  PBBReaderForMac
//
//  Created by huoshuguang on 2016/11/26.
//  Copyright © 2016年 recomend. All rights reserved.
//

import XCTest
@testable import PBBLogSDK

class DeviceInfoTest: XCTestCase {

    var currentNodeName = ""
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
        DeviceUtil().getIO()
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    //模仿使用shell命令，读取系统文件信息失败
    func testShell(){
//    $(/usr/libexec/PlistBuddy -c "Print MakeInstallerName" "$INFOPLIST_FILE")
        let pipe = Pipe()
        let task = Process()
        
        task.launchPath = "/usr/libexec/PlistBuddy"
        task.arguments = ["-c","Print machine_model","/usr/sbin/system_profiler"]
        task.standardOutput = pipe
        task.launch()
        let outData = pipe.fileHandleForReading.readDataToEndOfFile()
        let outString = String.init(data: outData, encoding: .utf8)
        NSLog(outString!)
    }
    
    
    
    func testModelIdentifierFromFile() {
        //
        let pipe = Pipe()
        let task = Process()
        task.launchPath = "/usr/sbin/system_profiler"
        task.arguments = ["-xml","SPHardwareDataType"]
        task.standardOutput = pipe
        task.launch()
        let outData = pipe.fileHandleForReading.readDataToEndOfFile()
        let outString:String! = String.init(data: outData, encoding: .utf8)
        //print(outString!)
        let list = (outString! as NSString).propertyList()
        hhhh(list: list)
    }
    
    //迭代方法实现该效果 : outDic[0]["_items"][0]["machine_model"]
    func hhhh(list:Any)  {
        //UnsafeMutableRawPointer!, _ notification:
        if list is NSMutableArray {
            //
            var tmparr = list as! NSArray
            tmparr.enumerateObjects({ (obj, index, stop) in
                //
                if obj is NSDictionary
                {
                    let dic = obj as! NSDictionary
                    let keys:[String] = dic.allKeys as! [String]
                    for key in keys
                    {
                        if key == "_items"
                        {
                            print("dddddd\(dic[key])")
                            hhhh(list: dic[key])
                            break
                        }
                        
                        if key == "machine_model"
                        {
                            print("sdfdddd\(dic[key])")
                            break
                        }
                    }
                }
                
                
            })
            
        }
    }
    
    
    func testModel() {
        //
        NSLog(DeviceUtil().modelIdentifier())
    }
    
    func testIOUSBDetector()
    {
        //
//        let expecttaion = expectation(description: "timeout....")
        NSLog("Event ")
        let test = IOUSBDetector(vendorID: 0x4e8, productID: 0x1a23)
        test?.callbackQueue = DispatchQueue.global()
        test?.callback = {
            (detector, event, service) in
//            expecttaion.fulfill()
            print("Event \(event)")
        };
        _ = test?.startDetection()
        while true { sleep(1)
             NSLog("Event ===")
        }
//        waitForExpectations(timeout: (dataTask.originalRequest?.timeoutInterval)!) { (error) in
            //错误处理
//        }
    }
}

/*
    XCTestCase无法使用XMLParserDelegate协议来实现解析，它无法作为代理者，因为永远不会去执行代理的方法
 解决办法：新建class 并遵循XMLParserDelegate协议，该这个类中实现代理，解析xml
 */
extension DeviceInfoTest
{
    func testXMLOutData()
    {
        //
        let pipe = Pipe()
        let task = Process()
        task.launchPath = "/usr/sbin/system_profiler"
        task.arguments = ["-xml","SPHardwareDataType"]
        task.standardOutput = pipe
        task.launch()
        
        let outData = pipe.fileHandleForReading.readDataToEndOfFile()
        DeviceXMLParser().parserDevier(outData: outData)
        
        
        
        
        
//        DeviceXMLParser().parserDevier(outData: outData)
        
        
//        let expectation = self.expectation(description: "XMLParserNotification")
//        let userInf = ["expectation":expectation]
//        NotificationCenter.default.post(name:Notification.Name(rawValue: "XMLParserNotification"),
//                                        object: self,
//                                        userInfo: userInf)
//        
//        waitForExpectations(timeout: 3, handler: nil)
        /*
         expectation(forNotification: "ParserNotif", object: nil){
         (notification) -> Bool in
         //
         let userInfo = notification.userInfo as! [String:String]
         let model = userInfo["machine_model"]
         print("model:\(model)")
         return true
         }
         waitForExpectations(timeout: 10, handler: nil)

         */
    }
}
