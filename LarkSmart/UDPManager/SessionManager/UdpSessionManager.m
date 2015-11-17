//
//  sessionManager.m
//  CloudBox
//
//  Created by TTS on 15-5-7.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "UdpSessionManager.h"

#define JSONITEM_ID                 @"id"
#define JSONITEM_METHOD             @"method"
#define JSONITEM_PARAMS             @"params"
#define JSONITEM_RESULT             @"result"
#define JSONITEM_ERROR              @"error"

// 错误对象 JSONITEM_ERROR
#define JSONITEM_ERROR_CODE         @"code"
#define JSONITEM_ERROR_MESSAGE      @"message"

#define TIMEOUT_RECEIVERESPONSE     2.0

@interface UdpSessionManager ()
{
    unsigned short sessionID;
    NSMutableArray *udpSessionList;
    dispatch_semaphore_t semForCreateSession;
    UdpSession *curSession;
    dispatch_semaphore_t semForUdpData;
}

@end


@implementation UdpSessionManager


- (instancetype)init {

    NSLog(@"%s", __func__);
    
    self = [super init];
    if (nil != self) {
        sessionID = 0;
        udpSessionList = [[NSMutableArray alloc] init];
        semForCreateSession = dispatch_semaphore_create(1);
        semForUdpData = dispatch_semaphore_create(0);
    }
    
    return self;
}

- (void)createUdpJsonRequestObject:(id)paramsItem method:(NSString *)method action:(SEL)action target:(id)target {
    
    NSLog(@"%s", __func__);
    
    if (nil == paramsItem) {
        return;
    }
    
    dispatch_semaphore_wait(semForCreateSession, DISPATCH_TIME_FOREVER); // 获取信号量，是否可以创建会话
    
    NSDictionary *root = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:sessionID], JSONITEM_ID, method, JSONITEM_METHOD, paramsItem, JSONITEM_PARAMS, nil]; // 将ID、method、params整合到一个NSDictionary中
    NSError *err;
    if ([NSJSONSerialization isValidJSONObject:root]) { // root是否是有效的JSON格式
        NSData *data = [NSJSONSerialization dataWithJSONObject:root options:NSJSONWritingPrettyPrinted error:&err]; // NSDictionary专为NSData
        if (nil != data) {
            UdpSession *session = [[UdpSession alloc] initWithID:sessionID++ target:target action:action data:data userInfo:nil];
            
            [udpSessionList addObject:session];
            dispatch_semaphore_signal(semForUdpData); // 有数据需要发送
        }
    }
    
    dispatch_semaphore_signal(semForCreateSession);
}

- (NSData *)getUdpData {
    
    NSLog(@"%s", __func__);
    
    dispatch_semaphore_wait(semForUdpData, DISPATCH_TIME_FOREVER); // 是否有需要发送的数据
    
    UdpSession *session = udpSessionList[0];
    
    [udpSessionList removeObject:session];
    
    return session.data;
}

@end
