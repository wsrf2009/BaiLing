//
//  UserDataClass.h
//  CloudBox
//
//  Created by TTS on 15-4-23.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlarmClass.h"
#import "RemindClass.h"
#import "BirthdayClass.h"
#import "WakeupClass.h"
#import "UndisturbedControl.h"
#import "SleepMusicClass.h"
#import "DeviceInfoClass.h"
#import "GeneralDataClass.h"
#import "GetupSetClass.h"
#import "Parameter1Class.h"

#define JSONITEM_DATA       @"data"

#define ITEMVALUE_USERDATA_GETUSERDATA        @"getUserData"
#define ITEMVALUE_USERDATA_SETUSERDATA        @"setUserData"
#define ITEMVALUE_USERDATA_INSERTUSERDATA     @"insertUserData"
#define ITEMVALUE_USERDATA_DELETEUSERDATA     @"deleteUserData"

@interface UserDataClass : NSObject
@property (nonatomic, retain) GeneralDataClass *generalData;
@property (nonatomic, retain) DeviceInfoClass *deviceInfo;
@property (atomic, retain) NSMutableArray *alarmList;
@property (nonatomic, retain) GetupSetClass *getupSet;
@property (atomic, retain) NSMutableArray *remindList;
@property (atomic, retain) NSMutableArray *birthdayList;
@property (nonatomic, retain) WakeupClass *wakeup;
@property (nonatomic, retain) Parameter1Class *parameter1;
@property (nonatomic, retain) UndisturbedControl *undisturbedControl;
@property (nonatomic, retain) SleepMusicClass *sleepMusic;


- (BOOL)parseResultItem:(NSDictionary *)resultItem;

- (NSArray *)getGeneral;
- (NSDictionary *)modifyGeneral;

- (NSArray *)getWakeup;
- (NSDictionary *)modifyWakeup;

- (NSArray *)getUndisturbedControl;
- (NSDictionary *)modifyUndisturbedControl;

- (NSArray *)getParameter1;
- (NSDictionary *)modifyParameter1;

- (NSArray *)getSleepMusic;
- (NSDictionary *)modifySleepMusic;

- (NSArray *)getDeviceInfo;

- (NSArray *)getAlarm;
- (NSDictionary *)modifyAlarm:(AlarmClass *)alarm;
- (NSDictionary *)addAlarm:(AlarmClass *)alarm;
- (NSDictionary *)deleteAlarmWithAlarmId:(NSInteger)alarmId;

- (NSArray *)getRemind;
- (NSDictionary *)modifyRemind:(RemindClass *)remind;
- (NSDictionary *)addRemind:(RemindClass *)remind;
- (NSDictionary *)deleteRemindWithRemindId:(NSInteger)remindId;

- (NSArray *)getBirthday;
- (NSDictionary *)modifyBirthday:(BirthdayClass *)birthday;
- (NSDictionary *)addBirthday:(BirthdayClass *)birthday;
- (NSDictionary *)deleteBirthdayWithBirthdayId:(NSInteger)birthdayId;

- (NSArray *)getGetupSet;
- (NSDictionary *)modifyGetupSet;

@end
