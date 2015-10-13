//
//  PageView.h
//  CloudBox
//
//  Created by TTS on 15-3-17.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomePageView : UIScrollView

@property (nonatomic) CGSize pageSize;

- (void)addSubview:(UIView *)view forCurrent:(BOOL)current;
- (void)addButton:(UIButton *)button onView:(UIView *)view;

@end
