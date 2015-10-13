//
//  GeneralDataClass.h
//  CloudBox
//
//  Created by TTS on 15-4-23.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

#define USERSET_AUTOMATICPOSITIONING        2
#define USERSET_MANUALSET                   1
#define USERSET_GETFROMSERVER               0

#define MAXNICKNAMELENGTH                   10

@interface GeneralDataClass : NSObject
@property (nonatomic, retain) NSString *nickName; // 设备的昵称
@property (nonatomic, retain) NSString *voiceMan;
@property (nonatomic, assign) NSUInteger userSet;
@property (nonatomic, retain) NSString *province;
@property (nonatomic, retain) NSString *city;
@property (nonatomic) BOOL logfilter;
@property (nonatomic, retain) NSString *openid;

@property (nonatomic, retain) NSString *deviceId; // 设备mac地址，测试用

- (NSDictionary *)modify;

- (BOOL)parseGeneral:(NSDictionary *)generalItem;

@end
