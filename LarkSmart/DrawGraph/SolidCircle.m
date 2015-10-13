//
//  SolidCircle.m
//  CloudBox
//
//  Created by TTS on 15/8/12.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "SolidCircle.h"

@implementation SolidCircle


- (instancetype)initWithFrame:(CGRect)frame circleRadius:(CGFloat)radius circleColor:(UIColor *)color {
    self = [super initWithFrame:frame];
    if (nil != self) {
        _circleColor = color;
        _circleRadius = radius;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, _circleColor.CGColor); //画笔颜色
    CGContextAddArc(context, center.x, center.y, _circleRadius, 0, 2*M_PI, 1);
    CGContextDrawPath(context, kCGPathFill);
}


@end
