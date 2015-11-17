//
//  AlarmClass.m
//  CloudBox
//
//  Created by TTS on 15-4-7.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "AlarmClass.h"
#import "NSDateNSStringConvert.h"

// alarm
#define JSONITEM_ALARM_TITLE              @"title"
#define JSONITEM_ALARM_ID                 @"ID"
#define JSONITEM_ALARM_ISVALID            @"is_valid"
#define JSONITEM_ALARM_ISLUNAR            @"is_lunar"
#define JSONITEM_ALARM_DATE               @"date"
#define JSONITEM_ALARM_CLOCK              @"clock"
#define JSONITEM_ALARM_FREMODE            @"fre_mode"
#define JSONITEM_ALARM_FREQUENCY          @"frequency"

#define ALARMID_MIN     0
#define ALARMID_MAX     19

@implementation AlarmClass

- (instancetype)initAlarmTitle:(NSString *)alarmTile alarmList:(NSMutableArray *)alarmList {
    
    self = [super init];
    if (nil != self) {
        _title = alarmTile;
        _ID = [AlarmClass getFreeId:alarmList];
        _is_valid = YES;
        _is_lunar = NO;
        _date = [[NSDate date] getDateString];
        _clock = [[NSDate date] getTimeString];
        _fre_mode = FRE_MODE_EVERYDAY;
        _frequency = 0;
    }
    
    return self;
}

+ (NSInteger)getFreeId:(NSMutableArray *)alarmList {
    NSUInteger i;
    BOOL isValid;
    
    for (i=ALARMID_MIN; i<=ALARMID_MAX; i++) {
        isValid = YES;
        for (AlarmClass *alarm in alarmList) {
            if (alarm.ID == i) {
                isValid = NO;
                break;
            }
        }
        
        if (isValid) {
            return i;
        }
    }
    
    return -1;
}

+ (NSString *)getAlarmCycle:(AlarmClass *)alarm {
    NSString *cycle;
    
    NSLog(@"%s mode:%@ fre:%@", __func__, @(alarm.fre_mode), @(alarm.frequency));
    
    if (FRE_MODE_ONEOFF == alarm.fre_mode) {
        cycle = NSLocalizedStringFromTable(@"oneOff", @"hint", nil);
    } else if (FRE_MODE_EVERYDAY == alarm.fre_mode) {
        cycle = @"每天";
    } else if (FRE_MODE_WEEKLY == alarm.fre_mode) {
        NSString *weekday = @"";
        
        if ( 0 == (alarm.frequency & (FREQUENCY_MONDAY|FREQUENCY_TUESDAY|FREQUENCY_WEDNESDAY|FREQUENCY_THURSDAY|FREQUENCY_FRIDAY|FREQUENCY_SATURDAY|FREQUENCY_SUNDAY))) {
            weekday = @"无周期";
        }
        
        if (FREQUENCY_MONDAY & alarm.frequency) {
            weekday = [weekday stringByAppendingFormat:@"%@ ", @"周一"];
        }
        
        if (FREQUENCY_TUESDAY & alarm.frequency) {
            weekday = [weekday stringByAppendingFormat:@"%@ ", @"周二"];
        }
        
        if (FREQUENCY_WEDNESDAY & alarm.frequency) {
            weekday = [weekday stringByAppendingFormat:@"%@ ", @"周三"];
        }
        
        if (FREQUENCY_THURSDAY & alarm.frequency) {
            weekday = [weekday stringByAppendingFormat:@"%@ ", @"周四"];
        }
        
        if (FREQUENCY_FRIDAY & alarm.frequency) {
            weekday = [weekday stringByAppendingFormat:@"%@ ", @"周五"];
        }
        
        if (FREQUENCY_SATURDAY & alarm.frequency) {
            weekday = [weekday stringByAppendingFormat:@"%@ ", @"周六"];
        }
        
        if (FREQUENCY_SUNDAY & alarm.frequency) {
            weekday = [weekday stringByAppendingFormat:@"%@ ", @"周日"];
        }
        
        cycle = weekday;
    } else {
        NSArray *arraydate = [alarm.date componentsSeparatedByString:@"-"];
        if (FRE_MODE_MONTHLY == alarm.fre_mode) {
            cycle = [NSString stringWithFormat: @"每月%@号", [arraydate objectAtIndex:2]];
        } else if (FRE_MODE_ANNUALLY == alarm.fre_mode) {
            cycle = [NSString stringWithFormat:@"每年%@月%@号", [arraydate objectAtIndex:1], [arraydate objectAtIndex:2]];
        }
    }
    
    return cycle;
}

+ (BOOL)parseAlarms:(NSArray *)alarmsItem alarmList:(NSMutableArray *)list {
    
    NSLog(@"%s", __func__);
    
    if (nil == alarmsItem) {
        return NO;
    }

    for (NSDictionary *alarmItem in alarmsItem) {
        AlarmClass *alarm = [[AlarmClass alloc] init];
        
        NSString *titleItem = [alarmItem objectForKey:JSONITEM_ALARM_TITLE];
        if(nil != titleItem) {
            alarm.title = titleItem;
        }
        
        NSNumber *idItem = [alarmItem objectForKey:JSONITEM_ALARM_ID];
        if(nil != idItem) {
            alarm.ID = [idItem integerValue];
        }
        
        NSNumber *isValidItem = [alarmItem objectForKey:JSONITEM_ALARM_ISVALID];
        if(nil != isValidItem) {
            alarm.is_valid = [isValidItem integerValue];
        }
        
        NSNumber *isLunarItem = [alarmItem objectForKey:JSONITEM_ALARM_ISLUNAR];
        if(nil != isLunarItem) {
            alarm.is_lunar = [isLunarItem integerValue];
        }
        
        NSString *dateItem = [alarmItem objectForKey:JSONITEM_ALARM_DATE];
        if(nil != dateItem) {
            alarm.date = dateItem;
        }
        
        NSString *clockItem = [alarmItem objectForKey:JSONITEM_ALARM_CLOCK];
        if(nil != clockItem) {
//            NSArray *arr = [clockItem componentsSeparatedByString:@":"];
//            alarm.clock = [NSString stringWithFormat:@"%@:%@", arr[0], arr[1]];
            alarm.clock = clockItem;
        }
        
        NSNumber *freModeItem = [alarmItem objectForKey:JSONITEM_ALARM_FREMODE];
        if(nil != freModeItem) {
            alarm.fre_mode = [freModeItem integerValue];
        }
        
        NSNumber *frequencyItem = [alarmItem objectForKey:JSONITEM_ALARM_FREQUENCY];
        if(nil != frequencyItem) {
            alarm.frequency = [frequencyItem integerValue];
        }
       
        [list addObject:alarm];
    }
    
    NSLog(@"exit %s", __func__);
    return YES;
}

+ (NSArray *)modifyAlarm:(AlarmClass *)alarm {
    
    if (nil == alarm) {
        return nil;
    }
    
    NSDictionary *alarmItem = [NSDictionary dictionaryWithObjectsAndKeys:alarm.title, JSONITEM_ALARM_TITLE, [NSNumber numberWithInteger:alarm.ID], JSONITEM_ALARM_ID, [NSNumber numberWithInteger:alarm.is_valid], JSONITEM_ALARM_ISVALID, [NSNumber numberWithInteger:alarm.is_lunar], JSONITEM_ALARM_ISLUNAR, alarm.date, JSONITEM_ALARM_DATE, alarm.clock, JSONITEM_ALARM_CLOCK, [NSNumber numberWithUnsignedInteger:alarm.fre_mode], JSONITEM_ALARM_FREMODE, [NSNumber numberWithUnsignedInteger:alarm.frequency], JSONITEM_ALARM_FREQUENCY, nil];

    return @[alarmItem];
}

+ (NSArray *)deleteAlarmWithAlarmId:(NSInteger)alarmId {
    NSDictionary *idItem = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:alarmId] forKey:JSONITEM_ALARM_ID];
    
    return @[idItem];
}

@end
