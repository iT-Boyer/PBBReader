//: [Previous](@previous)

import Foundation

var KDataBasePath = "123323"
let gg = KDataBasePath.appending("qwewe")
print(gg)


//: [Next](@next)


//: 测试File管理器重命名操作
let filePath = URL.init(string: "/Users/admin/Desktop/Fastfile_Fabric")
let filePath2 = URL.init(string: "/Users/admin/Desktop/Fastfile_Fabric2")
FileManager.default.fileExists(atPath: "/Users/admin/Desktop/Fastfile_Fabric")
//失败
//try! FileManager.default.moveItem(at: filePath!, to: filePath2!)

//使用路径成功
//try! FileManager.default.moveItem(atPath: "/Users/admin/Desktop/.Fastfile_Fabric2", toPath: "/Users/admin/Desktop/Fastfile_Fabric")

//: 拷贝操作

try! FileManager.default.copyItem(atPath: "/Users/admin/Desktop/Fastfile_Fabric", toPath: "/Users/admin/Desktop/Fastfile_Fabric3")