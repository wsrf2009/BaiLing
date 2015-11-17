//
//  WifiConfigClass.h
//  CloudBox
//
//  Created by TTS on 15-3-27.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WifiConfigClass : NSObject

/** 将SSID和密码生成FSK声波数据 */
+ (NSData *)generateFSKDataWithSSID:(NSString *)ssid password:(NSString *)password;

@end
