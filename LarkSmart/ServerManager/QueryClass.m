//
//  QueryClass.m
//  CloudBox
//
//  Created by TTS on 15-4-24.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "QueryClass.h"
#import "YYTXJsonObject.h"

#define JSONITEM_QUERY_BUYURL       @"buy_url"
#define JSONITEM_QUERY_HELPURL      @"help_url"
#define JSONITEM_QUERY_PRODUCTURL   @"product_url"
#define JSONITEM_QUERY_XMLYHELPURL  @"xmly_help_url"
#define JSONITEM_QUERY_WEIXINURL    @"weinxin_url"
#define JSONITEM_QUERY_CONFIG       @"config"

@implementation QueryClass

+ (QueryClass *)parseQuery:(NSData *)data {
    if (nil == data) {
        return nil;
    }
    
    NSError *err;
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (nil == root) {
        NSLog(@"%s %@", __func__, err);
        return nil;
    }
    
    NSDictionary *resultItem = [[[YYTXJsonObject alloc] init] getResultValueFromRootObject:root];
    if (nil == resultItem) {
        return nil;
    }
    
    NSDictionary *configItem = [resultItem objectForKey:JSONITEM_QUERY_CONFIG];
    if (nil == configItem) {
        return nil;
    }
    
    QueryClass *query = [[QueryClass alloc] init];
    
    NSString *buyUrlItem = [configItem objectForKey:JSONITEM_QUERY_BUYURL];
    if (nil != buyUrlItem) {
        query.urlBuy = buyUrlItem;
    }
    
    NSString *helpUrlItem = [configItem objectForKey:JSONITEM_QUERY_HELPURL];
    if (nil != helpUrlItem) {
        query.urlHelp = helpUrlItem;
    }
    
    NSString *productUrlItem = [configItem objectForKey:JSONITEM_QUERY_PRODUCTURL];
    if (nil != productUrlItem) {
        query.urlProduct = productUrlItem;
    }
    
    NSString *xmlyHelpUrlItem = [configItem objectForKey:JSONITEM_QUERY_XMLYHELPURL];
    if (nil != xmlyHelpUrlItem) {
        query.xmlyHelpUrl = xmlyHelpUrlItem;
    }
    
    NSString *weiXinUrlItem = [configItem objectForKey:JSONITEM_QUERY_WEIXINURL];
    if (nil != weiXinUrlItem) {
        query.weiXinUrl = weiXinUrlItem;
    }
    
    return query;
}

@end
