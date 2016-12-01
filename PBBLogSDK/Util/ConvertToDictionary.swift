//
//  ConvertToDictionary.swift
//  PBBReaderForMac
//
//  Created by huoshuguang on 2016/11/27.
//  Copyright © 2016年 recomend. All rights reserved.
//


#if os(OSX)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif


extension NSObject{
    
//    var toDictionary:[String:Any]?{
//        
//        guard self.toDictionary != nil else {
//            return self.toDictionary
//        }
//        return convertToDictionary()
//    }
    
    func convertToDictionary() -> [String:Any]
    {
        //
        var targetDic:[String:Any] = [:]
        var propsCount:UInt32 = 0;
        //object_getClass(self) 等价于type(of: self)
        if let properties:UnsafeMutablePointer<objc_property_t?> = class_copyPropertyList(type(of: self), &propsCount)
        {
            for i in 0..<propsCount
            {
                //
                if let property:objc_property_t = properties[Int(i)]
                {
                    //http://stackoverflow.com/questions/30895578/get-all-the-keys-for-a-class/30895965#30895965
                    if let propName =  String(cString: property_getName(property),
                                              encoding: String.Encoding.utf8)
                    {
                        if propName == "description" {
                            continue
                        }
                        //NSLog("\(propsCount)个，属性\(i)：\(propName)")
                        if var value = self.value(forKey: propName)
                        {
                            value = getObjectInternal(value: value)
                            targetDic.updateValue(value, forKey: propName)
                        }
                    }
                }
            }
        }
        return targetDic
    }
    
    fileprivate func getObjectInternal(value:Any) -> Any
    {
        //
        if value is String
            || value is NSNumber
            || value is NSData
        {
            //
            return value
        }
        
        if value is NSArray {
            //
            let tmpArr = value as! NSArray
            let targetArr = NSMutableArray()
            tmpArr.enumerateObjects({ (obj, index, nil) in
                //
                targetArr.add(getObjectInternal(value: obj))
            })
            return targetArr
        }
        
        if value is NSDictionary {
            let tmpDict = value as! NSDictionary
            let targetDict = NSMutableDictionary()
            for key in tmpDict.allKeys {
                //
                let value = tmpDict.object(forKey: key)
                targetDict.setValue(getObjectInternal(value: value as Any), forKey: key as! String)
            }
            return targetDict
        }
        //当不满足上述基本类型时，获取该对象的所有属性名，继续迭代这个自定义类的说有属性
        return convertToDictionary()
    }

    
    func requestBody()->String
    {
        let dic = convertToDictionary()
        let allKeys:[String] = (dic as NSDictionary).allKeys as! [String]
        var body = ""
        for key in allKeys {
            body += "\(key)=\(dic[key]!)&"
        }
        return body
    }
}
