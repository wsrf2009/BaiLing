//
//  NightControl.h
//  CloudBox
//
//  Created by TTS on 15/7/18.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PROMPT_ISOPEN          1
#define PROMPT_ISCLOSE         0

#define NIGHTCONTROL_ISOPEN         1
#define NIGHTCONTROL_ISCLOSE        0

@interface UndisturbedControl : NSObject
@property (nonatomic, assign) NSInteger undisturbedOpen;
@property (nonatomic, assign) NSInteger undisturbedOpenPrompt;
@property (nonatomic, retain) NSString *undisturbedTimeStart;
@property (nonatomic, retain) NSString *undisturbedTimeEnd;
@property (nonatomic, assign) NSInteger undisturbedInitVolume;

@property (nonatomic, retain) NSArray *nightVolumes;

- (NSInteger)getIndexAccrodingToVolumeTitle:(NSString *)title;
- (NSString *)getVolumeTitleAccrodingToIndex:(NSInteger)index;

/** 解析勿扰控制 */
- (BOOL)parseUndisturbedControl:(NSDictionary *)undisturbedControlItem;

- (NSDictionary *)modify;

@end
