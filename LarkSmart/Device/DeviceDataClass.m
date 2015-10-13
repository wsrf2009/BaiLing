//
//  DeviceData.m
//  CloudBox
//
//  Created by TTS on 15-4-7.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "DeviceDataClass.h"
#import "TcpConnection.h"
#import "BoxDatabase.h"
//#import "M2DHudView.h"

#define HEARTBEAT_INTERVAL          6 // 心跳间隔：s
#define TRANSFER_INTERVAL           6 // 发送一个会话的超时时间：s

NSString *const DeviceEventPlayerStart = @"DeviceEventPlayerStart";
NSString *const DeviceEventPlayerStop = @"DeviceEventPlayerStop";
NSString *const DeviceEventPlayerPause = @"DeviceEventPlayerPause";
NSString *const DeviceEventPlayerResume = @"DeviceEventPlayerResume";

NSString *const DevicePlayTTSWhenOperationSuccessful = @"DevicePlayTTSWhenOperationSuccessful";
NSString *const DevicePlayTTSWhenOperationFailed = @"DevicePlayTTSWhenOperationFailed";
NSString *const DevicePlayFileWhenOperationSuccessful = @"DevicePlayFileWhenOperationSuccessful";
NSString *const DevicePlayFileWhenOperationFailed = @"DevicePlayFileWhenOperationFailed";

@interface DeviceDataClass () <TcpConnectionDelegate>
@property (nonatomic, retain) TcpConnection *tcpConn;
@property (nonatomic, retain) NSTimer *heartBeatTimer;
@property (atomic, retain) dispatch_semaphore_t semaphoreForWriteFinish;
@property (atomic, retain) dispatch_semaphore_t semaphoreForHasData;
@property (nonatomic, retain) NSThread *threadForWriteData;
@property (atomic, retain) NSMutableArray *tcpSessionList;
@property (atomic, assign) UInt16 sessionID;
@property (nonatomic, retain) TcpSession *curSession;
@property (nonatomic, retain) dispatch_queue_t queueForAddSession;
@property (nonatomic, retain) NSTimer *timerForTransfer;

@property (nonatomic, retain) YYTXJsonObject *jsonObject;

@end

@implementation DeviceDataClass

- (instancetype)initWithHost:(NSString *)host port:(UInt16)port delegate:(id)delegate {
    
    NSLog(@"%s %@ %d", __func__, host, port);
    
    self = [super init];
    if (nil != self) {
        _host = host;
        _port = port;
        _delegate = delegate;
        
        _userData = [[UserDataClass alloc] init];
        _eventList = [[NSMutableArray alloc] init];
        _audioPlay = [[AudioPlay alloc] init];
        _deviceIconUrl = nil;
        
        _tag = 0;
        _isAbsent = YES;
        _isSelect = NO;
        
        _tcpSessionList = [[NSMutableArray alloc] init];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:HEARTBEAT_INTERVAL target:self selector:@selector(heartBeat) userInfo:nil repeats:YES];
            [_heartBeatTimer setFireDate:[NSDate distantFuture]];
            
            _timerForTransfer = [NSTimer scheduledTimerWithTimeInterval:TRANSFER_INTERVAL target:self selector:@selector(transferTimeout) userInfo:nil repeats:YES];
            [_timerForTransfer setFireDate:[NSDate distantFuture]];
        });
        
        _queueForAddSession = dispatch_queue_create("add session to session list", DISPATCH_QUEUE_SERIAL);
        _semaphoreForWriteFinish = dispatch_semaphore_create(0);
        _semaphoreForHasData = dispatch_semaphore_create(0);
        _threadForWriteData = [[NSThread alloc] initWithTarget:self selector:@selector(writeData) object:nil];
        [_threadForWriteData start];
        
        _tcpConn = [[TcpConnection alloc] initWithHost:host port:port delegate:self];
        _jsonObject = [[YYTXJsonObject alloc] init];
    }
    

    return self;
}

#pragma TCP Connection 代理

- (void)connected {
    
    NSLog(@"%s %@ %@", __func__, _host, _userData.generalData.nickName);
    
    _isAbsent = NO;
    
    [self getGeneral:^(YYTXDeviceReturnCode code) {
            
        if (YYTXOperationSuccessful == code) {

            [_delegate devicePresent:self];
            
            [_heartBeatTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:HEARTBEAT_INTERVAL]]; // 启动检测TCP连接的心跳定时器
        } else {
            
//            [self destroy];
            
//            [_delegate deviceIsInvalid:self];
        }
    }];
}

- (void)disconnected {
    
    NSLog(@"%s %@ %@", __func__, _host, _userData.generalData.nickName);
    
    [_heartBeatTimer setFireDate:[NSDate distantFuture]];
    
    [self sessionTransferFailed];
}

- (void)receivedData:(NSData *)data {
    
    NSLog(@"%s", __func__);
    
    YYTXSessionStatus status = [self parseData:data];
    if (YYTXSessionFinish == status) {
        
        [_timerForTransfer setFireDate:[NSDate distantFuture]];
        
        dispatch_semaphore_signal(_semaphoreForWriteFinish);
        
        [_heartBeatTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:HEARTBEAT_INTERVAL]]; // 启动检测TCP连接的心跳定时器
        
    } else if (YYTXSessionReceiveFailed == status) {
        /* 数据包有误，被弃用 */
    } else if (YYTXSessionReceivedOthers == status) {

        [_delegate dataUpdate:self]; // 设备有数据更新
        
        [_tcpConn readDataHead];
    }
}

- (void)transferFailed {
    
    NSLog(@"%s %@ %@ %d", __func__, _host, _userData.generalData.nickName, _curSession.ID);
    
    [self sessionTransferFailed];
}

#pragma device 方法

- (void)removed {
    
    NSLog(@"%s", __func__);

    [self disable];
    
    [_delegate deviceRemoved:self];
}

- (void)disable {
    
    NSLog(@"%s", __func__);

    [self destroy];
    
    [self cancelTask];
    
    /* 将当前正在执行的会话结束并返回 */
    [self sessionTransferFailed];
}

- (void)destroy {

    _isAbsent = YES;
    
    if ((nil != _tcpConn) && [_tcpConn isValid]) {
        [_tcpConn disable];
    }
    
    if ((nil != _heartBeatTimer) && [_heartBeatTimer isValid]) {
        [_heartBeatTimer invalidate];
    }
    
    if ((nil != _timerForTransfer) && [_timerForTransfer isValid]) {
        [_timerForTransfer invalidate];
    }
    
    if ((nil != _threadForWriteData) && ![_threadForWriteData isCancelled]) {
        [_threadForWriteData cancel];
    }
}

- (void)cancelTask {
    
    /* 将会话列表中的所有会话结束并返回 */
    NSMutableArray *arr = [NSMutableArray arrayWithArray:_tcpSessionList];
    for (TcpSession *session in arr) {
        if (nil != session.returnBlock) {
            session.returnBlock(YYTXTransferFailed);
        }
    }
    [_tcpSessionList removeAllObjects]; // 清空会话列表
}

#pragma 心跳检测

- (void)heartBeat {
    
    NSLog(@"%s %@", __func__, _host);

    [self heartBeat:^(YYTXDeviceReturnCode code) {
        
        if (YYTXOperationSuccessful == code) {
            [_delegate dataUpdate:self];
        }
    }];
}

#pragma 发送数据

- (void)writeData {
    
    while (![[NSThread currentThread] isCancelled]) {
        
        NSData *data = [self getData];
        
        if (nil != data) {
            
            if ((nil != _heartBeatTimer) && [_heartBeatTimer isValid]) {
                [_heartBeatTimer setFireDate:[NSDate distantFuture]];
            }
            
            if ((nil != _tcpConn) && [_tcpConn isValid]) {
                [_tcpConn writeData:data];
            }
            
            if ((nil != _timerForTransfer) && [_timerForTransfer isValid]) {
                [_timerForTransfer setFireDate:[NSDate dateWithTimeIntervalSinceNow:TRANSFER_INTERVAL]];
            }
            
            dispatch_semaphore_wait(_semaphoreForWriteFinish, DISPATCH_TIME_FOREVER);
        }
    }
}

- (void)transferTimeout {

    NSLog(@"%s ip:%@ id:%d", __func__, [SystemToolClass IPAddress], _curSession.ID);
    
    _isAbsent = YES;
    
    [_timerForTransfer setFireDate:[NSDate distantFuture]];
    
    [self sessionTransferFailed];
    
    [_tcpConn disconnect];
}

#pragma Session Manager

- (void)addToSessionQueue:(id)param method:(NSString *)method returnBlock:(void (^)(YYTXDeviceReturnCode code))block {
    NSError *err;
    
    NSLog(@"%s %@ %@ 1", __func__, _host, _userData.generalData.nickName);

    if ((nil == param) || (nil == method)) {
        if (nil != block) {
            block(YYTXParameterError);
        }
        return;
    }
#if 0
    if (_tcpSessionList.count>=1) {
        if (nil != block) {
            block(YYTXOperationIsTooFrequent);
        }
        return;
    }
#endif
    NSDictionary *root = [_jsonObject createRootObjectWithIdValue:_sessionID methodValue:method paramsValue:param];
    if ([NSJSONSerialization isValidJSONObject:root]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:root options:NSJSONWritingPrettyPrinted error:&err];
        if (nil != data) {
            if (!_isAbsent) {
                dispatch_async(_queueForAddSession, ^{
                    
                    TcpSession *session = [[TcpSession alloc] initWithId:_sessionID++ data:data returnBlock:block];
                    
                    [_tcpSessionList addObject:session];
                    
                    dispatch_semaphore_signal(_semaphoreForHasData);
                    
                    NSLog(@"%s %@ %@ 2 count:%lu", __func__, _host, _userData.generalData.nickName, (unsigned long)_tcpSessionList.count);
                });
                
            } else {
                NSLog(@"%s %@ %@ 设备不在当前网络，tcp会话队列已关闭", __func__, _host, _userData.generalData.nickName);
                if (nil != block) {
                    block(YYTXDeviceIsAbsent);
                }
            }
        } else {
            NSLog(@"%s %@ %@ %@", __func__, _host, _userData.generalData.nickName, err);
            if (nil != block) {
                block(YYTXParameterError);
            }
        }
    } else {
        NSLog(@"%s %@ %@ 传入参数不是有效的json数据格式", __func__, _host, _userData.generalData.nickName);
        if (nil != block) {
            block(YYTXParameterError);
        }
    }
}

- (void)addAnalysisResultToSessionQueue:(NSDictionary *)result returnBlock:(void (^)(YYTXDeviceReturnCode code))block {
    NSError *err;

    if (nil == result) {
        if (nil != block) {
            block(YYTXParameterError);
        }
        return;
    }
    
    NSDictionary *root = [_jsonObject createRootObjectWithIdValue:_sessionID resultValue:result];
    if ([NSJSONSerialization isValidJSONObject:root]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:root options:NSJSONWritingPrettyPrinted error:&err];
        if (nil != data) {
            if (!_isAbsent) {
                dispatch_async(_queueForAddSession, ^{
                    
                    TcpSession *session = [[TcpSession alloc] initWithId:_sessionID++ data:data returnBlock:block];
                    
                    [_tcpSessionList addObject:session];
                    
                    dispatch_semaphore_signal(_semaphoreForHasData);
                    
                    NSLog(@"%s %@ %@ 2 count:%lu", __func__, _host, _userData.generalData.nickName, (unsigned long)_tcpSessionList.count);
                });
                
            } else {
                NSLog(@"%s %@ %@ 设备不在当前网络，tcp会话队列已关闭", __func__, _host, _userData.generalData.nickName);
                if (nil != block) {
                    block(YYTXDeviceIsAbsent);
                }
            }
        } else {
            NSLog(@"%s %@ %@ %@", __func__, _host, _userData.generalData.nickName, err);
            if (nil != block) {
                block(YYTXParameterError);
            }
        }
    } else {
        NSLog(@"%s %@ %@ 传入参数不是有效的json数据格式", __func__, _host, _userData.generalData.nickName);
        if (nil != block) {
            block(YYTXParameterError);
        }
    }
}

- (NSData *)getData {
    
    NSLog(@"%s %@ %@ 1", __func__, _host, _userData.generalData.nickName);

    dispatch_semaphore_wait(_semaphoreForHasData, DISPATCH_TIME_FOREVER);
    
    NSLog(@"%s %@ %@ 2 count:%lu", __func__, _host, _userData.generalData.nickName, (unsigned long)_tcpSessionList.count);
    
    if (_tcpSessionList.count >= 1) {
        _curSession = _tcpSessionList[0];
        [_tcpSessionList removeObject:_curSession];
        
        return _curSession.data;
    } else {
        return nil;
    }
}

- (void)sessionTransferFailed {
    
    NSLog(@"%s", __func__);

    if (nil != _curSession) {
        if (nil != _curSession.returnBlock) {
            _curSession.returnBlock(YYTXTransferFailed);
        }
        
        NSLog(@"%s id:%d name:%@ %@", __func__, _curSession.ID, _userData.generalData.nickName, _host);
        
        _curSession = nil;
        
        dispatch_semaphore_signal(_semaphoreForWriteFinish);
    }
}

- (void)sessionComplete {

    _curSession = nil;
//    dispatch_semaphore_signal(_semaphoreForWriteFinish);
}

#pragma 分析接收到的数据(Json格式的)

- (BOOL)parseParamItem:(NSDictionary *)paramItem {
    BOOL retState = NO;
    
    if (nil == paramItem) {
        return NO;
    }

    NSDictionary *eventItem = [paramItem objectForKey:JSONITEM_EVENT];
    if (nil != eventItem) {
        if (_isSelect) {
            EventIndClass *event = [EventIndClass parseEventIndJsonItem:eventItem];
            NSLog(@"%s status:%@", __func__, event.status);
            if ([event.status isEqualToString:ITEMVALUE_EVENTIND_STATUS_START] && nil != event.query) {
                [[NSNotificationCenter defaultCenter] postNotificationName:DeviceEventPlayerStart object:self userInfo:@{JSONITEM_EVENTIND_QUERY:event.query}];
//                [BoxDatabase addName:_userData.generalData.nickName time:event.time question:event.query answer:event.replay help:event.help];
            } else if ([event.status isEqualToString:ITEMVALUE_EVENTIND_STATUS_STOP] && nil != event.query) {
                [[NSNotificationCenter defaultCenter] postNotificationName:DeviceEventPlayerStop object:self userInfo:@{JSONITEM_EVENTIND_QUERY:event.query}];
            } else if ([event.status isEqualToString:ITEMVALUE_EVENTIND_STATUS_PAUSE] && nil != event.query) {
                [[NSNotificationCenter defaultCenter] postNotificationName:DeviceEventPlayerPause object:self userInfo:@{JSONITEM_EVENTIND_QUERY:event.query}];
            } else if ([event.status isEqualToString:ITEMVALUE_EVENTIND_STATUS_RESUME] && nil != event.query) {
                [[NSNotificationCenter defaultCenter] postNotificationName:DeviceEventPlayerResume object:self userInfo:@{JSONITEM_EVENTIND_QUERY:event.query}];
            }
            retState = YES;
        } else {
            retState = NO;
        }
    }
    
    return retState;
}

- (YYTXSessionStatus)parseData:(NSData *)data {
    UInt16 rID;
    NSError *err;
    
    if (nil == data) {
        return YYTXSessionReceiveFailed;
    }
    
    NSLog(@"%s %@ %@ %@", __func__, [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding], _host, _userData.generalData.nickName);
    
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (nil == root) {
        NSLog(@"%s %@", __func__, err);
        return YYTXSessionReceiveFailed;
    }
    
    NSString *methodItem = [_jsonObject getMethodValueFromRootObject:root];
    if (nil != methodItem) {
        
        NSDictionary *paramItem = [_jsonObject getParamsValueFromRootObject:root];
        if (nil == paramItem) {
            return YYTXSessionReceiveFailed;
        }

        if ([self parseParamItem:paramItem]) {
            return YYTXSessionReceivedOthers;
        } else {
            return YYTXSessionReceiveFailed;
        }
    }
    
    NSNumber *idItem = [_jsonObject getIdValueFromRootObject:root];
    if (nil == idItem) {
        return YYTXSessionReceiveFailed;
    }
    
    NSDictionary *errorItem = [_jsonObject getErrorValueFromRootObject:root];
    id resultItem = [_jsonObject getResultValueFromRootObject:root];
    
    rID = [idItem integerValue];
    if (rID == _curSession.ID) {
        
        if (nil != errorItem) {
            
            NSLog(@"%s errCode:%ld errMessage:%@", __func__, (long)[_jsonObject getCodeValueFromErrorObject:errorItem].integerValue, [_jsonObject getMessageValueFromErrorObject:errorItem]);
            
            if (nil != _curSession.returnBlock) {
                _curSession.returnBlock(YYTXOperationFailed);
            }
        } else if (nil != resultItem) {
            if ([resultItem isKindOfClass:[NSNumber class]]) {
                
            } else if ([resultItem isKindOfClass:[NSDictionary class]]) {
                NSDictionary *result = resultItem;
                BOOL ret = [_userData parseResultItem:result];
                if (!ret) {
                    [_audioPlay parseVolume:resultItem];
                }
            }
            
            if (nil != _curSession.returnBlock) {
                _curSession.returnBlock(YYTXOperationSuccessful);
            }
        } else {
            if (nil != _curSession.returnBlock) {
                _curSession.returnBlock(YYTXTransferFailed);
            }
        }
    } else {
        goto back;
    }
    
    _curSession = nil;
//    [self performSelector:@selector(sessionComplete) withObject:nil afterDelay:1.0f];
    
    return YYTXSessionFinish;
    
back:
    return YYTXSessionReceiveFailed;
}

- (NSArray *)createOptionPlayObjectWithParams:(NSDictionary *)params {
    if (nil == params) {
        return nil;
    }
    
    NSDictionary *successfulObject;
    NSDictionary *failedObject;
    
    NSString *successful = [params objectForKey:DevicePlayTTSWhenOperationSuccessful];
    if (nil == successful) {
        successful = [params objectForKey:DevicePlayFileWhenOperationSuccessful];
        if (nil != successful) {
            successfulObject = [_audioPlay whenOperationSuccessfulPlay:successful playType:YYTXDevicePlayTypeLocalPreset];
        }
    } else {
        successfulObject = [_audioPlay whenOperationSuccessfulPlay:successful playType:YYTXDevicePlayTypeTTS];
    }
    
    
    NSString *failed = [params objectForKey:DevicePlayTTSWhenOperationFailed];
    if (nil == failed) {
        failed = [params objectForKey:DevicePlayFileWhenOperationFailed];
        if (nil != failed) {
            failedObject = [_audioPlay whenOperationFailedPlay:failed playType:YYTXDevicePlayTypeLocalPreset];
        }
    } else {
        failedObject = [_audioPlay whenOperationFailedPlay:failed playType:YYTXDevicePlayTypeTTS];
    }
    
    NSMutableArray *arr = [NSMutableArray array];
    
    if (nil != successfulObject) {
        [arr addObject:successfulObject];
    }
    
    if (nil != failedObject) {
        [arr addObject:failedObject];
    }
    
    if (arr.count <= 0) {
        return nil;
    } else {
        return arr;
    }
}

#pragma 用户数据(userdata)方法

- (void)getGeneral:(void (^)(YYTXDeviceReturnCode code))block {
    
    NSArray *getUserData = [_userData getGeneral];
    [self addToSessionQueue:[NSDictionary dictionaryWithObject:getUserData forKey:JSONITEM_DATA] method:ITEMVALUE_USERDATA_GETUSERDATA returnBlock:block];
}

- (void)modifyGeneral:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block {

    NSDictionary *setUserData = [_userData modifyGeneral];

    NSArray *optionPlay = [self createOptionPlayObjectWithParams:params];
    if (nil != optionPlay) {
        [self addToSessionQueue:@{JSONITEM_DATA:setUserData, JSONITEM_AUDIOPLAY_OPTIONPLAY:optionPlay} method:ITEMVALUE_USERDATA_SETUSERDATA returnBlock:block];
    } else {
        [self addToSessionQueue:@{JSONITEM_DATA:setUserData} method:ITEMVALUE_USERDATA_SETUSERDATA returnBlock:block];
    }
}

- (void)getDeviceInfo:(void (^)(YYTXDeviceReturnCode code))block {

    NSArray *getUserData = [_userData getDeviceInfo];
    [self addToSessionQueue:[NSDictionary dictionaryWithObject:getUserData forKey:JSONITEM_DATA] method:ITEMVALUE_USERDATA_GETUSERDATA returnBlock:block];
}

#pragma 唤醒控制方法

- (void)getWakeup:(void (^)(YYTXDeviceReturnCode code))block {

    NSArray *getUserData = [_userData getWakeup];
    [self addToSessionQueue:[NSDictionary dictionaryWithObject:getUserData forKey:JSONITEM_DATA] method:ITEMVALUE_USERDATA_GETUSERDATA returnBlock:block];
}

- (void)modifyWakeup:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block {

    NSDictionary *setUserData = [_userData modifyWakeup];

    NSArray *optionPlay = [self createOptionPlayObjectWithParams:params];
    if (nil != optionPlay) {
        [self addToSessionQueue:@{JSONITEM_DATA:setUserData, JSONITEM_AUDIOPLAY_OPTIONPLAY:optionPlay} method:ITEMVALUE_USERDATA_SETUSERDATA returnBlock:block];
    } else {
        [self addToSessionQueue:@{JSONITEM_DATA:setUserData} method:ITEMVALUE_USERDATA_SETUSERDATA returnBlock:block];
    }
}

#pragma 夜间控制方法

- (void)getUndisturbedControl:(void (^)(YYTXDeviceReturnCode))block {
    
    NSArray *getUserData = [_userData getUndisturbedControl];
    [self addToSessionQueue:[NSDictionary dictionaryWithObject:getUserData forKey:JSONITEM_DATA] method:ITEMVALUE_USERDATA_GETUSERDATA returnBlock:block];
}

- (void)modifyUndisturbedControl:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode))block {
    
    NSDictionary *setUserData = [_userData modifyUndisturbedControl];
    NSArray *optionPlay = [self createOptionPlayObjectWithParams:params];
    if (nil != optionPlay) {
        [self addToSessionQueue:@{JSONITEM_DATA:setUserData, JSONITEM_AUDIOPLAY_OPTIONPLAY:optionPlay} method:ITEMVALUE_USERDATA_SETUSERDATA returnBlock:block];
    } else {
        [self addToSessionQueue:@{JSONITEM_DATA:setUserData} method:ITEMVALUE_USERDATA_SETUSERDATA returnBlock:block];
    }
}

#pragma Parameter1 方法

- (void)getParameter1:(void (^)(YYTXDeviceReturnCode code))block {
    NSArray *getUserData = [_userData getParameter1];
    
    [self addToSessionQueue:[NSDictionary dictionaryWithObject:getUserData forKey:JSONITEM_DATA] method:ITEMVALUE_USERDATA_GETUSERDATA returnBlock:block];
}

- (void)modifyParameter1:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block {
    NSDictionary *setUserData = [_userData modifyParameter1];
    NSArray *optionPlay = [self createOptionPlayObjectWithParams:params];
    if (nil != optionPlay) {
        [self addToSessionQueue:@{JSONITEM_DATA:setUserData, JSONITEM_AUDIOPLAY_OPTIONPLAY:optionPlay} method:ITEMVALUE_USERDATA_SETUSERDATA returnBlock:block];
    } else {
        [self addToSessionQueue:@{JSONITEM_DATA:setUserData} method:ITEMVALUE_USERDATA_SETUSERDATA returnBlock:block];
    }
}

#pragma 睡前音乐方法

- (void)getSleepMusic:(void (^)(YYTXDeviceReturnCode code))block {

    NSArray *getUserData = [_userData getSleepMusic];
    [self addToSessionQueue:[NSDictionary dictionaryWithObject:getUserData forKey:JSONITEM_DATA] method:ITEMVALUE_USERDATA_GETUSERDATA returnBlock:block];
}

- (void)modifySleepMusicSuccessful:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block {

    NSDictionary *setUserData = [_userData modifySleepMusic];
    NSArray *optionPlay = [self createOptionPlayObjectWithParams:params];
    if (nil != optionPlay) {
        [self addToSessionQueue:@{JSONITEM_DATA:setUserData, JSONITEM_AUDIOPLAY_OPTIONPLAY:optionPlay} method:ITEMVALUE_USERDATA_SETUSERDATA returnBlock:block];
    } else {
        [self addToSessionQueue:@{JSONITEM_DATA:setUserData} method:ITEMVALUE_USERDATA_SETUSERDATA returnBlock:block];
    }
}

#pragma 闹铃方法

- (void)getAlarm:(void (^)(YYTXDeviceReturnCode code))block {

    NSArray *getUserData = [_userData getAlarm];
    [self addToSessionQueue:[NSDictionary dictionaryWithObject:getUserData forKey:JSONITEM_DATA] method:ITEMVALUE_USERDATA_GETUSERDATA returnBlock:block];
}

- (void)modifyAlarm:(AlarmClass *)alarm parameter:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block {

    if (nil == alarm) {
        if (NULL != block) {
            block(YYTXParameterError);
        }
    }

    NSDictionary *setUserData = [_userData modifyAlarm:alarm];
    NSArray *optionPlay = [self createOptionPlayObjectWithParams:params];
    if (nil != optionPlay) {
        [self addToSessionQueue:@{JSONITEM_DATA:setUserData, JSONITEM_AUDIOPLAY_OPTIONPLAY:optionPlay} method:ITEMVALUE_USERDATA_SETUSERDATA returnBlock:block];
    } else {
        [self addToSessionQueue:@{JSONITEM_DATA:setUserData} method:ITEMVALUE_USERDATA_SETUSERDATA returnBlock:block];
    }
    
}

- (void)addAlarm:(AlarmClass *)alarm params:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block {

    if (nil == alarm) {
        if (NULL != block) {
            block(YYTXParameterError);
        }
    }

    NSDictionary *insertUserData = [_userData addAlarm:alarm];
    NSArray *optionPlay = [self createOptionPlayObjectWithParams:params];
    if (nil != optionPlay) {
        [self addToSessionQueue:@{JSONITEM_DATA:insertUserData, JSONITEM_AUDIOPLAY_OPTIONPLAY:optionPlay} method:ITEMVALUE_USERDATA_INSERTUSERDATA returnBlock:block];
    } else {
        [self addToSessionQueue:@{JSONITEM_DATA:insertUserData} method:ITEMVALUE_USERDATA_INSERTUSERDATA returnBlock:block];
    }
}

- (void)deleteAlarm:(NSInteger)alarmId params:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block {

    NSDictionary *deleteUserData = [_userData deleteAlarmWithAlarmId:alarmId];
    NSArray *optionPlay = [self createOptionPlayObjectWithParams:params];
    if (nil != optionPlay) {
        [self addToSessionQueue:@{JSONITEM_DATA:deleteUserData, JSONITEM_AUDIOPLAY_OPTIONPLAY:optionPlay} method:ITEMVALUE_USERDATA_DELETEUSERDATA returnBlock:block];
    } else {
        [self addToSessionQueue:@{JSONITEM_DATA:deleteUserData} method:ITEMVALUE_USERDATA_DELETEUSERDATA returnBlock:block];
    }
}

#pragma 备忘方法

- (void)getRemind:(void (^)(YYTXDeviceReturnCode code))block {

    NSArray *getUserData = [_userData getRemind];
    [self addToSessionQueue:[NSDictionary dictionaryWithObject:getUserData forKey:JSONITEM_DATA] method:ITEMVALUE_USERDATA_GETUSERDATA returnBlock:block];
}

- (void)modifyRemind:(RemindClass *)remind parameter:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block {

    if (nil == remind) {
        if (NULL != block) {
            block(YYTXParameterError);
        }
    }

    NSDictionary *setUserData = [_userData modifyRemind:remind];
    NSArray *optionPlay = [self createOptionPlayObjectWithParams:params];
    if (nil != optionPlay) {
        [self addToSessionQueue:@{JSONITEM_DATA:setUserData, JSONITEM_AUDIOPLAY_OPTIONPLAY:optionPlay} method:ITEMVALUE_USERDATA_SETUSERDATA returnBlock:block];
    } else {
        [self addToSessionQueue:@{JSONITEM_DATA:setUserData} method:ITEMVALUE_USERDATA_SETUSERDATA returnBlock:block];
    }
}

- (void)addRemind:(RemindClass *)remind parameter:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block {

    if (nil == remind) {
        if (NULL != block) {
            block(YYTXParameterError);
        }
    }

    NSDictionary *insertUserData = [_userData addRemind:remind];
    NSArray *optionPlay = [self createOptionPlayObjectWithParams:params];
    if (nil != optionPlay) {
        [self addToSessionQueue:@{JSONITEM_DATA:insertUserData, JSONITEM_AUDIOPLAY_OPTIONPLAY:optionPlay} method:ITEMVALUE_USERDATA_INSERTUSERDATA returnBlock:block];
    } else {
        [self addToSessionQueue:@{JSONITEM_DATA:insertUserData} method:ITEMVALUE_USERDATA_INSERTUSERDATA returnBlock:block];
    }
}

- (void)deleteRemind:(NSUInteger)remindId params:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block {

    NSDictionary *deleteUserData = [_userData deleteRemindWithRemindId:remindId];
    NSArray *optionPlay = [self createOptionPlayObjectWithParams:params];
    if (nil != optionPlay) {
        [self addToSessionQueue:@{JSONITEM_DATA:deleteUserData, JSONITEM_AUDIOPLAY_OPTIONPLAY:optionPlay} method:ITEMVALUE_USERDATA_DELETEUSERDATA returnBlock:block];
    } else {
        [self addToSessionQueue:@{JSONITEM_DATA:deleteUserData} method:ITEMVALUE_USERDATA_DELETEUSERDATA returnBlock:block];
    }
}

#pragma 生日方法

- (void)getBirthday:(void (^)(YYTXDeviceReturnCode code))block {

    NSArray *getUserData = [_userData getBirthday];
    [self addToSessionQueue:[NSDictionary dictionaryWithObject:getUserData forKey:JSONITEM_DATA] method:ITEMVALUE_USERDATA_GETUSERDATA returnBlock:block];
}

- (void)modifyBirthday:(BirthdayClass *)birthday parameter:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block {

    if (nil == birthday) {
        if (NULL != block) {
            block(YYTXParameterError);
        }
    }

    NSDictionary *setUserData = [_userData modifyBirthday:birthday];
    NSArray *optionPlay = [self createOptionPlayObjectWithParams:params];
    if (nil != optionPlay) {
        [self addToSessionQueue:@{JSONITEM_DATA:setUserData, JSONITEM_AUDIOPLAY_OPTIONPLAY:optionPlay} method:ITEMVALUE_USERDATA_SETUSERDATA returnBlock:block];
    } else {
        [self addToSessionQueue:@{JSONITEM_DATA:setUserData} method:ITEMVALUE_USERDATA_SETUSERDATA returnBlock:block];
    }
}

- (void)addBirthday:(BirthdayClass *)birthday parameter:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block {

    if (nil == birthday) {
        if (NULL != block) {
            block(YYTXParameterError);
        }
    }

    NSDictionary *insertUserData = [_userData addBirthday:birthday];
    NSArray *optionPlay = [self createOptionPlayObjectWithParams:params];
    if (nil != optionPlay) {
        [self addToSessionQueue:@{JSONITEM_DATA:insertUserData, JSONITEM_AUDIOPLAY_OPTIONPLAY:optionPlay} method:ITEMVALUE_USERDATA_INSERTUSERDATA returnBlock:block];
    } else {
        [self addToSessionQueue:@{JSONITEM_DATA:insertUserData} method:ITEMVALUE_USERDATA_INSERTUSERDATA returnBlock:block];
    }
}

- (void)deleteBirthday:(NSInteger)birthdayId params:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block {

    NSDictionary *deleteUserData = [_userData deleteBirthdayWithBirthdayId:birthdayId];
    NSArray *optionPlay = [self createOptionPlayObjectWithParams:params];
    if (nil != optionPlay) {
        [self addToSessionQueue:@{JSONITEM_DATA:deleteUserData, JSONITEM_AUDIOPLAY_OPTIONPLAY:optionPlay} method:ITEMVALUE_USERDATA_DELETEUSERDATA returnBlock:block];
    } else {
        [self addToSessionQueue:@{JSONITEM_DATA:deleteUserData} method:ITEMVALUE_USERDATA_DELETEUSERDATA returnBlock:block];
    }
}

#pragma 起床闹铃通用设置方法

- (void)getGetupSet:(void (^)(YYTXDeviceReturnCode code))block {

    NSArray *getUserData = [_userData getGetupSet];
    [self addToSessionQueue:[NSDictionary dictionaryWithObject:getUserData forKey:JSONITEM_DATA] method:ITEMVALUE_USERDATA_GETUSERDATA returnBlock:block];
}

- (void)modifyGetupSet:(NSDictionary *)params completionBlock:(void (^)(YYTXDeviceReturnCode code))block {

    NSDictionary *setUserData = [_userData modifyGetupSet];
    NSArray *optionPlay = [self createOptionPlayObjectWithParams:params];
    if (nil != optionPlay) {
        [self addToSessionQueue:@{JSONITEM_DATA:setUserData, JSONITEM_AUDIOPLAY_OPTIONPLAY:optionPlay} method:ITEMVALUE_USERDATA_SETUSERDATA returnBlock:block];
    } else {
        [self addToSessionQueue:@{JSONITEM_DATA:setUserData} method:ITEMVALUE_USERDATA_SETUSERDATA returnBlock:block];
    }
}

#pragma 播放音频(AudioPlay)方法

- (void)playFileId:(NSString *)fId completionBlock:(void (^)(YYTXDeviceReturnCode code))block {
    
    if (nil == fId) {
        if (NULL != block) {
            block(YYTXParameterError);
        }
    }

    NSArray *playList = [_audioPlay playAudioWithFileId:fId];
    [self addToSessionQueue:[NSDictionary dictionaryWithObjectsAndKeys:playList, JSONITEM_AUDIOPLAY_PLAYLIST, nil] method:ITEMMETHOD_VALUE_MEDIAPLAY returnBlock:block];
}

- (void)playFilePath:(NSString *)fPath completionBlock:(void (^)(YYTXDeviceReturnCode code))block {
    
    if (nil == fPath) {
        if (NULL != block) {
            block(YYTXParameterError);
        }
    }

    NSArray *playList =[_audioPlay playAudioWithFilePath:fPath];
    [self addToSessionQueue:[NSDictionary dictionaryWithObjectsAndKeys:playList, JSONITEM_AUDIOPLAY_PLAYLIST, nil] method:ITEMMETHOD_VALUE_MEDIAPLAY returnBlock:block];
}

- (void)playFileTitle:(NSString *)tite phoneID:(NSString *)phoneId url:(NSString *)url completionBlock:(void (^)(YYTXDeviceReturnCode code))block {
    
    if (nil == url) {
        if (NULL != block) {
            block(YYTXParameterError);
        }
    }

    NSArray *playList =[_audioPlay playAudioWithUrl:url];
    NSDictionary *mediaInfo = [EventIndClass createMediaInfo:tite reply:NSLocalizedStringFromTable(@"nonRecognitionReply", @"hint", nil)];
    [self addToSessionQueue:[NSDictionary dictionaryWithObjectsAndKeys:playList, JSONITEM_AUDIOPLAY_PLAYLIST, mediaInfo, JSONITEM_EVENTIND_MEDIAINFO, nil] method:ITEMMETHOD_VALUE_MEDIAPLAY returnBlock:block];
}

- (void)sendAnalysisData:(NSDictionary *)result completionBlock:(void (^)(YYTXDeviceReturnCode code))block {
    
    if (nil == result) {
        if (NULL != block) {
            block(YYTXParameterError);
        }
    }

    [self addAnalysisResultToSessionQueue:result returnBlock:block];
}

- (void)stopPlay:(void (^)(YYTXDeviceReturnCode code))block {

    NSNull *stopItem = [_audioPlay stop];
    [self addToSessionQueue:stopItem method:ITEMMETHOD_VALUE_MEDIASTOP returnBlock:block];
}

- (void)pausePlay:(void (^)(YYTXDeviceReturnCode code))block {

    NSNull *pauseItem = [_audioPlay pause];
    [self addToSessionQueue:pauseItem method:ITEMMETHOD_VALUE_MEDIAPAUSE returnBlock:block];
}

- (void)resumePlay:(void (^)(YYTXDeviceReturnCode code))block {

    NSNull *resumeItem = [_audioPlay resume];
    [self addToSessionQueue:resumeItem method:ITEMMETHOD_VALUE_MEDIARESUME returnBlock:block];
}

- (void)playPrevious:(void (^)(YYTXDeviceReturnCode code))block {
    
    NSNull *previousItem = [_audioPlay previous];
    [self addToSessionQueue:previousItem method:ITEMMETHOD_VALUE_MEDIAPREVIOUS returnBlock:block];
}

- (void)playNext:(void (^)(YYTXDeviceReturnCode code))block {
    
    NSNull *nextItem = [_audioPlay next];
    [self addToSessionQueue:nextItem method:ITEMMETHOD_VALUE_MEDIANEXT returnBlock:block];
}

- (void)getVolume:(void (^)(YYTXDeviceReturnCode code))block {

    NSNull *getVolumeItem = [_audioPlay getVolume];
    [self addToSessionQueue:getVolumeItem method:ITEMMETHOD_VALUE_GETVOLUME returnBlock:block];
}

- (void)setVolume:(NSInteger)volume completionBlock:(void (^)(YYTXDeviceReturnCode code))block {
    
    NSNumber *setVolumeItem = [_audioPlay setVolume:volume];
    [self addToSessionQueue:setVolumeItem method:ITEMMETHOD_VALUE_SETVOLUME returnBlock:block];
}

- (void)setVolumeDown:(void (^)(YYTXDeviceReturnCode code))block {
    
    NSNull *setVolumeDownItem = [_audioPlay setVolumeDown];
    [self addToSessionQueue:setVolumeDownItem method:ITEMMETHOD_VALUE_SETVOLUMEDOWN returnBlock:block];
}

- (void)setVolumeUp:(void (^)(YYTXDeviceReturnCode code))block {
    
    NSNull *setVolumeUpItem = [_audioPlay setVolumeUp];
    [self addToSessionQueue:setVolumeUpItem method:ITEMMETHOD_VALUE_SETVOLUMEUP returnBlock:block];
}

#pragma Heartbeat

- (void)heartBeat:(void (^)(YYTXDeviceReturnCode code))block {
    
    NSDictionary *heartBeatItem = @{JSONITEM_DATA:[_userData getDeviceInfo]};
    [self addToSessionQueue:heartBeatItem method:YYTXTransferProtocolJsonKeyHeartBeat returnBlock:block];
}

@end
