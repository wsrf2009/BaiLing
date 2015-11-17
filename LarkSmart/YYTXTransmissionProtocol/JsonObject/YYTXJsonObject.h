//
//  YYTXJsonObject.h
//  CloudBox
//
//  Created by TTS on 15/8/5.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYTXJsonObject : NSObject

/** 从给定root json中获取ID */
- (NSNumber *)getIdValueFromRootObject:(NSDictionary *)rootObject;

/** 从给定的root json中获取method */
- (NSString *)getMethodValueFromRootObject:(NSDictionary *)rootObject;

/** 从给定的root json中获取params */
- (NSDictionary *)getParamsValueFromRootObject:(NSDictionary *)rootObject;

/** 从给定的root json中获取result */
- (id)getResultValueFromRootObject:(NSDictionary *)rootObject;

/** 从给定的root json中获取error */
- (NSDictionary *)getErrorValueFromRootObject:(NSDictionary *)rootObject;

/** 从error json中获取code */
- (NSNumber *)getCodeValueFromErrorObject:(NSDictionary *)errorObject;

/** 从error json中获取message */
- (NSString *)getMessageValueFromErrorObject:(NSDictionary *)errorObject;

/** 
 根据ID，method，params创建root json 
 @param Id
 @param method
 @param params
 */
- (NSDictionary *)createRootObjectWithIdValue:(NSInteger)Id methodValue:(NSString *)method paramsValue:(NSDictionary *)params;

/** 
 根据ID，result创建root json 
 @param Id
 @param result
 */
- (NSDictionary *)createRootObjectWithIdValue:(NSInteger)Id resultValue:(NSDictionary *)result;
@end
