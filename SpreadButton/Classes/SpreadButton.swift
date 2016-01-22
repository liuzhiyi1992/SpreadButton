//
//  SpreadButton.swift
//  SpreadButton
//
//  Created by lzy on 16/1/18.
//  Copyright © 2016年 lzy. All rights reserved.
//

import UIKit


let π = CGFloat(M_PI)

class SpreadButton: UIView {
    
    enum SpreadDirection {
        case SpreadDirectionTop
        case SpreadDirectionBottom
        case SpreadDirectionLeft
        case SpreadDirectionRight
    }
    
    var animationDuring = 0.5
    
    var coverColor: UIColor {
        set { cover.backgroundColor = newValue }
        get { return cover.backgroundColor! }
    }
    
    
    
    var direction: SpreadDirection = .SpreadDirectionTop {
        didSet {
            print("didset")
            if direction == .SpreadDirectionTop || direction == .SpreadDirectionLeft || direction == .SpreadDirectionRight || direction == .SpreadDirectionBottom {
                spreadAngle = 120.0
            } else {
                spreadAngle = 90.0
            }
        }
    }
    
    var radius: CGFloat = 100.0
    
    var subButtons: [UIButton]?
    var subButtonImages: NSArray?//装字典，字典里有普通image和highlightImage
    
    
    private let defaultCoverColor = UIColor.lightGrayColor()
    
    private var powerButton: UIButton!
    private var cover: UIView!
    
    private var powerButtonPosition: CGPoint {//记录Power相对于super的位置，还没展开时，就是SpreadButton的位置
        get { return self.powerButton.center }
        set {
            self.center = newValue
            superViewRelativePosition = newValue
        }
    }
    
    private var isSpread = false
    
    private var superViewRelativePosition: CGPoint!//记录展开按钮相对于super的位置
    
    private var spreadAngle: CGFloat = 120.0
    
    //    var angle = {(direction: SpreadDirection) -> CGFloat in
    //        let startSpace: CGFloat = (180 - spreadAngle)/2
    //        switch direction {
    //        case .SpreadDirectionTop:
    //            return -180 + startSpace
    //        case .SpreadDirectionBottom:
    //            return 180 - startSpace
    //        case .SpreadDirectionLeft:
    //            return 90 + startSpace
    //        case .SpreadDirectionRight:
    //            return -90 + startSpace
    //        }
    //    }
    
    
    
    
    
    
    
    
    init?(image: UIImage?, highlightImage: UIImage?) {
        guard let nonNilImage = image, let nonNilHighlightImage = highlightImage else {
            fatalError("ERROR, image can not be nil")
        }
        let mainFrame = CGRectMake(0, 0, nonNilImage.size.width, nonNilImage.size.height)
//        direction = .SpreadDirectionTop
        super.init(frame: mainFrame)
        configureMainButton(nonNilImage, highlightImage: nonNilHighlightImage)
        configureCover()
    }
    
    override init(frame: CGRect) {
//        direction = .SpreadDirectionTop
        super.init(frame: frame)
        
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureMainButton(image: UIImage, highlightImage: UIImage) {
        powerButton = UIButton(frame: CGRectMake(0, 0, image.size.width, image.size.height))
        //初始位置
        powerButtonPosition = CGPointMake(UIScreen.mainScreen().bounds.width/2, UIScreen.mainScreen().bounds.height - 50)
        powerButton.setBackgroundImage(image, forState: .Normal)
        powerButton.setBackgroundImage(highlightImage, forState: .Highlighted)
        powerButton.addTarget(self, action: "tapPowerButton:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(powerButton)
    }
    
    func configureCover() {
        cover = UIView(frame: self.bounds)
        cover.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        cover.userInteractionEnabled = true
        cover.backgroundColor = defaultCoverColor
        cover.alpha = 0
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapCover")
        cover.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    func tapPowerButton(button: UIButton) {
        print(button)
        isSpread ? closeButton() : spreadButton()
    }
    
    func tapCover() {
        if isSpread {
            closeButton()
        }
    }
    
    func spreadButton() {
        guard subButtons != nil else {
            print("subButton can not be nil")
            return
        }
        
        print("spread")
        isSpread = true
        
        //改变frame, 充满superView
        if (superview != nil) {
            frame = (superview?.bounds)!
        }
        //powerButton 改变位置
        powerButton.center = superViewRelativePosition
        //cover出来
        self.insertSubview(cover, belowSubview: powerButton)
        
        //cover渐现动画
        UIView.animateWithDuration(0.5) { () -> Void in
            self.cover.alpha = 0.5
            self.powerButtonSpreadAnimate()
        }
        
        //按钮展开
        spreadSubButton()
        
        
    }
    
    
    func spreadSubButton() {
        direction = .SpreadDirectionLeft
        
        let subButtonCrackAngle = spreadAngle / CGFloat(subButtons!.count - 1)
        //startAngle
        var angle: CGFloat
        let startSpace: CGFloat = (180 - spreadAngle)/2
        
        switch direction {
            case .SpreadDirectionTop:
                angle = startSpace
            case .SpreadDirectionBottom:
                angle = -180 + startSpace
            case .SpreadDirectionLeft:
                angle = 90 + startSpace
            case .SpreadDirectionRight:
                angle = -90 + startSpace
        }
        
        for btn in self.subButtons! {
            btn.transform = CGAffineTransformMakeTranslation(1.0, 1.0)
            self.insertSubview(btn, belowSubview: powerButton)
            btn.frame = powerButton.frame
            //to do 抖动效果
            let outsidePoint = calculatePoint(angle, radius: radius)

            let animationPath = movingPath(btn.layer.position, endPoint: outsidePoint, keyPoints: outsidePoint)
            
            let positionAnimation = CAKeyframeAnimation(keyPath: "position")
            positionAnimation.path = animationPath.CGPath
            positionAnimation.values = [0.0, 0.8, 1.0]
            positionAnimation.duration = animationDuring
            btn.layer.addAnimation(positionAnimation, forKey: "spread")
            
            CATransaction.begin()
            //设置kCATransactionDisableActions的valu为true, 来禁用layer的implicit animations
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            btn.layer.position = outsidePoint
            CATransaction.commit()
            
            angle += subButtonCrackAngle
        }
    }
    
    func movingPath(startPoint: CGPoint, endPoint: CGPoint, keyPoints: CGPoint...) -> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(startPoint)
        for point in keyPoints {
            path.addLineToPoint(point)
        }
        path.moveToPoint(endPoint)
        return path
    }
    
    
    func closeButton() {
        print("close")
        isSpread = false
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.cover.alpha = 0
            self.powerButtonCloseAnimate()
            }) { (flag) -> Void in
                self.cover.removeFromSuperview()
                self.frame = self.powerButton.frame
                self.powerButton.frame = self.bounds
        }
    }
    
    
    func calculatePoint(angle: CGFloat, radius: CGFloat) -> CGPoint {
        //根据弧度和半径计算点的位置
        //center => powerButton
        
        switch direction {
        case .SpreadDirectionTop:
            return CGPoint(x: powerButton.center.x + cos(angle/180.0 * π) * radius, y: powerButton.center.y - sin(angle/180.0 * π) * radius)
        case .SpreadDirectionBottom:
            return CGPoint(x: powerButton.center.x + cos(angle/180.0 * π) * radius, y: powerButton.center.y - sin(angle/180.0 * π) * radius)
        case .SpreadDirectionLeft:
            return CGPoint(x: powerButton.center.x + cos(angle/180.0 * π) * radius, y: powerButton.center.y - sin(angle/180.0 * π) * radius)
        case .SpreadDirectionRight:
            return CGPoint(x: powerButton.center.x + cos(angle/180.0 * π) * radius, y: powerButton.center.y - sin(angle/180.0 * π) * radius)

        }
    }
    
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        cover.frame = (newSuperview?.bounds)!
    }
    
    func powerButtonSpreadAnimate() {
        powerButton.transform = CGAffineTransformMakeRotation(CGFloat(-0.75 * π))
    }
    
    func powerButtonCloseAnimate() {
        powerButton.transform = CGAffineTransformMakeRotation(0)
    }
    
    
}
