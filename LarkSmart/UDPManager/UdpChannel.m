//
//  UdpData.m
//  CloudBox
//
//  Created by TTS on 15-5-6.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "UdpChannel.h"

@implementation UdpChannel

- (instancetype)initWithHost:(NSString *)host andPort:(UInt16)port {
    self = [super init];
    if (nil != self) {
        _port = port;
        _host = host;
        _data = [[YYTXDataFrame alloc] init];
//        _state = RECV_HEAD;
        _udpData = [[UdpDataClass alloc] init];
    }
    
    return self;
}

@end
