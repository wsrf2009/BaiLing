//
//  Session.h
//  CloudBox
//
//  Created by TTS on 15-5-11.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum  {
    YYTXSessionReceiveFailed, // 接收数据有误
    YYTXSessionReceivedOthers, // 接收到其他数据，如 EventInd
    YYTXSessionFinish // 该会话收到相应的应答
} YYTXSessionStatus;

typedef enum {
    YYTXDeviceIsAbsent = 1000,
    YYTXTransferFailed,
    YYTXOperationFailed,
    YYTXOperationSuccessful,
    YYTXParameterError,
    YYTXOperationIsTooFrequent
} YYTXDeviceReturnCode;

@interface TcpSession : NSObject
@property (nonatomic, assign) UInt16 ID;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, copy) void (^returnBlock)(YYTXDeviceReturnCode code);

- (instancetype)initWithId:(UInt16)Id data:(NSData *)data returnBlock:(void (^)(YYTXDeviceReturnCode code))block;

@end
