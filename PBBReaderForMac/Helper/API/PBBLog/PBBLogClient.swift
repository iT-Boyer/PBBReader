//
//  PBBLogClient.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 24/11/2016.
//  Copyright © 2016 recomend. All rights reserved.
//
#if os(OSX)
    import Cocoa
    import AppKit
    import Foundation
#elseif os(iOS)
    import UIKit
#endif

class PBBLogClient
{
    
    func upLoadLog(to serverUrl:String = url,logData logModel:PBBLogModel)
    {
        //
        var request = URLRequest(url: URL(string: serverUrl)!)
        let data = logModel.requestBody().data(using: .utf8)
        request.httpBodyStream = InputStream.init(data: data!)
        request.httpMethod = "POST"
        let dataTask: URLSessionDataTask = URLSession.shared.dataTask(with: request) {
            (data, resp, err) in
            print("响应的服务器地址：\(resp?.url?.absoluteString)")
            var dict:NSDictionary? = nil
            do {
                dict  = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as? NSDictionary
            } catch {
                
            }
            print("\(dict)")
        }
        dataTask.resume()
    }
    
    //上传
    func upLoadLogg(to URL:String = url,logData logModel:PBBLogModel)
    {
        let URL = Foundation.URL(string: URL)
        var request = URLRequest(url: URL!)
        //application/json Accept-Language:en;q=1
//        Content-Type: multipart/form-data; boundary=Boundary+29E471EAEC23B6A0
//        Connection: keep-alive
//        Accept: */*
//         User-Agent: RBAC/1.0 (iPhone; iOS 10.1; Scale/3.00)
//         Accept-Language: en;q=1
//         Accept-Encoding: gzip, deflate
//         Content-Length: 1575
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.addValue("en;q=1", forHTTPHeaderField: "Accept-Language")
//        request.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.cachePolicy = .reloadIgnoringCacheData
        if let sendData = logModel.toData()
        {
            let uploadTask = URLSession.shared.uploadTask(with: request,
                                                 from: sendData,
                                    completionHandler: {
                                                (data, response, error) in
                                                
                                            if let receiveData = data
                                            {
                                                let dataFormatToString = String(data: receiveData,
                                                                         encoding: String.Encoding.utf8)
                                                NSLog("上传成功。\(dataFormatToString)。。\(error)")
                                                if JSONSerialization.isValidJSONObject(receiveData)
                                                {
                                                    _ = try! JSONSerialization.data(withJSONObject: receiveData,
                                                                                              options: .prettyPrinted)
                                                    NSLog("")
                                                }
                                            }
                                        })
            uploadTask.resume()
        }
    }
}
