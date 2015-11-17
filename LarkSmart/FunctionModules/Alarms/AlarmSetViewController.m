//
//  AlarmSetViewController.m
//  CloudBox
//
//  Created by TTS on 15-4-9.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "AlarmSetViewController.h"
#import "AlarmCycleSetClass.h"
#import "AlarmRingViewController.h"
#import "AlarmRingClass.h"
//#import "AlarmRingTimeViewController.h"
//#import "TodayInfoPlayTimesViewController.h"
#import "DataPickerViewController.h"
#import "JGActionSheet.h"
#import "VOSegmentedControl.h"



@interface AlarmSetViewController () <YYTXDeviceManagerDelegate,  JGActionSheetDelegate>
{
    GetupSetClass *getupSet;
    AlarmRingViewController *alarmRingVC;
//    AlarmRingTimeViewController *alarmPlayTimeVC;
//    TodayInfoPlayTimesViewController *todayInfoPlayTimesVC;
    DataPickerViewController *dataPickerAlert;
    UIBarButtonItem *buttonSave;
}

@property (nonatomic, retain) NSArray *playTime;

@end

@implementation AlarmSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%s", __func__);
    
    _playTime = @[@"8", @"16", @"24", @"32"];
    getupSet = self.deviceManager.device.userData.getupSet;
    [self getGetupSet];

    buttonSave = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"save", @"hint", nil) style:UIBarButtonItemStyleDone target:self action:@selector(saveGetupSet)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = [NSArray arrayWithObjects:space, buttonSave, space, nil];
 
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"alarmGeneralSet", @"hint", nil)];
    
    [self hideEmptySeparators:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.deviceManager.delegate = self;
    
    if (self.deviceManager.device.isAbsent) {
        /* 设备与手机的连接已端开 */
        [self initEffectViewWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
    } else {
        
        [self updateUI];
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.deviceManager.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#if 0
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    if (0 == section) {
        return 30.0f;
    } else if (1 == section) {
        return 30.0f;
    }
    
    return .0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] init];
    UILabel *label = [[UILabel alloc] init];
    [label setTextColor:[UIColor blackColor]];
    [label setFont:[UIFont systemFontOfSize:15]];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (0 == section) {
        
        [label setText:NSLocalizedStringFromTable(@"ring", @"hint", nil)];
    } else if (1 == section) {

        [label setText:NSLocalizedStringFromTable(@"broadcast", @"hint", nil)];
    }
    
    [header addSubview:label];
    
    [header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[label]-(>=15)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
    [header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=10)-[label]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
    
    return header;
}
#endif

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (0 == indexPath.section) {
        if (0 == indexPath.row) {
            /* 铃声选择视图 */
            alarmRingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AlarmRingViewController"];
            alarmRingVC.deviceManager = self.deviceManager;
            alarmRingVC.getupSet = getupSet;
            alarmRingVC.selectRow = [AlarmRingClass getIndexFromPath:getupSet.ringPath];
            [self.navigationController pushViewController:alarmRingVC animated:YES];
        } else if (1 == indexPath.row) {
            /* 闹铃响铃时间 */
            NSInteger selectedIndex = -1;
            NSMutableArray *arr = [NSMutableArray array];
            for (NSInteger i=0; i<getupSet.ringTime.count; i++) {
                RingTimeClass *ringTime = getupSet.ringTime[i];
                [arr addObject:@{@"text":ringTime.text}];
                if (getupSet.playTime == ringTime.time) {
                    selectedIndex = i;
                }
            }
            VOSegmentedControl *alarmRingTime = [[VOSegmentedControl alloc] initWithSegments:arr];
            
            if (selectedIndex>=0 && selectedIndex < getupSet.ringTime.count) {
                alarmRingTime.selectedSegmentIndex = selectedIndex;
            }
            alarmRingTime.contentStyle = VOContentStyleTextAlone;
            alarmRingTime.indicatorStyle = VOSegCtrlIndicatorStyleBox;
            alarmRingTime.animationType = VOSegCtrlAnimationTypeBounce;
            alarmRingTime.backgroundColor = [UIColor groupTableViewBackgroundColor];
            alarmRingTime.selectedBackgroundColor = [UIColor colorWithRed:.0f green:188.0f/255.0f blue:212.0f/255.0f alpha:1.0f];
            alarmRingTime.allowNoSelection = NO;
            alarmRingTime.frame = CGRectMake(0, 20, 290.0f, 40.0f);
            alarmRingTime.textColor = [UIColor blackColor];
            alarmRingTime.selectedTextFont = [UIFont systemFontOfSize:17.0f];
            alarmRingTime.selectedTextColor = [UIColor whiteColor];
            alarmRingTime.indicatorThickness = 2;
            alarmRingTime.indicatorCornerRadius = 20;
            alarmRingTime.selectedIndicatorColor = [UIColor colorWithRed:.0f green:188.0f/255.0f blue:212.0f/255.0f alpha:1.0f];
            alarmRingTime.tag = 1;
            
            JGActionSheetSection *s0 = [JGActionSheetSection sectionWithTitle:NSLocalizedStringFromTable(@"alarmTime", @"hint", nil) message:nil contentView:alarmRingTime];
            JGActionSheetSection *s1 = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[NSLocalizedStringFromTable(@"ok", @"hint", nil)] buttonStyle:JGActionSheetButtonStyleDefault];
            [s1 setButtonStyle:JGActionSheetButtonStyleDefault forButtonAtIndex:0];
            
            JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:@[s0, s1]];
            sheet.delegate = self;
            sheet.insets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                /* iPad中的显示位置 */
                CGPoint p = (CGPoint){-5.0f, CGRectGetMidY(_label_RingDurationContent.bounds)};
                p = [self.navigationController.view convertPoint:p fromView:_label_RingDurationContent];
                [sheet showFromPoint:p inView:self.navigationController.view arrowDirection:JGActionSheetArrowDirectionRight animated:YES];
            }
            else {
                /* iPhone */
                [sheet showInView:self.navigationController.view animated:YES];
            }
            
            /* sheet之外区域点击 */
            [sheet setOutsidePressBlock:^(JGActionSheet *sheet) {
                [sheet dismissAnimated:YES];
            }];
            
            [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
                /* sheet之内的section被点击 */
                [sheet dismissAnimated:YES];
                
                if (1 == indexPath.section) {

                    RingTimeClass *ringTime = getupSet.ringTime[alarmRingTime.selectedSegmentIndex];
                    getupSet.playTime = ringTime.time;
                    [self updateUI];
                }
            }];
        }
    } else if (1 == indexPath.section) {
        if (4 == indexPath.row) {
            /* 今日信息播放次数 */
            NSInteger selectedIndex = -1;
            NSMutableArray *arr = [NSMutableArray array];
            for (NSInteger i=0; i<getupSet.playTimes.count; i++) {
                PlayTimesClass *playTimes = getupSet.playTimes[i];
                [arr addObject:@{@"text":playTimes.text}];
                if (getupSet.messageTimes == playTimes.times) {
                    selectedIndex = i;
                }
            }
            VOSegmentedControl *alarmPlayTimes = [[VOSegmentedControl alloc] initWithSegments:arr];
            
            if (selectedIndex>=0 && selectedIndex < getupSet.playTimes.count) {
                alarmPlayTimes.selectedSegmentIndex = selectedIndex;
            }
            alarmPlayTimes.contentStyle = VOContentStyleTextAlone;
            alarmPlayTimes.indicatorStyle = VOSegCtrlIndicatorStyleBox;
            alarmPlayTimes.animationType = VOSegCtrlAnimationTypeBounce;
            alarmPlayTimes.backgroundColor = [UIColor groupTableViewBackgroundColor];
            alarmPlayTimes.selectedBackgroundColor = [UIColor colorWithRed:.0f green:188.0f/255.0f blue:212.0f/255.0f alpha:1.0f];
            alarmPlayTimes.allowNoSelection = NO;
            alarmPlayTimes.frame = CGRectMake(0, 20, 290.0f, 40.0f);
            alarmPlayTimes.textColor = [UIColor blackColor];
            alarmPlayTimes.selectedTextFont = [UIFont systemFontOfSize:17.0f];
            alarmPlayTimes.selectedTextColor = [UIColor whiteColor];
            alarmPlayTimes.indicatorThickness = 2;
            alarmPlayTimes.indicatorCornerRadius = 20;
            alarmPlayTimes.selectedIndicatorColor = [UIColor colorWithRed:.0f green:188.0f/255.0f blue:212.0f/255.0f alpha:1.0f];
            alarmPlayTimes.tag = 1;
            
            JGActionSheetSection *s0 = [JGActionSheetSection sectionWithTitle:NSLocalizedStringFromTable(@"broadcastTimes", @"hint", nil) message:nil contentView:alarmPlayTimes];
            JGActionSheetSection *s1 = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[NSLocalizedStringFromTable(@"ok", @"hint", nil)] buttonStyle:JGActionSheetButtonStyleDefault];
            [s1 setButtonStyle:JGActionSheetButtonStyleDefault forButtonAtIndex:0];
            
            JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:@[s0, s1]];
            sheet.delegate = self;
            sheet.insets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                /* iPad中的显示位置 */
                CGPoint p = (CGPoint){-5.0f, CGRectGetMidY(_label_TodayInfoPlayTimes.bounds)};
                p = [self.navigationController.view convertPoint:p fromView:_label_TodayInfoPlayTimes];
                [sheet showFromPoint:p inView:self.navigationController.view arrowDirection:JGActionSheetArrowDirectionRight animated:YES];
            }
            else {
                /* iPhone */
                [sheet showInView:self.navigationController.view animated:YES];
            }
            
            /* sheet之外的区域被点击 */
            [sheet setOutsidePressBlock:^(JGActionSheet *sheet) {
                [sheet dismissAnimated:YES];
            }];
            
            /* sheet之内的section被点击 */
            [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
                
                [sheet dismissAnimated:YES];
                
                if (1 == indexPath.section) {
                    PlayTimesClass *playTimes = getupSet.playTimes[alarmPlayTimes.selectedSegmentIndex];
                    getupSet.messageTimes = playTimes.times;
                    [self updateUI];
                }
            }];
        }
    }
}

- (void)selectedDataIndexArray:(NSMutableArray *)selectedArray {
    
    getupSet.delayTime = [[selectedArray objectAtIndex:1] integerValue];
    getupSet.delayNum = [[selectedArray objectAtIndex:3] integerValue];
}

/** 今日信息－－－日期 */
- (IBAction)switchClick_Date:(UISwitch *)s_date {
    if (s_date.isOn) {
        getupSet.messageOpen |= MESSAGE_OPEN_DATETIME;
    } else {
        getupSet.messageOpen &= ~MESSAGE_OPEN_DATETIME;
    }
}

/** 今日信息－－－天气 */
- (IBAction)switchClick_Weather:(UISwitch *)s_weather {
    if (s_weather.isOn) {
        getupSet.messageOpen |= MESSAGE_OPEN_WEATHER;
    } else {
        getupSet.messageOpen &= ~MESSAGE_OPEN_WEATHER;
    }
}

/** 今日信息－－－生日 */
- (IBAction)switchClick_Birthday:(UISwitch *)s_birthday {
    if (s_birthday.isOn) {
        getupSet.messageOpen |= MESSAGE_OPEN_BIRTHDAY;
    } else {
        getupSet.messageOpen &= ~MESSAGE_OPEN_BIRTHDAY;
    }
}

/** 今日信息－－－备忘 */
- (IBAction)switchClick_Reamind:(UISwitch *)s_remind {
    if (s_remind.isOn) {
        getupSet.messageOpen |= MESSAGE_OPEN_REMIND;
    } else {
        getupSet.messageOpen &= ~MESSAGE_OPEN_REMIND;
    }
}

- (IBAction)switchClick_FestivalSolarterm:(UISwitch *)s_festivalSolarterm {
    if (s_festivalSolarterm.isOn) {
        getupSet.messageOpen |= MESSAGE_OPEN_FESTIVALSOLARTERM;
    } else {
        getupSet.messageOpen &= ~MESSAGE_OPEN_FESTIVALSOLARTERM;
    }
}

- (IBAction)switchClick_HolidayWishes:(UISwitch *)s_holidayWishes {
    if (s_holidayWishes.isOn) {
        getupSet.messageOpen |= MESSAGE_OPEN_HOLIDAYWISHES;
    } else {
        getupSet.messageOpen &= ~MESSAGE_OPEN_HOLIDAYWISHES;
    }
}

- (void)updateUI {
    if (getupSet.messageOpen & MESSAGE_OPEN_DATETIME) {
        [_switch_Date setOn:YES animated:YES];
    } else {
        [_switch_Date setOn:NO animated:YES];
    }
    
    if (getupSet.messageOpen & MESSAGE_OPEN_WEATHER) {
        [_switch_Weather setOn:YES animated:YES];
    } else {
        [_switch_Weather setOn:NO animated:YES];
    }
    
    if (getupSet.messageOpen & MESSAGE_OPEN_BIRTHDAY) {
        [_switch_Birthday setOn:YES animated:YES];
    } else {
        [_switch_Birthday setOn:NO animated:YES];
    }
    
    if (getupSet.messageOpen & MESSAGE_OPEN_REMIND) {
        [_switch_Remind setOn:YES animated:YES];
    } else {
        [_switch_Remind setOn:NO animated:YES];
    }
    
    if (getupSet.messageOpen & MESSAGE_OPEN_FESTIVALSOLARTERM) {
        [_switch_FestivalSolarterm setOn:YES animated:YES];
    } else {
        [_switch_FestivalSolarterm setOn:NO animated:YES];
    }
    
    if (getupSet.messageOpen & MESSAGE_OPEN_HOLIDAYWISHES) {
        [_switch_HolidayWishes setOn:YES animated:YES];
    } else {
        [_switch_HolidayWishes setOn:NO animated:YES];
    }

    if (RING_TYPE_LOCAL == getupSet.ringType) {
        [_label_RingContent setText:[AlarmRingClass getNameFromPath:getupSet.ringPath]];
    }
    
    /* 响铃时间 */
    [_label_RingDurationContent setText:[NSString stringWithFormat:@"%@", @(getupSet.playTime)]];
    for (RingTimeClass *ringTime in getupSet.ringTime) {
        if (getupSet.playTime == ringTime.time) {
            [_label_RingDurationContent setText:ringTime.text];
        }
    }
    
    /* 今日信息播放次数 */
    [_label_TodayInfoPlayTimes setText:[NSString stringWithFormat:@"%@", @(getupSet.messageTimes)]];
    for (PlayTimesClass *playTimes in getupSet.playTimes) {
        if (getupSet.messageTimes == playTimes.times) {
            [_label_TodayInfoPlayTimes setText:playTimes.text];
        }
    }
    
}

#pragma 起床闹铃通用设置数据源

/** 获取起床闹铃的通用设置 */
- (void)getGetupSet {

    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self showActiviting];
    });
    
    [self.deviceManager.device getGetupSet:^(YYTXDeviceReturnCode code) {
        
        dispatch_async(dispatch_get_main_queue(), ^{

            if (YYTXOperationSuccessful == code) {
                
                [self removeEffectView];
                [self updateUI];
            } else if (YYTXTransferFailed == code) {
                    
                [self showTitle:NSLocalizedStringFromTable(@"gettingGetupGeneralSetFailed", @"hint", nil) hint:NSLocalizedStringFromTable(@"hintForTransferFailed", @"hint", nil)];
            } else if (YYTXDeviceIsAbsent == code) {
                    
                [self showTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
            } else if (YYTXOperationIsTooFrequent == code) {
                [self removeEffectView];
//                [Toast showWithText:NSLocalizedStringFromTable(@"operationIsTooFrequenct", @"hint", nil)];
            } else {
                [self removeEffectView];
                [QXToast showMessage:NSLocalizedStringFromTable(@"gettingGetupGeneralSetFailed", @"hint", nil)];
            }
        });
    }];
}

/** 修改起床闹铃通用设置 */
- (void)saveGetupSet {
    
    NSLog(@"%s", __func__);

    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self showActiviting];
    });
    
    NSString *successful = NSLocalizedStringFromTable(@"modifyGetupSetSuccessful", @"hint", nil);
    NSString *failed = NSLocalizedStringFromTable(@"modifyGetupSetFailed", @"hint", nil);
    
    [self.deviceManager.device modifyGetupSet:@{DevicePlayTTSWhenOperationSuccessful:successful, DevicePlayTTSWhenOperationFailed:failed} completionBlock:^(YYTXDeviceReturnCode code) {
        
        dispatch_async(dispatch_get_main_queue(), ^{

            if (YYTXOperationSuccessful == code) {
                [self.navigationController popViewControllerAnimated:YES];
            } else if (YYTXTransferFailed == code) {
                    
                [self showTitle:NSLocalizedStringFromTable(@"savingFailed", @"hint", nil) hint:NSLocalizedStringFromTable(@"hintForTransferFailed", @"hint", nil)];
            } else if (YYTXDeviceIsAbsent == code) {
                    
                [self showTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
            } else if (YYTXOperationIsTooFrequent == code) {
                [self removeEffectView];
//                [Toast showWithText:NSLocalizedStringFromTable(@"operationIsTooFrequenct", @"hint", nil)];
            } else {
                [self removeEffectView];
                [QXToast showMessage:NSLocalizedStringFromTable(@"savingFailed", @"hint", nil)];
            }
        });
    }];
}

@end
