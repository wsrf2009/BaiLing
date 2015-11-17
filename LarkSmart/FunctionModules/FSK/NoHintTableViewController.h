//
//  ConfigFailedViewController.h
//  CloudBox
//
//  Created by TTS on 15/6/29.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "UICustomTableViewController.h"

@interface NoHintTableViewController : UICustomTableViewController
/** 是否需要重新发送FSK声波 */
@property (nonatomic, assign) BOOL needFSKConfig;

@end
