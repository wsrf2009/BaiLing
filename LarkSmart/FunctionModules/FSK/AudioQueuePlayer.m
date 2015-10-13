//
//  MainViewController.m
//  RawAudioDataPlayer
//
//  Created by SamYou on 12-8-18.
//  Copyright (c) 2012年 SamYou. All rights reserved.
//

#import "AudioQueuePlayer.h"
#import "WifiConfigClass.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define QUEUE_BUFFER_SIZE 4 //队列缓冲个数
#define EVERY_READ_LENGTH 1000 //每次从文件读取的长度
#define MIN_SIZE_PER_FRAME 2000 //每侦最小数据长度

@interface AudioQueuePlayer ()
{
    AudioQueueBufferRef audioQueueBuffers[QUEUE_BUFFER_SIZE];//音频缓存
    AudioStreamBasicDescription audioDescription; //音频参数
    AudioQueueRef audioQueue; //音频播放队列
    NSLock *synlock ; //同步控制
    NSUInteger readLength; // 已读长度
    NSData *stream;
}

@end

@implementation AudioQueuePlayer

- (instancetype)initWithData:(NSData *)data delegate:(id)delegate {
    
    if (nil == data || data.length <= 0) {
        return nil;
    }
    
    self = [super init];
    if (nil != self) {
        stream = data;
        _delegate = delegate;
    }
    
    return self;
}

- (void)play {
    
    [self initAudio];
    [self initAudioRoute];
    
    readLength = 0;
    
    AudioQueueStart(audioQueue, NULL);
    for (int i=0; i<QUEUE_BUFFER_SIZE; i++) {
        [self readPCMAndPlay:audioQueue buffer:audioQueueBuffers[i]];
    }
}

- (void)stop {
    AudioQueueStop(audioQueue, YES);
}

- (void)initAudioRoute {
    //初始化播放器的时候如下设置
 //   UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;

//    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    
//    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
//    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride), &audioRouteOverride);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *error;
    BOOL success = [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    if(!success)
    {
        NSLog(@"error doing outputaudioportoverride - %@", [error localizedDescription]);
    }
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
}

#pragma mark player call back
/*
 试了下其实可以不用静态函数，但是c写法的函数内是无法调用[self ***]这种格式的写法，所以还是用静态函数通过void *input来获取原类指针
 这个回调存在的意义是为了重用缓冲buffer区，当通过AudioQueueEnqueueBuffer(outQ, outQB, 0, NULL);函数放入queue里面的音频文件播放完以后，通过这个函数通知
 调用者，这样可以重新再使用回调传回的AudioQueueBufferRef
 */
static void AudioPlayerAQInputCallback(void *input, AudioQueueRef outQ, AudioQueueBufferRef outQB) {
//    NSLog(@"%s", __func__);
    AudioQueuePlayer *mainviewcontroller = (__bridge AudioQueuePlayer *)input;
//    [mainviewcontroller checkUsedQueueBuffer:outQB];
    [mainviewcontroller readPCMAndPlay:outQ buffer:outQB];
}

- (void) initAudio {
//    NSLog(@"%s", __func__);
    ///设置音频参数
    audioDescription.mSampleRate = 16000;//采样率
	audioDescription.mFormatID = kAudioFormatLinearPCM;
    audioDescription.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger;//|kAudioFormatFlagIsPacked;
    audioDescription.mChannelsPerFrame = 1;///单声道
    audioDescription.mFramesPerPacket = 1;//每一个packet一侦数据
    audioDescription.mBitsPerChannel = 16;//每个采样点16bit量化
    audioDescription.mBytesPerFrame = (audioDescription.mBitsPerChannel/8) * audioDescription.mChannelsPerFrame;
    audioDescription.mBytesPerPacket = audioDescription.mBytesPerFrame ;
    
    //创建一个新的从audioqueue到硬件层的通道
    AudioQueueNewOutput(&audioDescription, AudioPlayerAQInputCallback, (__bridge void *)(self), nil, nil, 0, &audioQueue);//使用player的内部线程播
    
	//添加buffer区
    for(int i=0; i<QUEUE_BUFFER_SIZE; i++) {
        AudioQueueAllocateBuffer(audioQueue, MIN_SIZE_PER_FRAME, &audioQueueBuffers[i]);///创建buffer区，MIN_SIZE_PER_FRAME为每一侦所需要的最小的大小，该大小应该比每次往buffer里写的最大的一次还大
    }
    
    //设置音量
    Float32 gain=1.0;
    AudioQueueSetParameter(audioQueue, kAudioQueueParam_Volume, gain);
    
    synlock = [[NSLock alloc] init];
}

- (void)readPCMAndPlay:(AudioQueueRef)outQ buffer:(AudioQueueBufferRef)outQB {
    NSUInteger rlen;
    NSUInteger num = (stream.length-readLength);
    
    [synlock lock];
    
    if (num > 0) {
        rlen = (num > EVERY_READ_LENGTH)? EVERY_READ_LENGTH:num;
    } else {
        rlen = 0;
    }
    NSLog(@"total:%lu read:%lu cur:%lu", (unsigned long)stream.length, (unsigned long)readLength, (unsigned long)rlen);
    
    outQB->mAudioDataByteSize = (UInt32)rlen;
    Byte *audiodata = (Byte *)outQB->mAudioData;
    for (int i=0; i<rlen; i++) {
        audiodata[i] = ((unsigned char *)stream.bytes)[readLength+i];
    }
    readLength += rlen;
    /*
     将创建的buffer区添加到audioqueue里播放
     AudioQueueBufferRef用来缓存待播放的数据区，AudioQueueBufferRef有两个比较重要的参数，AudioQueueBufferRef->mAudioDataByteSize用来指示数据区大小，AudioQueueBufferRef->mAudioData用来保存数据区
     */
    AudioQueueEnqueueBuffer(outQ, outQB, 0, NULL);
    
    if (readLength >= stream.length) {
        if ([_delegate respondsToSelector:@selector(audioQueuePlayFinished)]) {
            [_delegate audioQueuePlayFinished];
        }
    }
    
    [synlock unlock];
}

@end
