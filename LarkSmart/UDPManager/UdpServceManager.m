//
//  UdpDataManager.m
//  CloudBox
//
//  Created by TTS on 15-5-5.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "UdpServceManager.h"
#import "UdpChannel.h"
#import "SystemToolClass.h"
#import "YYTXDataFrame.h"
#import "UdpSessionManager.h"
#import "UdpServer.h"
#import "BoxDatabase.h"

#define SEARCHDEVICE_HIGH_FREQUENCY         1.0f
#define SEARCHDEVICE_LOW_FREQUENCY          5.0f

#define TEST        0

@interface UdpServceManager () <UdpServerDelegate>
{
    NSMutableArray *deviceChannels;
    NSTimer *timer;
    YYTXDataFrame *broadcastData;
    BOOL run;
    NSThread *threadBroadcast;
    
    UdpServer *udpServer;
}

@property (nonatomic, retain) UdpSessionManager *sessionManager;

#if TEST
@property (nonatomic, retain) NSMutableArray *deviceMacArray; // 设备mac数组，测试用
@property (nonatomic, assign) BOOL record;
@property (nonatomic, assign) NSInteger count;
#endif
@end

@implementation UdpServceManager

- (instancetype)initWithDelegate:(id)delegate {

    NSLog(@"%s", __func__);
    
    self = [super init];
    if (nil != self) {
        _delegate = delegate;
        _sessionManager = [[UdpSessionManager alloc] init];
        
        deviceChannels = [[NSMutableArray alloc] init];
        broadcastData = [[YYTXDataFrame alloc] init];
        threadBroadcast = [[NSThread alloc] initWithTarget:self selector:@selector(sendUdpBroadcast) object:nil];
        run = YES;
        [threadBroadcast start];
        
        udpServer = [[UdpServer alloc] initWithDelegate:self];
        [udpServer start];
#if TEST
        _deviceMacArray = [NSMutableArray array];
        _record = NO;
        _count = 0;
#endif
    }

    return self;
}

- (void)destroyBroadcast {
    
    NSLog(@"%s", __func__);
    
    [threadBroadcast cancel];
    run = NO;
    [timer invalidate];
}

- (void)pauseBroadcast {
    
//    NSLog(@"%s", __func__);
    
    if (nil != timer) {
        [timer invalidate];
    }
}

- (void)broadcastInHighFreq {
    
//    NSLog(@"%s", __func__);
    
    [self startTimer:SEARCHDEVICE_HIGH_FREQUENCY];
#if TEST
    _record = NO;
#endif
}

- (void)broadcastInLowFreq {
    
//    NSLog(@"%s", __func__);
    
    [self startTimer:SEARCHDEVICE_LOW_FREQUENCY];
#if TEST
    _record = YES;
#endif
}

- (void)transferSearchDeviceBroadcast {
    
    NSLog(@"%s", __func__);
#if TEST
    if (_record) {
        if (++_count >= 10) {
            _count = 0;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
            [BoxDatabase insertUdpScanResultWithScanTime:[dateFormatter stringFromDate:[NSDate date]] scanResult:_deviceMacArray];
            [_deviceMacArray removeAllObjects];
        }
        
    } else {
        [_deviceMacArray removeAllObjects];
    }
#endif
    NSDictionary *udpItem = [UdpDataClass searchDevice];
    [_sessionManager createUdpJsonRequestObject:udpItem method:ITEMVALUE_METHOD_UDP_SEARCH action:nil target:self]; // 将要广播的UDP包添加到会话队列中
}

- (void)sendUdpBroadcast {
    
    while (![[NSThread currentThread] isCancelled]) {
        
        if (run) {
            NSData *data = [_sessionManager getUdpData]; // 会话队列中获取要发送的会话
            
            NSLog(@"%s %s", __func__, data.bytes);
            
            NSData *pack = [broadcastData addType:YYTXFrameDataTypeJson andlengthFordata:data]; // 给JSON数据加上数据类型和数据长度的包头
            
            [udpServer sendData:pack toHost:@"255.255.255.255" Port:8089 Tag:1]; // 将数据包广播出去
        }
    }
}

- (void)startTimer:(NSTimeInterval)interval {
    if (nil != timer) {
        [timer invalidate];
    }
    
    /* 广播UDP包的定时器 */
    timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(transferSearchDeviceBroadcast) userInfo:nil repeats:YES];
    [timer fire];
}

#pragma 接收数据并处理

- (void)host:(NSString *)host onPort:(UInt16)port receiveData:(NSData *)data {
    NSUInteger i;
    UdpChannel *channel;

    /* 在列表中查找该设备是否已经存在 */
    for (i=0; i<deviceChannels.count; i++) {
        channel = deviceChannels[i];
        if ([channel.host isEqualToString:host] && channel.port == port) {
            break;
        }
    }

    /* 若列表中没有该设备则将其添加进去 */
    if (i>=deviceChannels.count) {
        channel = [[UdpChannel alloc] initWithHost:host andPort:port];
        if (nil != channel) {
            [deviceChannels addObject:channel];
        } else {
            return;
        }
    }

    // 接收数据
//    dataFrame.state = channel.state;
//    dataFrame.data = channel.data;
    [channel.data receiveData:(Byte *)data.bytes length:(UInt32)data.length];
//    channel.state = dataFrame.state;
    
    if (DataStateReceivedFinish == channel.data.state) {
        /* 该通道的数据接收完成 */
        channel.data.state = DataStateReceivingHead; // 开启下一个接收循环
        
        BOOL ret = [channel.udpData parseUdp:channel.data.body]; // 解析收到的UDP包
        if (ret) {
            if ([_delegate respondsToSelector:@selector(foundHost:port:)]) {
                /* 告知DevicesManager，发现新的设备 */
                [_delegate foundHost:channel.udpData.ip port:channel.udpData.port];
            }
        }
#if TEST
        if (nil != channel.udpData.deviceid) {
            [_deviceMacArray addObject:channel.udpData.deviceid];
        }
#endif
        [channel.data.body setLength:0]; // 开启下一个接收循环
    }
}

#pragma UdpServer 代理

- (void)receivedData:(NSData *)data fromHost:(NSString *)host port:(UInt16)port {

    if ([host isEqualToString:[SystemToolClass IPAddress]]) {
        return;
    }
    
    [self host:host onPort:port receiveData:data];
}

@end
