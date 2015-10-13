//
//  DeviceInfoClass.m
//  CloudBox
//
//  Created by TTS on 15-4-23.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "DeviceInfoClass.h"

#define JSONITEM_DEVICEINFO_IP                  @"ip" // 设备ip
#define JSONITEM_DEVICEINFO_MAC                 @"mac" // 设备mac
#define JSONITEM_DEVICEINFO_POWER               @"device_power" // 设备电量，百分制
#define JSONITEM_DEVICEINFO_HARDWARE_VERSION    @"hw_ver" // 设备硬件版本号
#define JSONITEM_DEVICEINFO_SOFTWARE_VERSION    @"sw_ver" // 设备软件版本号
#define JSONITEM_DEVICEINFO_PRODUCT_ID          @"productid" // 设备所属产品类型
#define JSONITEM_DEVICEINFO_GOODSID             @"goodsid" // 设备的产品及批次
#define JSONITEM_DEVICEINFO_RSSI                @"RSSI"
#define JSONITEM_DEVICEINFO_HOST                @"host"
#define JSONITEM_DEVICEINFO_CONFIG              @"config"

@implementation DeviceInfoClass

- (instancetype)init {
    self = [super init];
    if (nil != self) {
        _isValid = NO;
    }
    
    return self;
}

- (BOOL)parseDeviceInfo:(NSDictionary *)deviceInfoItem {
    
    NSLog(@"%s", __func__);
    
    if (nil == deviceInfoItem) {
        return NO;
    }
    
    NSString *ipItem = [deviceInfoItem objectForKey:JSONITEM_DEVICEINFO_IP];
    if(nil != ipItem) {
        _ip = ipItem;
    }
    
    NSString *macItem = [deviceInfoItem objectForKey:JSONITEM_DEVICEINFO_MAC];
    if(nil != macItem) {
        _mac = macItem;
    }
    
    NSNumber *powerItem = [deviceInfoItem objectForKey:JSONITEM_DEVICEINFO_POWER];
    if(nil != powerItem) {
        _power = [powerItem integerValue];
    }
    
    NSString *HWVerItem = [deviceInfoItem objectForKey:JSONITEM_DEVICEINFO_HARDWARE_VERSION];
    if(nil != HWVerItem) {
        _HWVersion = HWVerItem;
    }
    
    NSString *SWVerItem = [deviceInfoItem objectForKey:JSONITEM_DEVICEINFO_SOFTWARE_VERSION];
    if(nil != SWVerItem) {
        _SWVersion = SWVerItem;
    }
    
    NSString *PIDItem = [deviceInfoItem objectForKey:JSONITEM_DEVICEINFO_PRODUCT_ID];
    if(nil != PIDItem) {
        _productId = PIDItem;
    }
    
    NSString *goodIdItem = [deviceInfoItem objectForKey:JSONITEM_DEVICEINFO_GOODSID];
    if(nil != goodIdItem) {
        _goodsId = goodIdItem;
    }
    
    NSNumber *rssiItem = [deviceInfoItem objectForKey:JSONITEM_DEVICEINFO_RSSI];
    if (nil != rssiItem) {
        _rssi = [rssiItem unsignedCharValue];
    }
    
    NSString *hostItem = [deviceInfoItem objectForKey:JSONITEM_DEVICEINFO_HOST];
    if (nil != hostItem) {
        _host = hostItem;
    }
    
    NSString *configItem = [deviceInfoItem objectForKey:JSONITEM_DEVICEINFO_CONFIG];
    if (nil != configItem) {
        _config = configItem;
    }
    
//    _isValid = YES;
    
    return YES;
}


@end
