//
//  Parameter1Class.h
//  CloudBox
//
//  Created by TTS on 15/7/20.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Parameter1Class : NSObject
@property (nonatomic, assign) NSInteger dayInitVolume;
@property (nonatomic, assign) NSInteger loopPlayTime;
@property (nonatomic, assign) NSInteger chime;
@property (nonatomic, assign) NSInteger halfChime;
@property (nonatomic, retain) NSString *chimeStart;
@property (nonatomic, retain) NSString *chimeEnd;

@property (nonatomic, retain) NSArray *playTime;

- (NSInteger)getTimeAccrodingToTimeTitle:(NSString *)title;
- (NSString *)getTimeTitleAccrodingToTime:(NSInteger)time;

/** 解析其它参数设置，如播放时长、整点和半点报时 */
- (BOOL)parseParameter1:(NSDictionary *)parameter1Item;

- (NSDictionary *)modify;

@end
