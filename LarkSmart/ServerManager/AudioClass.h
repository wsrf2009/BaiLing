//
//  AudioClass.h
//  CloudBox
//
//  Created by TTS on 15-5-12.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

#define JSONITEM_AUDIOLIST_AUDIO        @"audio"

@interface AudioClass : NSObject
@property (nonatomic, retain) NSString *audioId;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *icon;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, assign) NSUInteger duration;

/** 解析AudioClass */
+ (AudioClass *)parseAudio:(NSDictionary *)audioItem;

@end
