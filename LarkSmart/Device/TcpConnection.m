//
//  TcpConnection.m
//  CloudBox
//
//  Created by TTS on 15-5-7.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "TcpConnection.h"
#import "YYTXDataFrame.h"
#import "GCDAsyncSocket.h"

#define WRITEDATA_TIMEOUT           2 // 发送数据超时时间：s
#define READDATA_TIMEOUT            4 // 读取设备数据超时时间：s
#define CONNECT_TIMEOUT             2 // 连接超时时间：s
#define RECONNECT_COUNT             3 // 重连次数

@interface TcpConnection ()
{
    YYTXDataFrame *dataFrame;
    GCDAsyncSocket *socket;
}

@property (nonatomic, retain) NSString *host;
@property (nonatomic, assign) UInt16 port;

@property (atomic, assign) NSInteger reconnCount;

@property (nonatomic, assign) BOOL isEnable;

@end

@implementation TcpConnection

- (instancetype)initWithHost:(NSString *)host port:(NSInteger)port delegate:(id)delegate {
    
    NSLog(@"%s", __func__);
    
    self = [super init];
    if (nil != self) {
        _delegate = delegate;
        _host = host;
        _port = port;
        socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_queue_create("tcp work queue", DISPATCH_QUEUE_SERIAL)];
        dataFrame = [[YYTXDataFrame alloc] init];

        _isEnable = YES;
        _reconnCount = 0;
        _state = TcpConnectionDisconnected;
        [self connect];
    }
    
    return  self;
}

- (void)writeData:(NSData *)data {

    NSData *pack = [dataFrame addType:YYTXFrameDataTypeJson andlengthFordata:data];
        
    NSLog(@"%s %@ %@ isConnected:%d", __func__, [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding], _host, [socket isConnected]);

    if ([socket isConnected]) {
        /* 若socket已连接，则直接发送数据 */
        [socket writeData:pack withTimeout:WRITEDATA_TIMEOUT tag:0];
    } else {
        /* 否则，告知上层传输失败，然后重连socket */
        [_delegate transferFailed];
        [self reconnect];
    }
}

/** 从缓冲区读取数据的包头 */
- (void)readDataHead {
    [socket readDataToLength:YYTXFrameHeadSize withTimeout:READDATA_TIMEOUT tag:DataStateReceivingHead];
}

/** 断开socket的连接 */
- (void)disconnect {
    [socket disconnect];
}

/** 重连socket */
- (void)reconnect {
    if (!_isEnable) {
        return;
    }
    
    NSLog(@"%s isConnected:%d isDisconnected:%d %@ state:%d reconnCount:%@", __func__, [socket isConnected], [socket isDisconnected], _host, _state, @(_reconnCount));
    
    if (_reconnCount >= RECONNECT_COUNT) {
        /* 连接次数超过3次则认为该设备已不在当前网络中 */
        _isEnable = NO;
        [_delegate removed];
        
        return;
    }

    [self connect];
}

- (void)connect {
    NSError *error;

    NSLog(@"%s %@ state:%d", __func__, _host, _state);
    
    if (TcpConnectionDisconnected != _state) {
        return;
    }
    
    if(![socket connectToHost:_host onPort:_port withTimeout:CONNECT_TIMEOUT error:&error]) {  // tcp连接设备
        
        NSLog(@"%s %@", __func__, error);
    } else {
        _reconnCount++;
        _state = TcpConnectionConnecting;
    }
}

/** disable该tcp socket */
- (void)disable {
    
    NSLog(@"%s %@", __func__, _host);
    
    _isEnable = NO;
    
    [socket disconnect]; // 将TCP连接断开
    
    _state = TcpConnectionDisconnecting;
}

/** 当前的tcp socket是否可用 */
- (BOOL)isValid {
    return _isEnable;
}

#pragma TCPSocket的代理

/* 已经建立了与设备的连接 */
- (void)socket:(GCDAsyncSocket *)socket didConnectToHost:(NSString *)host port:(UInt16)port {
    
    NSLog(@"%s %@", __func__, _host);

    _reconnCount = 0;
    _state = TcpConnectionConnected;
    
    if ([_delegate respondsToSelector:@selector(connected)]) {
        [_delegate connected];
    }
}

/** 与设备的连接已断开 */
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {

    NSLog(@"%s %@ %@", __func__, err, _host);
    
    _state = TcpConnectionDisconnected;

    [self reconnect];
}

/* 当发送完数据后调用此函数 */
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    
    NSLog(@"%s %@", __func__, _host);
    
    [self readDataHead];
}

/** 
 收到报文,按顺序循环接收报文头，报文体。 此方法的第一次调用是已经连接上的方法调用的时候, 会读取data，然后调用代理的此方法。此时tag就是上面的TAG_FIXED_LENGTH_HEADER，所以第一次执行读取header
 */
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    YYTXFrameHead head;
    
    NSLog(@"%s %@ %ld", __func__, _host, tag);
    
    switch (tag) {
        case DataStateReceivingHead:
            [dataFrame dataDecapsulate:(Byte *)data.bytes dataType:&head.type dataLength:&head.length];

            NSLog(@"%s type:%@ length:%@", __func__, @(head.type), @(head.length));
            
            // 读取数据包体 (1 To 10M bytes)
            if (head.length > 0 && head.length < 0xA00000) {
                [socket readDataToLength:head.length withTimeout:READDATA_TIMEOUT tag:DataStateReceivingBody];
            } else {
                [_delegate transferFailed];
            }
            
            break;
            
        case DataStateReceivingBody:

            [_delegate receivedData:data];

            break;
            
        default:
            break;
    }
}

/** 发送数据超时 */
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length {

    NSLog(@"%s tag:%ld %@", __func__, tag, _host);

    if (_isEnable) {
        [_delegate transferFailed];
    }
    
//    [self disconnect];
    
    return -1;
}

/** 接收数据超时 */
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length {

    NSLog(@"%s tag:%ld %@", __func__, tag, _host);

    if (_isEnable) {
        [_delegate transferFailed];
    }

//    [self disconnect];
    
    return -1;
}

/** 读取的进度 */
- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
}

@end
