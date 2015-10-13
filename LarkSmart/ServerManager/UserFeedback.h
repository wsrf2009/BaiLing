//
//  UserFeedback.h
//  CloudBox
//
//  Created by TTS on 15/8/17.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const methodValueSubmitUserFeedback;

extern NSString *const jsonItemKeyContactWay;
extern NSString *const jsonItemKeyContent;
extern NSString *const jsonItemKeySoftHartType;
extern NSString *const jsonItemKeyFeedbackType;
extern NSString *const jsonItemKeyYunBaoVersion;
extern NSString *const jsonItemKeyYunBaoBatchId;
extern NSString *const jsonItemKeyYunBaoConfigId;
extern NSString *const jsonItemKeyYunBaoOpenId;

@interface UserFeedback : NSObject

+ (NSMutableDictionary *)createWithFeedback:(NSDictionary *)feedback;
+ (NSString *)getResponseMessage:(NSDictionary *)root;

@end
