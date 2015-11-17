//
//  UdpDataManager.h
//  CloudBox
//
//  Created by TTS on 15-5-5.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UdpServceDelegate <NSObject>

- (void)foundHost:(NSString *)host port:(UInt16)port;

@end

@interface UdpServceManager : NSObject
@property (nonatomic, retain) id <UdpServceDelegate> delegate;

- (instancetype)initWithDelegate:(id)delegate;

/** 以较高的频率广播UDP包、大约1秒1次 */
- (void)broadcastInHighFreq;

/** 暂停广播UDP包 */
- (void)pauseBroadcast;

- (void)destroyBroadcast;

/** 以较高的频率广播UDP包 */
- (void)broadcastInLowFreq;

@end
