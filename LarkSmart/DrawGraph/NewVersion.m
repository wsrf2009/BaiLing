//
//  NewVersion.m
//  CloudBox
//
//  Created by TTS on 15-5-19.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "NewVersion.h"

@implementation NewVersion

- (void)setText:(NSString *)text {

    _text = text;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect1 = CGRectMake(rect.origin.x+1, rect.origin.y+1, rect.size.width-2, rect.size.height-2);
    CGRect rect2 = CGRectMake(rect1.origin.x+10, rect1.origin.y+5, rect1.size.width-20, rect1.size.height-10);
    
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetLineWidth(context, 1.0f);
    CGContextFillEllipseInRect(context, rect1); // 填充一个椭圆
    CGContextDrawPath(context, kCGPathFillStroke);
    CGContextStrokePath(context);
    
    if (nil != _text) {
        [_text drawInRect:rect2 withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:13], NSFontAttributeName, [UIColor yellowColor], NSForegroundColorAttributeName, nil]];
    }
}


@end
