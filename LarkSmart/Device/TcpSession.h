//
//  Session.h
//  CloudBox
//
//  Created by TTS on 15-5-11.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum  {
    /** 接收数据有误 */
    YYTXSessionReceiveFailed,
    /** 接收到其他数据，如 EventInd */
    YYTXSessionReceivedOthers,
    /** 该会话收到相应的应答 */
    YYTXSessionFinish
} YYTXSessionStatus;

typedef enum {
    /** 设备已不在当前局域网 */
    YYTXDeviceIsAbsent = 1000,
    /** 传输数据失败 */
    YYTXTransferFailed,
    /** 操作设备不成功 */
    YYTXOperationFailed,
    /** 设备操作成功 */
    YYTXOperationSuccessful,
    /** 传入参数错误 */
    YYTXParameterError,
    /** 操作太频繁 */
    YYTXOperationIsTooFrequent
} YYTXDeviceReturnCode;

@interface TcpSession : NSObject
@property (nonatomic, assign) UInt16 ID;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, copy) void (^returnBlock)(YYTXDeviceReturnCode code);

- (instancetype)initWithId:(UInt16)Id data:(NSData *)data returnBlock:(void (^)(YYTXDeviceReturnCode code))block;

@end
