//
//  BirthdayClass.h
//  CloudBox
//
//  Created by TTS on 15-4-8.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

// 日期类型 date_formate
#define DATETYPE_LUNAR                  1 // 农历
#define DATETYPE_SOLAR                  0 // 阳历

#define MAXNAMELENGTH   10

@interface BirthdayClass : NSObject

@property (nonatomic, retain) NSMutableArray *list;
@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, retain) NSString *who;
@property (nonatomic, assign) NSInteger date_type;
@property (nonatomic, retain) NSString *date_value;
@property (nonatomic, retain) NSString *congratulations;

- (instancetype)initWithBirtdayList:(NSMutableArray *)birthdayList;
+ (NSInteger)getFreeId:(NSMutableArray *)alarmList;
+ (NSArray *)modifyBirthday:(BirthdayClass *)birthday;
+ (NSArray *)deleteBirthdayWithBirthdayId:(NSInteger)birthdayId;

+ (BOOL)parseBirthdays:(NSArray *)birthdaysItem birthdayList:(NSMutableArray *)list;

@end
