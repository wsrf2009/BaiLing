//
//  RemindTableViewController.h
//  CloudBox
//
//  Created by TTS on 15-4-27.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "UICustomTableViewController.h"

@interface RemindViewController : UICustomTableViewController<YYTXDeviceManagerDelegate>
@property (nonatomic, retain) RemindClass *remind;
@property (nonatomic, assign) BOOL isAddAlarm;

- (void)addRemind:(void (^)(void))popVC;

@end
