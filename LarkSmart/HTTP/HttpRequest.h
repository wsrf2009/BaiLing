//
//  HttpClass.h
//  CloudBox
//
//  Created by TTS on 15-4-22.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpRequest : NSObject

/**
 同步Get请求
 @param url 请求的服务器端网络地址
 @param dicParam get参数
 @param block 服务器端返回时的网络地址
 */
- (void)syncGetRequestForURL:(NSString *)url parameters:(NSDictionary *)dicParam finishBlock:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))block;

/**
 同步POST请求
 @param url 请求的服务器端网络地址
 @param dicParam post参数
 @param parameters 发送给服务器的数据
 @param block 服务器端返回时的回调
 */
- (void)syncPostRequestForURL:(NSString *)url dictionaryParams:(NSDictionary *)dicParam requestParams:(NSString *)parameters finishBlock:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))block;

/** 
 异步GET请求
 @param url 请求的服务器端网络地址
 @param dicParam get参数
 @param block 服务器端返回时的回调
 */
- (void)asyncGetRequestForURL:(NSString *)url parameters:(NSDictionary *)dicParam finishBlock:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))block;

/**
 异步POST请求 参数为NSDictionary
 @param url 请求的服务器端网络地址
 @param dicParam post参数
 @param parameters 发送给服务器的数据
 @param block 服务器返回时的回调
 */
- (void)asyncPostRequestForURL:(NSString *)url dictionaryParams:(NSDictionary *)dicParam requestParams:(NSString *)parameters finishBlock:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))block;

@end
