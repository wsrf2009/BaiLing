//
//  WifiConfigClass.m
//  CloudBox
//
//  Created by TTS on 15-3-27.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "WifiConfigClass.h"
#import "FSKWavGenAPI.h"

@implementation WifiConfigClass
#if 0
+ (NSData *)copyBytes:(Byte *)data
          dataLength:(NSUInteger)len
          copyNumber:(NSUInteger)times {
    if (0 >= len || 0 >= times) {
        return nil;
    }
    
    Byte *result = alloca(len*times);
    if (NULL == result) {
        return nil;
    }
    for (NSUInteger i=0; i<times; i++) {
        memcpy(result+i*len, data, len);
    }
    
    return [[NSData alloc] initWithBytes:result length:len*times];
}

+ (NSData *)stringToGbkData:(NSString *)origin {
    NSStringEncoding gbkEncode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *gbkString = [[NSString alloc] initWithData:[origin dataUsingEncoding:NSUTF8StringEncoding] encoding:gbkEncode];
    NSLog(@"gbkString:%@", gbkString);
    return [gbkString dataUsingEncoding:gbkEncode];
}
#endif
+ (NSData *)generateFSKDataWithSSID:(NSString *)ssid password:(NSString *)password {
    NSString *content = [NSString stringWithFormat:@"%@%@", ssid, password];
//    NSData *gbkData = [self stringToGbkData:content];
    NSData *gbkData = [content dataUsingEncoding:NSUTF8StringEncoding]; // NSString转为NSData

    char *wavBytes;
    int wavBytesLength;
    
    wavBytes = WavGen((char *)gbkData.bytes, gbkData.length, ssid.length, FSK_ASR, &wavBytesLength);
    
    NSData *fsk = [NSData dataWithBytes:wavBytes length:wavBytesLength];
    
    return fsk;
}

@end
