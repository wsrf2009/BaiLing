//
//  RemindClass.h
//  CloudBox
//
//  Created by TTS on 15-4-8.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAXCONTENTLENGTH    40

@interface RemindClass : NSObject

@property (nonatomic, retain) NSMutableArray *list;
@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, assign) NSInteger is_valid;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSString *content;

- (instancetype)initWithRemindList:(NSMutableArray *)remindList;
+ (NSInteger)getFreeId:(NSMutableArray *)alarmList;
+ (NSArray *)modifyRemind:(RemindClass *)remind;
+ (NSArray *)deleteRemindWithRemindId:(NSInteger)remindId;

/** 解析备忘信息，将结果存放于list中 */
+ (BOOL)parseReminds:(NSArray *)remindsItem remindList:(NSMutableArray *)list;

@end
