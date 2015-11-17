//
//  MainViewController.h
//  RawAudioDataPlayer
//
//  Created by SamYou on 12-8-18.
//  Copyright (c) 2012年 SamYou. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AudioQueuePlayerDelegate <NSObject>

- (void)audioQueuePlayFinished;

@end

@interface AudioQueuePlayer : NSObject
@property (nonatomic, retain) id <AudioQueuePlayerDelegate> delegate;

/** 
 初始化播放器
 @param data为需要播放的数据
 */
- (instancetype)initWithData:(NSData *)data delegate:(id)delegate;

/** 开始播放 */
- (void)play;

/** 停止播放 */
- (void)stop;

@end
