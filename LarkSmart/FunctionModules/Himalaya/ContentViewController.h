//
//  ContentViewController.h
//  CloudBox
//
//  Created by TTS on 15-5-12.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "UICustomTableViewController.h"
#import "ToolBarPlayController.h"

@interface ContentViewController : UICustomTableViewController
@property (nonatomic, retain) NSString *parentCategoryID;
@property (nonatomic, retain) ToolBarPlayController *toolBarPlayer;
@property (nonatomic, retain) NSString *categoryTitle;

@end
