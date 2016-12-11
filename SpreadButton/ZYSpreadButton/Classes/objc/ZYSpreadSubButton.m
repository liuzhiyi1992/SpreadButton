//
//  SpreadSubButton.m
//  SpreadButton
//
//  Created by lzy on 16/2/4.
//  Copyright © 2016年 lzy. All rights reserved.
//

#import "ZYSpreadSubButton.h"

@implementation ZYSpreadSubButton

- (instancetype)initWithBackgroundImage:(UIImage *)backgroundImage highlightImage:(UIImage *)highlightImage clickedBlock:(ButtonClickBlock)buttonClickBlock {
    
    NSAssert(backgroundImage != nil, @"background can not be nil");
    
    self = [super init];
    if (self) {
        [self configureButtonWithBackgroundImage:backgroundImage highlightImage:highlightImage clickedBlock:buttonClickBlock];
    }
    return self;
}

- (void)configureButtonWithBackgroundImage:(UIImage *)backgroundImage highlightImage:(UIImage *)highlightImage clickedBlock:(ButtonClickBlock)buttonClickBlock {
    if (backgroundImage != nil) {
        [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        CGRect buttonFrame = CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height);
        [self setFrame:buttonFrame];
    }
    
    if (highlightImage != nil) {
        [self setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    }
    self.buttonClickBlock = buttonClickBlock;
}

- (ButtonClickBlock)buttonClickBlock {
    return _buttonClickBlock;
}

@end
