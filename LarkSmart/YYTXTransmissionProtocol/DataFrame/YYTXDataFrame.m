//
//  DataTransfer.m
//  CloudBox
//
//  Created by TTS on 15-5-5.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "YYTXDataFrame.h"

#define BigEndian_BytesToInt32(arr)  \
        ((arr[0]<<24)|(arr[1]<<16)|(arr[2]<<8)|arr[3])

@implementation YYTXDataFrame

- (instancetype)init {
    self = [super init];
    if (nil != self) {
        _head = [[NSMutableData alloc] initWithCapacity:YYTXFrameHeadSize];
        _state = DataStateReceivingHead;
    }
    
    return self;
}

- (NSData *)addType:(YYTXFrameDataType)type andlengthFordata:(NSData *)data {
    NSUInteger len = data.length;
    Byte *package = alloca(8+len);
    
    package[7] = len & 0xFF;
    package[6] = (len>>8) & 0xFF;
    package[5] = (len>>16) & 0xFF;
    package[4] = (len>>24) & 0xFF;
    
    package[3] = type & 0xFF;
    package[2] = (type>>8) & 0xFF;
    package[1] = (type>>16) & 0xFF;
    package[0] = (type>>24) & 0xFF;
    
    memcpy(package+8, data.bytes, len);
    
    NSData *blockData = [[NSData alloc] initWithBytes:package length:len+8];
    
    return blockData;
}

- (void) dataDecapsulate:(Byte *)data dataType:(UInt32 *)type dataLength:(UInt32 *)len {
    *type = BigEndian_BytesToInt32(data);
    data += 4;
    *len = BigEndian_BytesToInt32(data);
    
//    NSLog(@"%s [0] = %02X", __func__, data[0]);
//    NSLog(@"%s [1] = %02X", __func__, data[1]);
//    NSLog(@"%s [2] = %02X", __func__, data[2]);
//    NSLog(@"%s [3] = %02X", __func__, data[3]);
//    NSLog(@"%s [4] = %02X", __func__, data[4]);
//    NSLog(@"%s [5] = %02X", __func__, data[5]);
//    NSLog(@"%s [6] = %02X", __func__, data[6]);
//    NSLog(@"%s [7] = %02X", __func__, data[7]);
    
//    NSLog(@"%s %d %d", __func__, (unsigned int)*type, (unsigned int)*len);
}

- (void)receiveData:(Byte *)array length:(UInt32)arrLength {
    NSUInteger needLen; // 需要读取的长度
    NSUInteger reveLen = arrLength; // 缓冲区还能提供的长度
    NSUInteger factLen; // 实际能读取的长度
    
//    NSLog(@"%s length:%lu", __func__, (unsigned long)arrLength);
    
    switch (_state) {
        case DataStateReceivingHead:
            needLen = YYTXFrameHeadSize-_head.length;
            factLen = (reveLen > needLen) ? needLen : reveLen;
            if (factLen > 0) {
                [_head appendBytes:array length:factLen];
                reveLen -= factLen;
            }
            
            if(_head.length >= YYTXFrameHeadSize) {
                UInt32 type;
                UInt32 length;
                _state = DataStateReceivingBody; // 准备接收数据包的内容
                
                [self dataDecapsulate:(Byte *)_head.bytes dataType:&type dataLength:&length];

                _type = type;
                _length = length;
                
                [_head setLength:0];
                
                if (_length > 0) {
                    _body = [[NSMutableData alloc] init];
                    if ((arrLength-YYTXFrameHeadSize) > 0) {
                        needLen = _length;
                        factLen = (reveLen > needLen) ? needLen : reveLen;
                        if (factLen > 0) {
                            [_body appendBytes:array+YYTXFrameHeadSize length:factLen];
                            reveLen -= factLen;
                        }
                    }
                } else {
                    /* 数据包的内容为空 */
                    _state = DataStateReceivingHead;
                    return;
                }
            } else {
                /* 数据包的头还未接收完成 */
                return;
            }
            
        case DataStateReceivingBody:
            needLen = _length-_body.length;
            factLen = (reveLen > needLen) ? needLen : reveLen;
            if (factLen > 0) {
                [_body appendBytes:array length:factLen];
                reveLen -= factLen;
            }
            
            if (_length <= _body.length) {
                _state = DataStateReceivedFinish; // 数据包体接收完成
            }
            break;
            
        default:
            break;
    }
    
    return;
}

@end
