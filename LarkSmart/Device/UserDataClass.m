//
//  UserDataClass.m
//  CloudBox
//
//  Created by TTS on 15-4-23.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "UserDataClass.h"

// user data
#define JSONITEM_USERDATA_GENERAL       @"general"
#define JSONITEM_USERDATA_VERSION       @"version"
#define JSONITEM_USERDATA_WIFI          @"wifi"
#define JSONITEM_USERDATA_KEYBOARD      @"keyboard"
#define JSONITEM_USERDATA_CLOCKCHIME    @"clockchime"
#define JSONITEM_USERDATA_ALARM         @"alarm"
#define JSONITEM_USERDATA_REMIND        @"remind"
#define JSONITEM_USERDATA_BIRTHDAY      @"birthday"
#define JSONITEM_USERDATA_GETUPSET      @"getupset"
#define JSONITEM_USERDATA_ALBUM         @"album"     // 睡前音乐
#define JSONITEM_USERDATA_SERVER        @"server"
#define JSONITEM_USERDATA_DEVICE_INFO   @"device_info"
#define JSONITEM_USERDATA_WAKEUP        @"wakeup"
#define JSONITEM_USERDATA_PARAMETER1    @"parameter1"

NSString const *jsonItemUserDataUndisturbed = @"undisturbed";

@implementation UserDataClass

- (instancetype)init {
    self = [super init];
    if (nil != self) {
        _alarmList = [[NSMutableArray alloc] init];
        _remindList = [[NSMutableArray alloc] init];
        _birthdayList = [[NSMutableArray alloc] init];
        _wakeup = [[WakeupClass alloc] init];
        _undisturbedControl = [[UndisturbedControl alloc] init];
        _sleepMusic = [[SleepMusicClass alloc] init];
        _deviceInfo = [[DeviceInfoClass alloc] init];
        _generalData = [[GeneralDataClass alloc] init];
        _getupSet = [[GetupSetClass alloc] init];
        _parameter1 = [[Parameter1Class alloc] init];
    }
    return self;
}

- (BOOL)parseResultItem:(NSDictionary *)resultItem {
    if (nil == resultItem) {
        return NO;
    }
    
    NSDictionary *generalItem = [resultItem objectForKey:JSONITEM_USERDATA_GENERAL];
    if (nil != generalItem) {
        [_deviceInfo parseDeviceInfo:generalItem];
        return [_generalData parseGeneral:generalItem];
    }
    
    NSDictionary *deviceInfoItem = [resultItem objectForKey:JSONITEM_USERDATA_DEVICE_INFO];
    if (nil != deviceInfoItem) {
        _deviceInfo.isValid = YES;
        return [_deviceInfo parseDeviceInfo:deviceInfoItem];
    }
    
    NSArray *alarmsItem = [resultItem objectForKey:JSONITEM_USERDATA_ALARM];
    if (nil != alarmsItem) {
        return [AlarmClass parseAlarms:alarmsItem alarmList:_alarmList];
    }
    
    NSArray *birthdaysItem = [resultItem objectForKey:JSONITEM_USERDATA_BIRTHDAY];
    if (nil != birthdaysItem) {
        return [BirthdayClass parseBirthdays:birthdaysItem birthdayList:_birthdayList];
    }
    
    NSArray *remindsItem = [resultItem objectForKey:JSONITEM_USERDATA_REMIND];
    if (nil != remindsItem) {
        return [RemindClass parseReminds:remindsItem remindList:_remindList];
    }
    
    NSDictionary *sleepMusicItem = [resultItem objectForKey:JSONITEM_USERDATA_ALBUM];
    if (nil != sleepMusicItem) {
        return [_sleepMusic parseSleepMusic:sleepMusicItem];
    }
    
    NSDictionary *getupSetItem = [resultItem objectForKey:JSONITEM_USERDATA_GETUPSET];
    if (nil != getupSetItem) {
        return [_getupSet parseGetupSet:getupSetItem];
    }
    
    NSDictionary *wakeupItem = [resultItem objectForKey:JSONITEM_USERDATA_WAKEUP];
    if (nil != wakeupItem) {
        return [_wakeup parseWakeup:wakeupItem];
    }
    
    NSDictionary *undisturbedControlItem = [resultItem objectForKey:jsonItemUserDataUndisturbed];
    if (nil != undisturbedControlItem) {
        return [_undisturbedControl parseUndisturbedControl:undisturbedControlItem];
    }
    
    NSDictionary *parameter1Item = [resultItem objectForKey:JSONITEM_USERDATA_PARAMETER1];
    if (nil != parameter1Item) {
        return [_parameter1 parseParameter1:parameter1Item];
    }
    
    return NO;
}

#pragma general data方法

- (NSArray *)getGeneral {
    
    return @[JSONITEM_USERDATA_GENERAL];
}

- (NSDictionary *)modifyGeneral {
    NSDictionary *generalItem = [_generalData modify];
    NSDictionary *setUserDataItem = [NSDictionary dictionaryWithObject:generalItem forKey:JSONITEM_USERDATA_GENERAL];
    
    return setUserDataItem;
}

#pragma wakeup方法

- (NSArray *)getWakeup {

    return @[JSONITEM_USERDATA_WAKEUP];
}

- (NSDictionary *)modifyWakeup {
    NSDictionary *wakeupItem = [_wakeup modify];
    NSDictionary *setUserDataItem = [NSDictionary dictionaryWithObject:wakeupItem forKey:JSONITEM_USERDATA_WAKEUP];
    
    return setUserDataItem;
}

#pragma 夜间控制方法

- (NSArray *)getUndisturbedControl {
    
    return @[jsonItemUserDataUndisturbed];
}

- (NSDictionary *)modifyUndisturbedControl {
    NSDictionary *undisturbedControlItem = [_undisturbedControl modify];
    NSDictionary *setUserDataItem = [NSDictionary dictionaryWithObject:undisturbedControlItem forKey:jsonItemUserDataUndisturbed];
    
    return setUserDataItem;
}

#pragma Parameter1 方法

- (NSArray *)getParameter1 {

    return @[JSONITEM_USERDATA_PARAMETER1];
}

- (NSDictionary *)modifyParameter1 {
    NSDictionary *parameter1Item = [_parameter1 modify];
    NSDictionary *setUserDataItem = [NSDictionary dictionaryWithObject:parameter1Item forKey:JSONITEM_USERDATA_PARAMETER1];
    
    return setUserDataItem;
}

#pragma 睡前音乐方法

- (NSArray *)getSleepMusic {

    return @[JSONITEM_USERDATA_ALBUM];
}

- (NSDictionary *)modifySleepMusic {
    NSDictionary *sleepMusicItem = [_sleepMusic modify];
    NSDictionary *setUserDataItem = [NSDictionary dictionaryWithObject:sleepMusicItem forKey:JSONITEM_USERDATA_ALBUM];
    
    return setUserDataItem;
}

#pragma 设备信息方法

- (NSArray *)getDeviceInfo {

    return @[JSONITEM_USERDATA_DEVICE_INFO];
}

#pragma 闹铃方法

- (NSArray *)getAlarm {

    return @[JSONITEM_USERDATA_ALARM];
}

- (NSDictionary *)modifyAlarm:(AlarmClass *)alarm {
    NSArray *alarms = [AlarmClass modifyAlarm:alarm];
    NSDictionary *setUserDataItem = [NSDictionary dictionaryWithObject:alarms forKey:JSONITEM_USERDATA_ALARM];
    
    return setUserDataItem;
}

- (NSDictionary *)addAlarm:(AlarmClass *)alarm {
    NSArray *alarms = [AlarmClass modifyAlarm:alarm];
    NSDictionary *insertUserDataItem = [NSDictionary dictionaryWithObject:alarms forKey:JSONITEM_USERDATA_ALARM];
    
    return insertUserDataItem;
}

- (NSDictionary *)deleteAlarmWithAlarmId:(NSInteger)alarmId {
    NSArray *alarmIds = [AlarmClass deleteAlarmWithAlarmId:alarmId];
    NSDictionary *deleteUserDataItem = [NSDictionary dictionaryWithObject:alarmIds forKey:JSONITEM_USERDATA_ALARM];
    
    return deleteUserDataItem;
}

#pragma 备忘方法

- (NSArray *)getRemind {

    return @[JSONITEM_USERDATA_REMIND];
}

- (NSDictionary *)modifyRemind:(RemindClass *)remind {
    NSArray *reminds = [RemindClass modifyRemind:remind];
    NSDictionary *setUserDataItem = [NSDictionary dictionaryWithObject:reminds forKey:JSONITEM_USERDATA_REMIND];
    
    return setUserDataItem;
}

- (NSDictionary *)addRemind:(RemindClass *)remind {
    NSArray *reminds = [RemindClass modifyRemind:remind];
    NSDictionary *insertUserDataItem = [NSDictionary dictionaryWithObject:reminds forKey:JSONITEM_USERDATA_REMIND];
    
    return insertUserDataItem;
}

- (NSDictionary *)deleteRemindWithRemindId:(NSInteger)remindId {
    NSArray *remindIds = [RemindClass deleteRemindWithRemindId:remindId];
    NSDictionary *deleteUserDataItem = [NSDictionary dictionaryWithObject:remindIds forKey:JSONITEM_USERDATA_REMIND];
    
    return deleteUserDataItem;
}

#pragma 生日方法

- (NSArray *)getBirthday {

    return @[JSONITEM_USERDATA_BIRTHDAY];
}

- (NSDictionary *)modifyBirthday:(BirthdayClass *)birthday {
    NSArray *birthdays = [BirthdayClass modifyBirthday:birthday];
    NSDictionary *setUserDataItem = [NSDictionary dictionaryWithObject:birthdays forKey:JSONITEM_USERDATA_BIRTHDAY];
    
    return setUserDataItem;
}

- (NSDictionary *)addBirthday:(BirthdayClass *)birthday {
    NSArray *birthdays = [BirthdayClass modifyBirthday:birthday];
    NSDictionary *insertUserDataItem = [NSDictionary dictionaryWithObject:birthdays forKey:JSONITEM_USERDATA_BIRTHDAY];
    
    return insertUserDataItem;
}

- (NSDictionary *)deleteBirthdayWithBirthdayId:(NSInteger)birthdayId {
    NSArray *birthdayIds = [BirthdayClass deleteBirthdayWithBirthdayId:birthdayId];
    NSDictionary *deleteUserDataItem = [NSDictionary dictionaryWithObject:birthdayIds forKey:JSONITEM_USERDATA_BIRTHDAY];
    
    return deleteUserDataItem;
}

#pragma 起床闹铃通用设置方法

- (NSArray *)getGetupSet {

    return @[JSONITEM_USERDATA_GETUPSET];
}

- (NSDictionary *)modifyGetupSet {
    NSDictionary *getupSetItem = [_getupSet modify];
    NSDictionary *setUserDataItem = [NSDictionary dictionaryWithObject:getupSetItem forKey:JSONITEM_USERDATA_GETUPSET];
    
    return setUserDataItem;
}

@end
