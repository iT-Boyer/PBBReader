//
//  PycSocketClientManager.swift
//  ScaryBugsMac
//
//  Created by pengyucheng on 16/6/1.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Cocoa

struct ReceiveData {
    //
    var returnValue = 0
    init(returnValue:Int){
        self.returnValue = returnValue
    }
}

protocol PycSocketManagerDelegate{
    //查看获取文件信息
    func PycSocketManager(Manager:PycSocketClientManager,didFinishSeePycFileForUser:ReceiveData)->()
    //更新文件获取信息
    func PycSocketManager(Manager:PycSocketClientManager,didFinishGetFileInfo:ReceiveData) -> ()
}

class PycSocketClientManager{
    
    var Delegate:PycSocketManagerDelegate!
    var filePycNameFromServer = ""
    func SeePycSocketFile(pycFileName:String,logName:String?,var fileName:String,phoneOn:String,messageID:String,inout isOffLine:Bool,openedNum:Int) -> String {
        //
        if fileName == "" {
            fileName = (pycFileName as NSString).lastPathComponent
            filePycNameFromServer = fileName
        }
        
        //文件是否存在
        if !NSFileManager.defaultManager().fileExistsAtPath(pycFileName) {
            //
            return "1"
        }
        guard let _ = logName else{
            //
            return "2"
        }
        
        var hashValue:[UInt8]?
        
        
        
        
        
        
        
        return ""
    }
    
    
    
    
}
