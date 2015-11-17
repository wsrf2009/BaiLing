//
//  HttpClass.m
//  CloudBox
//
//  Created by TTS on 15-4-22.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "HttpRequest.h"

#define TIME_OUT_INTERVAL 3

@interface HttpRequest ()

@property (nonatomic, retain) NSMutableData *receiveData;

@end

@implementation HttpRequest

/**
 将NSDictionary专为Http的get请求的参数key＝value
 */
- (NSString *)HTTPBodyWithParameters:(NSDictionary *)parameters {
    NSMutableArray *parametersArray = [[NSMutableArray alloc] init];
    
    for (NSString *key in [parameters allKeys]) {
        id value = [parameters objectForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            [parametersArray addObject:[NSString stringWithFormat:@"%@=%@",key,value]];
        }
    }
    
    return [parametersArray componentsJoinedByString:@"&"];
}

// 同步GET请求
- (void)syncGetRequestForURL:(NSString *)url parameters:(NSDictionary *)parameters finishBlock:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))block {
    // 创建URL
    NSString *URLFellowString = [@"?" stringByAppendingString:[self HTTPBodyWithParameters:parameters]];
    NSString *finalURLString = [[url stringByAppendingString:URLFellowString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *finalURL = [NSURL URLWithString:finalURLString];
    
    /* 
     * 通过URL创建网络请求
     *
     * NSURLRequest初始化方法第一个参数：请求访问路径，第二个参数：缓存协议，第三个参数：网络请求超时时间（秒）
     * 其中缓存协议是个枚举类型包含：
     * NSURLRequestUseProtocolCachePolicy（基础策略）
     * NSURLRequestReloadIgnoringLocalCacheData（忽略本地缓存）
     * NSURLRequestReturnCacheDataElseLoad（首先使用缓存，如果没有本地缓存，才从原地址下载）
     * NSURLRequestReturnCacheDataDontLoad（使用本地缓存，从不下载，如果本地没有缓存，则请求失败，此策略多用于离线操作）
     * NSURLRequestReloadIgnoringLocalAndRemoteCacheData（无视任何缓存策略，无论是本地的还是远程的，总是从原地址重新下载）
     * NSURLRequestReloadRevalidatingCacheData（如果本地缓存是有效的则不下载，其他任何情况都从原地址重新下载）
     */
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:finalURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TIME_OUT_INTERVAL];

    // 连接服务器
    NSURLResponse *response;
    NSError *error;
    NSData *rData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    block(response, rData, error);
}

// 同步POST请求
- (void)syncPostRequestForURL:(NSString *)url dictionaryParams:(NSDictionary *)dic requestParams:(NSString *)parameters finishBlock:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))block {
    NSString *URLFellowString = [@"?" stringByAppendingString:[self HTTPBodyWithParameters:dic]];
    NSString *finalURLString = [[url stringByAppendingString:URLFellowString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"%s url:%@ param:%@", __func__, finalURLString, parameters);
    
    // 创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:finalURLString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TIME_OUT_INTERVAL];
    [request setHTTPMethod:@"POST"];// 设置请求方式为POST，默认为GET
    
    if (nil != parameters) {
        [request setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // 连接服务器
    NSURLResponse *response;
    NSError *error;
    NSData *rData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    block(response, rData, error);
}

// 异步GET请求
- (void)asyncGetRequestForURL:(NSString *)url parameters:(NSDictionary *)parameters finishBlock:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))block {
    
    // 创建url
    NSString *URLFellowString = [@"?" stringByAppendingString:[self HTTPBodyWithParameters:parameters]];
    NSString *finalURLString = [[url stringByAppendingString:URLFellowString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSLog(@"%s url:%@ param:%@", __func__, finalURLString, parameters);
    
    // 创建请求
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:finalURLString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TIME_OUT_INTERVAL];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:block];
}

// 异步POST请求 参数为NSDictionary
- (void)asyncPostRequestForURL:(NSString *)url dictionaryParams:(NSDictionary *)dic requestParams:(NSString *)parameters finishBlock:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))block {
    NSString *URLFellowString = [@"?" stringByAppendingString:[self HTTPBodyWithParameters:dic]];
    NSString *finalURLString = [[url stringByAppendingString:URLFellowString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"%s url:%@ param:%@", __func__, finalURLString, parameters);

    // 创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:finalURLString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TIME_OUT_INTERVAL];
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    
    if (nil != parameters) {
        [request setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //第三步，连接服务器
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:block];
}

/*
 * 异步请求的代理方法
 * 接收到服务器回应的时候调用此方法
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    NSLog(@"%s %@", __func__, [res allHeaderFields]);
    self.receiveData = [NSMutableData data];
}

//接收到服务器传输数据的时候调用，此方法根据数据大小执行若干次
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"%s %@", __func__, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    [self.receiveData appendData:data];
}

//数据传完之后调用此方法
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *receiveStr = [[NSString alloc] initWithData:self.receiveData encoding:NSUTF8StringEncoding];
    NSLog(@"%s %@", __func__, receiveStr);
}

//网络请求过程中，出现任何错误（断网，连接超时等）会进入此方法
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%s %@", __func__, [error localizedDescription]);
}

@end
