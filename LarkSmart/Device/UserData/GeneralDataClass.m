//
//  GeneralDataClass.m
//  CloudBox
//
//  Created by TTS on 15-4-23.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "GeneralDataClass.h"

#define JSONITEM_GENERAL_NICKNAME           @"nickname"
#define JSONITEM_GENERAL_VOICEMAN           @"voiceman"
#define JSONITEM_GENERAL_USERSET            @"userSet"
#define JSONITEM_GENERAL_PROVINCE           @"province"
#define JSONITEM_GENERAL_CITY               @"city"
#define JSONITEM_GENERAL_LOGFILTER          @"logfilter"
#define JSONITEM_GENERAL_OPENID             @"openid"

#define JSONITEM_GENERAL_DEVICEID           @"deviceid" // 设备mac地址，测试用

@implementation GeneralDataClass

- (NSDictionary *)modify {
    NSDictionary *general = [NSDictionary dictionaryWithObjectsAndKeys: _nickName, JSONITEM_GENERAL_NICKNAME, _voiceMan, JSONITEM_GENERAL_VOICEMAN, [NSNumber numberWithInteger:_userSet], JSONITEM_GENERAL_USERSET, _province, JSONITEM_GENERAL_PROVINCE, _city, JSONITEM_GENERAL_CITY, [NSNumber numberWithInteger:_logfilter], JSONITEM_GENERAL_LOGFILTER, nil];
    return general;
}

- (BOOL)parseGeneral:(NSDictionary *)generalItem {
    
    NSLog(@"%s", __func__);
    
    if (nil == generalItem) {
        return NO;
    }
    
    NSString *nickNameItem = [generalItem objectForKey:JSONITEM_GENERAL_NICKNAME];
    if(nil != nickNameItem) {
        _nickName = nickNameItem;
        NSLog(@"%s nickName:%@", __func__, _nickName);
    }
    
    NSString *voiceManItem = [generalItem objectForKey:JSONITEM_GENERAL_VOICEMAN];
    if(nil != voiceManItem) {
        _voiceMan = voiceManItem;
    }
    
    NSNumber *userSetItem = [generalItem objectForKey:JSONITEM_GENERAL_USERSET];
    if(nil != userSetItem) {
        _userSet = [userSetItem integerValue];
    }
    
    NSString *provinceItem = [generalItem objectForKey:JSONITEM_GENERAL_PROVINCE];
    if(nil != provinceItem) {
        _province = provinceItem;
    }
    
    NSString *cityItem = [generalItem objectForKey:JSONITEM_GENERAL_CITY];
    if(nil != cityItem) {
        _city = cityItem;
    }
    
    NSNumber *logfilterItem = [generalItem objectForKey:JSONITEM_GENERAL_LOGFILTER];
    if(nil != logfilterItem) {
        _logfilter = [logfilterItem integerValue];
    }
    
    NSString *openIdItem = [generalItem objectForKey:JSONITEM_GENERAL_OPENID];
    if (nil != openIdItem) {
        _openid = openIdItem;
    }
    
    _deviceId = [generalItem objectForKey:JSONITEM_GENERAL_DEVICEID];
    
    return YES;
}


@end
