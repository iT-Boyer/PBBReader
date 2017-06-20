//
//  View+shadeGuide.swift
//  PBB
//
//  Created by pengyucheng on 16/4/26.
//  Copyright © 2016年 pyc.com.cn. All rights reserved.
//
import Foundation

// MARK: - 扩展UIView添加全屏遮罩

/*
class TraitCollectionView:UIView{
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        //
        let traitCollection = self.traitCollection
        
        switch traitCollection.userInterfaceIdiom {
        case .Pad:
            print("Pad....")
        case .Phone:
            print("Phone....")
        case .TV:
            print("TV...")
        case .CarPlay:
            print("carPlay...")
        case .Unspecified:
            print("Unspecified...")
        }
        
        switch traitCollection.horizontalSizeClass {
        case .Compact:
            print("compact...")
        case .Regular:
            print("regular...")
        case .Unspecified:
            print("unspecified...")
        }
        
        switch traitCollection.verticalSizeClass {
        case .Compact:
            print("compact...")
        case .Regular:
            print("regular...")
        case .Unspecified:
            print("unspecified...")
        }
    }

}
*/

extension NSView{
    
    
    var leftTraitHrizontalOfLeftItem:CGFloat{
//        return traitCollection.userInterfaceIdiom == .Pad ? 20 : 16
        return 16
    }
    var rightTraitHrizontalOfRightItem:CGFloat{
//        return traitCollection.userInterfaceIdiom == .Pad ? 6 : 3
        return 3
    }
    
    public var backgroundImageView:NSImageView{
        get{
            
            return self.backgroundImageView
        }
        set{
            self.addSubview(newValue)
            //self.bringSubviewToFront(newValue)
            //将newValue视图移动到self.subviews最底层
            //self.sendSubviewToBack(newValue)
            newValue.translatesAutoresizingMaskIntoConstraints = false
            let backgroundImageViewV = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[ImageView]-0-|",
                                                                                      options: [],
                                                                                      metrics: nil,
                                                                                      views: ["ImageView":newValue])
            let backgroundImageViewH = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[ImageView]-0-|",
                                                                                      options: [],
                                                                                      metrics: nil,
                                                                                      views: ["ImageView":newValue])
            self.addConstraints(backgroundImageViewH)
            self.addConstraints(backgroundImageViewV)
        }
    }
    
    
    public var leftItem:NSButton{
        
        get{
            
            let leftButton = NSButton()
            leftButton.isHidden = true
            return leftButton
        }
        
        set{
            self.addSubview(newValue)
            newValue.translatesAutoresizingMaskIntoConstraints = false
            let leftItem_Vconstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-27-[leftItem]",
                                                                                       options: [],
                                                                                       metrics: nil,
                                                                                       views: ["leftItem":newValue])
            let leftItem_Hconstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-leftConstant-[leftItem]",
                                                                                       options: [],
                                                                                       metrics: ["leftConstant":NSNumber(leftTraitHrizontalOfLeftItem)],
                                                                                       views: ["leftItem":newValue])
            self.addConstraints(leftItem_Hconstraints)
            self.addConstraints(leftItem_Vconstraints)
            newValue.target = self
            newValue.action = #selector(NSView.hiddenGuideItem(_:))
        }
        
    }
    
    
    public var rightItem:NSButton{
        
        get{
            return self.rightItem
        }
        set{
            
            self.addSubview(newValue)
            
            newValue.translatesAutoresizingMaskIntoConstraints = false
            
            
            let rightItem_Vconstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-31-[rightItem]",
                                                                                        options: [],
                                                                                        metrics: nil,
                                                                                        views: ["rightItem":newValue])
            let rightItem_Hconstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[rightItem]-rightConstant-|",
                                                                                        options: [],
                                                                                        metrics: ["rightConstant":NSNumber(rightTraitHrizontalOfRightItem)],
                                                                                        views: ["rightItem":newValue])
            self.addConstraints(rightItem_Hconstraints)
            self.addConstraints(rightItem_Vconstraints)
            newValue.target = self
            newValue.action = #selector(NSView.hiddenGuideItem(_:))
        }
        
    }
    public func addGuideShadeToFullScreen(){
        //
        NSApplication.shared().keyWindow?.contentView!.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[self]-0-|",
                                                                          options: [],
                                                                          metrics: nil,
                                                                          views: ["self":self])
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[self]-0-|",
                                                                          options: [],
                                                                          metrics: nil,
                                                                          views: ["self":self])
        superview?.addConstraints(vConstraints)
        superview?.addConstraints(hConstraints)
    }
    
    //嵌套函数，隐藏操作
    func hiddenGuideItem(_ item:NSButton) {
        //
        print("隐藏操作。。。。")
        item.isHidden = true
        for view in self.subviews {
            //
            if view != item && view.isHidden {
                //
                self.isHidden = true
                self.removeFromSuperview()
            }
        }
    }
    
    
//    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator:UIViewControllerTransitionCoordinator){
//            super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
//            coordinator.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
//                if (newCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact) {
//                        //To Do: modify something for compact vertical size
//                
//                } else {
//                    //To Do: modify something for other vertical size
//                    
//                }
//                    self.view.setNeedsLayout()
//                }, completion: nil)
//    }
    
}
