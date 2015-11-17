//
//  DeviceData.h
//  CloudBox
//
//  Created by TTS on 15-4-7.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "UIKit/UIKit.h"
#import "UserDataClass.h"
#import "AudioPlay.h"
#import "EventIndClass.h"
#import "TcpSession.h"
#import "YYTXJsonObject.h"
#import "Heartbeat.h"
#import "SystemToolClass.h"

extern NSString *const DeviceEventPlayerStart;
extern NSString *const DeviceEventPlayerStop;
extern NSString *const DeviceEventPlayerPause;
extern NSString *const DeviceEventPlayerResume;

extern NSString *const DevicePlayTTSWhenOperationSuccessful;
extern NSString *const DevicePlayTTSWhenOperationFailed;
extern NSString *const DevicePlayFileWhenOperationSuccessful;
extern NSString *const DevicePlayFileWhenOperationFailed;

@protocol DeviceDelegate <NSObject>

- (void)devicePresent:(id)device;
- (void)dataUpdate:(id)device;
- (void)deviceRemoved:(id)device;
- (void)deviceIsInvalid:(id)device;

@end

@interface DeviceDataClass : NSObject
@property (nonatomic, retain) id <DeviceDelegate> delegate;
@property (nonatomic, retain) UserDataClass *userData;
@property (nonatomic, retain) AudioPlay *audioPlay;
@property (nonatomic, retain) NSMutableArray *eventList;
@property (nonatomic, assign) long tag;

/** 设备的icon url */
@property (nonatomic, retain) NSString *deviceIconUrl;

// absent为YES时，终端已经断开了与手机的连接，比如终端与手机不在同一个网络，或终端已关机
// absent为NO时，终端与手机的连接很顺畅
@property (atomic, assign) BOOL isAbsent;
@property (atomic, assign) BOOL isSelect;

@property (nonatomic, retain) NSString *host;
@property (nonatomic, assign) UInt16 port;

- (instancetype)initWithHost:(NSString *)host port:(UInt16)port delegate:(id)delegate;
- (void)disable;
- (void)connected;

/** 获取设备的睡前音乐设置 */
- (void)getSleepMusic:(void (^)(YYTXDeviceReturnCode code))completion;

/** 修改设备的睡前音乐设置 */
- (void)modifySleepMusicSuccessful:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

/** 获取设备的唤醒控制的配置 */
- (void)getWakeup:(void (^)(YYTXDeviceReturnCode code))completion;

/** 修改设备的唤醒控制的配置 */
- (void)modifyWakeup:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

/** 获取设备的勿扰控制的配置 */
- (void)getUndisturbedControl:(void (^)(YYTXDeviceReturnCode code))block;
/** 修改设备的勿扰控制的配置 */
- (void)modifyUndisturbedControl:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode))block;

/** 获取设备的其他参数设置 */
- (void)getParameter1:(void (^)(YYTXDeviceReturnCode code))block;

/** 修改设备的其他参数设置 */
- (void)modifyParameter1:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

/** 获取设备的General数据 */
- (void)getGeneral:(void (^)(YYTXDeviceReturnCode code))block;

/** 修改设备的General数据 */
- (void)modifyGeneral:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

/** 播放设备预存文件－－－ID */
- (void)playFileId:(NSString *)fId completionBlock:(void (^)(YYTXDeviceReturnCode code))completion;

/** 播放预存文件－－－文件名 */
- (void)playFilePath:(NSString *)fPath completionBlock:(void (^)(YYTXDeviceReturnCode code))completion;

/** 播放网络资源 */
- (void)playFileTitle:(NSString *)tite url:(NSString *)url completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

/** 给设备发送百度语音解析的结果 */
- (void)sendAnalysisData:(NSDictionary *)result completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

/** 停止播放 */
- (void)stopPlay:(void (^)(YYTXDeviceReturnCode code))block;

/** 暂停播放 */
- (void)pausePlay:(void (^)(YYTXDeviceReturnCode code))block;

/** 恢复播放 */
- (void)resumePlay:(void (^)(YYTXDeviceReturnCode code))block;

/** 播放前一曲 */
- (void)playPrevious:(void (^)(YYTXDeviceReturnCode code))block;

/** 播放下一曲 */
- (void)playNext:(void (^)(YYTXDeviceReturnCode code))block;

/** 获取设备的音量 */
- (void)getVolume:(void (^)(YYTXDeviceReturnCode code))block;

/** 设置设备的音量 */
- (void)setVolume:(NSInteger)volume completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

/** 减小设备的音量 */
- (void)setVolumeDown:(void (^)(YYTXDeviceReturnCode code))block;

/** 增加设备的音量 */
- (void)setVolumeUp:(void (^)(YYTXDeviceReturnCode code))block;

/** 获取设备信息 */
- (void)getDeviceInfo:(void (^)(YYTXDeviceReturnCode code))completion;

/** 获取闹铃列表，起床闹铃和自定义闹铃 */
- (void)getAlarm:(void (^)(YYTXDeviceReturnCode code))completion;

/** 修改闹铃 */
- (void)modifyAlarm:(AlarmClass *)alarm parameter:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

/** 添加闹铃 */
- (void)addAlarm:(AlarmClass *)alarm params:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

/** 删除闹铃 */
- (void)deleteAlarm:(NSInteger)alarmId params:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

/** 获取备忘信息 */
- (void)getRemind:(void (^)(YYTXDeviceReturnCode code))completion;

/** 修改备忘信息 */
- (void)modifyRemind:(RemindClass *)remind parameter:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

/** 添加备忘信息 */
- (void)addRemind:(RemindClass *)remind parameter:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block ;

/** 删除备忘信息 */
- (void)deleteRemind:(NSUInteger)remindId params:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

/** 获取生日信息 */
- (void)getBirthday:(void (^)(YYTXDeviceReturnCode code))completion;

/** 修改生日信息 */
- (void)modifyBirthday:(BirthdayClass *)birthday parameter:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

/** 添加生日信息 */
- (void)addBirthday:(BirthdayClass *)birthday parameter:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

/** 删除生日信息 */
- (void)deleteBirthday:(NSInteger)birthdayId params:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

/** 获取起床闹铃通用设置 */
- (void)getGetupSet:(void (^)(YYTXDeviceReturnCode code))completion;

/** 修改起床闹铃通用设置 */
- (void)modifyGetupSet:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

- (void)heartBeat:(void (^)(YYTXDeviceReturnCode code))block;
@end
