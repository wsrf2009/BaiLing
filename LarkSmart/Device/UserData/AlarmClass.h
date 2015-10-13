//
//  AlarmClass.h
//  CloudBox
//
//  Created by TTS on 15-4-7.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAXCUSTOMIZEALARMTITLELENGTH   20

// 周期模式
#define FRE_MODE_ONEOFF         0 // 一次性闹铃
#define FRE_MODE_EVERYDAY       1 // 每天重复
#define FRE_MODE_WEEKLY         2 // 每周重复
#define FRE_MODE_MONTHLY        3 // 每月重复
#define FRE_MODE_ANNUALLY       4 // 每年重复

// 每周重复日期
#define FREQUENCY_MONDAY        0x40 // 星期一
#define FREQUENCY_TUESDAY       0x20 // 星期二
#define FREQUENCY_WEDNESDAY     0x10 // 星期三
#define FREQUENCY_THURSDAY      0x08 // 星期四
#define FREQUENCY_FRIDAY        0x04 // 星期五
#define FREQUENCY_SATURDAY      0x02 // 星期六
#define FREQUENCY_SUNDAY        0x01 // 星期天

// 闹铃类型 alarm
#define ALARMTYPE_GETUP                 "起床"
#define ALARMTYPE_CUSTOM                "自定义"

// 闹铃音乐类型 ring_type
#define RING_TYPE_LOCAL                 0
#define RING_TYPE_NET                   1




@interface AlarmClass : NSObject

@property (nonatomic, retain) NSMutableArray *list;

@property (nonatomic, retain) NSString *title; // 标题
@property (nonatomic, assign) NSInteger ID; // 唯一标志
@property (nonatomic, assign) NSInteger is_valid; // 是否生效
@property (nonatomic, assign) NSInteger is_lunar; // 农历标识
@property (nonatomic, retain) NSString *date; // 日期：“YYYY-MM-DD”
@property (nonatomic, retain) NSString *clock; // 时间：“hh:mm:ss”
@property (nonatomic, assign) NSInteger fre_mode; // 周期模式
@property (nonatomic, assign) NSInteger frequency; // 每周重复日期fre_mode＝2时有效

- (instancetype)initAlarmTitle:(NSString *)alarmTile alarmList:(NSMutableArray *)alarmList;
+ (NSInteger)getFreeId:(NSMutableArray *)alarmList;
+ (NSString *)getAlarmCycle:(AlarmClass *)alarm;
+ (NSArray *)modifyAlarm:(AlarmClass *)alarm;
+ (NSArray *)deleteAlarmWithAlarmId:(NSInteger)alarmId;

+ (BOOL)parseAlarms:(NSArray *)alarmsItem alarmList:(NSMutableArray *)list;

@end
