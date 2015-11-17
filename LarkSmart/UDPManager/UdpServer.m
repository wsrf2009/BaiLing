//
//  UdpServer.m
//  CloudBox
//
//  Created by TTS on 15-5-21.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "UdpServer.h"
#import "GCDAsyncUdpSocket.h"

@interface UdpServer () <GCDAsyncUdpSocketDelegate>
{
    GCDAsyncUdpSocket *udpServer;
    GCDAsyncUdpSocket *udpClient;
}

@end

@implementation UdpServer

- (instancetype)initWithDelegate:(id)delegate {
    
    self = [super init];
    if (nil != self) {
        _delegate = delegate;
    }
    
    return self;
}

/* 启动udp 服务器，监听60000端口 */
- (void)start {
    NSError *error = nil;
    
    if (nil == udpServer) {
        udpServer = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_queue_create("udp server work queue", DISPATCH_QUEUE_SERIAL)];
        
        if (![udpServer bindToPort:60000 error:&error]) {
            NSLog(@"Error starting server (bind): %@", error);
            return;
        }
        
        if(![udpServer enableBroadcast:YES error:&error]){
            NSLog(@"Error enableBroadcast (bind): %@", error);
            return;
        }
        
        if (![udpServer joinMulticastGroup:@"224.0.0.1"  error:&error]) {
            NSLog(@"Error joinMulticastGroup (bind): %@", error);
            return;
        }
        
        if (![udpServer beginReceiving:&error]) {
            [udpServer close];
            NSLog(@"Error starting server (recv): %@", error);
            return;
        }
    }
}

- (void)stop {
    [udpServer close];
}

/** 创建udp客户端 */
- (void)getUdpClient {
    NSError *error = nil;
    
    if(nil == udpClient) {
        
        udpClient = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_queue_create("udp client work queue", DISPATCH_QUEUE_SERIAL)];
        
        if (![udpClient enableBroadcast:YES error:&error]) {
            
            NSLog(@"Error enableBroadcast (bind): %@", error);
            return;
        }
        if (![udpClient beginReceiving:&error]) {
            
            NSLog(@"Error starting (recv): %@", error);
            return;
        }
    }
}

/**
 * (1)接收组播消息，并分发到相应的处理类中；
 * (2)接收设备主动上报的mcu报文，如告警上报等，分发到相应的处理类
 */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *host;
    UInt16 port=0;
    
//    NSLog(@"%s", __func__);
    
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
    
    NSLog(@"%s host:%@ port:%d data:%@", __func__, host, port, [NSString stringWithUTF8String:data.bytes+8]);
    
    if ([_delegate respondsToSelector:@selector(receivedData:fromHost:port:)]) {
        [_delegate receivedData:data fromHost:host port:port];
    }
}

/** 用已创建的udp服务器发送数据，使用默认的超时 */
- (void)sendData:(NSData *)data toHost:(NSString *)host Port:(int)port Tag:(int)tag {
    
    if ([udpServer isClosed]) {
        udpServer = nil;
        [self start];
    }
    
    [udpServer sendData:data toHost:host port:port withTimeout:20 tag:tag];
}

/** 用已创建的udp服务器发送数据，使用自定义的超时 */
- (void)serverSendData:(NSData *)data toHost:(NSString *)host Port:(int)port Timeout:(int)time Tag:(int)tag {
    
    [udpServer sendData:data toHost:host port:port withTimeout:time tag:tag];
}

/** 用已创建的udp客户端发送数据，使用默认的超时 */
- (void)clientSendData:(NSData *)data toHost:(NSString *)host Port:(int)port Tag:(int)tag {
    
    [udpClient sendData:data toHost:host port:port withTimeout:20 tag:tag];
}

/** 用已创建的udp客户端发送数据，使用自定义的超时 */
- (void)clientSendData:(NSData *)data toHost:(NSString *)host Port:(int)port Timeout:(int)time Tag:(int)tag {
    
    [udpClient sendData:data toHost:host port:port withTimeout:time tag:tag];
}

@end
