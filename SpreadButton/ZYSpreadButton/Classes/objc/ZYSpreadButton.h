//
//  SpreadButton.h
//  SpreadButton
//
//  Created by lzy on 16/2/4.
//  Copyright © 2016年 lzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYSpreadSubButton.h"

@interface ZYSpreadButton : UIView

typedef void (^ButtonWillSpreadBlock)(ZYSpreadButton *spreadButton);
typedef void (^ButtonDidSpreadBlock)(ZYSpreadButton *spreadButton);
typedef void (^ButtonWillCloseBlock)(ZYSpreadButton *spreadButton);
typedef void (^ButtonDidCloseBlock)(ZYSpreadButton *spreadButton);

typedef enum {
    SpreadDirectionTop,
    SpreadDirectionBottom,
    SpreadDirectionLeft,
    SpreadDirectionRight,
    SpreadDirectionLeftUp,
    SpreadDirectionLeftDown,
    SpreadDirectionRightUp,
    SpreadDirectionRightDown
}SpreadDirection;

typedef enum {
    SpreadModeSickleSpread,
    SpreadModeFlowerSpread
}SpreadMode;

typedef enum {
    SpreadPositionModeFixed,
    SpreadPositionModeTouchBorder
}SpreadPositionMode;

#define π M_PI

#define SICKLE_SPREAD_ANGLE_DEFAULT 90.0f
#define FLOWER_SPREAD_ANGLE_DEFAULT 120.0f
#define SPREAD_DIRECTION_DEFAULT SpreadDirectionTop
#define SPREAD_MODE_DEFAULT SpreadModeFlowerSpread
#define SPREAD_RADIUS_DEFAULT 100.0f
#define COVER_ALPHA_DEFAULT 0.1f
#define TOUCHBORDER_MARGIN_DEFAULT 10.0f
#define TOUCHBORDER_ANIMATION_DURING_DEFAULT 0.5f
#define ANIMATION_DURING_DEFAULT 0.2f
#define ANIMATION_DURING_TOUCHBORDER_DEFAULT 0.5f
#define COVER_COLOR_DEFAULT [UIColor blackColor]
#define MAGNETIC_SCOPE_RATIO_VERTICAL 0.15

@property (assign, nonatomic) SpreadMode mode;
@property (assign, nonatomic) SpreadPositionMode positionMode;
@property (assign, nonatomic) SpreadDirection direction;
@property (assign, nonatomic) CGFloat animationDuring;
@property (assign, nonatomic) CGFloat coverAlpha;
@property (strong, nonatomic) UIColor *coverColor;
@property (assign, nonatomic) CGFloat radius;
@property (assign, nonatomic) CGFloat touchBorderMargin;
@property (assign, nonatomic) CGPoint superViewRelativePosition;
@property (assign, nonatomic) CGFloat spreadAngle;
@property (assign, nonatomic) BOOL isSpread;

@property (strong, nonatomic) NSArray *subButtons;
@property (strong, nonatomic) UIButton *powerButton;
@property (strong, nonatomic) UIView *cover;
@property (assign, nonatomic) CGRect mainFrame;

@property (copy, nonatomic) ButtonWillSpreadBlock buttonWillSpreadBlock;
@property (copy, nonatomic) ButtonDidSpreadBlock buttonDidSpreadBlock;
@property (copy, nonatomic) ButtonWillCloseBlock buttonWillCloseBlock;
@property (copy, nonatomic) ButtonDidCloseBlock buttonDidCloseBlock;

- (instancetype)initWithBackgroundImage:(UIImage *)backgroundImage highlightImage:(UIImage *)highlightImage position:(CGPoint)position;
- (void)setSubButtons:(NSArray *)subButtons;
@end
