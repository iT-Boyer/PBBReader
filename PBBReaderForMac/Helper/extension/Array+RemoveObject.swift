//
//  Array+RemoveObject.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 16/5/24.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Foundation

extension RangeReplaceableCollection where Iterator.Element : Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(_ object : Iterator.Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
}
