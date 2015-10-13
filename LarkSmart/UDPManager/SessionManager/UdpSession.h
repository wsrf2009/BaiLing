//
//  Session.h
//  CloudBox
//
//  Created by TTS on 15-5-11.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdpSession : NSObject
@property (nonatomic, assign) UInt16 ID;
@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) id device;

- (instancetype)initWithID:(UInt16)ID target:(id)target action:(SEL)action data:(NSData *)data userInfo:(id)device;

@end
