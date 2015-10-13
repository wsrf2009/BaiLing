//
//  AlarmDetailViewController.h
//  CloudBox
//
//  Created by TTS on 15-4-8.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "UICustomTableViewController.h"

@interface AlarmDetailViewController : UICustomTableViewController
@property (nonatomic, retain) AlarmClass *alarm;
@property (nonatomic, assign) BOOL isAddAlarm;
@property (nonatomic, assign) BOOL isGetupAlarm;

- (void)addAlarm:(void (^)(void))popVC;

@end
