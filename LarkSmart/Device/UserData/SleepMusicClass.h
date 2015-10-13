//
//  AlbumClass.h
//  CloudBox
//
//  Created by TTS on 15-4-22.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SleepMusicClass : NSObject

@property (nonatomic, assign) NSInteger isValid;
@property (nonatomic, retain) NSString *categoryId;
@property (nonatomic, assign) NSUInteger playTime;
@property (nonatomic, assign) NSUInteger willDo;

@property (nonatomic, retain) NSArray *timeList;

- (NSString *)getMinuteLableAccrodingToSecond:(NSUInteger)second;
- (BOOL)parseSleepMusic:(NSDictionary *)sleepMusicItem;
- (NSDictionary *)modify;

@end

@interface sleepMusicTime : NSObject

@property (nonatomic, retain) NSString *miunteLable;
@property (nonatomic, assign) NSUInteger seconds;

@end

