//
//  YYTXJsonObject.m
//  CloudBox
//
//  Created by TTS on 15/8/5.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "YYTXJsonObject.h"

NSString *const YYTXTransferProtocolJsonKeyID = @"id";
NSString *const YYTXTransferProtocolJsonKeyMethod = @"method";
NSString *const YYTXTransferProtocolJsonKeyParams = @"params";
NSString *const YYTXTransferProtocolJsonKeyResult = @"result";

NSString *const YYTXTransferProtocolJsonKeyError = @"error";
NSString *const YYTXTransferProtocolJsonKeyCode = @"code";
NSString *const YYTXTransferProtocolJsonKeyMessage = @"message";

@implementation YYTXJsonObject

- (NSNumber *)getIdValueFromRootObject:(NSDictionary *)rootObject {
    
    return [rootObject objectForKey:YYTXTransferProtocolJsonKeyID];
}

- (NSString *)getMethodValueFromRootObject:(NSDictionary *)rootObject {
    
    return [rootObject objectForKey:YYTXTransferProtocolJsonKeyMethod];
}

- (NSDictionary *)getParamsValueFromRootObject:(NSDictionary *)rootObject {
    
    return [rootObject objectForKey:YYTXTransferProtocolJsonKeyParams];
}

- (id)getResultValueFromRootObject:(NSDictionary *)rootObject {
    
    return [rootObject objectForKey:YYTXTransferProtocolJsonKeyResult];
}

- (NSDictionary *)getErrorValueFromRootObject:(NSDictionary *)rootObject {
    
    return [rootObject objectForKey:YYTXTransferProtocolJsonKeyError];
}

- (NSNumber *)getCodeValueFromErrorObject:(NSDictionary *)errorObject {
    
    return [errorObject objectForKey:YYTXTransferProtocolJsonKeyCode];
}

- (NSString *)getMessageValueFromErrorObject:(NSDictionary *)errorObject {
    
    return [errorObject objectForKey:YYTXTransferProtocolJsonKeyMessage];
}

- (NSDictionary *)createRootObjectWithIdValue:(NSInteger)Id methodValue:(NSString *)method paramsValue:(NSDictionary *)params {
    
    if (Id < 0 || Id > 65535 || nil == method || nil == params) {
        return nil;
    }
    
    return @{YYTXTransferProtocolJsonKeyID:[NSNumber numberWithInteger:Id], YYTXTransferProtocolJsonKeyMethod:method, YYTXTransferProtocolJsonKeyParams:params};
}

- (NSDictionary *)createRootObjectWithIdValue:(NSInteger)Id resultValue:(NSDictionary *)result {
    
    if (Id < 0 || Id > 65535 || nil == result) {
        return nil;
    }
    
    return @{YYTXTransferProtocolJsonKeyID:[NSNumber numberWithInteger:Id], YYTXTransferProtocolJsonKeyResult:result};
}

@end
