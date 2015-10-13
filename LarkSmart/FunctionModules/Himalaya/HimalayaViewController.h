//
//  HimalayaViewController.h
//  CloudBox
//
//  Created by TTS on 15/6/11.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYTXDeviceManager.h"
#import "ToolBarPlayController.h"

@interface HimalayaViewController : UITableViewController
@property (nonatomic, retain) YYTXDeviceManager *deviceManager;
@property (nonatomic, retain) ToolBarPlayController *toolBarPlayer;

@end
