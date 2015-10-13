//
//  Session.m
//  CloudBox
//
//  Created by TTS on 15-5-11.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "TcpSession.h"

@implementation TcpSession

- (instancetype)initWithId:(UInt16)Id data:(NSData *)data returnBlock:(void (^)(YYTXDeviceReturnCode code))block {
    self = [super init];
    if (nil != self) {
        _ID = Id;
        _data = data;
        _returnBlock = block;
    }
    
    return self;
}

@end
