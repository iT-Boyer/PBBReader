//
//  PBBLogClient.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 24/11/2016.
//  Copyright © 2016 recomend. All rights reserved.
//

//let url = "http://114.112.104.138:6001/HostMonitor/client/log/addLog"
let url = "http://192.168.85.92:8099/HostMonitor/client/log/addLog"
class PBBLogClient
{
    
    //上传
    func upLoadLog(to URL:String = url,logData logModel:PBBLogModel)
    {
        let URL = Foundation.URL(string: url)
        var request = URLRequest(url: URL!)
        //application/json Accept-Language:en;q=1
        request.addValue("multipart/form-data; boundary=Boundary+7B85D32FB0763B96", forHTTPHeaderField: "Content-Type")
        request.addValue("*/*", forHTTPHeaderField: "Accept")
        request.addValue("en;q=1", forHTTPHeaderField: "Accept-Language")
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
                                                let dataFormatToString = String(data: receiveData, encoding:String.Encoding.utf8)
                                                NSLog("上传成功。\(dataFormatToString)。。\(error)")
                                                if JSONSerialization.isValidJSONObject(receiveData)
                                                {
                                                    let data1 = try! JSONSerialization.data(withJSONObject: receiveData, options: .prettyPrinted)
                                                }
                                            }
                                        })
            uploadTask.resume()
        }
        
      
    }
}
