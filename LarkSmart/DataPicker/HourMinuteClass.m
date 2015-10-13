//
//  HourMinuteClass.m
//  CloudBox
//
//  Created by TTS on 15-4-1.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "HourMinuteClass.h"

@implementation HourMinuteClass

+ (NSArray *) hourInitialize {
    
    return @[@"00", @"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23"];
}

+ (NSArray *) minuteInitialize {
    return @[@"00", @"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39", @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49", @"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59"];
}

+ (NSMutableArray *) initialize {
    NSArray *array1 = [self hourInitialize];
    NSArray *array2 = [NSArray arrayWithObject:@"时"];
    NSArray *array3 = [self minuteInitialize];
    NSArray *array4 = [NSArray arrayWithObject:@"分"];
    
    return [NSMutableArray arrayWithObjects:array1, array2, array3, array4, nil];
}

@end
