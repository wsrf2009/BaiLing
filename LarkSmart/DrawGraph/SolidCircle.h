//
//  SolidCircle.h
//  CloudBox
//
//  Created by TTS on 15/8/12.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SolidCircle : UIView
@property (nonatomic, retain) UIColor *circleColor;
@property (nonatomic, assign) CGFloat circleRadius;

- (instancetype)initWithFrame:(CGRect)frame circleRadius:(CGFloat)radius circleColor:(UIColor *)color;

@end
