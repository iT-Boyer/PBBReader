//
//  Array+RemoveObject.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 16/5/24.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Foundation

extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}