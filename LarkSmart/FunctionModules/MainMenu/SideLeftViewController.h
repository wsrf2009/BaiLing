//
//  DeviceFunctionTableViewController.h
//  CloudBox
//
//  Created by TTS on 15/8/5.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "UICustomTableViewController.h"
#import "ToolBarPlayController.h"
#import "DeviceFunctionsViewController.h"

@interface SideLeftViewController : UICustomTableViewController
@property (nonatomic, retain) id <DeviceFunctionsDelegate> delegate;
@property (nonatomic, retain) ToolBarPlayController *toolBarPlayer;

@end
