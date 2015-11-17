//
//  LocalMusicTask.h
//  CloudBox
//
//  Created by TTS on 15/9/25.
//  Copyright © 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioClass.h"
#import "TSLibraryImport.h"

typedef NS_ENUM(NSInteger, YYTXMediaExportingState) {
    YYTXMediaExportingStateUnknown = 0,
    YYTXMediaExportingStateWaiting,
    YYTXMediaExportingStateExporting,
    YYTXMediaExportingStateCompleted,
    YYTXMediaExportingStateFailed,
    YYTXMediaExportingStateCancelled
};

@interface YYTXMediaItem :NSObject
@property (nonatomic, retain) AudioClass *audio;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, retain) NSString *file;
@property (nonatomic, retain) NSURL *assetUrl;
@property (nonatomic, retain) TSLibraryImport *libraryImport;
@property (nonatomic, assign) YYTXMediaExportingState state;
@property (nonatomic, retain) NSString *pinYin;
@end

@protocol YYTXMediaExportDelegate <NSObject>

- (void)mediaExportStateChange;
@end

@interface LocalMusicTask : NSObject
@property (nonatomic, retain) id<YYTXMediaExportDelegate> delegate;
/** 手机上发现的音乐条目 */
@property (nonatomic, retain) NSMutableArray *musicItems;

/** 清空musicItems */
- (void)clearMediaList;

/** 重新扫描手机上的音乐 */
- (void)regainMedias;

@end
