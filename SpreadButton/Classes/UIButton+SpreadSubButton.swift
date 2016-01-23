//
//  UIButton+SpreadSubButton.swift
//  SpreadButton
//
//  Created by lzy on 16/1/22.
//  Copyright © 2016年 lzy. All rights reserved.
//

import UIKit


//TODO: 未解决携带闭包问题
extension UIButton {
    
    
//    var
//    var tapBlock: ButtonClickBlock?
    
    class func createSpreadSubButton(backgroundImage: UIImage?, highlightImage: UIImage?, clickedBlock: ButtonClickBlock?) -> UIButton? {
        guard let nonNilBackgroundImage = backgroundImage else {
            print("backgroundImage can not be nil")
            return nil
        }
        let buttonFrame = CGRectMake(0, 0, nonNilBackgroundImage.size.width, nonNilBackgroundImage.size.height)
        let subButton = UIButton(frame: buttonFrame)
        subButton.setBackgroundImage(nonNilBackgroundImage, forState: .Normal)
        
        if let nonNilHighlightImage = highlightImage {
            subButton.setBackgroundImage(nonNilHighlightImage, forState: .Highlighted)
        }
        
        
        if let nonNilClickedBlock = clickedBlock {
//            objc_setAssociatedObject(self, &KEY_BUTTON_CLICK_BLOCK, nonNilClickedBlock as! AnyObject, .OBJC_ASSOCIATION_COPY_NONATOMIC)

        }
        
        return subButton
    }
    
    
    
    
    
    
}