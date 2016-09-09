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
    static var stopRotating = false
    static var angle = 0.0
    
    func startRotate() {
        //
        NSButton.stopRotating = false
        self.rotateRefreshImage()
    }
    
    func endUpdating() {
        //
         NSButton.stopRotating = true
    }
    
    /* http://www.tanhao.me/pieces/702.html/
     * Mac不支持tranform
       let endAngle = CGAffineTransformMakeRotation(CGFloat(NSButton.angle * (M_PI/180.0))) //M_PI
       self.transform = endAngle
     */
    func rotateRefreshImage() {
        //动画组
        NSAnimationContext.runAnimationGroup({ (context) in
                //
                context.duration = 0.05
                self.animator().alphaValue = 1
                let rotation = self.frameRotation + 360
                self.animator().setFrameOrigin(NSZeroPoint)
                self.animator().frameRotation = rotation
            })
             {
                if !NSButton.stopRotating
                {
                    self.rotateRefreshImage()
                }
            }
    }
    
    //动画组其他实现
    func startAnimation() {
        //
        let animation = CABasicAnimation.init(keyPath: "opacity")
        animation.duration = 2.0
        animation.autoreverses = true
        animation.repeatCount = MAXFLOAT //NSIntegerMax // CGFLOAT_MAX
        animation.fromValue = NSNumber.init(float: 1.0)
        animation.toValue = NSNumber.init(float: 0.0)
        
        let animation1 = CABasicAnimation.init(keyPath: "transform.rotation")
        animation1.duration = 2.0
        animation1.autoreverses = true
        animation1.repeatCount = MAXFLOAT
        animation1.fromValue = NSNumber.init(float: 0)
        animation1.toValue = NSNumber.init(double: 2 * M_PI)
        
        let group = CAAnimationGroup.init()
        group.duration = 2.0
        group.autoreverses = true
        group.repeatCount = MAXFLOAT
        group.animations = [animation,animation1]
        self.layer?.addAnimation(group, forKey: "")
    }
    
    
    
    
    
    
    
    
    
}
