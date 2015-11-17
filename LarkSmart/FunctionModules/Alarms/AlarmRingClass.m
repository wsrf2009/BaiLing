//
//  AlarmRingClass.m
//  CloudBox
//
//  Created by TTS on 15-4-10.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "AlarmRingClass.h"

#define RING_PATH   "D:\\Audio\\"

NSArray *rings;

@interface AlarmRingClass ()

@end

@implementation AlarmRingClass


- (instancetype)initWithName:(NSString *)n info:(NSString *)i fileName:(NSString *)fN {
    
    self = [super init];
    
    _name = n;
    _info = i;
    _fileName = fN;
    
    return self;
}

/** 起床闹铃铃声数组 */
+ (void)initializeRingArray {
    AlarmRingClass *ring1 = [[AlarmRingClass alloc] initWithName:@"自然晨曦" info:@"铃声 10s" fileName:@"ring001.mp3"];
    AlarmRingClass *ring2 = [[AlarmRingClass alloc] initWithName:@"常用滴滴" info:@"铃声 4s" fileName:@"ring002.mp3"];
    AlarmRingClass *ring3 = [[AlarmRingClass alloc] initWithName:@"滴滴铃声" info:@"铃声 4s" fileName:@"ring003.mp3"];
    AlarmRingClass *ring4 = [[AlarmRingClass alloc] initWithName:@"温馨提醒" info:@"铃声 4s" fileName:@"ring004.mp3"];
    AlarmRingClass *ring5 = [[AlarmRingClass alloc] initWithName:@"智商通用" info:@"人声 8s" fileName:@"ring005.mp3"];
    AlarmRingClass *ring6 = [[AlarmRingClass alloc] initWithName:@"太阳公公" info:@"人声 4s" fileName:@"ring006.mp3"];
    AlarmRingClass *ring7 = [[AlarmRingClass alloc] initWithName:@"懒猪起床" info:@"人声 4s" fileName:@"ring007.mp3"];
    AlarmRingClass *ring8 = [[AlarmRingClass alloc] initWithName:@"懒猪起床" info:@"人声 8s" fileName:@"ring008.mp3"];
    AlarmRingClass *ring9 = [[AlarmRingClass alloc] initWithName:@"童声翻唱" info:@"人声 18s" fileName:@"ring009.mp3"];
    AlarmRingClass *ring10 = [[AlarmRingClass alloc] initWithName:@"鸟鸣卡农" info:@"音乐 32s" fileName:@"ring010.mp3"];
    AlarmRingClass *ring11 = [[AlarmRingClass alloc] initWithName:@"寂静之声" info:@"音乐 32s" fileName:@"ring011.mp3"];
    AlarmRingClass *ring12 = [[AlarmRingClass alloc] initWithName:@"月光音乐" info:@"音乐 32s" fileName:@"ring012.mp3"];
    AlarmRingClass *ring13 = [[AlarmRingClass alloc] initWithName:@"梦中婚礼" info:@"音乐 32s" fileName:@"ring013.mp3"];
    AlarmRingClass *ring14 = [[AlarmRingClass alloc] initWithName:@"世界无限" info:@"音乐 32s" fileName:@"ring014.mp3"];
    
    rings = [NSArray arrayWithObjects:ring1, ring2, ring3, ring4, ring5, ring6, ring7, ring8, ring9, ring10, ring11, ring12, ring13, ring14, nil];
}

+ (NSArray *) getRingArray {
    if (nil == rings) {
        [AlarmRingClass initializeRingArray];
    }
    return rings;
}

+ (NSString *)getNameFromPath:(NSString *)path {
    if (nil == rings) {
        [AlarmRingClass initializeRingArray];
    }
    
    NSArray *arr = [path componentsSeparatedByString:@"\\"];
    NSString *fName = [arr objectAtIndex:2];
    
    for (AlarmRingClass *ring in rings) {
        if ([ring.fileName isEqualToString:fName]) {
            return ring.name;
        }
    }
    
    return nil;
}

+ (NSInteger) getIndexFromPath:(NSString *)path {
    if (nil == rings) {
        [AlarmRingClass initializeRingArray];
    }
    
    NSArray *arr = [path componentsSeparatedByString:@"\\"];
    NSString *fName = [arr objectAtIndex:2];
    
    for (NSInteger i=0; i<rings.count; i++) {
        AlarmRingClass *ring = [rings objectAtIndex:i];
        if ([ring.fileName isEqualToString:fName]) {
            return i;
        }
    }
    
    return -1;
}

+ (NSString *) getPathViaIndex:(NSInteger)index {
    if (nil == rings) {
        [AlarmRingClass initializeRingArray];
    }
    
    AlarmRingClass *ring = [rings objectAtIndex:index];
    
    return [NSString stringWithFormat:@"%s%@", RING_PATH, ring.fileName];
}


@end
