//
//  MutipleMediaClass.h
//  CloudBox
//
//  Created by TTS on 15-4-23.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ITEMMETHOD_VALUE_MEDIAPLAY          @"mediaPlay"
#define ITEMMETHOD_VALUE_MEDIASTOP          @"mediaStop"
#define ITEMMETHOD_VALUE_MEDIAPAUSE         @"mediaPause"
#define ITEMMETHOD_VALUE_MEDIARESUME        @"mediaResume"
#define ITEMMETHOD_VALUE_MEDIAPREVIOUS      @"mediaPrevious"
#define ITEMMETHOD_VALUE_MEDIANEXT          @"mediaNext"
#define ITEMMETHOD_VALUE_GETVOLUME          @"getVolume"
#define ITEMMETHOD_VALUE_SETVOLUME          @"setVolume"
#define ITEMMETHOD_VALUE_SETVOLUMEDOWN      @"setVolumeDown"
#define ITEMMETHOD_VALUE_SETVOLUMEUP        @"setVolumeUp"

//const NSString *itemMethodValueAudioPlayGetVolume = @"getVolume";
//const NSString *itemMethodValueAudioPlaySetVolume = @"setVolume";

#define JSONITEM_AUDIOPLAY_PLAYLIST         @"playlist"

// 终端文件ID
extern NSString *const devicePromptFileIdIMHere; // 我在这
extern NSString *const devicePromptFileIdConnected; // 已连接
extern NSString *const devicePromptFileIdModifySuccessful; // 修改成功
extern NSString *const devicePromptFileIdModifyFailed; // 修改失败

#define JSONITEM_AUDIOPLAY_OPTIONPLAY         @"optionPlay"

/** 播放类型 */
typedef enum {
    YYTXDevicePlayTypeTTS = 0,      // 0  TTS
    YYTXDevicePlayTypeLocal,        // 1  本地资源
    YYTXDevicePlayTypeNet,      // 2  网络资源
    YYTXDevicePlayTypeLocalPreset,      // 3  本地预设ID
    YYTXDevicePlayTypeLocalNeedDealwith     // 4  需要处理的TTS
} YYTXDevicePlayType;

@interface AudioPlay : NSObject
@property (nonatomic, assign) NSInteger curVolume;
@property (nonatomic, assign) NSInteger maxVolume;

- (NSArray *)playAudioWithUrl:(NSString *)url;
- (NSArray *)playAudioWithFilePath:(NSString *)fPath;
- (NSArray *)playAudioWithFileId:(NSString *)fId;
- (NSDictionary *)whenOperationSuccessfulPlay:(NSString *)string playType:(YYTXDevicePlayType)type;
- (NSDictionary *)whenOperationFailedPlay:(NSString *)string playType:(YYTXDevicePlayType)type;
- (NSArray *)playTtsWhenFailed:(NSString *)failed playTtsWhenSuccessful:(NSString *)successful;
- (NSNull *)stop;
- (NSNull *)pause;
- (NSNull *)resume;
- (NSNull *)previous;
- (NSNull *)next;
- (NSNull *)getVolume;
- (NSNumber *)setVolume:(NSInteger)volume;
- (NSNull *)setVolumeDown;
- (NSNull *)setVolumeUp;
- (NSString *)getPlayContent:(NSDictionary *)paramItem;
- (BOOL)parseVolume:(NSDictionary *)resultItem;

@end
