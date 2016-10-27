//
//  Toasty.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 2016/10/9.
//  Copyright © 2016年 recomend. All rights reserved.
//

/**
 TODO:
 - Toast vertical alignment (Top, Center, Bottom).
 - Add width/height FillAvailableArea/FitToText options.
 - Toast horizontal aligment (Left, Center, Right).
 - Queue vs show over.
 - OS X support.
 - Show toast with NSAttributedString.
 */

import Foundation
#if os(OSX)
    import AppKit
#else
    import UIKit
#endif

// MARK: - Style Structure

public struct ToastyStyle {
    
    
    public var borderWidth: CGFloat = 0
    public var borderColor: CGColor? = nil
    
    public var cornerRadius: CGFloat = 0
    
    #if os(OSX)
    public var backgroundColor = NSColor.black.withAlphaComponent(0.8)
    public var textColor = NSColor.white
    public var margin  = NSEdgeInsetsZero
    public var padding = EdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    #else
    public var backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
    public var textColor = UIColor.whiteColor()
    
    public var margin  = UIEdgeInsetsZero
    public var padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    #endif
    
    public var textAlignment = NSTextAlignment.center
}

// MARK: - Main Functionality

open class Toasty {
    open static var defaultStyle = ToastyStyle()
    
    open static let shortDuration: TimeInterval = 2
    open static let longDuration: TimeInterval = 3.5
    
    #if os(OSX)
    
    open static func showToastWithText(_ text: String, inView view: NSView, forDuration duration: TimeInterval = Toasty.shortDuration, usingStyle style: ToastyStyle = Toasty.defaultStyle) {
//        assert(false, "Toasty is not yet implemented for OS X")
        
        let toastView = NSView()
        toastView.wantsLayer = true
        toastView.layer?.backgroundColor = style.backgroundColor.cgColor
        toastView.layer?.borderColor  = style.borderColor
        toastView.layer?.borderWidth  = style.borderWidth
        toastView.layer?.cornerRadius = style.cornerRadius
        toastView.layer?.zPosition    = 1000
        
        
        let messageLabel = NSTextField()
        messageLabel.stringValue   = text
        messageLabel.backgroundColor = NSColor.clear
        messageLabel.textColor     = style.textColor
        messageLabel.alignment     = NSTextAlignment(rawValue:2)! //居中
        messageLabel.isEditable    = false
        
        // Add views.
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        toastView.addSubview(messageLabel)
        toastView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toastView)
        
        // Add constraints.
        toastView.addConstraints([
            NSLayoutConstraint(item: messageLabel, attribute: .top, relatedBy: .equal, toItem: toastView, attribute: .top, multiplier: 1, constant: style.padding.top),
            NSLayoutConstraint(item: messageLabel, attribute: .right, relatedBy: .equal, toItem: toastView, attribute: .right, multiplier: 1, constant: -style.padding.right),
            NSLayoutConstraint(item: messageLabel, attribute: .bottom, relatedBy: .equal, toItem: toastView, attribute: .bottom, multiplier: 1, constant: -style.padding.bottom),
            NSLayoutConstraint(item: messageLabel, attribute: .left, relatedBy: .equal, toItem: toastView, attribute: .left, multiplier: 1, constant: style.padding.left)])
        
        view.addConstraints([
            NSLayoutConstraint(item: toastView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: style.margin.top),
            NSLayoutConstraint(item: toastView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: -style.margin.right),
            NSLayoutConstraint(item: toastView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: style.margin.left)
//            NSLayoutConstraint(item: messageLabel, attribute: .Bottom, relatedBy: .Equal, toItem: toastView, attribute: .Bottom, multiplier: 1, constant: -style.padding.bottom)
            ])
        
        
        // Animate in.
        toastView.animator().alphaValue = 0
        NSAnimationContext.runAnimationGroup({ (context) in
            //
            context.duration = 0.2
            toastView.animator().alphaValue = 1
            
        }) {
            //                print("end...")
        }

        // Wait for duration and animate out.
        //http://stackoverflow.com/questions/38387939/dispatch-time-now-in-swift-3-and-backward-compatibility
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC))), DispatchQueue.main)
        //xcode8-bate
//        (DispatchQueue.main).after(when: DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) 
        //xcode8:http://stackoverflow.com/questions/24034544/dispatch-after-gcd-in-swift
//        let deadlineTime = DispatchTime.now() + .seconds(1)
        let deadlineTime = DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            NSAnimationContext.runAnimationGroup({ (context) in
                //
                context.duration = 0.2
                toastView.animator().alphaValue = 0
                
            }) {
                toastView.removeFromSuperview()
            }
        }
    }
    
    #else
    
    public static func showToastWithText(text: String, inView view: UIView, forDuration duration: NSTimeInterval = Toasty.shortDuration, usingStyle style: ToastyStyle = Toasty.defaultStyle) {
    let toastView = UIView()
    toastView.backgroundColor    = style.backgroundColor
    toastView.layer.borderColor  = style.borderColor
    toastView.layer.borderWidth  = style.borderWidth
    toastView.layer.cornerRadius = style.cornerRadius
    toastView.layer.zPosition    = 1000
    
    let messageLabel = UILabel()
    messageLabel.text          = text
    messageLabel.textColor     = style.textColor
    messageLabel.textAlignment = style.textAlignment
    
    // Add views.
    messageLabel.translatesAutoresizingMaskIntoConstraints = false
    toastView.addSubview(messageLabel)
    toastView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(toastView)
    
    // Add constraints.
    toastView.addConstraints([
    NSLayoutConstraint(item: messageLabel, attribute: .Top, relatedBy: .Equal, toItem: toastView, attribute: .Top, multiplier: 1, constant: style.padding.top),
    NSLayoutConstraint(item: messageLabel, attribute: .Right, relatedBy: .Equal, toItem: toastView, attribute: .Right, multiplier: 1, constant: -style.padding.right),
    NSLayoutConstraint(item: messageLabel, attribute: .Bottom, relatedBy: .Equal, toItem: toastView, attribute: .Bottom, multiplier: 1, constant: -style.padding.bottom),
    NSLayoutConstraint(item: messageLabel, attribute: .Left, relatedBy: .Equal, toItem: toastView, attribute: .Left, multiplier: 1, constant: style.padding.left)])
    
    view.addConstraints([
    NSLayoutConstraint(item: toastView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: style.margin.top),
    NSLayoutConstraint(item: toastView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: -style.margin.right),
    NSLayoutConstraint(item: toastView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: style.margin.left)])
    
    // Animate in.
    toastView.alpha = 0
    UIView.animateWithDuration(0.2) {
    toastView.alpha = 1
    }
    
    // Wait for duration and animate out.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
    UIView.animateWithDuration(
    0.2,
    animations: { [weak toastView] in
    toastView?.alpha = 0
    },
    completion: { [weak toastView] completed in
    toastView?.removeFromSuperview()
    })
    }
    }
    
    #endif
}

// MARK: - View Extensions

#if os(OSX)
    
    public extension NSView {
        
        public func showToastWithText(_ text: String, forDuration duration: TimeInterval = Toasty.shortDuration, usingStyle style: ToastyStyle = Toasty.defaultStyle) {
            Toasty.showToastWithText(text, inView: self, forDuration: duration, usingStyle: style)
        }
    }
    
#else
    
    public extension UIView {
        
        public func showToastWithText(text: String, forDuration duration: NSTimeInterval = Toasty.shortDuration, usingStyle style: ToastyStyle = Toasty.defaultStyle) {
            Toasty.showToastWithText(text, inView: self, forDuration: duration, usingStyle: style)
        }
    }
    
#endif
