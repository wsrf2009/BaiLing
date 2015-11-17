//
//  UICustomTableViewController.h
//  CloudBox
//
//  Created by TTS on 15/7/13.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYTXDeviceManager.h"

@interface UICustomTableViewController : UITableViewController
@property (nonatomic, retain) YYTXDeviceManager *deviceManager;
@property (nonatomic, assign) BOOL isAnimating; // 当前视图是否正在切换的标志

/** 初始化一个EffectView，并在其上显示title和hint */
- (void)initEffectViewWithTitle:(NSString *)title hint:(NSString *)hint;

/** 隐藏UITableView中多余的横线 */
- (void)hideEmptySeparators:(UITableView *)tableView;

/** 在EffectView上显示titile和hint */
- (void)showTitle:(NSString *)title hint:(NSString *)hint;

/** 移除覆盖在UITableView上的视图，恢复原来UITableView的内容 */
- (void)removeEffectView;

/** 显示繁忙的状态视图 */
- (void)showActiviting;

/** 显示一个Busy视图，并文字显示当前的状态 */
- (void)showBusying:(NSString *)message;

@end
