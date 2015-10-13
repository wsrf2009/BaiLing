//
//  NetTools.m
//  CloudBox
//
//  Created by TTS on 15-5-21.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "NetworkMonitor.h"
#import "Reachability.h"
#import <UIKit/UIKit.h>
#import <SystemConfiguration/CaptiveNetwork.h>

Reachability *netReachability;
NSString *preSSID;

@implementation NetworkMonitor

- (instancetype)initWithDelegate:(id)delegate {

    self = [super init];
    if (nil != self) {
        _delegate = delegate;
        
//        [self checkNetworkStatus];
        
        [self startMonitor];
    }
    
    return self;
}

+ (BOOL)isEnableWIFI {
    
    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == ReachableViaWiFi);
}

+ (BOOL)isEnable3G {
    
    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
}

- (void)startMonitor {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object: nil];
    netReachability = [Reachability reachabilityForLocalWiFi];
    [netReachability startNotifier];
}

+ (void)dealloc {
    
    [netReachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    
    [self checkWiFiStatus:curReach];
}

- (void)checkWiFiStatus:(Reachability *)reach {
    
    //对连接改变做出响应的处理动作。
    NetworkStatus status = [reach currentReachabilityStatus];
    if (ReachableViaWiFi != status) {
        
        preSSID = nil;
        if ([_delegate respondsToSelector:@selector(wifiDisconnected)]) {
            [_delegate wifiDisconnected];
        }
    } else {
        NSString *curSSID = [NetworkMonitor currentWifiSSID];
        
        if (nil != preSSID) {
            if ([preSSID isEqual:curSSID]) {
                return;
            }
        }
        
        if ([_delegate respondsToSelector:@selector(connectedToSSID:)]) {
            [_delegate connectedToSSID:curSSID];
        }
    }
}

- (void)checkNetworkStatus {
    [self checkWiFiStatus:[Reachability reachabilityForLocalWiFi]];
}

+ (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
    }
    return info;
}

+ (NSString *)currentWifiSSID {
    NSString *ssid = nil;
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        
        if (info[@"SSID"]) {
            ssid = info[@"SSID"];
            break;
        }
    }
    
    return ssid;
}

@end
