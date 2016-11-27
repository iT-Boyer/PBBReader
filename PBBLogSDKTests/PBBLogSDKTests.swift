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
    
    let url = "http://114.112.104.138:6001/HostMonitor/client/log/addLog"
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
//        let url = "http://114.112.104.138:6001/HostMonitor/client/log/addLog"
//        let model = PBBLogModel.init(.LogTypeFatal,
//                                 APPName: .APPNameReader,
//                                 description: "ddddd")
//        let url = "http://192.168.85.92:8099/HostMonitor/client/log/addLog"
//        let model = PBBLogModel.init(.FATAL, in: .APPNameReaderMac, desc: "dddd")
////                                     APPName: .APPNameReader,
////                                     description: "ddddd")
//        _ = PBBLogAPI.shareInstance.upLoadLog(to: url, logModel: model)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testMyMethod()
    {
        //
        let logmodel = PBBLogModel.init(.INFO, in: .APPNameReaderMac, desc: "dddd")
//        NSLog(logmodel.description)
        logmodel.sendTo()
    }
    
    func testReplace() {
        //
        var str = "{  \"system\" : \"Reader for iOS\",  \"account_name\" : \"123456\",  \"login_type\" : \"1010100\",  \"application_name\" : \"Reader for iOS\",  \"imei\" : \"1231313112\",  \"content\" : \"1010100\",  \"account_password\" : \"iOS\",  \"sdk_version\" : \"123456\"}"
        str = str.replacingOccurrences(of: "\\", with: "")
        NSLog("\(str)")
    }
    
    
    func testRequest()
    {
        //
        let params:NSMutableDictionary = NSMutableDictionary()
        params["application_name"] = "Reader for iOS"
        params["account_name"] = "123456"
        params["account_password"] = "iOS"
        params["login_type"] = "1010100"
        params["system"] = "Reader for iOS"
        params["sdk_version"] = "123456"
        params["imei"] = "1231313112"
        params["content"] = "1010100"
        var jsonData:Data!
        var stringd = ""
        do {
            jsonData = try JSONSerialization.data(withJSONObject: params,
                                                         options: .prettyPrinted)
            stringd = String.init(data: jsonData, encoding: String.Encoding.utf8)!
            let dd = stringd.replacingOccurrences(of: "\n", with: "")
            stringd = dd.replacingOccurrences(of: "\\", with: "")
            NSLog("\(stringd)")
        } catch {

        }
        var request: URLRequest = URLRequest(url: URL(string:url)!)
        request.httpMethod = "POST"
        let strData = stringd.data(using:String.Encoding.utf8)
        request.httpBodyStream = InputStream.init(data: strData!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("en;q=1", forHTTPHeaderField: "Accept-Language")
        request.addValue("application/x-www-form-urlencoded;charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("*/*", forHTTPHeaderField: "Accept")
        request.addValue("en;q=1", forHTTPHeaderField: "Accept-Language")
        request.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        let expecttaion = expectation(description: "timeout....")
        let dataTask: URLSessionDataTask = URLSession.shared.dataTask(with: request) { (data, resp, err) in
            expecttaion.fulfill()
            print("响应的服务器地址：\(resp?.url?.absoluteString)")
            XCTAssertNotNil(data,"数据返回为nil")
            XCTAssertNil(err, (err?.localizedDescription)!)
            var dict:NSDictionary? = nil
            do {
                dict  = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as? NSDictionary
            } catch {
                
            }
            print("\(dict)")
            
            
        }
        dataTask.resume()
        waitForExpectations(timeout: (dataTask.originalRequest?.timeoutInterval)!) { (error) in
            //错误处理
        }
        
    }
    
    func testRequestBodyStream()
    {
        let session: URLSession = URLSession.shared
        var request: URLRequest = URLRequest(url: URL(string:url)!)

//        let vvv:NSString = "sdk_version=9.3.1&login_type=未登录&extension3=自定义extension3&equip_model=iPad&network_type=Wifi&imei=bd6d65bc85e22c29e790f9feb044d534d4f3b94f&file_name=ShareFolderFileListViewController_Pad&systemType=0&system=iOS&method_name=-[ShareFolderFileListViewController tableView:didSelectRowAtIndexPath:]&logType=0&loginType=0&level=FATAL&appName=0&account_password=自定义account_password&networkType=5&equip_host=绥知的 iPad&application_name=Reader for iOS&equip_serial=bd6d65bc85e22c29e790f9feb044d534d4f3b94f&op_version=9.3.1&desc=自定义desc&device_info=iPad5,1&extension1=自定义extension1&content=自定义content&extension2=自定义extension2"
        let logmodel = PBBLogModel.init(.INFO, in: .APPNameReaderMac, desc: "dddd")
        let vvv = logmodel.requestBody()
        
        let evvv = vvv.data(using: .utf8)
        
        request.httpBodyStream = InputStream.init(data: evvv!)
        request.httpMethod = "POST"
        let expecttaion = expectation(description: "timeout....")
        let dataTask: URLSessionDataTask = session.dataTask(with: request) { (data, resp, err) in
            expecttaion.fulfill()
            print("响应的服务器地址：\(resp?.url?.absoluteString)")
            XCTAssertNotNil(data,"数据返回为nil")
            XCTAssertNil(err, (err?.localizedDescription)!)
            var dict:NSDictionary? = nil
            do {
                dict  = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as? NSDictionary
            } catch {
                
            }
            print("\(dict)")
        }
        dataTask.resume()
        waitForExpectations(timeout: (dataTask.originalRequest?.timeoutInterval)!) { (error) in
            //错误处理
        }
    }
    
}
