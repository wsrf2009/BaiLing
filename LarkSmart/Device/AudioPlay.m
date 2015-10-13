//
//  MutipleMediaClass.m
//  CloudBox
//
//  Created by TTS on 15-4-23.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "AudioPlay.h"

//#define ITEMMETHOD_VALUE_MEDIAPREVIOUS      @"mediaPrevious"
//#define ITEMMETHOD_VALUE_MEDIANEXT          @"mediaNext"
//#define ITEMMETHOD_VALUE_MEDIAMUTE          @"mediaMute"
//#define ITEMMETHOD_VALUE_MEDIASEEK          @"mediaSeek"
//#define ITEMMETHOD_VALUE_SETVOLUMEUP        @"setVolumeUp"
//#define ITEMMETHOD_VALUE_SETVOLUMEDOWN      @"setVolumeDown"
//#define ITEMMETHOD_VALUE_GETVOLUME          @"getVolume"
//#define ITEMMETHOD_VALUE_SETVOLUME          @"setVolume"

// 输入参数 mediaPlay
#define JSONITEM_AUDIOPLAY_PLAYITEM         @"playitem"
#define JSONITEM_AUDIOPLAY_PLAYOBJECT       @"playobject"
#define JSONITEM_AUDIOPLAY_PRIORITY         @"priority"  // 可选，播放优先级
#define JSONITEM_AUDIOPLAY_TOHISTORY        @"toHistory" // 可选，本次播放是否追加到历史记录

// 操作状态取值 JSONITEM_STATUS
#define JSONITEM_STATUS                 @"status"
#define ITEMVALUE_STATUS_FAIL           0
#define ITEMVALUE_STATUS_SUCCESSFUL     1

// playobject
#define JSONITEM_AUDIOPLAY_TYPE           @"type"
#define JSONITEM_AUDIOPLAY_CONTENT        @"content"

NSString *const devicePromptFileIdIMHere = @"10301"; // 我在这
NSString *const devicePromptFileIdConnected = @"10302"; // 已连接
NSString *const devicePromptFileIdModifySuccessful = @"40102"; // 修改成功
NSString *const devicePromptFileIdModifyFailed = @"40107"; // 修改失败



NSString *jsonItemAudioPlayCurVol = @"curVol";
NSString *jsonItemAudioPlayMaxVol = @"maxVol";

@implementation AudioPlay

- (NSArray *)playAudioWithUrl:(NSString *)url {
    NSDictionary *playItemObject = @{JSONITEM_AUDIOPLAY_CONTENT:url, JSONITEM_AUDIOPLAY_TYPE:[NSNumber numberWithInteger: YYTXDevicePlayTypeNet]};
    NSArray *playItem = @[playItemObject];
    NSDictionary *playListObject = @{JSONITEM_AUDIOPLAY_PLAYITEM:playItem};
    NSArray *playList = @[playListObject];
    
    return playList;
}

- (NSArray *)playAudioWithFilePath:(NSString *)fPath {
    NSDictionary *playItemObject = @{JSONITEM_AUDIOPLAY_CONTENT:fPath, JSONITEM_AUDIOPLAY_TYPE:[NSNumber numberWithInteger: YYTXDevicePlayTypeLocal]};
    NSArray *playItem = @[playItemObject];
    NSDictionary *playListObject = @{JSONITEM_AUDIOPLAY_PLAYITEM:playItem};
    NSArray *playList = @[playListObject];
    
    return playList;
}

- (NSArray *)playAudioWithFileId:(NSString *)fId {
    NSDictionary *playItemObject = @{JSONITEM_AUDIOPLAY_CONTENT:fId, JSONITEM_AUDIOPLAY_TYPE:[NSNumber numberWithInteger:YYTXDevicePlayTypeLocalPreset]};
    NSArray *playItem = @[playItemObject];
    NSDictionary *playListObject = @{JSONITEM_AUDIOPLAY_PLAYITEM:playItem};
    NSArray *playList = @[playListObject];
    
    return playList;
}

- (NSDictionary *)createPlayObjectWithContent:(NSString *)content andType:(NSInteger)type {
    if (nil == content) {
        content = @"";
    }
    
    return @{JSONITEM_AUDIOPLAY_TYPE:[NSNumber numberWithInteger:type], JSONITEM_AUDIOPLAY_CONTENT:content};
}

- (NSDictionary *)createObjectWithPlayObject:(NSDictionary *)playObject andStatus:(NSInteger)status {
    if (nil == playObject) {
        return nil;
    }
    
    return @{JSONITEM_STATUS:[NSNumber numberWithInteger:status], JSONITEM_AUDIOPLAY_PLAYOBJECT:playObject};
}

- (NSDictionary *)whenOperationSuccessfulPlay:(NSString *)string playType:(YYTXDevicePlayType)type {
    NSDictionary *successPlayObject = [self createPlayObjectWithContent:string andType:type];
    NSDictionary *successfulPlay = [self createObjectWithPlayObject:successPlayObject andStatus:ITEMVALUE_STATUS_SUCCESSFUL];
    
    return successfulPlay;
}

- (NSDictionary *)whenOperationFailedPlay:(NSString *)string playType:(YYTXDevicePlayType)type {
    NSDictionary *failPlayObject = [self createPlayObjectWithContent:string andType:type];
    NSDictionary *failPlay = [self createObjectWithPlayObject:failPlayObject andStatus:ITEMVALUE_STATUS_FAIL];
    
    return failPlay;
}

- (NSArray *)playTtsWhenFailed:(NSString *)failed playTtsWhenSuccessful:(NSString *)successful {
    
    if (nil == failed) {
        failed = @"";
    }
    
    if (nil == successful) {
        successful = @"";
    }
    
    NSDictionary *failPlayObject = [self createPlayObjectWithContent:failed andType:YYTXDevicePlayTypeTTS];
    NSDictionary *failPlay = [self createObjectWithPlayObject:failPlayObject andStatus:ITEMVALUE_STATUS_FAIL];
    
    NSDictionary *successPlayObject = [self createPlayObjectWithContent:successful andType:YYTXDevicePlayTypeTTS];
    NSDictionary *successfulPlay = [self createObjectWithPlayObject:successPlayObject andStatus:ITEMVALUE_STATUS_SUCCESSFUL];
    
    return @[failPlay, successfulPlay];
}

- (NSNull *)stop {
    
    return [[NSNull alloc] init];
}

- (NSNull *)pause {
    
    return [[NSNull alloc] init];
}

- (NSNull *)resume {
    
    return [[NSNull alloc] init];
}

- (NSNull *)previous {
    
    return [[NSNull alloc] init];
}

- (NSNull *)next {

    return [[NSNull alloc] init];
}

- (NSNull *)getVolume {

    return [[NSNull alloc] init];
}

- (NSNumber *)setVolume:(NSInteger)volume {

    return [NSNumber numberWithInteger:volume];
}

- (NSNull *)setVolumeDown {

    return [[NSNull alloc] init];
}

- (NSNull *)setVolumeUp {
    
    return [[NSNull alloc] init];
}

- (NSString *)getPlayContent:(NSDictionary *)paramItem {
    
    if (nil == paramItem) {
        return nil;
    }
    
    NSArray *playListItems = [paramItem objectForKey:JSONITEM_AUDIOPLAY_PLAYLIST];
    if (nil != playListItems) {
        for (NSDictionary *playListItem in playListItems) {
            NSArray *playItems = [playListItem objectForKey:JSONITEM_AUDIOPLAY_PLAYITEM];
            if (nil != playItems) {
                for (NSDictionary *playItem in playItems) {
                    NSNumber *typeItem = [playItem objectForKey:JSONITEM_AUDIOPLAY_TYPE];
                    if (nil != typeItem) {
                        if ([typeItem integerValue] == YYTXDevicePlayTypeTTS) {
                            NSString *contentItem = [playItem objectForKey:JSONITEM_AUDIOPLAY_CONTENT];
                            return contentItem;
                        }
                    }
                }
            }
        }
    }
    
    return nil;
}

- (BOOL)parseVolume:(NSDictionary *)resultItem {
    
    if (nil == resultItem) {
        return  NO;
    }
    
    NSNumber *curVolItem = [resultItem objectForKey:jsonItemAudioPlayCurVol];
    if (nil != curVolItem) {
        _curVolume = [curVolItem integerValue];
    } else {
        return NO;
    }
    
    NSNumber *maxVolItem = [resultItem objectForKey:jsonItemAudioPlayMaxVol];
    if (nil != maxVolItem) {
        _maxVolume = [maxVolItem integerValue];
    } else {
        return NO;
    }
    
    return YES;
}

@end
