//
//  DeviceInfoClass.h
//  CloudBox
//
//  Created by TTS on 15-4-23.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceInfoClass : NSObject

@property (nonatomic, retain) NSString *ip;
@property (nonatomic, retain) NSString *mac;
@property (nonatomic, assign) NSInteger power;
@property (nonatomic, retain) NSString *HWVersion;
@property (nonatomic, retain) NSString *SWVersion;
@property (nonatomic, retain) NSString *productId;
@property (nonatomic, retain) NSString *goodsId;
@property (nonatomic, assign) UInt8 rssi;
@property (nonatomic, retain) NSString *host;
@property (nonatomic, retain) NSString *config;
@property (nonatomic, assign) BOOL isValid;

- (BOOL)parseDeviceInfo:(NSDictionary *)deviceInfoItem;

@end
