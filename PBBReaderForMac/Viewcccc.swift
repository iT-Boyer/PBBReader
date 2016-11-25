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
        
        request.httpMethod = "POST"
        
        var jsonData:NSData? = nil
        do {
            
            jsonData = try JSONSerialization.data(withJSONObject: params, options:
                JSONSerialization.WritingOptions.prettyPrinted) as NSData?
        } catch {
            
        }
        
        request.httpBodyStream = InputStream.init(data: jsonData as! Data)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("en;q=1", forHTTPHeaderField: "Accept-Language")
        
        let dataTask: URLSessionDataTask = session.dataTask(with: request) { (data, resp, err) in
            
            var dict:NSDictionary? = nil
            do {
                dict  = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as! NSDictionary
            } catch {
                
            }
            print("%@",dict)
            
            
        }
        
        dataTask.resume()
    }
}
