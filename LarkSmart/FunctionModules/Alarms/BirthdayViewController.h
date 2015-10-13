//
//  BirthdayTableViewController.h
//  CloudBox
//
//  Created by TTS on 15-4-27.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "UICustomTableViewController.h"

@interface BirthdayViewController : UICustomTableViewController<YYTXDeviceManagerDelegate>
@property (nonatomic, retain) BirthdayClass *birthday;
@property (nonatomic, assign) BOOL isAddAlarm;

+ (NSString *)tileLunarFromLarkLunar:(NSString *)lunarDate;

- (void)addBirthday:(void (^)(void))popVC;

@end
