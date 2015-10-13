//
//  Session.m
//  CloudBox
//
//  Created by TTS on 15-5-11.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "UdpSession.h"

@implementation UdpSession

- (instancetype)initWithID:(UInt16)ID target:(id)target action:(SEL)action data:(NSData *)data userInfo:(id)device {
    self = [super init];
    if (nil != self) {
        _ID = ID;
        _target = target;
        _action = action;
        _data = data;
        _device = device;
    }
    
    return self;
}

@end
