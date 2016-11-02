//
//  CustomRotateButton.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 16/9/13.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Cocoa

extension NSButton
{
    //static var stopRotating = false 错误提示：A declaration cannot be both 'final' and 'dynamic'
    static var stopRotating:Bool!
    
    var angle:CGFloat{
        get{
            tag = tag - 10
            return CGFloat(tag)
        }
    }
}

//方法一: 重写属性frame观察器，解决动画错位问题
//方法二: 观察者模式控制图标中心点位置
class CustomRotateButton: NSButton {
    
    
    //-------------方法一: 重写属性frame观察器，解决动画错位问题
    override var frame: NSRect{
        didSet{
//            NSLog("yyyy\(oldValue)")
            if frame != oldValue
            {
                resetLayerPoint()
            }
        }
    }
    
    //重置layer
    func resetLayerPoint() {
        //
        layer?.anchorPoint = NSMakePoint(0.5, 0.5)
        layer?.position = NSMakePoint(frame.origin.x + frame.width/2, frame.origin.y + frame.height/2)
    }
    
    
    
    //添加旋转动画
    func addGroupRotateAnimation(_ cellID:Int) {
        //持久化动画runing
        UserDefaults.standard.set(true, forKey: "\(cellID)")
        UserDefaults.standard.synchronize()
        
        //-------------方法二: 观察者模式控制图标中心点位置
//        addObserVerKVO()
//        resetLayerPoint()
        
        //渐隐渐现效果
        let animation = CABasicAnimation.init(keyPath: "opacity")
        animation.duration = 2.0
        animation.autoreverses = true
        animation.repeatCount = MAXFLOAT //NSIntegerMax // CGFLOAT_MAX
        animation.fromValue = NSNumber.init(value: 1.0)
        animation.toValue = NSNumber.init(value: 0.0)
        
        //自转动画
        let animation1 = CABasicAnimation.init(keyPath: "transform.rotation")
        animation1.duration = 2.0
        //        animation1.autoreverses = true
        animation1.repeatCount = MAXFLOAT
        animation1.fromValue = NSNumber.init(value: Double(self.angle))
        animation1.toValue = NSNumber.init(value: Double(self.angle))
        //        animation1.toValue = NSNumber.init(double: Double(self.angle) * (M_PI/180.0))
        
        let group = CAAnimationGroup.init()
        group.duration = 2.0
        //        group.autoreverses = true
        group.repeatCount = MAXFLOAT
        group.animations = [animation1]
        
        layer?.add(group, forKey: "")
    }
    
    //添加KVO :http://www.jianshu.com/p/e036e53d240e
    fileprivate var myContext = 0
    func addObserVerKVO() {
        //
        addObserver(self, forKeyPath: "frame", options: .new, context: &myContext)
    }
    
//    override func observeValue(forKeyPath keyPath: String?, of object: AnyObject?, change: [NSKeyValueChangeKey : AnyObject]?, context: UnsafeMutableRawPointer) {
//        //
//        if context == &myContext {
//            if let newValue = change?[NSKeyValueChangeKey.newKey] {
//                NSLog("Date changed: \(newValue)")
//                resetLayerPoint()
//            }
//        } else {
//            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
//        }
//    }
    
    deinit {
        removeObserver(self, forKeyPath: "frame", context: &myContext)
    }
}


