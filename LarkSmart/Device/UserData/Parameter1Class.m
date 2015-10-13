//
//  Parameter1Class.m
//  CloudBox
//
//  Created by TTS on 15/7/20.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "Parameter1Class.h"

#define JSONITEM_PARAMETER1_DAYINITVOLUME       @"dayInitVolume"
#define JSONITEM_PARAMETER1_LOOPPLAYTIME        @"loopPlayTime"
#define JSONITEM_PARAMETER1_CHIME               @"chime"
#define JSONITEM_PARAMETER1_HALFCHIME           @"halfchime"
#define JSONITEM_PARAMETER1_CHIMESTART          @"chime_start"
#define JSONITEM_PARAMETER1_CHIMEEND            @"chime_end"

@implementation Parameter1Class

- (instancetype)init {
    
    self = [super init];
    if (nil != self) {
        _playTime = @[@{@"10分钟":@10}, @{@"20分钟":@20}, @{@"30分钟":@30}, @{@"40分钟":@40}, @{@"50分钟":@50}, @{@"60分钟":@60}];
    }
    
    return self;
}

- (NSInteger)getTimeAccrodingToTimeTitle:(NSString *)title {
    NSDictionary *dic0 = [_playTime objectAtIndex:0];
    NSNumber *defaultValue = [dic0 allValues][0];
    
    if (nil == title) {
        return [defaultValue integerValue];
    }
    
    for (NSDictionary *dic in _playTime) {
        NSString *key = [dic allKeys][0];
        if ([key isEqualToString:title]) {
            NSNumber *value = [dic allValues][0];
            return [value integerValue];
        }
    }
    
    return [defaultValue integerValue];
}

- (NSString *)getTimeTitleAccrodingToTime:(NSInteger)time {
    NSDictionary *dic0 = [_playTime objectAtIndex:0];
    NSString *defaultTitle = [dic0 allKeys][0];
    
    for (NSDictionary *dic in _playTime) {
        NSNumber *value = [dic allValues][0];
        if ([value integerValue] == time) {
            return [dic allKeys][0];
        }
    }
    
    return defaultTitle;
}

- (BOOL)parseParameter1:(NSDictionary *)parameter1Item {
    
    NSLog(@"%s", __func__);
    
    if (nil == parameter1Item) {
        return NO;
    }

    NSNumber *dayInitVolumeItem = [parameter1Item objectForKey:JSONITEM_PARAMETER1_DAYINITVOLUME];
    if (nil != dayInitVolumeItem) {
        _dayInitVolume = [dayInitVolumeItem integerValue];
    }
    
    NSNumber *loopPlayTimeItem = [parameter1Item objectForKey:JSONITEM_PARAMETER1_LOOPPLAYTIME];
    if (nil != loopPlayTimeItem) {
        _loopPlayTime = [loopPlayTimeItem integerValue];
    }
    
    NSNumber *chimeItem = [parameter1Item objectForKey:JSONITEM_PARAMETER1_CHIME];
    if (nil != chimeItem) {
        _chime = [chimeItem integerValue];
    }
    
    NSNumber *halfChimeItem = [parameter1Item objectForKey:JSONITEM_PARAMETER1_HALFCHIME];
    if (nil != halfChimeItem) {
        _halfChime = [halfChimeItem integerValue];
    }
    
    NSString *chimeStartItem = [parameter1Item objectForKey:JSONITEM_PARAMETER1_CHIMESTART];
    if (nil != chimeStartItem) {
        _chimeStart = chimeStartItem;
    }
    
    NSString *chimeEndItem = [parameter1Item objectForKey:JSONITEM_PARAMETER1_CHIMEEND];
    if (nil != chimeEndItem) {
        _chimeEnd = chimeEndItem;
    }
    
    return YES;
}

- (NSDictionary *)modify {
    NSDictionary *parameter1Item = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:_dayInitVolume], JSONITEM_PARAMETER1_DAYINITVOLUME, [NSNumber numberWithInteger:_loopPlayTime], JSONITEM_PARAMETER1_LOOPPLAYTIME, [NSNumber numberWithInteger:_chime], JSONITEM_PARAMETER1_CHIME, [NSNumber numberWithInteger:_halfChime], JSONITEM_PARAMETER1_HALFCHIME, _chimeStart, JSONITEM_PARAMETER1_CHIMESTART, _chimeEnd, JSONITEM_PARAMETER1_CHIMEEND, nil];
    
    return parameter1Item;
}

@end
