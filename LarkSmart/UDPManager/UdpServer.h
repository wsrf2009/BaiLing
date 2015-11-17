//
//  UdpServer.h
//  CloudBox
//
//  Created by TTS on 15-5-21.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UdpServerDelegate <NSObject>

- (void)receivedData:(NSData *)data fromHost:(NSString *)host port:(UInt16)port;

@end

@interface UdpServer : NSObject
@property (nonatomic, retain) id <UdpServerDelegate> delegate;

- (instancetype)initWithDelegate:(id)delegate;

/** 启动UDP服务 */
- (void)start;

/** 停止UDP服务 */
- (void)stop;

/** 用已创建的udp服务器发送数据，使用默认的超时 */
- (void)sendData:(NSData *)data toHost:(NSString *)host Port:(int)port Tag:(int)tag;

@end
