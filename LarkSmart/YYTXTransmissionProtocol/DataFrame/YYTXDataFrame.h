//
//  DataTransfer.h
//  CloudBox
//
//  Created by TTS on 15-5-5.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 传输的数据类型 */
typedef enum {
    YYTXFrameDataTypeJson = 0x00,
    YYTXFrameDataTypeStream = 0x01,
    YYTXFrameDataTypeXML = 0x02
} YYTXFrameDataType;

typedef struct {
    UInt32 type;
    UInt32 length;
} YYTXFrameHead;

#define YYTXFrameHeadSize     (sizeof(YYTXFrameHead))

typedef enum {
    DataStateReceivedFinish,
    DataStateReceivingHead,
    DataStateReceivingBody
} DataReceivingState;

@interface YYTXDataFrame : NSObject
@property (nonatomic, assign) UInt32 type;
@property (nonatomic, assign) UInt32 length;
@property (nonatomic, retain) NSMutableData *head;
@property (nonatomic, retain) NSMutableData *body;

@property (nonatomic, assign) DataReceivingState state;

/** 对数据再次封装，添加数据类型和数据长度 */
- (NSData *)addType:(YYTXFrameDataType)type andlengthFordata:(NSData *)data;

/** 接收数据 */
- (void)receiveData:(Byte *)data length:(UInt32)length;

/** 解析数据的类型后后面数据区域的长度 */
- (void)dataDecapsulate:(Byte *)data dataType:(UInt32 *)type dataLength:(UInt32 *)len;

@end
