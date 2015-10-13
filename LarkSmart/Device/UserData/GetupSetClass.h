//
//  GetupSet.h
//  CloudBox
//
//  Created by TTS on 15-4-29.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

// 今天信息开关 JSONITEM_ALARM_MESSAGEOPEN
#define MESSAGE_OPEN_DATETIME       0x01 // 是否播放日期信息
#define MESSAGE_OPEN_WEATHER        0x02 // 是否播放天气信息
#define MESSAGE_OPEN_REMIND         0x04 // 是否播放明天备忘录
#define MESSAGE_OPEN_BIRTHDAY       0x08 // 是否播放生日信息
#define MESSAGE_OPEN_FESTIVALSOLARTERM  0x10 // 是否播放节日节气信息
#define MESSAGE_OPEN_HOLIDAYWISHES      0x20 // 是否播放节日祝福信息

@interface RingTimeClass : NSObject
@property (nonatomic, retain) NSString *text;
@property (nonatomic, assign) NSInteger time;

@end

@interface PlayTimesClass : NSObject
@property (nonatomic, retain) NSString *text;
@property (nonatomic, assign) NSInteger times;

@end

@interface GetupSetClass : NSObject

@property (nonatomic, assign) NSUInteger ringType; // 音乐类型
@property (nonatomic, retain) NSString *ringPath; // 音乐路径名
@property (nonatomic, assign) NSUInteger playTime; // 播放时间
@property (nonatomic, assign) NSUInteger delayNum; // 贪睡次数
@property (nonatomic, assign) NSUInteger delayTime; // 贪睡时间间隔
@property (nonatomic, assign) NSUInteger messageTimes; // 今天信息播放次数
@property (nonatomic, assign) NSUInteger messageOpen; // 今天信息开关
@property (nonatomic, assign) NSUInteger willDo; // 闹铃启动后的自定义操作

@property (nonatomic, retain) NSArray *ringTime;
@property (nonatomic, retain) NSArray *playTimes;

- (NSDictionary *)modify;
- (BOOL)parseGetupSet:(NSDictionary *)getupSetItem;

@end
