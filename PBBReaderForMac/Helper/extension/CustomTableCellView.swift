//
//  CustomTableCellView.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 16/9/7.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Cocoa

/// 通过监听cell选中事件发送广播，来控制背景图片的显示/隐藏
class CustomTableCellView: NSTableCellView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    //当前ID
    var cellID:Int = 0
    //选中的背景图片
    @IBOutlet weak var ibCellBackgroundImageView: NSImageView!
    @IBOutlet weak var ibFileTypeIamge: NSImageView!
    
    
    //当被选中时，添加监听通知，同时发出取消通知
    func SendBySelecedNotification(_ isManySelected:Bool) {
        //
        ibCellBackgroundImageView.isHidden = false
        //通知
        NotificationCenter.default.post(name: Notification.Name(rawValue: "BYSELECED_IS_ME"), object: self, userInfo: ["pycFileID":cellID,"isManySelected":isManySelected])
        //监听
        NotificationCenter.default.addObserver(self, selector: #selector(CustomTableCellView.CancelSelectedStatus(_:)), name: NSNotification.Name("BYSELECED_IS_ME"), object: nil)
    }
    
    //取消选中状态，移除监听事件
    @objc func CancelSelectedStatus(_ info:Notification) {
        //多选模式
        let isManySelected = (info as NSNotification).userInfo!["isManySelected"] as! Bool
        if !isManySelected {
            let fileID = (info as NSNotification).userInfo!["pycFileID"] as! Int
            if fileID != cellID {
                //重置默认状态
                ibCellBackgroundImageView.isHidden = true
                NotificationCenter.default.removeObserver(self)
            }
        }
    }
    
}
