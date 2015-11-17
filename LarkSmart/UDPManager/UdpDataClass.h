//
//  UDPClass.h
//  CloudBox
//
//  Created by TTS on 15-5-5.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ITEMVALUE_METHOD_UDP_SEARCH     @"search"

@interface UdpDataClass : NSObject
@property (nonatomic, retain) NSString *ip;
@property (nonatomic, assign) NSUInteger port;
@property (nonatomic, retain) NSString *deviceid;
@property (nonatomic, retain) NSString *version;
@property (nonatomic, retain) NSString *productid;

/** 创建UDP广播包 */
+ (NSDictionary *)searchDevice;

/** 解析设备端返回的UDP包 */
- (BOOL)parseUdp:(NSData *)data;

@end
