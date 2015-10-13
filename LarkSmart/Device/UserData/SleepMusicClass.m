//
//  AlbumClass.m
//  CloudBox
//
//  Created by TTS on 15-4-22.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "SleepMusicClass.h"

#define JSONITEM_SLEEPMUSIC_ISVALID         @"is_valid"
#define JSONITEM_SLEEPMUSIC_CATEGORYID      @"categoryid"
#define JSONITEM_SLEEPMUSIC_PLAYTIME        @"playtime"
#define JSONITEM_SLEEPMUSIC_WILLDO          @"will_do"


@implementation sleepMusicTime

- (instancetype)initWithMinuteLable:(NSString *)m second:(NSUInteger)s {
    self = [super init];
    if (nil != self) {
        _miunteLable = m;
        _seconds = s;
    }
    
    return self;
}

@end


@implementation SleepMusicClass

- (instancetype) init {
    self = [super init];
    
    sleepMusicTime *time1 = [[sleepMusicTime alloc] initWithMinuteLable:@"1分钟" second:60];
    sleepMusicTime *time2 = [[sleepMusicTime alloc] initWithMinuteLable:@"10分钟" second:600];
    sleepMusicTime *time3 = [[sleepMusicTime alloc] initWithMinuteLable:@"15分钟" second:900];
    sleepMusicTime *time4 = [[sleepMusicTime alloc] initWithMinuteLable:@"20分钟" second:1200];
    sleepMusicTime *time5 = [[sleepMusicTime alloc] initWithMinuteLable:@"25分钟" second:1500];
    sleepMusicTime *time6 = [[sleepMusicTime alloc] initWithMinuteLable:@"30分钟" second:1800];
    sleepMusicTime *time7 = [[sleepMusicTime alloc] initWithMinuteLable:@"40分钟" second:2400];
    sleepMusicTime *time8 = [[sleepMusicTime alloc] initWithMinuteLable:@"50分钟" second:3000];
    sleepMusicTime *time9 = [[sleepMusicTime alloc] initWithMinuteLable:@"60分钟" second:3600];
    
    _timeList = @[time1, time2, time3, time4, time5, time6, time7, time8, time9];
    
    return self;
}

- (NSString *)getMinuteLableAccrodingToSecond:(NSUInteger)second {
    for (sleepMusicTime *time in _timeList) {
        if (time.seconds == second) {
            return time.miunteLable;
        }
    }
    
    return nil;
}

- (BOOL)parseSleepMusic:(NSDictionary *)sleepMusicItem {
    
    if (nil == sleepMusicItem) {
        return NO;
    }
    
    NSNumber *isValidItem = [sleepMusicItem objectForKey:JSONITEM_SLEEPMUSIC_ISVALID];
    if (nil != isValidItem) {
        _isValid = [isValidItem integerValue];
    }
    
    NSString *categoryIdItem = [sleepMusicItem objectForKey:JSONITEM_SLEEPMUSIC_CATEGORYID];
    if(nil != categoryIdItem) {
        _categoryId = categoryIdItem;
    }
    
    NSNumber *playTimeItem = [sleepMusicItem objectForKey:JSONITEM_SLEEPMUSIC_PLAYTIME];
    if(nil != playTimeItem) {
        _playTime = [playTimeItem integerValue];
    }
    
    NSNumber *willDoItem = [sleepMusicItem objectForKey:JSONITEM_SLEEPMUSIC_WILLDO];
    if(nil != willDoItem) {
        _willDo = [willDoItem integerValue];
    }
    
    return YES;
}

- (NSDictionary *)modify {
    NSDictionary *sleepMusicItem = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:_isValid], JSONITEM_SLEEPMUSIC_ISVALID, _categoryId, JSONITEM_SLEEPMUSIC_CATEGORYID, [NSNumber numberWithInteger:_playTime], JSONITEM_SLEEPMUSIC_PLAYTIME, [NSNumber numberWithInteger:0], JSONITEM_SLEEPMUSIC_WILLDO, nil];
    return sleepMusicItem;
}

@end
