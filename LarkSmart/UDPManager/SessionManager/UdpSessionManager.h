//
//  sessionManager.h
//  CloudBox
//
//  Created by TTS on 15-5-7.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UdpSession.h"

@interface UdpSessionManager : NSObject

- (void)createUdpJsonRequestObject:(id)paramsItem method:(NSString *)method action:(SEL)action target:(id)target;
- (NSData *)getUdpData;

@end
