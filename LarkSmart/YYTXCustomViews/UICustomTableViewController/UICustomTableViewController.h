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
@property (nonatomic, assign) BOOL isAnimating;

- (void)initEffectViewWithTitle:(NSString *)title hint:(NSString *)hint;
- (void)hideEmptySeparators:(UITableView *)tableView;
- (void)showTitle:(NSString *)title hint:(NSString *)hint;
- (void)removeEffectView;
- (void)showActiviting;

- (void)showBusying:(NSString *)message;
- (void)showMessage:(NSString *)message messageType:(NSInteger)type;

@end
