//
//  SpreadSubButton.h
//  SpreadButton
//
//  Created by lzy on 16/2/4.
//  Copyright © 2016年 lzy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ButtonClickBlock)(int index, UIButton *sender);

@interface ZYSpreadSubButton : UIButton

@property (copy, nonatomic) ButtonClickBlock buttonClickBlock;

- (instancetype)initWithBackgroundImage:(UIImage *)backgroundImage highlightImage:(UIImage *)highlightImage clickedBlock:(ButtonClickBlock)buttonClickBlock;


@end
