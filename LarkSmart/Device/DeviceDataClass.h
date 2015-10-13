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

- (void)getSleepMusic:(void (^)(YYTXDeviceReturnCode code))completion;
- (void)modifySleepMusicSuccessful:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

- (void)getWakeup:(void (^)(YYTXDeviceReturnCode code))completion;
- (void)modifyWakeup:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

- (void)getUndisturbedControl:(void (^)(YYTXDeviceReturnCode code))block;
- (void)modifyUndisturbedControl:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode))block;

- (void)getParameter1:(void (^)(YYTXDeviceReturnCode code))block;
- (void)modifyParameter1:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

- (void)getGeneral:(void (^)(YYTXDeviceReturnCode code))block;
- (void)modifyGeneral:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

- (void)playFileId:(NSString *)fId completionBlock:(void (^)(YYTXDeviceReturnCode code))completion;
- (void)playFilePath:(NSString *)fPath completionBlock:(void (^)(YYTXDeviceReturnCode code))completion;
- (void)playFileTitle:(NSString *)tite phoneID:(NSString *)phoneId url:(NSString *)url completionBlock:(void (^)(YYTXDeviceReturnCode code))block;
- (void)sendAnalysisData:(NSDictionary *)result completionBlock:(void (^)(YYTXDeviceReturnCode code))block;
- (void)stopPlay:(void (^)(YYTXDeviceReturnCode code))block;
- (void)pausePlay:(void (^)(YYTXDeviceReturnCode code))block;
- (void)resumePlay:(void (^)(YYTXDeviceReturnCode code))block;
- (void)playPrevious:(void (^)(YYTXDeviceReturnCode code))block;
- (void)playNext:(void (^)(YYTXDeviceReturnCode code))block;
- (void)getVolume:(void (^)(YYTXDeviceReturnCode code))block;
- (void)setVolume:(NSInteger)volume completionBlock:(void (^)(YYTXDeviceReturnCode code))block;
- (void)setVolumeDown:(void (^)(YYTXDeviceReturnCode code))block;
- (void)setVolumeUp:(void (^)(YYTXDeviceReturnCode code))block;

- (void)getDeviceInfo:(void (^)(YYTXDeviceReturnCode code))completion;

- (void)getAlarm:(void (^)(YYTXDeviceReturnCode code))completion;
- (void)modifyAlarm:(AlarmClass *)alarm parameter:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;
- (void)addAlarm:(AlarmClass *)alarm params:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;
- (void)deleteAlarm:(NSInteger)alarmId params:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

- (void)getRemind:(void (^)(YYTXDeviceReturnCode code))completion;
- (void)modifyRemind:(RemindClass *)remind parameter:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;
- (void)addRemind:(RemindClass *)remind parameter:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block ;
- (void)deleteRemind:(NSUInteger)remindId params:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

- (void)getBirthday:(void (^)(YYTXDeviceReturnCode code))completion;
- (void)modifyBirthday:(BirthdayClass *)birthday parameter:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;
- (void)addBirthday:(BirthdayClass *)birthday parameter:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;
- (void)deleteBirthday:(NSInteger)birthdayId params:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

- (void)getGetupSet:(void (^)(YYTXDeviceReturnCode code))completion;
- (void)modifyGetupSet:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block;

- (void)heartBeat:(void (^)(YYTXDeviceReturnCode code))block;
@end
