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
- (void)start;
- (void)stop;
- (void)sendData:(NSData *)data toHost:(NSString *)host Port:(int)port Tag:(int)tag;

@end
