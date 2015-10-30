//
//  DeviceManger.h
//  CloudBox
//
//  Created by TTS on 15-3-26.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceDataClass.h"
#import "ServerServiceManager.h"
#import "BoxDatabase.h"
#import "NetworkMonitor.h"
#import "QXToast.h"
#import "SystemToolClass.h"
#import "UICustomAlertView.h"
#import "LocalMusicTask.h"

extern NSString *const YYTXDeviceManagerWIFIConnected;
extern NSString *const YYTXDeviceManagerWIFIDisconnected;
extern NSString *const YYTXNewWIFISSID;

@protocol YYTXDeviceManagerDelegate <NSObject>

@optional
- (void)deviceListUpdate;

@end

@interface YYTXDeviceManager : NSObject
@property (nonatomic, assign) id <YYTXDeviceManagerDelegate> delegate;
@property (nonatomic, retain) DeviceDataClass *device;
@property (nonatomic, retain) ServerServiceManager *serverService;
@property (nonatomic, retain) LocalMusicTask *mediaTask;

- (NSUInteger)deviceCount;
- (DeviceDataClass *)deviceAtIndex:(NSUInteger)index;


- (void)checkNetWorkStatus;
- (void)searchDeviceInHighFreq;
- (void)pauseSearchDevice;
- (void)searchDeviceInLowFreq;

- (void)clearDevices;
- (void)refreshDevices;

- (BOOL)checkServerStatus:(NSString **)status;

/*
 * 从语音天下的后台服务器获取最新的数据
 */
- (void)updateDataFromServer;

@end
