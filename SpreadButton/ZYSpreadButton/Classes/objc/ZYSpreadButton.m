//
//  SpreadButton.m
//  SpreadButton
//
//  Created by lzy on 16/2/4.
//  Copyright © 2016年 lzy. All rights reserved.
//

#import "ZYSpreadButton.h"

@interface ZYSpreadButton () <CAAnimationDelegate>
@property (strong, nonatomic) UIDynamicAnimator *animator;
@end

@implementation ZYSpreadButton

- (instancetype)initWithBackgroundImage:(UIImage *)backgroundImage highlightImage:(UIImage *)highlightImage position:(CGPoint)position {
    
    NSAssert(backgroundImage != nil, @"background can not be nil");
    
    self = [super init];
    if (self) {
        self.mainFrame = CGRectMake(position.x, position.y, backgroundImage.size.width, backgroundImage.size.height);
        self.superViewRelativePosition = position;
        
        //main Button
        self.powerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
        [self.powerButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        if (highlightImage != nil) {
            [self.powerButton setBackgroundImage:backgroundImage forState:UIControlStateHighlighted];
        }
        [self.powerButton addTarget:self action:@selector(tapPowerButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_powerButton];
        
        //configuration
        [self configureDefaultValue];
        [self setFrame:_mainFrame];
        self.center = position;
        [self configureGesture];
        [self configureCover];
    }
    return self;
}

- (void)configureDefaultValue {
    self.animationDuring = ANIMATION_DURING_DEFAULT;
    self.coverAlpha = COVER_ALPHA_DEFAULT;
    self.coverColor = COVER_COLOR_DEFAULT;
    self.radius = SPREAD_RADIUS_DEFAULT;
    self.touchBorderMargin = TOUCHBORDER_MARGIN_DEFAULT;
    self.spreadAngle = FLOWER_SPREAD_ANGLE_DEFAULT;
    self.mode = SPREAD_MODE_DEFAULT;
    self.isSpread = NO;
    self.direction = SPREAD_DIRECTION_DEFAULT;
}

- (void)configureGesture {
    UIPanGestureRecognizer *panGestureRecongnizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panSpreadButton:)];
    [self addGestureRecognizer:panGestureRecongnizer];
}

- (void)configureCover {
    self.cover = [[UIView alloc] initWithFrame:self.bounds];
    self.cover.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.cover.userInteractionEnabled = YES;
    self.cover.backgroundColor = self.coverColor;
    self.cover.alpha = 0;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCover)];
    [self.cover addGestureRecognizer:tapGestureRecognizer];
}

- (void)panSpreadButton:(UIPanGestureRecognizer *)gesture {
    //UISnapBehavior & touchBorder Animation & panMove
    if (_isSpread) {
        return;
    }
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [_animator removeAllBehaviors];
            break;
        case UIGestureRecognizerStateEnded:
            switch (_positionMode) {
                case SpreadPositionModeFixed:
                {
                    UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:self snapToPoint:_superViewRelativePosition];
                    snapBehavior.damping = 0.5;
                    [_animator addBehavior:snapBehavior];
                    break;
                }
                case SpreadPositionModeTouchBorder:
                {
                    CGPoint location = [gesture locationInView:self.superview];
                    if (![self.superview.layer containsPoint:location]) {
                        //outside superView
                        location = self.center;
                    }
                    CGSize superViewSize = self.superview.bounds.size;
                    CGFloat magneticDistance = superViewSize.height * MAGNETIC_SCOPE_RATIO_VERTICAL;
                    CGPoint destinationLocation;
                    if (location.y < magneticDistance) {//上面区域
                        destinationLocation = CGPointMake(location.x, self.bounds.size.width/2 + _touchBorderMargin);
                    } else if (location.y > superViewSize.height - magneticDistance) {//下面
                        destinationLocation = CGPointMake(location.x, superViewSize.height - self.bounds.size.height/2 - _touchBorderMargin);
                    } else if (location.x > superViewSize.width/2) {//右边
                        destinationLocation = CGPointMake(superViewSize.width - (self.bounds.size.width/2 + _touchBorderMargin), location.y);
                    } else {//左边
                        destinationLocation = CGPointMake(self.bounds.size.width/2 + _touchBorderMargin, location.y);
                    }
                    
                    CABasicAnimation *touchBorderAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
                    touchBorderAnimation.delegate = self;
                    touchBorderAnimation.removedOnCompletion = NO;//动画完成后不去除Animation
                    touchBorderAnimation.fromValue = [NSValue valueWithCGPoint:location];
                    touchBorderAnimation.toValue = [NSValue valueWithCGPoint:destinationLocation];
                    touchBorderAnimation.duration = ANIMATION_DURING_TOUCHBORDER_DEFAULT;
                    touchBorderAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    [self.layer addAnimation:touchBorderAnimation forKey:@"touchBorder"];
                    
                    [CATransaction begin];
                    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                    self.layer.position = destinationLocation;
                    [CATransaction commit];
                    break;
                }
            }
            break;
        default:
        {
            CGPoint location = [gesture locationInView:self.superview];
            if ([self.superview.layer containsPoint:location]) {
                self.center = location;
            }
            break;
        }
    }
}

- (void)tapCover {
    if (_isSpread) {
        [self closeButton:nil];
    }
}

- (void)tapPowerButton:(UIButton *)sender {
    _isSpread ? [self closeButton:nil] : [self spreadButton];
}

- (void)clickedSubButton:(ZYSpreadSubButton *)sender {
    [self closeButton:sender];
    NSUInteger uintIndex = [_subButtons indexOfObject:sender];
    sender.buttonClickBlock((int)uintIndex, sender);
}

- (void)spreadButton {
    NSLog(@"spread");
    if (_subButtons.count <= 0) {
        return;
    }
    //Block
    self.buttonWillSpreadBlock(self);
    [self.animator removeAllBehaviors];
    self.isSpread = YES;
    
    //改变frame,充满整个superView
    self.frame = self.superview.bounds;
    
    //position powerButton
    self.powerButton.center = _superViewRelativePosition;
    
    //insert cover
    [self insertSubview:_cover belowSubview:_powerButton];
    
    //cover animation
    [UIView animateWithDuration:_animationDuring animations:^{
        self.cover.alpha = self.coverAlpha;
        [self powerButtonRotationAnimate];
    }];
    
    //spreadSubButton
    [self spreadSubButton];
    
    //Block
    self.buttonDidSpreadBlock(self);
}

- (void)spreadSubButton {
    CGFloat subButtonCrackAngle = _spreadAngle / (_subButtons.count - 1);
    CGFloat startSpace = (180 - _spreadAngle) / 2;
    CGFloat angle;
    switch (_direction) {
        case SpreadDirectionTop:
            angle = startSpace;
            break;
        case SpreadDirectionBottom:
            angle = -180 + startSpace;
            break;
        case SpreadDirectionLeft:
            angle = 90 + startSpace;
            break;
        case SpreadDirectionRight:
            angle = -90 + startSpace;
            break;
        case SpreadDirectionLeftUp:
            angle = 90;
            break;
        case SpreadDirectionLeftDown:
            angle = 180;
            break;
        case SpreadDirectionRightUp:
            angle = 0;
            break;
        case SpreadDirectionRightDown:
            angle = -90;
            break;
    }
    
    CGPoint startOutSidePoint = CGPointZero;
    CGFloat startAngle = 0.0;
    for (ZYSpreadSubButton *btn in _subButtons) {
        btn.transform = CGAffineTransformMakeTranslation(1.0, 1.0);
        [self insertSubview:btn belowSubview:_powerButton];
        btn.alpha = 1.0;
        btn.center = _powerButton.center;
        
        NSUInteger btnIndex = [_subButtons indexOfObject:btn];
        if (btnIndex == 0) {//first btn
            startOutSidePoint = [self calculatePointWithAngle:angle radius:_radius];
            //得到startAngle
            startAngle = angle;
        }
        
        CGPoint outsidePoint = [self calculatePointWithAngle:angle radius:_radius];
        CGPoint shockOutsidePoint = [self calculatePointWithAngle:angle radius:_radius + 10];
        CGPoint shockInsidePoint = [self calculatePointWithAngle:angle radius:_radius - 3];
        
        CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        UIBezierPath *animationPath;
        
        //which mode
        switch (_mode) {
            case SpreadModeSickleSpread:
                if (_direction == SpreadDirectionTop || _direction == SpreadDirectionBottom || _direction == SpreadDirectionLeft || _direction == SpreadDirectionRight) {
                    //---It does not provide SickleSpread in those four directions---
                    animationPath = [self movingPathWithStartPoint:btn.layer.position keyPointCount:3 keyPoints:shockOutsidePoint, shockInsidePoint, outsidePoint, nil];
                    positionAnimation.keyTimes = @[@(0.0), @(0.8), @(0.93), @(1.0)];
                    positionAnimation.duration = _animationDuring;
                } else {
                    if (btnIndex == 0) { //the first btn
                        animationPath = [self movingPathWithStartPoint:btn.layer.position keyPointCount:1 keyPoints:startOutSidePoint, nil];
                        positionAnimation.keyTimes = @[@(0.0), @(0.2)];
                    } else if (btnIndex != (_subButtons.count - 1)) {
                        animationPath = [self movingPathWithStartPoint:btn.layer.position endPoint:startOutSidePoint startAngle:startAngle endAngle:angle center:btn.layer.position shock:NO];
                        positionAnimation.keyTimes = @[@(0.0), @(0.2),   @(0.3), @(1.0)];
                    } else { //the last btn
                        animationPath = [self movingPathWithStartPoint:btn.layer.position endPoint:startOutSidePoint startAngle:startAngle endAngle:angle center:btn.layer.position shock:YES];
                        positionAnimation.keyTimes = @[@(0.0), @(0.2),   @(0.3), @(0.9),   @(0.9), @(0.95),   @(0.95), @(1.0)];
                    }
                    positionAnimation.duration = _animationDuring*(1+0.2*btnIndex);
                }
                break;
            case SpreadModeFlowerSpread:
                animationPath = [self movingPathWithStartPoint:btn.layer.position keyPointCount:3 keyPoints:shockOutsidePoint, shockInsidePoint, outsidePoint, nil];
                positionAnimation.keyTimes = @[@(0.0), @(0.8), @(0.93), @(1.0)];
                positionAnimation.duration = _animationDuring;
        }
        positionAnimation.path = animationPath.CGPath;
        [btn.layer addAnimation:positionAnimation forKey:@"sickleSpread"];
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        btn.layer.position = outsidePoint;
        [CATransaction commit];
        
        angle += subButtonCrackAngle;
    }
}

- (void)closeButton:(ZYSpreadSubButton *)exclusiveBtn {
    NSLog(@"close");
    
    //Block
    self.buttonWillCloseBlock(self);
    self.isSpread = NO;
    
    //cover animation
    [UIView animateWithDuration:_animationDuring animations:^{
        self.cover.alpha = 0;
        [self powerButtonCloseAnimation];
    } completion:^(BOOL finished) {
        [self.cover removeFromSuperview];
        self.frame = self.powerButton.frame;
        self.powerButton.frame = self.bounds;
    }];
    
    [self closeSubButton:exclusiveBtn];
    
    //Block
    self.buttonDidCloseBlock(self);
}

- (void)closeSubButton:(ZYSpreadSubButton *)exclusiveBtn {
    for (ZYSpreadSubButton *btn in _subButtons) {
        if (exclusiveBtn != nil) {
            if (btn != exclusiveBtn) {
                [btn removeFromSuperview];
            }
            continue;
        }
        
        UIBezierPath *animationPath = [self movingPathWithStartPoint:btn.layer.position keyPointCount:1 keyPoints:_powerButton.layer.position, nil];
        CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        positionAnimation.path = animationPath.CGPath;
        positionAnimation.keyTimes = @[@(0.0), @(1.0)];
        positionAnimation.duration = _animationDuring;
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [btn.layer addAnimation:positionAnimation forKey:@"close"];
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        btn.frame = CGRectMake(0, 0, btn.bounds.size.width, btn.bounds.size.height);
        [CATransaction commit];
    }
    
    if (exclusiveBtn != nil) {
        CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        alphaAnimation.fromValue = @(1.0f);
        alphaAnimation.toValue = @(0.0f);
        alphaAnimation.duration = _animationDuring;
        alphaAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = @(1.0f);
        scaleAnimation.toValue = @(3.0f);
        scaleAnimation.duration = _animationDuring;
        scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        
        CAAnimationGroup *dismissGroupAnimation = [[CAAnimationGroup alloc] init];
        dismissGroupAnimation.animations = @[alphaAnimation, scaleAnimation];
        dismissGroupAnimation.duration = _animationDuring;
        
        [exclusiveBtn.layer addAnimation:dismissGroupAnimation forKey:@"closeGroup"];
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        exclusiveBtn.transform = CGAffineTransformMakeScale(3.0f, 3.0f);
        exclusiveBtn.layer.opaque = 0.0f;
        [CATransaction commit];
    }
}

- (void)powerButtonRotationAnimate {
    _powerButton.transform = CGAffineTransformMakeRotation(-0.75f * π);
}

- (void)powerButtonCloseAnimation {
    _powerButton.transform = CGAffineTransformMakeRotation(0.0f);
}

- (CGPoint)calculatePointWithAngle:(CGFloat)angle radius:(CGFloat)radius {
    //根据弧度和半径计算点的位置
    //center => powerButton
    CGFloat x = _powerButton.center.x + cos(angle / 180.0 * π) * radius;
    CGFloat y = _powerButton.center.y - sin(angle / 180.0 * π) * radius;
    return CGPointMake(x, y);
}

- (UIBezierPath *)movingPathWithStartPoint:(CGPoint)startPoint keyPointCount:(int)keyPointCount keyPoints:(CGPoint)keyPoints, ...NS_REQUIRES_NIL_TERMINATION {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:startPoint];
    [path addLineToPoint:keyPoints];
    
    va_list varList;
    va_start(varList, keyPoints);    
    for (int i = 0; i < keyPointCount - 1; i++) {
        CGPoint point = va_arg(varList, CGPoint);
        [path addLineToPoint:point];
    }
    va_end(varList);
    return path;
}

//- (UIBezierPath *)movingPathWithStartPoint:(CGPoint)startPoint keyPoints:(CGPoint)keyPoints, ... {
//- (UIBezierPath *)movingPathWithStartPoint:(CGPoint)startPoint keyPointCount:(int)keyPointCount keyPoints:(CGPoint)keyPoints, ...NS_REQUIRES_NIL_TERMINATION {
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    va_list varList;
//    NSMutableArray *argArray = [NSMutableArray array];
//    NSValue *arg;
//    va_start(varList, keyPoints);
//    while ((arg = va_arg(varList, NSValue *))) {
//        [argArray addObject:arg];
//    }
//    va_end(varList);
//    [path moveToPoint:startPoint];
//    [path addLineToPoint:keyPoints];
//    for (NSValue *value in argArray) {
//        CGPoint tempPoint;
//        [value getValue:&tempPoint];
//        [path addLineToPoint:tempPoint];
//    }
//    return path;
//}

- (UIBezierPath *)movingPathWithStartPoint:(CGPoint)startPoint
                                  endPoint:(CGPoint)endPoint
                                startAngle:(CGFloat)startAngle
                                  endAngle:(CGFloat)endAngle
                                    center:(CGPoint)center
                                     shock:(BOOL)shock {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    //arc
    if (shock) {
        [path addArcWithCenter:center radius:_radius startAngle:-startAngle/180*π endAngle:(-endAngle - 3)/180*π clockwise:NO];
        [path addArcWithCenter:center radius:_radius startAngle:(-endAngle - 3)/180*π endAngle:(-endAngle + 1)/180*π clockwise:YES];
        [path addArcWithCenter:center radius:_radius startAngle:(-endAngle + 1)/180*π endAngle:-endAngle/180*π clockwise:NO];
    } else  {
        [path addArcWithCenter:center radius:_radius startAngle:-startAngle/180*π endAngle:-endAngle/180*π clockwise:NO];
    }
    return path;
}

- (void)changeSpreadDirection {
    CGFloat superviewWidth = self.superview.bounds.size.width;
    CGFloat superviewHeight = self.superview.bounds.size.height;
    CGFloat centerAreaWidth = superviewWidth - 2*_radius;
    CGPoint location = self.center;
    
    //改变下次Spreading的位置
    self.superViewRelativePosition = location;
    
    if (location.x < (superviewWidth - centerAreaWidth)/2) {//左边区域
        if (0 <= location.y && location.y < _radius) {//上
            self.direction = SpreadDirectionRightDown;
        } else if (_radius <= location.y && location.y < (superviewHeight - _radius)) {//中
            self.direction = SpreadDirectionRight;
        } else {//下
            self.direction = SpreadDirectionRightUp;
        }
    } else if (location.x > superviewWidth/2 + centerAreaWidth/2) {//右边区域
        if (0 <= location.y && location.y < _radius) {
            self.direction = SpreadDirectionLeftDown;
        } else if (_radius <= location.y && location.y < (superviewHeight - _radius)) {
            self.direction = SpreadDirectionLeft;
        } else {
            self.direction = SpreadDirectionLeftUp;
        }
    } else {//中间区域
        if (location.y < superviewHeight/2) {
            self.direction = SpreadDirectionBottom;
        } else {
            self.direction = SpreadDirectionTop;
        }
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    _cover.frame = newSuperview.bounds;
}

- (void)didMoveToSuperview {
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    CAAnimation *touchBorderAnim = [self.layer animationForKey:@"touchBorder"];
    if (touchBorderAnim == anim) {
        [self changeSpreadDirection];
    }
}

- (void)setSubButtons:(NSArray *)subButtons {
    _subButtons = subButtons;
    for (ZYSpreadSubButton *btn in _subButtons) {
        [btn addTarget:self action:@selector(clickedSubButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

- (void)setDirection:(SpreadDirection)direction {
    _direction = direction;
    if (direction == SpreadDirectionTop || direction == SpreadDirectionBottom || direction == SpreadDirectionLeft || direction == SpreadDirectionRight) {
        _spreadAngle = FLOWER_SPREAD_ANGLE_DEFAULT;
    } else {
        _spreadAngle = SICKLE_SPREAD_ANGLE_DEFAULT;
    }
}



@end
