//
//  SecondCategoryViewController.h
//  CloudBox
//
//  Created by TTS on 15-5-11.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "UICustomTableViewController.h"
#import "ToolBarPlayController.h"

@interface ListViewController : UICustomTableViewController
@property (nonatomic, retain) NSString *parentCategoryID;
@property (nonatomic, retain) ToolBarPlayController *toolBarPlayer;

@end
