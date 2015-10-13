//
//  AlarmSetViewController.h
//  CloudBox
//
//  Created by TTS on 15-4-9.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "UICustomTableViewController.h"

@interface AlarmSetViewController : UICustomTableViewController<YYTXDeviceManagerDelegate>
@property (nonatomic, retain) IBOutlet UILabel *label_RingTitle;
@property (nonatomic, retain) IBOutlet UILabel *label_RingContent;
@property (nonatomic, retain) IBOutlet UILabel *label_RingDurationTitle;
@property (nonatomic, retain) IBOutlet UILabel *label_RingDurationContent;
@property (nonatomic, retain) IBOutlet UISwitch *switch_Date;
@property (nonatomic, retain) IBOutlet UISwitch *switch_Weather;
@property (nonatomic, retain) IBOutlet UISwitch *switch_Birthday;
@property (nonatomic, retain) IBOutlet UISwitch *switch_Remind;
@property (nonatomic, retain) IBOutlet UISwitch *switch_FestivalSolarterm;
@property (nonatomic, retain) IBOutlet UISwitch *switch_HolidayWishes;
@property (nonatomic, retain) IBOutlet UILabel *label_TodayInfoPlayTimes;

- (IBAction)switchClick_Date:(id)sender;
- (IBAction)switchClick_Weather:(id)sender;
- (IBAction)switchClick_Birthday:(id)sender;
- (IBAction)switchClick_Reamind:(id)sender;
- (IBAction)switchClick_FestivalSolarterm:(id)sender;
- (IBAction)switchClick_HolidayWishes:(id)sender;

@end
