//: [Previous](@previous)

import Foundation

//var str1 = try! NSString.init(contentsOfURL: NSURL.init(string: "http://www.pyc.com.cn/appupdate/updateinfo.txt")!, encoding: NSUTF8StringEncoding)

//var str2 = try! NSString.init(contentsOfFile: [#FileReference(fileReferenceLiteral: "updateinfo.txt")#], encoding: NSUTF8StringEncoding)

if let updateInfo = try? String(contentsOfURL: #fileLiteral(resourceName: "updateinfo.txt")){
    
        print(updateInfo)
}

if let info = NSDictionary.init(contentsOfURL:#fileLiteral(resourceName: "updateinfo.plist") )
{
    print(info.allKeys)
    print(info.allValues)
    let str = info.objectForKey("CFBundleShortVersionString")!
    print(info.valueForKey("CFBundleVersion")!)
    print(info.objectForKey("InstallerPackage")!)
}
