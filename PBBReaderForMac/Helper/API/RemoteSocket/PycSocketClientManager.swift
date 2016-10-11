//
//  PycSocketClientManager.swift
//  PBBReaderForMac
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
    func PycSocketManager(_ Manager:PycSocketClientManager,didFinishSeePycFileForUser:ReceiveData)->()
    //更新文件获取信息
    func PycSocketManager(_ Manager:PycSocketClientManager,didFinishGetFileInfo:ReceiveData) -> ()
}

class PycSocketClientManager{
    
    var Delegate:PycSocketManagerDelegate!
    var filePycNameFromServer = ""
    func SeePycSocketFile(_ pycFileName:String,logName:String?,fileName:String,phoneOn:String,messageID:String,isOffLine:inout Bool,openedNum:Int) -> String {
        var fileName = fileName
        //
        if fileName == "" {
            fileName = (pycFileName as NSString).lastPathComponent
            filePycNameFromServer = fileName
        }
        
        //文件是否存在
        if !FileManager.default.fileExists(atPath: pycFileName) {
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
