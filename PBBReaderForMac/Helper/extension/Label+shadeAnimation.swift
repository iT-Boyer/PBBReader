//
//  Label+shadeAnimation.swift
//  PBB
//
//  Created by pengyucheng on 16/4/5.
//  Copyright © 2016年 pyc.com.cn. All rights reserved.
//
import Cocoa

extension NSTextField
{
    
    var shadeOrigin:CGPoint{
        guard let mvFrame = superview?.bounds
        else
        {
            return CGPointMake(0,0);
        }
        //x 区间大小（0...x_max）
        let x_max = mvFrame.width - self.frame.size.width
        //y 区间大小（0...y_max）
        let y_max = mvFrame.height - self.frame.size.height - 100
        //随机区间 ＝ 区间最小值 + 随机值
        var x_random:UInt32 = 0
        var y_random:UInt32 = 0
        if x_max > 0 {
            x_random = arc4random() % UInt32(x_max)
        }
        if y_max > 0 {
            y_random = arc4random() % UInt32(y_max) + 60
        }
        
        //随机坐标 : xy坐标为控件的左上角(0,0)所以不用作一下计算
        //            let x = x_random + UInt32(self.frame.size.width)
        //            let y = y_random + UInt32(self.frame.size.height)
//        print("水印坐标：x = \(x_random),Y = \(y_random)")
        return CGPointMake(CGFloat(x_random), CGFloat(y_random))
    }
    
    
    //秒
    static var seconds:Int!
    static var minutes:Int!
    static var countDownNumber:Int!
    var second:Double{
        set{
        }
        get{
            return self.second
        }
    }
    //分
    var minute:Double{
        set(newValue){
        }
        get{
            return self.minute
        }
    }
    
    var countDownNumber:Int{
        set(newValue){
            NSTextField.countDownNumber = newValue
        }
        get{
            return NSTextField.countDownNumber
        }
    }
    
    func fireTimer(Countdown:Double)->()->()
    {
        //倒计时
        var timer:NSTimer!
        
        if Countdown > 0 {
            NSTextField.countDownNumber = Int(Countdown)
            self.translatesAutoresizingMaskIntoConstraints = false
            let textFieldV = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[textField]",
                                                                                      options: [],
                                                                                      metrics: nil,
                                                                                      views: ["textField":self])
            let textFieldH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[textField]-0-|",
                                                                                      options: [],
                                                                                      metrics: nil,
                                                                                      views: ["textField":self])
            superview?.addConstraints(textFieldH)
            superview?.addConstraints(textFieldV)
            
            self.editable = false
            self.bordered = false
            
//            (self as NSControl).alignment = NSTextAlignment(rawValue:2)!
            self.alignment = NSTextAlignment(rawValue:2)!
//            (self as NSControl).font = NSFont.systemFontOfSize(CGFloat(20))
            self.font = NSFont.systemFontOfSize(CGFloat(20))
            self.textColor = NSColor.whiteColor()
            self.backgroundColor = NSColor.grayColor()
            
            NSTextField.minutes = Int(Countdown / 60)
            NSTextField.seconds = Int(Countdown % 60)
            timer = NSTimer(timeInterval: 1.0, target: self, selector: #selector(NSTextField.Countdown), userInfo: nil, repeats: true)
            
        }else if Countdown == 0{
            //水印
            if (stringValue as NSString).length == 0 {
                return {}
            }
            //默认显示，24s之后隐藏
            timer = NSTimer(timeInterval: 24.0, target: self, selector: #selector(NSTextField.hiddenShade as (NSTextField) -> () -> ()), userInfo: nil, repeats: true)
        }
        else
        {
            self.hidden = true
            return {}
        }
        
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        
        //匿名函数
       return {
            self.animator().alphaValue = 1
            self.hidden = false
            timer.invalidate()
//            print("关闭隐藏动画....")
        }
    }

    @objc func Countdown() {
        //
        if NSTextField.minutes > 0 {
            //ms
            self.stringValue = "\(Int(NSTextField.minutes))分\(Int(NSTextField.seconds))秒"
            
            if (NSTextField.seconds == 0) {
                NSTextField.minutes = NSTextField.minutes - 1
                NSTextField.seconds = 60
            }
            
            NSTextField.seconds = NSTextField.seconds - 1
            
        }else{
            
            //背景色
            if (NSTextField.seconds < 10)
            {
                self.animator().alphaValue = 0.7
                self.backgroundColor = NSColor.redColor()
                if (NSTextField.seconds == 0)
                {
                    //关闭播放器
                    NSNotificationCenter.defaultCenter().postNotificationName("CancleClosePlayerWindows", object: nil)
                }
            }
            //s
            self.stringValue = "\(Int(NSTextField.seconds))秒"
            NSTextField.seconds = NSTextField.seconds - 1
        }
//        self.sizeToFit()
        NSTextField.countDownNumber = NSTextField.countDownNumber - 1
    }
    
    func hiddenShade()
    {
        //
        NSAnimationContext.runAnimationGroup({ (context) in
            //
            context.duration = 1.0
            self.hidden = true
            self.animator().alphaValue = 0
            
        }) {
//            print("\(NSDate())水印隐藏....")
            //隐藏20秒之后，再显示出来
            NSTimer.scheduledTimerWithTimeInterval(18.0, target: self, selector: #selector(NSTextField.show), userInfo: nil, repeats: false)
        }

    }
    
    func show()
    {
        //动画
        NSAnimationContext.runAnimationGroup({ (context) in
            //
            context.duration = 0
            self.hidden = false
            self.animator().alphaValue = 1
            self.animator().setFrameOrigin(self.shadeOrigin)
            
            }) { 
//                print("\(NSDate())水印显示....")
        }
    }
}