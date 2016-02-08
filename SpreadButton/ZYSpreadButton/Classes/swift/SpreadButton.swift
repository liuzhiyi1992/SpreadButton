//
//  SpreadButton.swift
//  SpreadButton
//
//  Created by lzy on 16/1/18.
//  Copyright © 2016年 lzy. All rights reserved.
//

import UIKit


let π = CGFloat(M_PI)

enum SpreadDirection {
    case SpreadDirectionTop
    case SpreadDirectionBottom
    case SpreadDirectionLeft
    case SpreadDirectionRight
    case SpreadDirectionLeftUp
    case SpreadDirectionLeftDown
    case SpreadDirectionRightUp
    case SpreadDirectionRightDown
}

enum SpreadMode {
    case SpreadModeSickleSpread
    case SpreadModeFlowerSpread
}

enum SpreadPositionMode {
    case SpreadPositionModeFixed
    case SpreadPositionModeTouchBorder
}

typealias ButtonWillSpreadBlock = (spreadButton: SpreadButton) -> Void
typealias ButtonDidSpreadBlock = (spreadButton: SpreadButton) -> Void
typealias ButtonWillCloseBlock = (spreadButton: SpreadButton) -> Void
typealias ButtonDidCloseBlock = (spreadButton: SpreadButton) -> Void


class SpreadButton: UIView {
    
    lazy var buttonWillSpreadBlock: ButtonWillSpreadBlock = {
        return {print("Button Will Spread")}
    }()
    
    lazy var buttonDidSpreadBlock: ButtonDidSpreadBlock = {
        return { print("Button Did Spread") }
    }()
    
    lazy var buttonWillCloseBlock: ButtonWillCloseBlock = {
        return { print("Button Will Close") }
    }()
    
    lazy var buttonDidCloseBlock: ButtonDidCloseBlock = {
        return { print("Button Did Closed") }
    }()
    
    private static let sickleSpreadAngleDefault: CGFloat = 90.0
    private static let flowerSpreadAngleDefault: CGFloat = 120.0
    private static let spredaDirectionDefault: SpreadDirection = .SpreadDirectionTop
    private static let spreadRadiusDefault: CGFloat = 100.0
    private static let coverAlphaDefault: CGFloat = 0.1
    private static let touchBorderMarginDefault: CGFloat = 10.0
    private static let touchBorderAnimationDuringDefault = 0.5
    private static let animationDuringDefault = 0.2
    
    //During
    var animationDuring = animationDuringDefault {
        didSet {
            animationDuringSpread = animationDuring
            animationDuringClose = animationDuring
        }
    }
    var animationDuringSpread = animationDuringDefault
    var animationDuringClose = animationDuringDefault
    
    var coverAlpha: CGFloat = coverAlphaDefault
    var coverColor: UIColor {
        set { cover.backgroundColor = newValue }
        get { return cover.backgroundColor! }
    }
    
    var mode: SpreadMode = .SpreadModeSickleSpread
    var positionMode: SpreadPositionMode = .SpreadPositionModeFixed
    
    var radius: CGFloat = spreadRadiusDefault
    
    var direction: SpreadDirection = spredaDirectionDefault {
        didSet {
            print("didset")
            if direction == .SpreadDirectionTop || direction == .SpreadDirectionLeft || direction == .SpreadDirectionRight || direction == .SpreadDirectionBottom {
                spreadAngle = SpreadButton.flowerSpreadAngleDefault
            } else {
                spreadAngle = SpreadButton.sickleSpreadAngleDefault
            }
        }
    }
    
    var touchBorderMargin: CGFloat = touchBorderMarginDefault
    
    
    private var subButtons: [SpreadSubButton]?
    private let defaultCoverColor = UIColor.blackColor()
    
    private var powerButton: UIButton!
    
    private var cover: UIView!
    
    private var animator: UIDynamicAnimator!
    
    private var mainFrame: CGRect!
    
    private var powerButtonPosition: CGPoint {//记录Power相对于super的位置，还没展开时，就是SpreadButton的位置
        get { return isSpread ? self.powerButton.center : self.center }
        set {
            self.center = newValue
            superViewRelativePosition = newValue
        }
    }
    
    private var isSpread = false
    
    private var superViewRelativePosition: CGPoint!//记录展开按钮相对于super的位置
    
    private var spreadAngle: CGFloat = flowerSpreadAngleDefault
    
    
    
    init?(image: UIImage?, highlightImage: UIImage?, position: CGPoint) {
        guard let nonNilImage = image else {
            fatalError("ERROR, image can not be nil")
        }
        
        let mainFrame = CGRectMake(position.x, position.y, nonNilImage.size.width, nonNilImage.size.height)
        super.init(frame: mainFrame)
        
        //save the mainFrame
        self.mainFrame = mainFrame
        self.powerButtonPosition = position
        
        configureGesture()
        configureMainButton(nonNilImage, highlightImage: highlightImage)
        configureCover()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureMainButton(image: UIImage, highlightImage: UIImage?) {
        powerButton = UIButton(frame: CGRectMake(0, 0, image.size.width, image.size.height))
        //初始位置
        powerButton.setBackgroundImage(image, forState: .Normal)
        if let nonNilhighlightImage = highlightImage {
            powerButton.setBackgroundImage(nonNilhighlightImage, forState: .Highlighted)
        }
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
    
    func configureGesture() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "panSpreadButton:")
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    func tapPowerButton(button: UIButton) {
        isSpread ? closeButton(nil) : spreadButton()
    }
    
    func tapCover() {
        if isSpread {
            closeButton(nil)
        }
    }
    
    func panSpreadButton(gesture: UIPanGestureRecognizer) {
        //drag the powerButton
        if isSpread {
            return
        }
        switch gesture.state {
        case .Began:
            animator.removeAllBehaviors()
        case .Ended:
            switch positionMode {
            case .SpreadPositionModeFixed:
                let snapBehavior = UISnapBehavior(item: self, snapToPoint: superViewRelativePosition)
                snapBehavior.damping = 0.5
                animator.addBehavior(snapBehavior)
            case .SpreadPositionModeTouchBorder:
                let location = gesture.locationInView(self.superview)
                var destinationLocation: CGPoint
                
                if location.y < 90 {//上面
                    destinationLocation = CGPointMake(location.x, self.bounds.width/2 + touchBorderMargin)
                } else if location.y > UIScreen.mainScreen().bounds.height - 90 {//下面
                    destinationLocation = CGPointMake(location.x, UIScreen.mainScreen().bounds.height - self.bounds.height/2 - touchBorderMargin)
                } else if location.x > UIScreen.mainScreen().bounds.width/2 {//右边
                    destinationLocation = CGPointMake(UIScreen.mainScreen().bounds.width - (self.bounds.width/2 + touchBorderMargin), location.y)
                } else {//左边
                    destinationLocation = CGPointMake(self.bounds.width/2 + touchBorderMargin, location.y)
                }
                
                let touchBorderAnimation = CABasicAnimation(keyPath: "position")
                touchBorderAnimation.delegate = self
                touchBorderAnimation.removedOnCompletion = false
                touchBorderAnimation.fromValue = location as? AnyObject
                touchBorderAnimation.toValue = destinationLocation as? AnyObject
                touchBorderAnimation.duration = SpreadButton.touchBorderAnimationDuringDefault
                touchBorderAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                self.layer.addAnimation(touchBorderAnimation, forKey: "touchBorder")
                
                CATransaction.begin()
                CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                self.center = destinationLocation
                CATransaction.commit()
            }
            
        default:
            let location = gesture.locationInView(self.superview)
            self.center = location
        }
    }
    
    //展开按钮
    func spreadButton() {
        guard subButtons != nil else {
            print("subButton can not be nil")
            return
        }
        //Block
        buttonWillSpreadBlock(spreadButton: self)
        animator.removeAllBehaviors()
        isSpread = true
        
        //改变frame, 充满superView
        if (superview != nil) {
            frame = (superview?.bounds)!
        }
        //position powerButton
        powerButton.center = superViewRelativePosition
        
        //insert cover
        self.insertSubview(cover, belowSubview: powerButton)
        
        //cover animation
        UIView.animateWithDuration(animationDuringSpread) { () -> Void in
            self.cover.alpha = self.coverAlpha
            self.powerButtonRotationAnimate()
        }
        //按钮展开
        spreadSubButton()
        
        //Block
        buttonDidSpreadBlock(spreadButton: self)
    }
    
    //子按钮展开动作
    func spreadSubButton() {
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
            case .SpreadDirectionLeftUp:
                angle = 90
            case .SpreadDirectionLeftDown:
                angle = 180
            case .SpreadDirectionRightUp:
                angle = 0
            case .SpreadDirectionRightDown:
                angle = -90
        }
        
        var startOutSidePoint: CGPoint!
        var startAngle: CGFloat!
        for btn in self.subButtons! {
            btn.transform = CGAffineTransformMakeTranslation(1.0, 1.0)
            self.insertSubview(btn, belowSubview: powerButton)
            btn.alpha = 1.0
            btn.center = powerButton.center
            
            let btnIndex = subButtons?.indexOf(btn)
            if btnIndex == 0 {
                startOutSidePoint = calculatePoint(angle, radius: radius)
                startAngle = angle
            }
            
            let outsidePoint = calculatePoint(angle, radius: radius)
            let shockOutsidePoint = calculatePoint(angle, radius: radius + 10)
            let shockInsidePoint = calculatePoint(angle, radius: radius - 3)
            
            let positionAnimation = CAKeyframeAnimation(keyPath: "position")
            var animationPath: UIBezierPath!
            
            switch mode {
                case .SpreadModeSickleSpread:
                    if direction == .SpreadDirectionTop || direction == .SpreadDirectionBottom || direction == .SpreadDirectionLeft || direction == .SpreadDirectionRight {
                        //---It does not provide SickleSpread in those four directions---
                        animationPath = movingPath(btn.layer.position, keyPoints: shockOutsidePoint, shockInsidePoint, outsidePoint)
                        positionAnimation.keyTimes = [0.0, 0.8, 0.93, 1.0]
                        positionAnimation.duration = animationDuringSpread
                    } else {
                        if btnIndex == 0 {
                            animationPath = movingPath(btn.layer.position, keyPoints: startOutSidePoint)
                            positionAnimation.keyTimes = [0.0, 0.2]
                        } else if btnIndex != ((subButtons?.count)! - 1) {
                            animationPath = movingPath(btn.layer.position, endPoint: startOutSidePoint, startAngle: startAngle/180*π, endAngle: angle/180*π, center: btn.layer.position)
                            positionAnimation.keyTimes = [0.0, 0.2,    0.3, 1.0]
                        }
                        else {
                            animationPath = movingPath(btn.layer.position, endPoint: startOutSidePoint, startAngle: startAngle/180*π, endAngle: angle/180*π, center: btn.layer.position, shock: true)
                            positionAnimation.keyTimes = [0.0, 0.2,    0.3, 0.9,    0.9, 0.95,   0.95, 1.0]
                        }
                        positionAnimation.duration = animationDuringSpread*(1+0.2*Double((btnIndex?.hashValue)!))
                    }
                case .SpreadModeFlowerSpread:
                    animationPath = movingPath(btn.layer.position, keyPoints: shockOutsidePoint, shockInsidePoint, outsidePoint)
                    positionAnimation.keyTimes = [0.0, 0.8, 0.93, 1.0]
                    positionAnimation.duration = animationDuringSpread
            }
            positionAnimation.path = animationPath.CGPath
            btn.layer.addAnimation(positionAnimation, forKey: "sickleSpread")
            positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            CATransaction.begin()
            //设置kCATransactionDisableActions的valu为true, 来禁用layer的implicit animations
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            btn.layer.position = outsidePoint
            CATransaction.commit()
            
            angle += subButtonCrackAngle
        }
    }
    
    
    func closeButton(exclusiveBtn: SpreadSubButton?) {
        //Block
        buttonWillCloseBlock(spreadButton: self)
        isSpread = false
        
        //cover animation
        UIView.animateWithDuration(animationDuringClose, animations: { () -> Void in
            self.cover.alpha = 0
            self.powerButtonCloseAnimate()
            }) { (flag) -> Void in
                self.cover.removeFromSuperview()
                self.frame = self.powerButton.frame
                self.powerButton.frame = self.bounds
        }
        
        closeSubButton(exclusiveBtn)
        
        //Block
        buttonDidCloseBlock(spreadButton: self)
    }
    
    func closeSubButton(exclusiveBtn: SpreadSubButton?) {
        for btn in subButtons! {
            if exclusiveBtn != nil {
                if btn != exclusiveBtn {
                    btn.removeFromSuperview()
                }
                continue
            }
            
            let animationPath = movingPath(btn.layer.position, keyPoints: powerButton.layer.position)
            let positionAnimation = CAKeyframeAnimation(keyPath: "position")
            positionAnimation.path = animationPath.CGPath
            //TODO这里错了。。times?
            positionAnimation.values = [0.0, 1.0]
            positionAnimation.duration = animationDuringClose
            positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            btn.layer.addAnimation(positionAnimation, forKey: "close")
            
            CATransaction.begin()
            //设置kCATransactionDisableActions的valu为true, 来禁用layer的implicit animations
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            btn.frame = CGRectMake(0, 0, btn.bounds.width, btn.bounds.height)
            CATransaction.commit()
        }
        
        if let nonNilExclusiveBtn = exclusiveBtn {
            let alphaAnimation = CABasicAnimation(keyPath: "opacity")
            alphaAnimation.fromValue = 1.0
            alphaAnimation.toValue = 0.0
            alphaAnimation.duration = animationDuringClose
            alphaAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
            
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.fromValue = 1.0
            scaleAnimation.toValue = 3.0
            scaleAnimation.duration = animationDuringClose
            scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
            
            let dismissGroupAnimation = CAAnimationGroup()
            dismissGroupAnimation.animations = [alphaAnimation, scaleAnimation]
            dismissGroupAnimation.duration = animationDuringClose
            
            nonNilExclusiveBtn.layer.addAnimation(dismissGroupAnimation, forKey: "closeGroup")
            
            CATransaction.begin()
            //设置kCATransactionDisableActions的valu为true, 来禁用layer的implicit animations
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            nonNilExclusiveBtn.transform = CGAffineTransformMakeScale(3.0, 3.0)
            nonNilExclusiveBtn.layer.opacity = 0.0
            CATransaction.commit()
            
        }
    }
    
    
    func calculatePoint(angle: CGFloat, radius: CGFloat) -> CGPoint {
        //根据弧度和半径计算点的位置
        //center => powerButton
        return CGPoint(x: powerButton.center.x + cos(angle/180.0 * π) * radius, y: powerButton.center.y - sin(angle/180.0 * π) * radius)
    }
    
    //移动路径
    func movingPath(startPoint: CGPoint, keyPoints: CGPoint...) -> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(startPoint)
        for point in keyPoints {
            path.addLineToPoint(point)
        }
        return path
    }
    
    func movingPath(startPoint: CGPoint, endPoint: CGPoint, startAngle: CGFloat, endAngle: CGFloat, center: CGPoint, shock: Bool = false) -> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(startPoint)
        path.addLineToPoint(endPoint)
        
        if shock {
            path.addArcWithCenter(center, radius: radius, startAngle: -startAngle, endAngle: -endAngle - 3/180*π, clockwise: false)
            path.addArcWithCenter(center, radius: radius, startAngle: -endAngle - 3/180*π, endAngle: -endAngle + 1/180*π, clockwise: true)
            path.addArcWithCenter(center, radius: radius, startAngle: -endAngle + 1/180*π, endAngle: -endAngle, clockwise: false)
        } else {
            path.addArcWithCenter(center, radius: radius, startAngle: -startAngle, endAngle: -endAngle, clockwise: false)
        }
        
        return path
    }
    
    func changeSpreadDirection() {
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        let centerAreaWidth = screenWidth - 2 * radius
        let location = self.center
        //改变Spreading的位置
        superViewRelativePosition = location
        
        if location.x < screenWidth/2 - centerAreaWidth/2 {//左边
            switch location.y {
            case 0..<radius:
                direction = .SpreadDirectionRightDown
            case radius..<(screenHeight - radius):
                direction = .SpreadDirectionRight
            case (screenHeight - radius)..<screenHeight:
                direction = .SpreadDirectionRightUp
            default: break
            }
        } else if location.x > screenWidth/2 + centerAreaWidth/2 {//右边
            switch location.y {
            case 0..<radius:
                direction = .SpreadDirectionLeftDown
            case radius..<(screenHeight - radius):
                direction = .SpreadDirectionLeft
            case (screenHeight - radius)..<screenHeight:
                direction = .SpreadDirectionLeftUp
            default: break
            }
        } else {//中间
            if location.y < screenHeight/2 {
                direction = .SpreadDirectionBottom
            } else {
                direction = .SpreadDirectionTop
            }
        }
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        cover.frame = (newSuperview?.bounds)!
    }
    
    override func didMoveToSuperview() {
        animator = UIDynamicAnimator(referenceView: self.superview!)
    }
    
    func powerButtonRotationAnimate() {
        powerButton.transform = CGAffineTransformMakeRotation(CGFloat(-0.75 * π))
    }
    
    func powerButtonCloseAnimate() {
        powerButton.transform = CGAffineTransformMakeRotation(0)
    }
    
    //setter
    func setSubButtons(buttons: [SpreadSubButton?]) {
        _ = buttons.flatMap { $0?.addTarget(self, action: "clickedSubButton:", forControlEvents: .TouchUpInside) }
        let nonNilButtons = buttons.flatMap { $0 }
        subButtons = Array<SpreadSubButton>()
        subButtons?.appendContentsOf(nonNilButtons)
    }
    
    func clickedSubButton(sender: SpreadSubButton) {
        closeButton(sender)
        let index = subButtons?.indexOf(sender)
        if let nonNilIndex = index {
            sender.clickedBlock?(index:nonNilIndex, sender: sender)
        }
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        let touchBorderAnim = self.layer.animationForKey("touchBorder")
        if touchBorderAnim == anim {
            changeSpreadDirection()
        }
    }
    
}
