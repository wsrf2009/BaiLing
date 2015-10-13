//
//  SubCategoryListTableViewController.h
//  CloudBox
//
//  Created by TTS on 15-4-23.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICustomTableViewController.h"

@interface MusicListViewController : UICustomTableViewController
@property (nonatomic, retain) NSMutableArray *source;
@property (nonatomic, retain) NSString *selectId;

@end
