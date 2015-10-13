//
//  DeviceFunctionsViewController.h
//  CloudBox
//
//  Created by TTS on 15/9/6.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "UICustomTableViewController.h"
#import "ToolBarPlayController.h"

@protocol DeviceFunctionsDelegate <NSObject>

- (void)selectedViewController:(UIViewController *)vc;

@end

@interface DeviceFunctionsViewController : UICustomTableViewController
@property (nonatomic, retain) id <DeviceFunctionsDelegate> delegate;
@property (nonatomic, retain) ToolBarPlayController *toolBarPlayer;

@end
