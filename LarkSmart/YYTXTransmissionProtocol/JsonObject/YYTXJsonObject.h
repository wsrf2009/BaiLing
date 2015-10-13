//
//  YYTXJsonObject.h
//  CloudBox
//
//  Created by TTS on 15/8/5.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYTXJsonObject : NSObject

- (NSNumber *)getIdValueFromRootObject:(NSDictionary *)rootObject;
- (NSString *)getMethodValueFromRootObject:(NSDictionary *)rootObject;
- (NSDictionary *)getParamsValueFromRootObject:(NSDictionary *)rootObject;
- (id)getResultValueFromRootObject:(NSDictionary *)rootObject;
- (NSDictionary *)getErrorValueFromRootObject:(NSDictionary *)rootObject;
- (NSNumber *)getCodeValueFromErrorObject:(NSDictionary *)errorObject;
- (NSString *)getMessageValueFromErrorObject:(NSDictionary *)errorObject;
- (NSDictionary *)createRootObjectWithIdValue:(NSInteger)Id methodValue:(NSString *)method paramsValue:(NSDictionary *)params;
- (NSDictionary *)createRootObjectWithIdValue:(NSInteger)Id resultValue:(NSDictionary *)result;
@end
