//
//  AppAuthentication.m
//  CloudBox
//
//  Created by TTS on 15/6/5.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "AppAuthentication.h"
#import "SystemToolClass.h"
#import "YYTXJsonObject.h"

#define JSONITEM_APPAUTHENTICATION_OPENID       @"openid"

@implementation AppAuthentication

+ (NSString *)getOpenid:(NSData *)data {
    if (nil == data) {
        return nil;
    }
    
    NSError *err;
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err]; // NSData解析为Json格式的NSDictionary
    if (nil == root) {
        NSLog(@"%s %@", __func__, err);
        return nil;
    }
    
    NSDictionary *resultItem = [[[YYTXJsonObject alloc] init] getResultValueFromRootObject:root];
    if (nil != resultItem) {
        NSString *openIdItem = [resultItem objectForKey:JSONITEM_APPAUTHENTICATION_OPENID];
        
            return openIdItem;
    }
    
    return nil;
}

@end
