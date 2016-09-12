//
//  Button+RotateRefresh.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 16/9/9.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Cocoa

extension NSButton
{
//    A declaration cannot be both 'final' and 'dynamic'
//    static var stopRotating = false
    static var stopRotating:Bool!
    
    var angle:CGFloat{
//        set(newValue){
//        }
        get{
            tag = tag + 10
            return CGFloat(tag)
        }
    }
    
    //动画组其他实现
    var groupAnimation:CAAnimationGroup{
        //渐隐渐现效果
        let animation = CABasicAnimation.init(keyPath: "opacity")
        animation.duration = 2.0
        animation.autoreverses = true
        animation.repeatCount = MAXFLOAT //NSIntegerMax // CGFLOAT_MAX
        animation.fromValue = NSNumber.init(float: 1.0)
        animation.toValue = NSNumber.init(float: 0.0)
        
        //自转动画
        self.layer?.anchorPoint = NSMakePoint(0.5, 0.5)
        //
        layer?.position = NSMakePoint(frame.origin.x + frame.width/2, frame.origin.y + frame.height/2)
        let animation1 = CABasicAnimation.init(keyPath: "transform.rotation")
        animation1.duration = 2.0
//        animation1.autoreverses = true
        animation1.repeatCount = MAXFLOAT
        animation1.fromValue = NSNumber.init(double: Double(self.angle))
        animation1.toValue = NSNumber.init(double: Double(self.angle))
        //        animation1.toValue = NSNumber.init(double: Double(self.angle) * (M_PI/180.0))
        
        let group = CAAnimationGroup.init()
        group.duration = 2.0
//        group.autoreverses = true
        group.repeatCount = MAXFLOAT
        group.animations = [animation1]
        return group
    }
    

    func startRotate() {
        //添加动画
        layer?.addAnimation(groupAnimation, forKey: "")
        NSButton.stopRotating = false
//        self.rotateRefreshImage(false)
    }
    
    func endUpdating() {
        //
         NSButton.stopRotating = true
        
//        layer?.removeAllAnimations()
    }
    
    /* http://www.tanhao.me/pieces/702.html/
     * Mac不支持tranform
       let endAngle = CGAffineTransformMakeRotation(CGFloat(NSButton.angle * (M_PI/180.0))) //M_PI
       self.transform = endAngle
     */
    func rotateRefreshImage(isGroup:Bool)
    {
        if !isGroup {
            startGroupAnimation()
        }
        
        //迭代
        if !NSButton.stopRotating {
            rotateRefreshImage(false)
        }
    }
    
    //
    func startGroupAnimation() {
        //        var rotation = self.frameRotation
        //动画组
        NSAnimationContext.runAnimationGroup({ (context) in
            //
            context.duration = 0.05
            self.animator().alphaValue = 1
            //                let rotation = self.frameRotation + 360
            
            
            //自转
            //                self.layer?.anchorPoint = NSMakePoint(0.5, 0.5)
            //                self.animator().translateOriginToPoint(NSZeroPoint)
            //                self.animator().setBoundsOrigin(NSZeroPoint)
            self.animator().frameCenterRotation = self.angle //公转：CGFloat(Double(self.angle) * (M_PI/180.0))
            
            //公转
            //                self.animator().setFrameOrigin(NSZeroPoint)
            //                self.animator().frameRotation = self.angle
            
            //
            //            self.animator().rotateByAngle(self.angle)
            })
        {
            //                NSButton.angle = NSButton.angle + 10
            //                rotation = rotation + 10
            if !NSButton.stopRotating
            {
                self.rotateRefreshImage(true)
            }
        }
    }
}
