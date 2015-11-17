//
//  ToolBarPlayController.h
//  CloudBox
//
//  Created by TTS on 15-5-12.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYTXDeviceManager.h"

@protocol ToolBarPlayerDelegate <NSObject>

@optional

/** 告知当前正在播放曲目的偏移量和曲目名称 */
- (void)indexOfPlaying:(NSUInteger)index programTitle:(NSString *)title;

@end

@interface ToolBarPlayController : UIViewController
@property (nonatomic, retain) YYTXDeviceManager *deviceManager;
@property (nonatomic, retain) NSMutableArray *playList;
@property (nonatomic, retain) id <ToolBarPlayerDelegate> delegate;

/** 初始化界面底端位于工具栏中的播放控制视图 */
- (instancetype)initWithManager:(YYTXDeviceManager *)manager;

/** 返回要在工具栏中显示的items */
- (NSArray *)toolItems;

/** 播放列表playList中偏移量为index的条目 */
- (void)playAudioAtIndex:(NSUInteger)index;

@end
