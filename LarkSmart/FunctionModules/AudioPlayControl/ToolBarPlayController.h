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
- (void)indexOfPlaying:(NSUInteger)index programTitle:(NSString *)title;

@end

@interface ToolBarPlayController : UIViewController
@property (nonatomic, retain) YYTXDeviceManager *deviceManager;
@property (nonatomic, retain) NSMutableArray *playList;
@property (nonatomic, retain) id <ToolBarPlayerDelegate> delegate;

- (instancetype)initWithManager:(YYTXDeviceManager *)manager;
- (NSArray *)toolItems;
- (void)playAudioAtIndex:(NSUInteger)index;

@end
