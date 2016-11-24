//
//  PBBLogClient.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 24/11/2016.
//  Copyright © 2016 recomend. All rights reserved.
//

let url = "http://114.112.104.138:6001/HostMonitor/client/log/addLog"
class PBBLogClient
{
    
    //上传
    func upLoadLog(to URL:String = url,logData logModel:PBBLogModel)
    {
        let URL = Foundation.URL(string: URL)
        let request = URLRequest(url: URL!)
        
        let uploadTask = URLSession.shared.uploadTask(with: request,
                                                      from: logModel.toData(),
                                                      completionHandler: {
                                                        (data, response, error) in
                                                        //解析上传后，返回的信息
                                                       let data = try! JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted)
                                                       NSLog("上传成功。\(data)。。。。\(error)")
        })
        uploadTask.resume()
    }

}
