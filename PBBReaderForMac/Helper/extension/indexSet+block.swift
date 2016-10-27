//
//  indexSet+block.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 2016/10/11.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Foundation

extension IndexSet {
    func bs_indexPathsForSection(_ section: Int) -> [IndexPath] {
        return self.map { IndexPath(item: $0, section: section) }
    }
}
