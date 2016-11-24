//
//  PBBLogAPI.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 24/11/2016.
//  Copyright © 2016 recomend. All rights reserved.
//
//#if os(OSX)
//import Cocoa
//#elseif os(iOS)
// import Cocoa
//#endif


public class PBBLogAPI: NSObject
{
    //创建一个属于自己类型的计算类型的类变量
    public class var shareInstance:PBBLogAPI
    {
        //嵌套一个 Singleton 结构体
        struct Singleton{
            //定义一个存储类型的类常量，
            static let instance = PBBLogAPI()
        }
        return Singleton.instance
    }
    
    fileprivate var logClient:PBBLogClient
    override init()
    {
        logClient = PBBLogClient()
        
    }
    
    public func upLoadLog(to url:String,logModel:PBBLogModel)
    {
        //
        logClient.upLoadLog(to: url,logData: logModel)
    }
    
}

