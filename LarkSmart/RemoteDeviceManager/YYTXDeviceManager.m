//
//  DeviceManger.m
//  CloudBox
//
//  Created by TTS on 15-3-26.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "YYTXDeviceManager.h"
#import <UIKit/UIKit.h>
#import "UdpServceManager.h"
#import "ScanDeviceViewController.h"
#import "WelcomeViewController.h"
#import "ViewController.h"

NSString *const YYTXDeviceManagerWIFIConnected = @"YYTXDeviceManagerWIFIConnected";
NSString *const YYTXDeviceManagerWIFIDisconnected = @"YYTXDeviceManagerWIFIDisconnected";
NSString *const YYTXNewWIFISSID = @"YYTXNewWIFISSID";

#define TEST        0

@interface YYTXDeviceManager () <NetworkMonitorDelegate, UdpServceDelegate, DeviceDelegate, ServerServiceDelegate>
{
    UdpServceManager *udpServce;
    NetworkMonitor *networkMonitor;
    BOOL pauseSearch;
}

@property (atomic, retain) NSMutableArray *foundDevices; // 已发现的设备
@property (atomic, retain) NSMutableArray *connectedDevices; // 已连接的设备
#if TEST
@property (nonatomic, retain) NSMutableArray *deviceMacArray;
@property (nonatomic, retain) NSTimer *timerForTcpScanning;
@property (nonatomic, assign) BOOL record;
#endif
@property (nonatomic, assign) BOOL alertIsPresent;
@property (nonatomic, retain) UICustomAlertView *alertView;
@property (nonatomic, retain) UIAlertController *alertController;
@end

@implementation YYTXDeviceManager

- (instancetype)init {
    
    NSLog(@"%s", __func__);
    
    self = [super init];
    if (nil != self) {
        networkMonitor = [[NetworkMonitor alloc] initWithDelegate:self];
        udpServce = [[UdpServceManager alloc] initWithDelegate:self];
        _serverService = [[ServerServiceManager alloc] initWithDelegate:self];
        _foundDevices = [[NSMutableArray alloc] init];
        _connectedDevices = [[NSMutableArray alloc] init];
        _alertIsPresent = NO;
        _mediaTask = [[LocalMusicTask alloc] init];
        
#if TEST
        _deviceMacArray = [NSMutableArray array];
        _timerForTcpScanning = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(tcpScanTask) userInfo:nil repeats:YES];
        _record = NO;
#endif
    }

    return self;
}

- (void)checkNetWorkStatus {
    [networkMonitor checkNetworkStatus];
}

- (void)searchDeviceInHighFreq {
    
    NSLog(@"%s", __func__);
#if TEST
    _record = NO;
#endif
    [udpServce broadcastInHighFreq];
}

- (void)pauseSearchDevice {
    
    NSLog(@"%s", __func__);

    [udpServce pauseBroadcast];
}

- (void)searchDeviceInLowFreq {

    NSLog(@"%s", __func__);
#if TEST
    _record = YES;
#endif
    [udpServce broadcastInLowFreq];
}

- (void)clearDevices {
    
    NSLog(@"%s", __func__);

    [_connectedDevices removeAllObjects];
}

/** 将所有已扫描到的设备断开连接，并释放它们的资源 */
- (void)disconnectAllDevices {

    NSLog(@"%s", __func__);
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:_foundDevices];
    for (DeviceDataClass *device in arr) {
        NSLog(@"%s %@, %@, %@ -----------------------------------", __func__, device.host, device.userData.generalData.nickName, device.userData.generalData.deviceId);
        [device disable];
    }
}

- (void)refreshDevices {
    
    NSLog(@"%s", __func__);
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:_foundDevices];
    for (DeviceDataClass *device in arr) {
        NSLog(@"%s %@, %@, %@ -----------------------------------", __func__, device.host, device.userData.generalData.nickName, device.userData.generalData.deviceId);
        [device connected];
    }
}
#if TEST
- (void)tcpScanTask {
    
    if (_record) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        [BoxDatabase insertTcpScanResultWithScanTime:[dateFormatter stringFromDate:[NSDate date]] scanResult:_deviceMacArray];
    }
    [_deviceMacArray removeAllObjects];

    [self refreshDevices];
}
#endif
- (NSUInteger)deviceCount {
    return [_connectedDevices count];
}

- (DeviceDataClass *)deviceAtIndex:(NSUInteger)index {
    if (index >= ([_connectedDevices count])) {
        return nil;
    }
    
    return [_connectedDevices objectAtIndex:index];
}

/** 添加新的设备到已发现设备列表 */
- (void)addNewDeviceWithHost:(NSString *)host port:(UInt16)port {

    NSLog(@"%s %@", __func__, @(_foundDevices.count));
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:_foundDevices];
    for (DeviceDataClass *device in arr) {
        if ([device.host isEqualToString:host] && device.port == port) {
            /* 该设备已存在于已发现设备的列表则返回 */
            return;
        }
    }
    
    /* 以设备的host和port为参数创建新的设备，并将其添加到已发现设备的列表中 */
    DeviceDataClass *device = [[DeviceDataClass alloc] initWithHost:host port:port delegate:self];
    [_foundDevices addObject:device];
}

/** 获取当前视图层级中位于最上层的用户直接能看到的视图 */
- (UIViewController *)appRootViewController {
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

- (BOOL)checkServerStatus:(NSString **)status {
    
    if (nil == _device.userData.deviceInfo.host || nil == _device.userData.deviceInfo.host) {
        /* 如果还没有从设备设备端获取到所连服务器信息，则返回 */
        return NO;
    }
    
    NSLog(@"%s deviceInfo:%@", __func__, _device.userData.deviceInfo);
    
    NSString *deviceServerAddr = _device.userData.deviceInfo.host; // 设备所用服务器
    NSString *appServerAddr = _serverService.ServerAddress; // APP所用服务器
    if ([deviceServerAddr isEqualToString:YYTXServerNormal] && [appServerAddr isEqualToString:YYTXServerNormal]) {
        /* 设备和APP都用的是正式服务器 */
        *status = @"正常";
        return NO;
    } else if ([deviceServerAddr isEqualToString:YYTXServerTest] && [appServerAddr isEqualToString:YYTXServerTest]) {
        /* 设备和APP都用的是测试服务器 */
        *status = @"测试";
        return YES;
    } else {
        /* 设备和APP所用的服务器不一样 */
        NSString *hardStr;
        NSString *softStr;
        if ([deviceServerAddr isEqualToString:YYTXServerNormal]) {
            hardStr = @"硬正";
        } else if ([deviceServerAddr isEqualToString:YYTXServerTest]) {
            hardStr = @"硬测";
        } else {
            hardStr = @"硬异";
        }
        
        if ([appServerAddr isEqualToString:YYTXServerNormal]) {
            softStr = @"软正";
        } else if ([appServerAddr isEqualToString:YYTXServerTest]) {
            softStr = @"软测";
        } else {
            softStr = @"软异";
        }
        
        *status = [hardStr stringByAppendingString:softStr];
        
        NSString *title = NSLocalizedStringFromTable(@"kindlyReminder", @"hint", nil);
        NSString *message = [NSLocalizedStringFromTable(@"ServerAbnormal", @"hint", nil) stringByAppendingString:*status];
        NSString *buttonOkTitle = NSLocalizedStringFromTable(@"ok", @"hint", nil);
        
        /* 在屏幕上以弹窗的形式告知用户当前APP和设备所用的服务器是不一样的 */
        if ([SystemToolClass systemVersionIsNotLessThan:@"8.0"]) {
            /* IOS8.0及以后的系统 */
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:nil]];
            if (nil != alertController) {
                [[self appRootViewController] presentViewController:alertController animated:YES completion:nil];
            }
        } else {
            /* IOS8.0以前的系统 */
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:buttonOkTitle, nil];
            [alertView show];
        }
        
        
        return YES;
    }
}

#pragma Mark:UdpServce 代理

/** UDP发现了新的设备 */
- (void)foundHost:(NSString *)host port:(UInt16)port {
    
    NSLog(@"%s host:%@ port:%d", __func__, host, port);
    
    /* UdpManager发现了新的设备 */
    [self addNewDeviceWithHost:host port:port];
}

#pragma Mark:设备代理

/** TCP已与设备建立了稳定的连接 */
- (void)devicePresent:(DeviceDataClass *)device {
    
    NSLog(@"%s %@", __func__, device.userData.generalData.nickName);
    
    if (nil == device) {
        return;
    }
#if TEST
    if (nil != device.userData.generalData.deviceId) {
       [_deviceMacArray addObject:device.userData.generalData.deviceId];
    }
#endif
    if (![_connectedDevices containsObject:device]) { // 已连接设备列表中是否已包含该设备

        [_connectedDevices addObject:device]; // 将设备添加到已连接设备列表中
        
        if ([device.host isEqualToString:_device.host] && device.port == _device.port) {
            /** 若该设备为当前正在操作的设备 */
            _device = device;
            
            if (_alertIsPresent) {
                /* 若已有弹窗提示设备已端开连接，则将此弹窗dismiss */
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if ([SystemToolClass systemVersionIsNotLessThan:@"8.0"]) {
                        [_alertController dismissViewControllerAnimated:YES completion:nil];
                    } else {
                        [_alertView dismissWithClickedButtonIndex:0 animated:YES];
                    }
                });
            }
        }
        
        if ([_delegate respondsToSelector:@selector(deviceListUpdate)]) {
            [_delegate deviceListUpdate];
        }
    }
}

- (void)dataUpdate:(DeviceDataClass *)device {
    
    NSLog(@"%s %@", __func__, _delegate);
    
//    if ([_delegate respondsToSelector:@selector(deviceDataUpdate)]) {
//        [_delegate deviceDataUpdate];
//    }
}

- (void)deviceIsInvalid:(id)device {
    
    NSLog(@"%s", __func__);
    
    if ([_foundDevices containsObject:device]) {
        [_foundDevices removeObject:device];
    }
    
    if ([_connectedDevices containsObject:device]) {
        [_connectedDevices removeObject:device];
    }
}

/** 设备的TCP连接已端开，被认为不在当前网络 */
- (void)deviceRemoved:(DeviceDataClass *)device {
    
    NSLog(@"%s", __func__);
    
    /* 从已发现的设备列表和已连接的设备列表移去该设备 */
    [_foundDevices removeObject:device];
    [_connectedDevices removeObject:device];
    
    if ([device.host isEqualToString:_device.host] && device.port == _device.port) {
        
        /* 若该设备为当前正在操控的设备 */
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *title = [SystemToolClass appName];
            NSString *message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), device.userData.generalData.nickName];
            NSString *buttonRescanTitle = NSLocalizedStringFromTable(@"rescanningDevice", @"hint", nil);
            
            /* 在手机屏幕上弹出提示，告知用户该设备已与手机端开连接 */
            if ([SystemToolClass systemVersionIsNotLessThan:@"8.0"]) {
                /* IOS8.0及以后的系统 */
                _alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
                
                [_alertController addAction:[UIAlertAction actionWithTitle:buttonRescanTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    _alertIsPresent = NO;
                    
                    [self gotoScanningVC];
                }]];
                
                UIViewController *VC = [self appRootViewController];
                
                NSLog(@"%s _alertController:%@ _alertIsPresent:%d", __func__, _alertController, _alertIsPresent);
                
                if (nil != _alertController && !_alertIsPresent) {
                    _alertIsPresent = YES;
                    [VC presentViewController:_alertController animated:YES completion:nil];
                }
            } else {
                /* IOS8.0以前的系统 */
                _alertView = [[UICustomAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:buttonRescanTitle, nil];
                
                NSLog(@"%s _alertView:%@ _alertIsPresent:%d", __func__, _alertView, _alertIsPresent);
                
                if (!_alertIsPresent) {
                    _alertIsPresent = YES;
                    [_alertView showAlertViewWithCompleteBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        
                        _alertIsPresent = NO;
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            
                            [self gotoScanningVC];
                        });
                    }];
                }
            }
        });
    }
    
    if ([_delegate respondsToSelector:@selector(deviceListUpdate)]) {
        [_delegate deviceListUpdate];
    }
}

/** 跳转到扫描设备的视图 */
- (void)gotoScanningVC {
        
    UIViewController *VC = [self appRootViewController];
    if ([VC isKindOfClass:[ScanDeviceViewController class]]) {
        return;
    }
        
    ScanDeviceViewController *scanDeviceVC = [[UIStoryboard storyboardWithName:@"ScanDevice" bundle:nil] instantiateViewControllerWithIdentifier:@"ScanDeviceViewController"];
    scanDeviceVC.deviceManager = self;
    if (nil != scanDeviceVC) {
        _alertIsPresent = NO;
        [VC presentViewController:scanDeviceVC animated:YES completion:nil];
    }
}

#pragma Mark:NetworkMonitor 代理

/** 手机的WIFI已端开连接 */
- (void)wifiDisconnected {

    NSLog(@"%s", __func__);
    
    [self disconnectAllDevices];
    [_foundDevices removeAllObjects];
    [_connectedDevices removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:YYTXDeviceManagerWIFIDisconnected object:self userInfo:nil]; // 发送通知，告知（FSK配置中输入SSID和密码界面）手机的WIFI已端开连接
    
    if ([_delegate respondsToSelector:@selector(deviceListUpdate)]) {
        [_delegate deviceListUpdate];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *title = [SystemToolClass appName];
        NSString *message = NSLocalizedStringFromTable(@"wifiIsNotEnable", @"hint", nil);
        NSString *titleOk = NSLocalizedStringFromTable(@"ok", @"hint", nil);
        NSString *titleRescan = NSLocalizedStringFromTable(@"rescanningDevice", @"hint", nil);
        NSString *buttonTitle;
        UIViewController *VC = [self appRootViewController];
        if ([VC isKindOfClass:[ScanDeviceViewController class]] || [VC isKindOfClass:[WelcomeViewController class]] || [VC isKindOfClass:[ViewController class]]) {
            
            buttonTitle = titleOk;
        } else {
            buttonTitle = titleRescan;
        }
        
        /** 在屏幕上弹出提示告知用户WIFI没连接上 */
        if ([SystemToolClass systemVersionIsNotLessThan:@"8.0"]) {
            /* IOS8.0及以后的系统 */
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

            [alertController addAction:[UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                _alertIsPresent = NO;
                
                if ([action.title isEqualToString:titleRescan]) {
                    [self gotoScanningVC];
                }
            }]];
            
            NSLog(@"%s alertController:%@ _alertIsPresent:%d", __func__, alertController, _alertIsPresent);
            
            if (nil != alertController && !_alertIsPresent) {
                _alertIsPresent = YES;
                [VC presentViewController:alertController animated:YES completion:nil];
            }
        } else {
            /* IOS8.0以前的系统 */
            UICustomAlertView *alertView = [[UICustomAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:buttonTitle, nil];
            
            NSLog(@"%s alertView:%@ _alertIsPresent:%d", __func__, alertView, _alertIsPresent);
            
            if (!_alertIsPresent) {
                _alertIsPresent = YES;
                [alertView showAlertViewWithCompleteBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                    _alertIsPresent = NO;
                    
                    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
                    if ([buttonTitle isEqualToString:titleRescan]) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            
                            [self gotoScanningVC];
                        });
                    }
                }];
            }
        }
    });
}

/** 手机已连接到WIFI网络 */
- (void)connectedToSSID:(NSString *)ssid {

    NSLog(@"%s", __func__);

    dispatch_async(dispatch_get_main_queue(), ^{

        /* 会在屏幕上给出提示当前手机连接的是哪个SSID */
        if (nil != ssid) {
            [QXToast showMessage:[NSString stringWithFormat:NSLocalizedStringFromTable(@"connectedToWireless:%@", @"hint", nil), ssid]];
        } else {
            [QXToast showMessage:NSLocalizedStringFromTable(@"failedToGetSSID", @"hint", nil)];
        }
    });
    
    if (nil != ssid) {
        [[NSNotificationCenter defaultCenter] postNotificationName:YYTXDeviceManagerWIFIConnected object:self userInfo:@{YYTXNewWIFISSID:ssid}]; // 通知（FSK配置中输入SSID和密码界面）手机已连上WIFI网络
    }

    if (nil != udpServce) {
//        [udpServce broadcastInLowFreq];
    }
}

#pragma 宇音天下后台服务器方法

- (void)updateDataFromServer {
    
    [_serverService login];
    
    [_serverService updateUrls];
    
    [_serverService requestProductInfo];
}

@end
