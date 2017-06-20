//: [Previous](@previous)

import Foundation
import PBBLogSDK
//: 检测两个字母串是否是仅排序不同的相同字母组成的词。
func checkWord(_ word:String,_ isAnagramOfWord:String)->Bool
{
        return false
}

let url = "http://114.112.104.138:6001/HostMonitor/client/log/addLog"
let model = PBBLogModel.init(.LogTypeFatal,
                             APPName: .APPNameReader,
                             description: "ddddd")
let log = PBBLogAPI.shareInstance.upLoadLog(to: url, logModel: model)






































//: [Next](@next)
