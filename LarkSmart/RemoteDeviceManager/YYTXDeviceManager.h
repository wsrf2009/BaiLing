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

/** WIFI已连接 */
extern NSString *const YYTXDeviceManagerWIFIConnected;
/** WIFI已端开连接 */
extern NSString *const YYTXDeviceManagerWIFIDisconnected;
/** 连接到新的WIFI */
extern NSString *const YYTXNewWIFISSID;

@protocol YYTXDeviceManagerDelegate <NSObject>

@optional
/** 设备列表有更新 */
- (void)deviceListUpdate;

@end

@interface YYTXDeviceManager : NSObject
@property (nonatomic, assign) id <YYTXDeviceManagerDelegate> delegate;
@property (nonatomic, retain) DeviceDataClass *device; // 选中的设备
@property (nonatomic, retain) ServerServiceManager *serverService;
/** 本地音乐中从ipod－library中导出歌曲的任务 */
@property (nonatomic, retain) LocalMusicTask *mediaTask;

/** 扫描到的设备的数量 */
- (NSUInteger)deviceCount;

/** 在已扫描到的设备中获取第index个设备 */
- (DeviceDataClass *)deviceAtIndex:(NSUInteger)index;

/** 检查手机的网络连接状态，WIFI或者蜂窝 */
- (void)checkNetWorkStatus;

/** 以较高的频率扫描设备，1s一次 */
- (void)searchDeviceInHighFreq;

/** 暂停搜索设备 */
- (void)pauseSearchDevice;

/** 以较低的频率搜索设备，5s一次 */
- (void)searchDeviceInLowFreq;

/** 清空已扫描到的设备列表 */
- (void)clearDevices;

/** 刷新设备列表。每个已扫描到的设备重新获取一次General数据，看是否能正常获取到 */
- (void)refreshDevices;

/** 检查APP和设备所连的服务器，正式服务器还是测试服务器，结果在status中 */
- (BOOL)checkServerStatus:(NSString **)status;

/** 从语音天下的后台服务器获取最新的数据 */
- (void)updateDataFromServer;

@end
