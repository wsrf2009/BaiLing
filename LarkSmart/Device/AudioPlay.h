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

/** 
 播放一个网络资源
 @param url 资源的网络地址
 */
- (NSArray *)playAudioWithUrl:(NSString *)url;

/** 
 播放设备中预存的文件
 @param fPath 文件的路径，如@"太阳公公"、@"懒猪起床"
 */
- (NSArray *)playAudioWithFilePath:(NSString *)fPath;

/** 
 播放设备中预存文件的ID
 @param fId 文件的ID，如@"10302"、@"10301"
 */
- (NSArray *)playAudioWithFileId:(NSString *)fId;

/** 
 创建optionplay中操作成功时设备要播放的内容 
 @param string 要播放的内容
 @param type string的类型
 */
- (NSDictionary *)whenOperationSuccessfulPlay:(NSString *)string playType:(YYTXDevicePlayType)type;

/** 
 创建optionplay中操作失败时设备要播放的内容 
 @param string 要播放的内容
 @param type string的类型
 */
- (NSDictionary *)whenOperationFailedPlay:(NSString *)string playType:(YYTXDevicePlayType)type;

/** 
 optionplay中操作成功和操作失败时播放什么样的TTS文本 
 @param failed，操作失败时播放的TTS文本
 @param successful，操作成功时播放的TTS文本
 */
- (NSArray *)playTtsWhenFailed:(NSString *)failed playTtsWhenSuccessful:(NSString *)successful;

/** 让硬件设备停止播放 */
- (NSNull *)stop;

/** 让硬件设备暂停播放 */
- (NSNull *)pause;

/** 让硬件设备恢复播放 */
- (NSNull *)resume;

/** 播放前一首 */
- (NSNull *)previous;

/** 播放下一曲 */
- (NSNull *)next;

/** 获取设备的音量，硬件设备还不支持，尚不可用 */
- (NSNull *)getVolume;

/** 设置设备的音量，硬件设备还不支持，尚不可用 */
- (NSNumber *)setVolume:(NSInteger)volume;

/** 减小设备的音量 */
- (NSNull *)setVolumeDown;

/** 增加设备的音量 */
- (NSNull *)setVolumeUp;

/** 从paramItem中获取播放的内容 */
- (NSString *)getPlayContent:(NSDictionary *)paramItem;

/** 从resultItem中解析出设备返回的音量值 */
- (BOOL)parseVolume:(NSDictionary *)resultItem;

@end
