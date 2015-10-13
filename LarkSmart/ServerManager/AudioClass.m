//
//  AudioClass.m
//  CloudBox
//
//  Created by TTS on 15-5-12.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "AudioClass.h"

#define JSONITEM_AUDIO_AUDIOID          @"audioid"
#define JSONITEM_AUDIO_TITLE            @"title"
#define JSONITEM_AUDIO_ICON             @"icon"
#define JSONITEM_AUDIO_URL              @"url"
#define JSONITEM_AUDIO_DURATION         @"duration"

@implementation AudioClass

+ (AudioClass *)parseAudio:(NSDictionary *)audioItem {
    
    if (nil == audioItem) {
        return nil;
    }
    
    AudioClass *audio = [[AudioClass alloc] init];
    
    NSString *audioIdItem = [audioItem objectForKey:JSONITEM_AUDIO_AUDIOID];
    if (nil != audioIdItem) {
        audio.audioId = audioIdItem;
    }
    
    NSString *titleItem = [audioItem objectForKey:JSONITEM_AUDIO_TITLE];
    if (nil != titleItem) {
        audio.title = titleItem;
    }
    
    NSString *iconItem = [audioItem objectForKey:JSONITEM_AUDIO_ICON];
    if (NULL != iconItem) {
        audio.icon = iconItem;
    }
    
    NSString *urlItem = [audioItem objectForKey:JSONITEM_AUDIO_URL];
    if (nil != urlItem) {
        audio.url = urlItem;
    }
    
    NSNumber *durationItem = [audioItem objectForKey:JSONITEM_AUDIO_DURATION];
    if (NULL != durationItem) {
        audio.duration = [durationItem unsignedIntegerValue];
    }
    
    return audio;
}

@end
