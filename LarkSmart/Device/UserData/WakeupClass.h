//
//  WakeupClass.h
//  CloudBox
//
//  Created by TTS on 15-4-16.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

// 唤醒开关 open_wakeup
//#define WAKEUP_OPEN             1
//#define WAKEUP_CLOSE            0
// 唤醒提示音开关 open_prompt
#define WAKEUP_TONE_OPEN        1
#define WAKEUP_TONE_CLOSE       0
// 唤醒时间段限制开关 time_limit
//#define WAKEUP_TIMELIMIT_OPEN   1
//#define WAKEUP_TIMELIMIT_CLOSE  0

@interface WakeupClass : NSObject

@property (nonatomic, assign) NSInteger openPrompt;
@property (nonatomic, retain) NSString *name;
//@property (nonatomic, assign) NSInteger promptTimeLimit;
//@property (nonatomic, retain) NSString *promptTimeStart;
//@property (nonatomic, retain) NSString *promptTimeEnd;

@property (nonatomic, retain) NSArray *arrayName;

- (BOOL)parseWakeup:(NSDictionary *)wakeupItem;
- (NSDictionary *)modify;

@end

@interface WakeupName : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, assign) BOOL highlight;

@end
