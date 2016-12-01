//
//  DeviceXMLParser.swift
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

class DeviceXMLParser: NSObject,XMLParserDelegate
{
    //启动解析
    
    func parserDevier(outData:Data)
    {
        //
        let parser = XMLParser.init(data: outData)
        parser.delegate = self
        parser.parse()
//        return Dictionary()
    }
    
    //解析协议方法
    var currentNodeName = ""
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        //
        currentNodeName = elementName
        if elementName == "_items"{
            NSLog("elementName:\(elementName)")
            if let id = attributeDict["machine_model"]{
                print("id:\(id)")
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        //
        let str = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if str != "" {
            print("\(currentNodeName):\(str)")
        }
    }
}
