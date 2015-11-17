//
//  HttpServceManager.h
//  CloudBox
//
//  Created by TTS on 15-5-11.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryClass.h"
#import "AudioClass.h"
#import "AudioCategory.h"
#import "AudioList.h"
#import "QueryClass.h"
#import "ProductInfo.h"
#import "AppAuthentication.h"
#import "SemanticAnalysis.h"
#import "UserFeedback.h"

extern NSString *const YYTXServerTest;
extern NSString *const YYTXServerNormal;

typedef enum {
    /** 同步Get */
    YYTXHttpRequestGetAndSync = 100,
    
    /** 异步Get */
    YYTXHttpRequestGetAndAsync,
    
    /** 同步Post */
    YYTXHttpRequestPostAndSync,
    
    /** 异步Post */
    YYTXHttpRequestPostAndAsync
} YYTXHttpRequestMode;

typedef enum {
    YYTXHttpRequestSuccessful = 1000,
    YYTXHttpRequestParameterError,
    YYTXHttpRequestTimeout,
    YYTXHttpRequestUnknownError
} YYTXHttpRequestReturnCode;

@protocol ServerServiceDelegate <NSObject>



@end

@interface ServerServiceManager : NSObject

@property (nonatomic, retain) id <ServerServiceDelegate> delegate;
@property (nonatomic, retain) NSString *ServerAddress;

- (instancetype)initWithDelegate:(id)delegate;

/** 根据音乐分类ID从服务器请求该音乐分类的子目录
 @param cId 音乐分类的ID
 @param mode 请求的方式 同步POST或异步POST
 @param finishBlock 服务器返回时的回调
 */
- (void)requestSubCategorysWithCateogryId:(NSString *)cId requestMode:(YYTXHttpRequestMode)mode requestFinish:(void (^)(NSMutableArray *subCategorys, YYTXHttpRequestReturnCode code))finishBlock;

/** 根据音乐分类ID从服务器请求该分类下的音乐列表
 @param Id 音乐分类Id
 @param pageNo 音乐列表的页数
 @param number 请求的该页的音乐条数
 @param mode 请求的方式，同步POST或异步POST
 @param finishBlock 服务器返回时的回调
 */
- (void)requestAudioListWithCategoryId:(NSString *)Id pageNo:(NSUInteger)page itemsPerpage:(NSUInteger)number requestMode:(YYTXHttpRequestMode)mode requestFinish:(void (^)(NSMutableArray *subCategorys, YYTXHttpRequestReturnCode code))finishBlock;

/** 
 异步GET请求新的 buyurl，helpurl，producturl
 */
- (void)updateUrls;

/** 
 异步请求最新的产品信息
 */
- (void)requestProductInfo;

/** 
 请求后台对百度返回的进行语义分析
 @param data 待解析的数据
 @param openId 设备的openId
 @param finishBlock 服务器返回时的回调
 */
- (void)requestAnalysis:(NSData *)data deviceOpenId:(NSString *)openId requestFinish:(void (^)(NSDictionary *result))finishBlock;

/** 提交用户反馈 */
- (void)postUserFeedback:(NSDictionary *)feedback requestFinish:(void (^)(NSString *message))finishBlock;

/** 同步POST的方式在服务器登陆本APP */
- (void)login;

/** 在服务器端登出该APP */
- (void)logout;

@end
