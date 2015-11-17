//
//  NetTools.h
//  CloudBox
//
//  Created by TTS on 15-5-21.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetworkMonitorDelegate <NSObject>

- (void)wifiDisconnected;
- (void)connectedToSSID:(NSString *)ssid;

@end

@interface NetworkMonitor : NSObject
@property (nonatomic, retain) id <NetworkMonitorDelegate> delegate;

/** 手机当前是否已使用WIFI */
+ (BOOL)isEnableWIFI;

- (instancetype)initWithDelegate:(id)delegate;

/** 获取手机当前连接到的SSID */
+ (NSString *)currentWifiSSID;

/** 检查手机当前的网络连接状态 */
- (void)checkNetworkStatus;

@end
