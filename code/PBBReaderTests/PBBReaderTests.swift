//
//  PBBReaderTests.swift
//  PBBReaderTests
//
//  Created by pengyucheng on 16/9/27.
//  Copyright © 2016年 recomend. All rights reserved.
//

import XCTest
@testable import PBBReader 

class PBBReaderTests: XCTestCase {
    
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
        let URL = Foundation.URL(string: "http://114.112.104.138:6001/HostMonitor/client/log/addLog")
        let request = URLRequest(url: URL!)
        let mode = RequestAddLog()
        mode.logType = LogTypeFatal
        mode.file_name = self.class
        mode.method_name = #function
        mode.content = "自定义content"
        mode.desc = "自定义desc"
        mode.extension1 = "自定义extension1"
        let data = Data()
        let expectation = self.expectation(description: "上传文件超时...")
        let uploadTask = URLSession.shared.uploadTask(with: request, from: data, completionHandler: { (data, response, error) in
            //解析上传后，返回的信息
            //parsedata()
//            expectation.fulfill()
        })
        uploadTask.resume()
    }
    
    func testPerformanceExample()
    {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
