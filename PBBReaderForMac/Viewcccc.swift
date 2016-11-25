//
//  Viewcccc.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 24/11/2016.
//  Copyright © 2016 recomend. All rights reserved.
//

import Cocoa
import AppKit
import PBBLogSDK

class Viewcccc: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func dfdfdfdf(_ sender: Any) {
//        let url = "http://192.168.85.92:8099/HostMonitor/client/log/addLog"
//        let model = PBBLogModel.init(.LogTypeFatal, in: .APPNameReader, desc: "ddddd")
//        let log = PBBLogAPI.shareInstance.upLoadLog(to: url, logModel: model)
//        PBBLogAPI.shareInstance.upLoadLog.(<#T##String#>, <#T##PBBLogModel#>)
        TestPost()
    }
    
    
    func TestPost()
    {
        let params:NSMutableDictionary = NSMutableDictionary()
        params["application_name"] = "Reader for iOS"
        params["account_name"] = "123456"
        params["account_password"] = "iOS"
        params["login_type"] = "1010100"
        params["system"] = "Reader for iOS"
        params["sdk_version"] = "123456"
        params["imei"] = "1231313112"
        params["content"] = "1010100"
        
        
        let session: URLSession = URLSession.shared
        
        let url: URL = URL(string: "http://192.168.85.92:8099/HostMonitor/client/log/addLog")!
        
        var request: URLRequest = URLRequest(url: url)
        let vvv:NSString = "sdk_version=9.3.1&login_type=未登录&extension3=自定义extension3&equip_model=iPad&network_type=Wifi&imei=bd6d65bc85e22c29e790f9feb044d534d4f3b94f&file_name=ShareFolderFileListViewController_Pad&systemType=0&system=iOS&method_name=-[ShareFolderFileListViewController tableView:didSelectRowAtIndexPath:]&logType=0&loginType=0&level=FATAL&appName=0&account_password=自定义account_password&networkType=5&equip_host=绥知的 iPad&application_name=Reader for iOS&equip_serial=bd6d65bc85e22c29e790f9feb044d534d4f3b94f&op_version=9.3.1&desc=自定义desc&device_info=iPad5,1&extension1=自定义extension1&content=自定义content&extension2=自定义extension2"
//        var jsonData:NSData? = nil
//        do {
//            
//            jsonData = try JSONSerialization.data(withJSONObject: params, options:
//                JSONSerialization.WritingOptions.prettyPrinted) as NSData?
//        } catch {
//            
//        }
//        let datad = NSData.init(base64Encoded: vvv, options: .ignoreUnknownCharacters) as! Data
        
        let vvv = vvv.data(using:NSUTF8StringEncoding.rawValue)
        
        request.httpBodyStream = InputStream.init(data: vvv as! Data)
        
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("*/*", forHTTPHeaderField: "Accept")
//        request.setValue("en;q=1", forHTTPHeaderField: "Accept-Language")
//        request.addValue("application/x-www-form-urlencoded;charset=utf-8", forHTTPHeaderField: "Content-Type")
//        request.addValue("*/*", forHTTPHeaderField: "Accept")
//        request.addValue("en;q=1", forHTTPHeaderField: "Accept-Language")
//        request.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        
        request.httpMethod = "POST"
        let dataTask: URLSessionDataTask = session.dataTask(with: request) { (data, resp, err) in
            
            var dict:NSDictionary? = nil
            do {
//                dict  = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as! NSDictionary
            } catch {
                
            }
            print("%@",dict)
            
            
        }
        
        dataTask.resume()
    }
}
