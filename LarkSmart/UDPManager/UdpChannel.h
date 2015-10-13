//
//  UdpData.h
//  CloudBox
//
//  Created by TTS on 15-5-6.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYTXDataFrame.h"
#import "UdpDataClass.h"

@interface UdpChannel : NSObject

@property (nonatomic, retain) NSString *host;
@property (nonatomic, assign) UInt16 port;

//@property (nonatomic, assign) enum recvState state;
@property (nonatomic, retain) YYTXDataFrame *data;

@property (nonatomic, retain) UdpDataClass *udpData;

- (instancetype)initWithHost:(NSString *)host andPort:(UInt16)port;


@end
