//
//  UDPClass.m
//  CloudBox
//
//  Created by TTS on 15-5-5.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "UdpDataClass.h"
#import "SystemToolClass.h"
#import "BoxDatabase.h"

#define JSONITEM_UDP_ID             @"id"
#define JSONITEM_UDP_RESULT         @"result"

// UDP
#define JSONITEM_UDP_PORT           @"port"
#define JSONITEM_UDP_DEVICE         @"device"
#define JSONITEM_UDP_CALLER         @"caller"
#define JSONITEM_UDP_IP             @"ip"
#define JSONITEM_UDP_DEVICEID       @"deviceid"
#define JSONITEM_UDP_APPVERSION     @"app_version"
#define JSONITEM_UDP_OSVERSION      @"os_version"
#define JSONITEM_UDP_VERSION        @"version"
#define JSONITEM_UDP_PRODUCTID      @"productid"


#define ITEMVALUE_DEVICE_UDP_LARK       @"lark"

@implementation UdpDataClass

+ (NSDictionary *)searchDevice {
    NSDictionary *callerItem = [NSDictionary dictionaryWithObjectsAndKeys:[SystemToolClass IPAddress], JSONITEM_UDP_IP, [SystemToolClass uuid], JSONITEM_UDP_DEVICEID, [SystemToolClass  appVersion], JSONITEM_UDP_APPVERSION, [SystemToolClass IOSVersion], JSONITEM_UDP_OSVERSION, nil];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:ITEMVALUE_DEVICE_UDP_LARK, JSONITEM_UDP_DEVICE, callerItem, JSONITEM_UDP_CALLER, nil];
}

- (BOOL)parseUdp:(NSData *)data {
    
    if (NULL == data) {
        return NO;
    }
    
    NSError *err;
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (nil == root) {
        NSLog(@"%s length:%ld data:%@", __func__, (unsigned long)data.length, data);
        NSLog(@"%s %@", __func__, err);
        return NO;
    }
    
    NSNumber *idItem = [root objectForKey:JSONITEM_UDP_ID];
    if (nil == idItem) {
        return NO;
    }
    
    NSDictionary *resultItem = [root objectForKey:JSONITEM_UDP_RESULT];
    if (nil == resultItem) {
        return NO;
    }
    
    NSDictionary *deviceItem = [resultItem objectForKey:ITEMVALUE_DEVICE_UDP_LARK];
    if (nil == deviceItem) {
        return NO;
    }
    
    NSString *ipItem = [deviceItem objectForKey:JSONITEM_UDP_IP];
    if (nil != ipItem) {
        _ip = ipItem;
    }
    
    NSNumber *portItem = [deviceItem objectForKey:JSONITEM_UDP_PORT];
    if (NULL != portItem) {
        _port = [portItem unsignedIntegerValue];
    }
    
    NSString *deviceIdItem = [deviceItem objectForKey:JSONITEM_UDP_DEVICEID];
    if (NULL != deviceIdItem) {
        _deviceid = deviceIdItem;
    }
    
    NSString *versionItem = [deviceItem objectForKey:JSONITEM_UDP_VERSION];
    if (NULL != versionItem) {
        _version = versionItem;
    }
    
    NSString *productIdItem = [deviceItem objectForKey:JSONITEM_UDP_PRODUCTID];
    if (NULL != productIdItem) {
        _productid = productIdItem;
    }
    
    return YES;
}

@end
