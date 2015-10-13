//
//  WakeupClass.m
//  CloudBox
//
//  Created by TTS on 15-4-16.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "WakeupClass.h"

// 唤醒控制 wakeup
#define JSONITEM_WAKEUP_NAME                @"wake_name"
#define JSONITEM_WAKEUP_OPENPROMPT          @"open_prompt"
//#define JSONITEM_WAKEUP_PROMPTTIMELIMIT     @"prompt_time_limit"
//#define JSONITEM_WAKEUP_PROMPTTIMESTART     @"prompt_time_start"
//#define JSONITEM_WAKEUP_PROMPTTIMEEND       @"prompt_time_end"

@implementation WakeupName

- (instancetype) initWithName:(NSString *)n fileIdentifier:(NSString *)iden highlight:(BOOL)h {
    
    self = [super init];
    
    _name = n;
    _identifier = iden;
    _highlight = h;

    return self;
}

@end

@implementation WakeupClass

- (instancetype) init {
    self = [super init];
    
    WakeupName *name1 = [[WakeupName alloc] initWithName:@"Hi百灵" fileIdentifier:@"10110" highlight:YES];
    WakeupName *name2 = [[WakeupName alloc] initWithName:@"Hi小播" fileIdentifier:@"10104" highlight:YES];
    WakeupName *name3 = [[WakeupName alloc] initWithName:@"Hi云宝" fileIdentifier:@"10103" highlight:YES];
    WakeupName *name4 = [[WakeupName alloc] initWithName:@"百灵" fileIdentifier:@"10109" highlight:NO];
    WakeupName *name5 = [[WakeupName alloc] initWithName:@"小播" fileIdentifier:@"10106" highlight:NO];
    WakeupName *name6 = [[WakeupName alloc] initWithName:@"云宝" fileIdentifier:@"10105" highlight:NO];
    
    _arrayName = @[name1, name2, name3, name4, name5, name6];
    
    return self;
}

- (BOOL)parseWakeup:(NSDictionary *)wakeupItem {
    
    NSLog(@"%s", __func__);
    
    if (nil == wakeupItem) {
        return NO;
    }
    
    NSString *wakeupNameItem = [wakeupItem objectForKey:JSONITEM_WAKEUP_NAME];
    if(nil != wakeupNameItem) {
        _name = wakeupNameItem;
    }
    
    NSNumber *openPromptItem = [wakeupItem objectForKey:JSONITEM_WAKEUP_OPENPROMPT];
    if (nil != openPromptItem) {
        _openPrompt = [openPromptItem integerValue];
    }

    return YES;
}

- (NSDictionary *)modify {
    NSDictionary *wakeupItem = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:_openPrompt], JSONITEM_WAKEUP_OPENPROMPT, _name, JSONITEM_WAKEUP_NAME, nil];
    
    return wakeupItem;
}

@end
