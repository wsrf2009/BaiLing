//
//  AlarmCycleSetClass.m
//  CloudBox
//
//  Created by TTS on 15-4-10.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "AlarmCycleSetClass.h"

@implementation AlarmCycleSetClass

+ (NSMutableArray *) initialize {
    NSArray *array1 = @[@"每"];
    NSArray *array2 = @[@"0", @"1", @"2", @"3", @"4", @"5"];
    NSArray *array3 = @[@"分钟"];
    NSArray *array4 = @[@"0", @"1", @"2"];
    NSArray *array5 = @[@"次"];
    
    return [[NSMutableArray alloc] initWithObjects:array1, array2, array3, array4, array5, nil];
}

@end
