//
//  GetupSet.m
//  CloudBox
//
//  Created by TTS on 15-4-29.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "GetupSetClass.h"


@implementation RingTimeClass

- (instancetype)initWithText:(NSString *)text time:(NSInteger)time {
    self = [super init];
    if (nil != self) {
        _text = text;
        _time = time;
    }
    
    return self;
}

@end

@implementation PlayTimesClass

- (instancetype)initWithText:(NSString *)text times:(NSInteger)times {
    self = [super init];
    if (nil != self) {
        _text = text;
        _times = times;
    }
    
    return self;
}

@end

#define JSONITEM_GETUPSET_RINGTYPE           @"ring_type"
#define JSONITEM_GETUPSET_RINGPATH           @"ring_path"
#define JSONITEM_GETUPSET_PLAYTIME           @"play_time"
#define JSONITEM_GETUPSET_DELAYNUM           @"delay_num"
#define JSONITEM_GETUPSET_DELAYTIME          @"delay_time"
#define JSONITEM_GETUPSET_MESSAGETIMES       @"message_times"
#define JSONITEM_GETUPSET_MESSAGEOPEN        @"message_open"
#define JSONITEM_GETUPSET_WILLDO             @"will_do"

@implementation GetupSetClass

- (instancetype)init {
    self = [super init];
    if (nil != self) {
        RingTimeClass *ringTime1 = [[RingTimeClass alloc] initWithText:@"8秒" time:8];
        RingTimeClass *ringTime2 = [[RingTimeClass alloc] initWithText:@"16秒" time:16];
        RingTimeClass *ringTime3 = [[RingTimeClass alloc] initWithText:@"24秒" time:24];
        RingTimeClass *ringTime4 = [[RingTimeClass alloc] initWithText:@"32秒" time:32];
        
        _ringTime = @[ringTime1, ringTime2, ringTime3, ringTime4];
        
        PlayTimesClass *playTimes1 = [[PlayTimesClass alloc] initWithText:@"不播报" times:0];
        PlayTimesClass *playTimes2 = [[PlayTimesClass alloc] initWithText:@"1次" times:1];
        PlayTimesClass *playTimes3 = [[PlayTimesClass alloc] initWithText:@"2次" times:2];
        
        _playTimes = @[playTimes1, playTimes2, playTimes3];
    }
    
    return self;
}

- (BOOL)parseGetupSet:(NSDictionary *)getupSetItem {
    
    NSLog(@"%s", __func__);
    
    if (nil == getupSetItem) {
        return NO;
    }
    
    NSNumber *ringTypeItem = [getupSetItem objectForKey:JSONITEM_GETUPSET_RINGTYPE];
    if (nil != ringTypeItem) {
        _ringType = [ringTypeItem integerValue];
    }
    
    NSString *ringPathItem = [getupSetItem objectForKey:JSONITEM_GETUPSET_RINGPATH];
    if (nil != ringPathItem) {
        _ringPath = ringPathItem;
    }
    
    NSNumber *playTimeItem = [getupSetItem objectForKey:JSONITEM_GETUPSET_PLAYTIME];
    if (nil != playTimeItem) {
        _playTime = [playTimeItem integerValue];
    }
    
    NSNumber *delayNumItem = [getupSetItem objectForKey:JSONITEM_GETUPSET_DELAYNUM];
    if (nil != delayNumItem) {
        _delayNum = [delayNumItem integerValue];
    }
    
    NSNumber *delayTimeItem = [getupSetItem objectForKey:JSONITEM_GETUPSET_DELAYTIME];
    if (nil != delayTimeItem) {
        _delayTime = [delayTimeItem integerValue];
    }
    
    NSNumber *messageTimesItem = [getupSetItem objectForKey:JSONITEM_GETUPSET_MESSAGETIMES];
    if (nil != messageTimesItem) {
        _messageTimes = [messageTimesItem integerValue];
    }
    
    NSNumber *messageOpenItem = [getupSetItem objectForKey:JSONITEM_GETUPSET_MESSAGEOPEN];
    if (nil != messageOpenItem) {
        _messageOpen = [messageOpenItem integerValue];
    }
    
    NSNumber *willDoItem = [getupSetItem objectForKey:JSONITEM_GETUPSET_WILLDO];
    if (nil != willDoItem) {
        _willDo = [willDoItem integerValue];
    }
    
    NSLog(@"exit %s", __func__);
    
    return YES;
}

- (NSDictionary *)modify {
    NSDictionary *getupSetItem = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:_ringType], JSONITEM_GETUPSET_RINGTYPE, _ringPath, JSONITEM_GETUPSET_RINGPATH, [NSNumber numberWithUnsignedInteger:_playTime], JSONITEM_GETUPSET_PLAYTIME, [NSNumber numberWithUnsignedInteger:_delayNum], JSONITEM_GETUPSET_DELAYNUM, [NSNumber numberWithUnsignedInteger:_delayTime], JSONITEM_GETUPSET_DELAYTIME, [NSNumber numberWithUnsignedInteger:_messageTimes], JSONITEM_GETUPSET_MESSAGETIMES, [NSNumber numberWithUnsignedInteger:_messageOpen], JSONITEM_GETUPSET_MESSAGEOPEN, [NSNumber numberWithUnsignedInteger:_willDo], JSONITEM_GETUPSET_WILLDO, nil];
    
    return getupSetItem;
}


@end
