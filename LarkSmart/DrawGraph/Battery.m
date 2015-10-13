//
//  DrawBattery.m
//  CloudBox
//
//  Created by TTS on 15-5-15.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "Battery.h"

#define BATTERY_HEAD_WIDTH      2
#define BATTERY_HEAD_HEIGHT     2

#define ROUNDEDRECT_RADIUS             3

@implementation Battery

- (void)setPower:(CGFloat)power {
    
    _power = power;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect1 = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width-BATTERY_HEAD_WIDTH, rect.size.height);
    CGRect rect2 = CGRectMake(rect1.origin.x+rect1.size.width, rect1.origin.y+(rect1.size.height-BATTERY_HEAD_HEIGHT)/2, BATTERY_HEAD_WIDTH, BATTERY_HEAD_HEIGHT);
    CGRect innerRect = CGRectMake(rect1.origin.x+1, rect1.origin.y+1, rect1.size.width-2, rect1.size.height-2);
    CGRect powerIndRect = CGRectMake(innerRect.origin.x+1, innerRect.origin.y+1, (innerRect.size.width-2)*_power, innerRect.size.height-2);

    // rect1 电池的圆角矩形
    CGContextSetLineWidth(context, 0.5f);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGPathRef clippath1 = [UIBezierPath bezierPathWithRoundedRect:rect1 cornerRadius:ROUNDEDRECT_RADIUS].CGPath;
    CGContextAddPath(context, clippath1);
    CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
    CGContextStrokePath(context);

    // rect2 电池的头部
    CGContextSetLineWidth(context, 1.0f);
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);//填充颜色 黑色
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor); // 线框颜色 黑色
    CGContextAddRect(context, rect2);
    CGContextDrawPath(context, kCGPathFillStroke);//绘画路径
    CGContextStrokePath(context);

    // rect3 电池内部白色方框
    CGContextSetLineWidth(context, 1.0f);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);//填充颜色 白色
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor); // 线框颜色 白色
    CGPathRef clippath3 = [UIBezierPath bezierPathWithRoundedRect:innerRect cornerRadius:ROUNDEDRECT_RADIUS].CGPath;
    CGContextAddPath(context, clippath3);
    CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
    CGContextStrokePath(context);
    
    // rect4 电池电量
    CGContextSetLineWidth(context, 1.0f);
    if (_power > 0.2f) {
        CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);//填充颜色 灰色
        CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor); // 线框颜色 灰色
    } else {
        CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);//填充颜色 红色
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor); // 线框颜色 红色
    }
    
    CGPathRef clippath4 = [UIBezierPath bezierPathWithRoundedRect:powerIndRect cornerRadius:1].CGPath;
    CGContextAddPath(context, clippath4);
    CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
    CGContextStrokePath(context);
}

@end
