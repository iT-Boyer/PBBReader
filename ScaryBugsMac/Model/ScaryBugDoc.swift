//
//  ScaryBugDoc.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 16/5/23.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Foundation
import AppKit

class ScaryBugDoc:Equatable {
    //
    var data:ScaryBugData
    var thumbImage:NSImage
    var fullImage:NSImage
    
    init(title:String,rating:Float,thumbImage:NSImage,fullImage:NSImage){
    
        self.data = ScaryBugData.init(title: title, rating: rating)
        self.thumbImage = thumbImage
        self.fullImage = fullImage
    }
    
    //sampleData
    class func getSampleData() -> Array<ScaryBugDoc> {

        // Setup sample data
        let bug1 = ScaryBugDoc.init(title: "Potato Bug",
                                    rating: 4,
                                    thumbImage: NSImage.init(named: "potatoBugThumb")!,
                                    fullImage: NSImage.init(named: "potatoBug")!)
        let bug2 = ScaryBugDoc.init(title: "House Centipede",
                                    rating: 3,
                                    thumbImage: NSImage.init(named: "centipedeThumb")!,
                                    fullImage: NSImage.init(named: "centipede")!)
        let bug3 = ScaryBugDoc.init(title: "Wolf Spider",
                                    rating: 5,
                                    thumbImage: NSImage.init(named: "wolfSpiderThumb")!,
                                    fullImage: NSImage.init(named: "wolfSpider")!)
        let bug4 = ScaryBugDoc.init(title: "Lady Bug",
                                    rating: 1,
                                    thumbImage: NSImage.init(named: "ladybugThumb")!,
                                    fullImage: NSImage.init(named: "ladybug")!)
        
        return [bug1,bug2,bug3,bug4]
        
    }
    
}

//Equatable:
//该协议要求任何遵循的类型实现等式符(==)和不等符(!=)对任何两个该类型进行比较。所有的Swift标准类型自动支持Equatable协议
func == (lhs: ScaryBugDoc, rhs: ScaryBugDoc) -> Bool {
    return lhs.fullImage == lhs.fullImage
}