//
//  UserFeedback.m
//  CloudBox
//
//  Created by TTS on 15/8/17.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "UserFeedback.h"
#import "YYTXJsonObject.h"
#import "SystemToolClass.h"

#define SUBMITSUCCESSFUL        0

NSString *const methodValueSubmitUserFeedback = @"submitUserFeedback";

NSString *const jsonItemKeyContactWay = @"contractway";
NSString *const jsonItemKeyContent = @"content";
NSString *const jsonItemKeySoftHartType = @"soft_hard_type";
NSString *const jsonItemKeyFeedbackType = @"feedback_type";
NSString *const jsonItemKeyPhoneModel = @"phone_model";
NSString *const jsonItemKeyPhoneOs = @"phone_os";
NSString *const jsonItemKeyAppVersion = @"app_version";
NSString *const jsonItemKeyYunBaoVersion = @"yunbao_version";
NSString *const jsonItemKeyYunBaoBatchId = @"yunbao_batchid";
NSString *const jsonItemKeyYunBaoConfigId = @"yunbao_configid";
NSString *const jsonItemKeyYunBaoOpenId = @"yunbao_openid";

@implementation UserFeedback

+ (NSMutableDictionary *)createWithFeedback:(NSDictionary *)feedback {
    
    if (nil == feedback) {
        return nil;
    }
    
    NSString *phoneModel = [SystemToolClass getCurrentDeviceModel];
    NSString *phoneOs = [SystemToolClass IOSVersion];
    NSString *appVersion = [SystemToolClass appVersion];

    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:feedback];
    [dic addEntriesFromDictionary:@{jsonItemKeyPhoneModel:phoneModel}];
    [dic addEntriesFromDictionary:@{jsonItemKeyPhoneOs:phoneOs}];
    [dic addEntriesFromDictionary:@{jsonItemKeyAppVersion:appVersion}];
    
    NSLog(@"%s dic:%@", __func__, [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]);
    
    return dic;
}

+ (NSString *)getResponseMessage:(NSDictionary *)root {
    if (nil == root) {
        return nil;
    }
    YYTXJsonObject *object = [[YYTXJsonObject alloc] init];
    NSDictionary *errItem = [object getErrorValueFromRootObject:root];
    
    if (nil == errItem) {
        return nil;
    }
    
    NSNumber *codeItem = [object getCodeValueFromErrorObject:errItem];
    NSString *message = [object getMessageValueFromErrorObject:errItem];
    if (nil != codeItem) {
        if (SUBMITSUCCESSFUL == codeItem.integerValue) {
            return nil;
        } else {
            if (nil != message) {
                return message;
            }
        }
    } else {
        return NSLocalizedStringFromTable(@"unknownError", @"hint", nil);
    }
    
    return nil;
}

@end
