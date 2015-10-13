//
//  RSSIIndiCator.m
//  CloudBox
//
//  Created by TTS on 15/6/24.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "RSSIIndicator.h"

@implementation RSSIIndicator

- (void)setRssi:(UInt8)rssi {

    _rssi = rssi;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat wUnit = rect.size.width/9;
    CGFloat hUnit = rect.size.height/5;
    CGRect rect1 = CGRectMake(rect.origin.x, rect.origin.y+4*hUnit, wUnit, hUnit);
    CGRect rect2 = CGRectMake(rect.origin.x+2.0f*wUnit, rect.origin.y+3.5f*hUnit, wUnit, hUnit*1.5f);
    CGRect rect3 = CGRectMake(rect.origin.x+4.0f*wUnit, rect.origin.y+2.85f*hUnit, wUnit, hUnit*2.15f);
    CGRect rect4 = CGRectMake(rect.origin.x+6.0f*wUnit, rect.origin.y+1.75f*hUnit, wUnit, hUnit*3.25f);
    CGRect rect5 = CGRectMake(rect.origin.x+8.0f*wUnit, rect.origin.y, wUnit, hUnit*5.0f);
    CGColorRef rectColor;
    
    if (_rssi < 1) {
        rectColor = [UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f].CGColor;
    } else if (_rssi <= 2) {
        rectColor = [UIColor redColor].CGColor;
    } else {
        rectColor = [UIColor colorWithRed:103.0f/255.0f green:219.0f/255.0f blue:228.0f/255.0f alpha:1.0f].CGColor;
    }
    CGContextSetLineWidth(context, 0.7f);
    CGContextSetFillColorWithColor(context, rectColor);//填充颜色 黑色
    CGContextSetStrokeColorWithColor(context, rectColor); // 线框颜色 黑色
    CGContextAddRect(context, rect1);
    CGContextDrawPath(context, kCGPathFillStroke);//绘画路径
    CGContextStrokePath(context);
    
    if (_rssi < 2) {
        rectColor = [UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f].CGColor;
    } else if (_rssi <= 2) {
        rectColor = [UIColor redColor].CGColor;
    } else {
        rectColor = [UIColor colorWithRed:103.0f/255.0f green:219.0f/255.0f blue:228.0f/255.0f alpha:1.0f].CGColor;
    }
    CGContextSetLineWidth(context, 0.7f);
    CGContextSetFillColorWithColor(context, rectColor);//填充颜色 黑色
    CGContextSetStrokeColorWithColor(context, rectColor); // 线框颜色 黑色
    CGContextAddRect(context, rect2);
    CGContextDrawPath(context, kCGPathFillStroke);//绘画路径
    CGContextStrokePath(context);
    
    if (_rssi < 3) {
        rectColor = [UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f].CGColor;
    } else {
        rectColor = [UIColor colorWithRed:103.0f/255.0f green:219.0f/255.0f blue:228.0f/255.0f alpha:1.0f].CGColor;
    }
    CGContextSetLineWidth(context, 0.7f);
    CGContextSetFillColorWithColor(context, rectColor);//填充颜色 黑色
    CGContextSetStrokeColorWithColor(context, rectColor); // 线框颜色 黑色
    CGContextAddRect(context, rect3);
    CGContextDrawPath(context, kCGPathFillStroke);//绘画路径
    CGContextStrokePath(context);
    
    if (_rssi < 4) {
        rectColor = [UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f].CGColor;
    } else {
        rectColor = [UIColor colorWithRed:103.0f/255.0f green:219.0f/255.0f blue:228.0f/255.0f alpha:1.0f].CGColor;
    }
    CGContextSetLineWidth(context, 0.7f);
    CGContextSetFillColorWithColor(context, rectColor);//填充颜色 黑色
    CGContextSetStrokeColorWithColor(context, rectColor); // 线框颜色 黑色
    CGContextAddRect(context, rect4);
    CGContextDrawPath(context, kCGPathFillStroke);//绘画路径
    CGContextStrokePath(context);
    
    if (_rssi < 5) {
        rectColor = [UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f].CGColor;
    } else {
        rectColor = [UIColor colorWithRed:103.0f/255.0f green:219.0f/255.0f blue:228.0f/255.0f alpha:1.0f].CGColor;
    }
    CGContextSetLineWidth(context, 0.7f);
    CGContextSetFillColorWithColor(context, rectColor);//填充颜色 黑色
    CGContextSetStrokeColorWithColor(context, rectColor); // 线框颜色 黑色
    CGContextAddRect(context, rect5);
    CGContextDrawPath(context, kCGPathFillStroke);//绘画路径
    CGContextStrokePath(context);
}


@end
