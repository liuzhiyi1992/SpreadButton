//
//  SpreadSubButton.swift
//  SpreadButton
//
//  Created by lzy on 16/1/22.
//  Copyright © 2016年 lzy. All rights reserved.
//

import UIKit

typealias ButtonClickBlock = (index: Int, sender: UIButton) -> Void

class SpreadSubButton: UIButton {
    
    var clickedBlock: ButtonClickBlock?
    
    init(backgroundImage: UIImage?, highlightImage: UIImage?, clickedBlock: ButtonClickBlock?) {
        
        guard let nonNilBackgroundImage = backgroundImage else {
            fatalError("ERROR, image can not be nil")
        }
        
        let buttonFrame = CGRectMake(0, 0, nonNilBackgroundImage.size.width, nonNilBackgroundImage.size.height)
        super.init(frame: buttonFrame)
        self.setBackgroundImage(nonNilBackgroundImage, forState: .Normal)
        
        if let nonNilHighlightImage = highlightImage {
            self.setBackgroundImage(nonNilHighlightImage, forState: .Highlighted)
        }
        
        self.clickedBlock = clickedBlock
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}