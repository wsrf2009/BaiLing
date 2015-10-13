//
//  HttpServceManager.m
//  CloudBox
//
//  Created by TTS on 15-5-11.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "ServerServiceManager.h"
#import "HttpRequest.h"
#import "SystemToolClass.h"
#import "BoxDatabase.h"
#import "YYTXJsonObject.h"

NSString *const YYTXServerTest = @"http://123.57.62.98:8080"; // 测试服务器
NSString *const YYTXServerNormal = @"http://www.voicehw.com:8080"; // 正式服务器

//#define URL_REQUESTINFO     "http://123.57.6.144:8080/v1/adapter"
NSString *const DirAdapter = @"v1/adapter";
NSString *const DirQuery = @"v1/query";
//#define URL_REGIST          "http://www.sirihw.com:8080/v1/regist"
NSString *const DirRegist = @"v1/regist";

#define APP_ACTIVE          "active"
#define APP_LOGIN           "login"
#define APP_LOGOUT          "logout"

#define APPID       "iLarkHelper"
#define SIGN        "sign"
//#define CONFIGID    "99990000"
#define ID          "11"

@interface ServerServiceManager ()
{
    HttpRequest *httpRequest;
    AudioCategory *audioCategory;
    AudioList *audioList;
    unsigned short sessionID;
}

@property (nonatomic, retain) NSString *openId;
//@property (nonatomic, retain) YYTXJsonRequest *jsonRequest;

@end

@implementation ServerServiceManager

- (instancetype)initWithDelegate:(id)delegate {
    
    self = [super init];
    if (nil != self) {
        _delegate = delegate;
        sessionID = 0;
        httpRequest = [[HttpRequest alloc] init];
        audioCategory = [[AudioCategory alloc] init];
        audioList = [[AudioList alloc] init];
//        _jsonRequest = [[YYTXJsonRequest alloc] init];
        
#if 1
        _ServerAddress = YYTXServerNormal;
#else
        _ServerAddress = YYTXServerTest;
#endif
    }
    
    return self;
}

- (NSData *)createHttpRequestObject:(id)paramsItem method:(NSString *)method action:(SEL)action target:(id)target {
    
    if (nil == paramsItem) {
        return nil;
    }
    
    NSDictionary *root = [[[YYTXJsonObject alloc] init] createRootObjectWithIdValue:sessionID++ methodValue:method paramsValue:paramsItem];
    NSError *err;
    if ([NSJSONSerialization isValidJSONObject:root]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:root options:NSJSONWritingPrettyPrinted error:&err];
        if (nil == data) {
            NSLog(@"%s %@", __func__, err);
        } else {
            return data;
        }
    } else {
        NSLog(@"%s 不是一个有效的Json数据", __func__);
    }
    
    return nil;
}

#pragma 从服务器获取新的url

- (NSDictionary *)createQueryParams {
    NSString *appVersion = [SystemToolClass appVersion];
    NSString *configId = [appVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    NSLog(@"%s appVersion:%@ configId:%@", __func__, appVersion, configId);
    
    return @{@"appid":@APPID, @"sign":@SIGN, @"openid":_openId, @"configid":configId};
}

/*
 * 异步GET请求新的 buyurl，helpurl， producturl
 */
- (void)updateUrls {
    
    NSLog(@"%s", __func__);
    
    NSDictionary *dictionary = [self createQueryParams];
    
    [httpRequest asyncGetRequestForURL:[_ServerAddress stringByAppendingPathComponent:DirQuery] parameters:dictionary finishBlock:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (nil != data) {
            NSLog(@"%s %@", __func__, [NSString stringWithUTF8String:data.bytes]);
            
            QueryClass *query = [QueryClass parseQuery:data];
            
            if (nil != query) {
                if (nil != query.urlBuy) {
                    [BoxDatabase updateUrl:query.urlBuy withName:DT_ITEM_BUYURL];
                }
                
                if (nil != query.urlHelp) {
                    [BoxDatabase updateUrl:query.urlHelp withName:DT_ITEM_HELPURL];
                }
                
                if (nil != query.urlProduct) {
                    [BoxDatabase updateUrl:query.urlProduct withName:DT_ITEM_PRODUCTURL];
                }
                
                if (nil != query.xmlyHelpUrl) {
                    [BoxDatabase updateUrl:query.xmlyHelpUrl withName:DT_ITEM_XMLYHELPURL];
                }
                
                if (nil != query.weiXinUrl) {
                    [BoxDatabase updateUrl:query.weiXinUrl withName:DT_ITEM_WEIXINURL];
                }
            }
        } else {
            NSLog(@"%s response:%@ connectionError:%@", __func__, response, connectionError);
        }
    }];
}

#pragma 从服务器请求数据

- (NSDictionary *)createRequestParams {
    return @{@"sign":@SIGN, @"appid":@APPID, @"openid":_openId, @"id":@ID};
}

/*
 * 根据目录ID从服务器请求盖目录的子目录, 同步POST或异步POST
 */
- (void)requestSubCategorysWithCateogryId:(NSString *)cId requestMode:(YYTXHttpRequestMode)mode requestFinish:(void (^)(NSMutableArray *subCategorys, YYTXHttpRequestReturnCode code))finishBlock {
    NSDictionary *categoryIdItem = [audioCategory getAudioCategoryWithID:cId];
    NSData *data = [self createHttpRequestObject:categoryIdItem method:ITEMMETHOD_VALUE_GETAUDIOCATEGORY action:nil target:nil];
    
    NSLog(@"%s ID:%@", __func__, cId);

    if (YYTXHttpRequestPostAndSync == mode) {

        [httpRequest syncPostRequestForURL:[_ServerAddress stringByAppendingPathComponent:DirAdapter] dictionaryParams:[self createRequestParams] requestParams:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] finishBlock:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            if (nil != data) {
                NSLog(@"%s %@", __func__, [NSString stringWithUTF8String:data.bytes]);
                
                NSMutableArray *categoryList = [audioCategory analyzeAudioCategoryData:data];
                
                if (nil != categoryList) {
                    finishBlock(categoryList, YYTXHttpRequestSuccessful);
                } else {
                    finishBlock(categoryList, YYTXHttpRequestUnknownError);
                }
            } else {
                
                NSLog(@"%s response:%@ connectionError:%@", __func__, response, connectionError);
                
                if (NSURLErrorTimedOut == connectionError.code) {
                    finishBlock(nil, YYTXHttpRequestTimeout);
                } else {
                    finishBlock(nil, YYTXHttpRequestUnknownError);
                }
            }
        }];
    } else if (YYTXHttpRequestPostAndAsync == mode) {
        [httpRequest asyncPostRequestForURL:[_ServerAddress stringByAppendingPathComponent:DirAdapter] dictionaryParams:[self createRequestParams] requestParams:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] finishBlock:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            if (nil != data) {
                NSLog(@"%s %@", __func__, [NSString stringWithUTF8String:data.bytes]);
                
                NSMutableArray *categoryList = [audioCategory analyzeAudioCategoryData:data];
                
                if (nil != categoryList) {
                    finishBlock(categoryList, YYTXHttpRequestSuccessful);
                } else {
                    finishBlock(categoryList, YYTXHttpRequestUnknownError);
                }
            } else {
                
                NSLog(@"%s response:%@ connectionError:%@", __func__, response, connectionError);
                
                if (NSURLErrorTimedOut == connectionError.code) {
                    finishBlock(nil, YYTXHttpRequestTimeout);
                } else {
                    finishBlock(nil, YYTXHttpRequestUnknownError);
                }
            }
        }];
    } else {
        finishBlock(nil, YYTXHttpRequestParameterError);
    }
}

/*
 * 根据目录ID从服务器请求播放列表, 同步POST或异步POST
 */
- (void)requestAudioListWithCategoryId:(NSString *)Id pageNo:(NSUInteger)page itemsPerpage:(NSUInteger)number requestMode:(YYTXHttpRequestMode)mode requestFinish:(void (^)(NSMutableArray *subCategorys, YYTXHttpRequestReturnCode code))finishBlock {
    NSDictionary *audioListItem = [audioList getAudioListWithCategoryId:Id pageNo:page itemsPerpage:number];
    NSData *data = [self createHttpRequestObject:audioListItem method:ITEMMETHOD_VALUE_GETAUDIOLIST action:nil target:nil];
    
    if (YYTXHttpRequestPostAndSync == mode) {
        [httpRequest syncPostRequestForURL:[_ServerAddress stringByAppendingPathComponent:DirAdapter] dictionaryParams:[self createRequestParams] requestParams:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] finishBlock:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            if (nil != data) {
                NSLog(@"%s %@", __func__, [NSString stringWithUTF8String:data.bytes]);
                
                NSMutableArray *audioArray = [audioList parseAudioList:data];
                
                if (nil != audioArray) {
                    finishBlock(audioArray, YYTXHttpRequestSuccessful);
                } else {
                    finishBlock(audioArray, YYTXHttpRequestUnknownError);
                }
            } else {
                
                NSLog(@"%s response:%@ connectionError:%@", __func__, response, connectionError);
            
                if (NSURLErrorTimedOut == connectionError.code) {
                    finishBlock(nil, YYTXHttpRequestTimeout);
                } else {
                    finishBlock(nil, YYTXHttpRequestUnknownError);
                }
            }
        }];
    } else if (YYTXHttpRequestPostAndAsync == mode) {
        [httpRequest asyncPostRequestForURL:[_ServerAddress stringByAppendingPathComponent:DirAdapter] dictionaryParams:[self createRequestParams] requestParams:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] finishBlock:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            if (nil != data) {
                NSLog(@"%s %@", __func__, [NSString stringWithUTF8String:data.bytes]);
                
                NSMutableArray *audioArray = [audioList parseAudioList:data];
                
                if (nil != audioArray) {
                    finishBlock(audioArray, YYTXHttpRequestSuccessful);
                } else {
                    finishBlock(audioArray, YYTXHttpRequestUnknownError);
                }
            } else {
                
                NSLog(@"%s response:%@ connectionError:%@", __func__, response, connectionError);
                
                if (NSURLErrorTimedOut == connectionError.code) {
                    finishBlock(nil, YYTXHttpRequestTimeout);
                } else {
                    finishBlock(nil, YYTXHttpRequestUnknownError);
                }
            }
        }];
    } else {
        finishBlock(nil, YYTXHttpRequestParameterError);
    }
}

/*
 * 异步请求最新的产品信息
 */
- (void)requestProductInfo {
    NSDictionary *getProductItem = [ProductInfo getAllTheProductsInfo];
    NSData *data = [self createHttpRequestObject:getProductItem method:ITEMMETHOD_VALUE_GETPRODUCTINFO action:nil target:nil];
    
    [httpRequest asyncPostRequestForURL:[_ServerAddress stringByAppendingPathComponent:DirAdapter] dictionaryParams:[self createRequestParams] requestParams:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] finishBlock:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (nil != data) {
            
            NSLog(@"%s %@", __func__, [NSString stringWithUTF8String:data.bytes]);
            
            [ProductInfo parseProductInfo:data];
        } else {
            
            NSLog(@"%s response:%@ connectionError:%@", __func__, response, connectionError);
        }
        
        
    }];
}

- (NSDictionary *)createAnalysisParamsWithdeviceOpenId:(NSString *)openId {
    return @{@"sign":@SIGN, @"appid":@APPID, @"openid":_openId, @"id":@ID, @"yunbaoopenid":openId};
}

/*
 * 请求后台对百度返回的进行语义分析
 */
- (void)requestAnalysis:(NSData *)data deviceOpenId:(NSString *)openId requestFinish:(void (^)(NSDictionary *result))finishBlock {
    NSDictionary *dic = [SemanticAnalysis sendJsonItem:data];
    NSData *reqData = [self createHttpRequestObject:dic method:METHODVALUE_SEMANTICANALYSIS action:nil target:nil];

    [httpRequest syncPostRequestForURL:[_ServerAddress stringByAppendingPathComponent:DirAdapter] dictionaryParams:[self createAnalysisParamsWithdeviceOpenId:openId] requestParams:[[NSString alloc] initWithData:reqData encoding:NSUTF8StringEncoding] finishBlock:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (nil != data) {
            
            NSLog(@"%s %@", __func__, [NSString stringWithUTF8String:data.bytes]);
            
            NSDictionary *root = [ServerServiceManager getRootObjectFromData:data];
#if 0
            if (nil != root) {
                finishBlock([[[YYTXJsonObject alloc] init] getResultValueFromRootObject:root]);
            } else {
                finishBlock(nil);
            }
#else
            finishBlock(root);
#endif
        } else {
            
            NSLog(@"%s response:%@ connectionError:%@", __func__, response, connectionError);
            
            finishBlock(nil);
        }
    }];
}

/* 提交用户反馈 */
- (void)postUserFeedback:(NSDictionary *)feedback requestFinish:(void (^)(NSString *message))finishBlock {
    NSMutableDictionary *dic = [UserFeedback createWithFeedback:feedback];
    NSData *feedbackData = [self createHttpRequestObject:dic method:methodValueSubmitUserFeedback action:nil target:nil];

    [httpRequest syncPostRequestForURL:[_ServerAddress stringByAppendingPathComponent:DirAdapter] dictionaryParams:[self createRequestParams] requestParams:[[NSString alloc] initWithData:feedbackData encoding:NSUTF8StringEncoding] finishBlock:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        NSLog(@"%s response:%@ data:%@ error:%@", __func__, response, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], connectionError);
        NSDictionary *root = [ServerServiceManager getRootObjectFromData:data];
        
        finishBlock([UserFeedback getResponseMessage:root]);
    }];

}

#pragma 在服务器激活、登陆、登出设备

+ (NSDictionary *)createAPPAuthenticationParams:(NSString *)action {
    
    if (nil == action) {
        return nil;
    } else if (action.length <= 0) {
        return nil;
    }
    
    NSString *appVersion = [SystemToolClass appVersion];
    NSString *uuid = [SystemToolClass uuid];
    
    if (nil == appVersion) {
        appVersion = @"appVersion";
    } else if (appVersion.length <= 0) {
        appVersion = @"appVersion";
    }
    
    if (nil == uuid) {
        uuid = @"uuid";
    } else if (uuid.length <= 0) {
        uuid = @"uuid";
    }
    
    return @{@"action":action, @"appid":@APPID, @"sign":@SIGN, @"deviceid":uuid, @"version":appVersion};
}

/*
 * 同步POST的方式在服务器激活本APP
 */
- (void)active {
    NSLog(@"%s", __func__);
    [httpRequest syncPostRequestForURL:[_ServerAddress stringByAppendingPathComponent:DirRegist] dictionaryParams:[ServerServiceManager createAPPAuthenticationParams:@APP_ACTIVE] requestParams:nil finishBlock:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (nil != data) {
            NSLog(@"%s %@", __func__, [NSString stringWithUTF8String:data.bytes]);
            
            NSString *openId = [AppAuthentication getOpenid:data];
            if (nil == openId) {
                /* 激活不成功则从数据库读取之前的已保存的openid */
                _openId = [BoxDatabase openId];
            } else {
                /* 获取成功，则将心的openid更新进数据库 */
                _openId = openId;
                [BoxDatabase updateOpenId:_openId];
            }
        } else {
        
            NSLog(@"%s response:%@ connectionError:%@", __func__, response, connectionError);
            
            _openId = [BoxDatabase openId];
        }
        
    }];
}

/*
 * 同步POST的方式在服务器登陆本APP
 */
- (void)login {
    NSLog(@"%s", __func__);
    
    [httpRequest syncPostRequestForURL:[_ServerAddress stringByAppendingPathComponent:DirRegist] dictionaryParams:[ServerServiceManager createAPPAuthenticationParams:@APP_LOGIN] requestParams:nil finishBlock:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (nil != data) {
            NSLog(@"%s %@", __func__, [NSString stringWithUTF8String:data.bytes]);
            
            NSString *openId = [AppAuthentication getOpenid:data];
            if (nil == openId) {
                /* 注册不成功则需要先激活 */
                [self active];
            } else {
                /* 获取成功，则将心的openid更新进数据库 */
                _openId = openId;
                [BoxDatabase updateOpenId:_openId];
            }
        } else {
            
            NSLog(@"%s response:%@ connectionError:%@", __func__, response, connectionError);
            NSLog(@"%s %ld", __func__, (long)connectionError.code);
            NSLog(@"%s %@", __func__, connectionError.localizedDescription);
            NSLog(@"%s %@", __func__, connectionError.localizedFailureReason);
            NSLog(@"%s %@", __func__, connectionError.localizedRecoverySuggestion);
            NSLog(@"%s %@", __func__, connectionError.localizedRecoveryOptions);
            NSLog(@"%s %@", __func__, connectionError.recoveryAttempter);
            NSLog(@"%s %@", __func__, connectionError.helpAnchor);
            
            [self active];
        }
    }];
}

- (void)logout {
    [httpRequest asyncPostRequestForURL:[_ServerAddress stringByAppendingPathComponent:DirRegist] dictionaryParams:[ServerServiceManager createAPPAuthenticationParams:@APP_LOGOUT] requestParams:nil finishBlock:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        
    }];
}

+ (NSDictionary *)getRootObjectFromData:(NSData *)data {

    if (nil == data) {
        return nil;
    }
    
    NSError *err;
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];

    NSLog(@"%s %@", __func__, err);

    return root;
}

@end
