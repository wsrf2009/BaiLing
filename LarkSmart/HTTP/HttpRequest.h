//
//  HttpClass.h
//  CloudBox
//
//  Created by TTS on 15-4-22.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpRequest : NSObject

- (void)syncGetRequestForURL:(NSString *)url parameters:(NSDictionary *)parameters finishBlock:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))block;

// 同步POST请求
- (void)syncPostRequestForURL:(NSString *)url dictionaryParams:(NSDictionary *)dic requestParams:(NSString *)parameters finishBlock:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))block;

// 异步GET请求
- (void)asyncGetRequestForURL:(NSString *)url parameters:(NSDictionary *)parameters finishBlock:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))block;

// 异步POST请求 参数为NSDictionary
- (void)asyncPostRequestForURL:(NSString *)url dictionaryParams:(NSDictionary *)dic requestParams:(NSString *)parameters finishBlock:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))block;

@end
