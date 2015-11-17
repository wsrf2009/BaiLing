//
//  AppAuthentication.h
//  CloudBox
//
//  Created by TTS on 15/6/5.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppAuthentication : NSObject

/** 从NSData中获取出OpenId */
+ (NSString *)getOpenid:(NSData *)data;

@end
