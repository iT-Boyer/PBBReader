//
//  PBBLogSDKTests.swift
//  PBBLogSDKTests
//
//  Created by pengyucheng on 24/11/2016.
//  Copyright © 2016 recomend. All rights reserved.
//

import XCTest
@testable import PBBLogSDK

class PBBLogSDKTests: XCTestCase {
    
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
        let url = "http://114.112.104.138:6001/HostMonitor/client/log/addLog"
        let model = PBBLogModel.init(.LogTypeFatal,
                                 APPName: .APPNameReader,
                                 description: "ddddd")
        let log = PBBLogAPI.shareInstance.upLoadLog(to: url, logModel: model)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
