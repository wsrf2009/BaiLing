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

+ (BOOL)isEnableWIFI;
- (instancetype)initWithDelegate:(id)delegate;
+ (NSString *)currentWifiSSID;
- (void)checkNetworkStatus;

@end
