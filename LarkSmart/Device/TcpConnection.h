//
//  TcpConnection.h
//  CloudBox
//
//  Created by TTS on 15-5-7.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TcpConnectionDisconnected,
    TcpConnectionConnecting,
    TcpConnectionConnected,
    TcpConnectionDisconnecting
} TcpConnectionState;

@protocol TcpConnectionDelegate <NSObject>

- (void)connected;
- (void)receivedData:(NSData *)data;
- (void)disconnected;
- (void)transferFailed; // 读写超时，接收数据长度有误
- (void)removed; // 重连3次仍连不上

@end

@interface TcpConnection : NSObject
@property (nonatomic, retain) id <TcpConnectionDelegate> delegate;
@property (nonatomic, assign) TcpConnectionState state;

- (instancetype)initWithHost:(NSString *)host port:(NSInteger)port delegate:(id)delegate;
- (void)writeData:(NSData *)data;
- (void)readDataHead;
- (void)disable;
- (void)disconnect;
- (BOOL)isValid;

@end
