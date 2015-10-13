//
//  NightControl.m
//  CloudBox
//
//  Created by TTS on 15/7/18.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "UndisturbedControl.h"

//#define JSONITEM_UNDISTURBEDCONTROL_UNDISTURBEDOPEN         @"undisturbed_open"
//#define JSONITEM_UNDISTURBEDCONTROL_UNDISTURBEDOPENPROMPT    @"undisturbed_open_prompt"
//#define JSONITEM_UNDISTURBEDCONTROL_UNDISTURBEDTIMESTART    @"undisturbed_time_start"
//#define JSONITEM_UNDISTURBEDCONTROL_UNDISTURBEDTIMEEND      @"undisturbed_time_end"
//#define JSONITEM_UNDISTURBEDCONTROL_UNDISTURBEDINITVOLUME   @"undisturbed_InitVolume"

NSString const *jsonItemUndisturbedControlUndisturbedOpen = @"undisturbed_open";
NSString const *jsonItemUndisturbedControlUndisturbedOpenPrompt = @"undisturbed_open_prompt";
NSString const *jsonItemUndisturbedControlUndisturbedTimeStart = @"undisturbed_time_start";
NSString const *jsonItemUndisturbedControlUndisturbedTimeEnd = @"undisturbed_time_end";
NSString const *jsonItemUndisturbedControlUndisturbedInitVolume = @"undisturbed_InitVolume";

@implementation UndisturbedControl

- (instancetype)init {

    self = [super init];
    if (nil != self) {
        _nightVolumes = @[@{@"维持不变":@255}, @{@"1级音量":@0}, @{@"2级音量":@1}, @{@"3级音量":@3}, @{@"4级音量":@5}, @{@"5级音量":@7}, @{@"6级音量":@9}];
    }
    
    return self;
}

- (NSInteger)getIndexAccrodingToVolumeTitle:(NSString *)title {
    NSDictionary *dic0 = [_nightVolumes objectAtIndex:0];
    NSNumber *defaultValue = [dic0 allValues][0];
    
    if (nil == title) {
        return [defaultValue integerValue];
    }

    for (NSDictionary *dic in _nightVolumes) {
        NSString *key = [dic allKeys][0];
        if ([key isEqualToString:title]) {
            NSNumber *value = [dic allValues][0];
            return [value integerValue];
        }
    }
    
    return [defaultValue integerValue];;
}

- (NSString *)getVolumeTitleAccrodingToIndex:(NSInteger)index {
    NSDictionary *dic0 = [_nightVolumes objectAtIndex:0];
    NSString *defaultTitle = [dic0 allKeys][0];

    for (NSDictionary *dic in _nightVolumes) {
        NSString *value = [dic allValues][0];
        if ([value integerValue] == index) {
            return [dic allKeys][0];
        }
    }
    
    return defaultTitle;
}

- (BOOL)parseUndisturbedControl:(NSDictionary *)undisturbedControlItem {
    
    NSLog(@"%s", __func__);
    
    if (nil == undisturbedControlItem) {
        return NO;
    }
    
    NSNumber *undisturbedOpenItem = [undisturbedControlItem objectForKey:jsonItemUndisturbedControlUndisturbedOpen];
    if (nil != undisturbedOpenItem) {
        _undisturbedOpen = [undisturbedOpenItem integerValue];
    }
    
    NSNumber *undisturbedOpenPromptItem = [undisturbedControlItem objectForKey:jsonItemUndisturbedControlUndisturbedOpenPrompt];
    if (nil != undisturbedOpenPromptItem) {
        _undisturbedOpenPrompt = [undisturbedOpenPromptItem integerValue];
    }
    
    NSString *undisturbedTimeStartItem = [undisturbedControlItem objectForKey:jsonItemUndisturbedControlUndisturbedTimeStart];
    if (nil != undisturbedTimeStartItem) {
        _undisturbedTimeStart = undisturbedTimeStartItem;
    }
    
    NSString *undisturbedTimeEndItem = [undisturbedControlItem objectForKey:jsonItemUndisturbedControlUndisturbedTimeEnd];
    if (nil != undisturbedTimeEndItem) {
        _undisturbedTimeEnd = undisturbedTimeEndItem;
    }
    
    NSNumber *undisturbedInitVolumeItem = [undisturbedControlItem objectForKey:jsonItemUndisturbedControlUndisturbedInitVolume];
    if (nil != undisturbedInitVolumeItem) {
        _undisturbedInitVolume = [undisturbedInitVolumeItem integerValue];
    }
    
    return YES;
}

- (NSDictionary *)modify {
    NSDictionary *nightControlItem = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:_undisturbedOpen], jsonItemUndisturbedControlUndisturbedOpen, [NSNumber numberWithInteger:_undisturbedOpenPrompt], jsonItemUndisturbedControlUndisturbedOpenPrompt, _undisturbedTimeStart, jsonItemUndisturbedControlUndisturbedTimeStart, _undisturbedTimeEnd, jsonItemUndisturbedControlUndisturbedTimeEnd, [NSNumber numberWithInteger:_undisturbedInitVolume], jsonItemUndisturbedControlUndisturbedInitVolume, nil];
    
    return nightControlItem;
}

@end
