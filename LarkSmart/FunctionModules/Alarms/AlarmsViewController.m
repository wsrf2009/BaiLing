//
//  AlarmsViewController.m
//  CloudBox
//
//  Created by TTS on 15-4-2.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "AlarmsViewController.h"
#import "AlarmTableViewCell.h"
#import "AlarmDetailViewController.h"
#import "RemindViewController.h"
#import "BirthdayViewController.h"
#import "QXToast.h"
#import "BirthdayTableViewCell.h"
#import "RemindTableViewCell.h"
#import "AddingAlarmViewController.h"
#import "UICustomAlertView.h"


#define DATE_TYPE_LUNAR         @"农历"
#define DATE_TYPE_SOLAR         @"阳历"

enum {
    AlertViewTagTypeSwitchAlarm = 10,
} AlertViewTagType;

NSString *const AlertViewType = @"AlertViewType";
NSString *const NSIndexPathValue = @"NSIndexPathValue";

@interface AlarmsViewController ()
{
    AlarmClass *selectAlarm;
    /** 起床闹铃个数 */
    NSUInteger getupAlarmNumber;
    /** 自定义闹铃数量 */
    NSUInteger customAlarmNumber;
    /** 备忘信息数量 */
    NSUInteger remindNumber;
    /** 生日闹铃数量 */
    NSUInteger birthdayNumber;

    /** 闹铃总数量 */
    NSInteger totalNumber;

    UIBarButtonItem *buttonRefresh;
}

@property (nonatomic, retain) UIBarButtonItem *barButtonAdd;
/** 起床闹铃列表 */
@property (nonatomic, retain) NSMutableArray *getupAlarmArray;
/** 自定义闹铃列表 */
@property (nonatomic, retain) NSMutableArray *customAlarmArray;
/** 备忘信息列表 */
@property (nonatomic, retain) NSMutableArray *remindArray;
/** 生日闹铃列表 */
@property (nonatomic, retain) NSMutableArray *birthdayArray;

@end

@implementation AlarmsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.deviceManager.delegate = self;

    buttonRefresh = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"refresh", @"hint", nil) style:UIBarButtonItemStylePlain target:self action:@selector(getAlarms)];
    self.navigationItem.rightBarButtonItem = buttonRefresh;

    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _barButtonAdd = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"insertAlarm", @"hint", nil) style:UIBarButtonItemStyleDone target:self action:@selector(addAlarm)];
    self.toolbarItems = [NSArray arrayWithObjects:space, _barButtonAdd, space, nil];
    
    /* 闹铃列表初始化 */
    _getupAlarmArray = [NSMutableArray array];
    _customAlarmArray = [NSMutableArray array];
    _remindArray = [NSMutableArray array];
    _birthdayArray = [NSMutableArray array];
    getupAlarmNumber = 0;
    customAlarmNumber = 0;
    remindNumber = 0;
    birthdayNumber = 0;

    [self hideEmptySeparators:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"%s", __func__);
    
    [self getAlarms]; // 进入该界面即获取闹铃列表
    
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    /* 1秒后再enable闹铃添加按钮 */
    [_barButtonAdd setEnabled:NO];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(enableBarButtonAdd) userInfo:nil repeats:NO];
    
    self.deviceManager.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.deviceManager.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    /* 统计闹铃数量 */
    getupAlarmNumber = _getupAlarmArray.count;
    customAlarmNumber = _customAlarmArray.count;
    remindNumber = _remindArray.count;
    birthdayNumber = _birthdayArray.count;
    totalNumber = getupAlarmNumber+customAlarmNumber+remindNumber+birthdayNumber;

    [self.navigationItem setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"alarmCount", @"hint", nil), (long)totalNumber]];
    
    return totalNumber;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"%s (%ld, %ld)", __func__, (long)indexPath.section, (long)indexPath.row);
    NSInteger rowIndex = indexPath.row;
    
    if (rowIndex < getupAlarmNumber) {
        /* 起床闹铃 */
        AlarmTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmTableViewCell" forIndexPath:indexPath];
        AlarmClass *alarm = [_getupAlarmArray objectAtIndex:rowIndex]; // 取得对应的起床闹铃
        if (nil != alarm) {
            [cell.lableTime setText:[alarm.clock substringToIndex:5]];
            if (FRE_MODE_ONEOFF == alarm.fre_mode) {
                [cell.lableDetail setText:alarm.date];
            } else {
                [cell.lableDetail setText:[AlarmClass getAlarmCycle:alarm]];
            }
        
            if ([alarm is_valid]) {
                /* 闹铃已被开启 */
                [cell.imageViewType setImage:[UIImage imageNamed:@"awakealart_pre.png"]];
                
                [cell.lableTitle setText:alarm.title];
                
                [cell setBackgroundColor:[UIColor whiteColor]];
                [cell.lableTime setTextColor:[UIColor blackColor]];
                [cell.lableTitle setTextColor:[UIColor blackColor]];
            } else {
                /* 闹铃已被关闭 */
                [cell.imageViewType setImage:[UIImage imageNamed:@"awakealart_nor.png"]];
                
                [cell.lableTitle setText:[alarm.title stringByAppendingFormat:@"(%@)", NSLocalizedStringFromTable(@"closed", @"hint", nil)]];
                
                [cell setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f]];
                [cell.lableTime setTextColor:[UIColor grayColor]];
                [cell.lableTitle setTextColor:[UIColor grayColor]];
            }
        }

        return cell;
    } else if (rowIndex < (getupAlarmNumber+customAlarmNumber)) {
        /* 自定义闹铃 */
        AlarmTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmTableViewCell" forIndexPath:indexPath];
        
        AlarmClass *alarm = [_customAlarmArray objectAtIndex:(rowIndex-getupAlarmNumber)];
        if (nil != alarm) {
            
            [cell.lableTime setText:[alarm.clock substringToIndex:5]];
            if (FRE_MODE_ONEOFF == alarm.fre_mode) {
                [cell.lableDetail setText:alarm.date];
            } else {
                [cell.lableDetail setText:[AlarmClass getAlarmCycle:alarm]];
            }
            
            if ([alarm is_valid]) {
                /* 闹铃已被开启 */
                [cell.imageViewType setImage:[UIImage imageNamed:@"definedalart_pre.png"]];
                
                [cell.lableTitle setText:alarm.title];
                
                [cell setBackgroundColor:[UIColor whiteColor]];
                [cell.lableTime setTextColor:[UIColor blackColor]];
                [cell.lableTitle setTextColor:[UIColor blackColor]];
            } else {
                /* 闹铃已被关闭 */
                [cell.imageViewType setImage:[UIImage imageNamed:@"definedalart_nor.png"]];
                
                [cell.lableTitle setText:[alarm.title stringByAppendingFormat:@"(%@)", NSLocalizedStringFromTable(@"closed", @"hint", nil)]];
                
                [cell setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f]];
                [cell.lableTime setTextColor:[UIColor grayColor]];
                [cell.lableTitle setTextColor:[UIColor grayColor]];
            }
        }

        return cell;
    } else if (rowIndex < (getupAlarmNumber+customAlarmNumber+remindNumber)) {
        /* 备忘信息 */
        RemindTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RemindTableViewCell" forIndexPath:indexPath];
        
        RemindClass *remind = [_remindArray objectAtIndex:(rowIndex-(getupAlarmNumber+customAlarmNumber))];
        if (nil != remind) {

            [cell.labelDate setText:remind.date];
        
            if ([remind is_valid]) {
                /* 备忘提醒已开启 */
                [cell.imageViewType setImage:[UIImage imageNamed:@"remind_pre.png"]];
                
                [cell.remind setText:remind.content];
                
                [cell setBackgroundColor:[UIColor whiteColor]];
                [cell.labelDate setTextColor:[UIColor blackColor]];
                [cell.remind setTextColor:[UIColor blackColor]];
            } else {
                /* 备忘提醒已关闭 */
                [cell.imageViewType setImage:[UIImage imageNamed:@"remind_nor.png"]];
                
                [cell.remind setText:[remind.content stringByAppendingFormat:@"(%@)", NSLocalizedStringFromTable(@"closed", @"hint", nil)]];
                
                [cell setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f]];
                [cell.labelDate setTextColor:[UIColor grayColor]];
                [cell.remind setTextColor:[UIColor grayColor]];
            }
        }

        return cell;
    } else if (rowIndex < (getupAlarmNumber+customAlarmNumber+remindNumber+birthdayNumber)) {
        /* 生日闹铃 */
        BirthdayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BirthdayTableViewCell" forIndexPath:indexPath];
        
        BirthdayClass *birthday = [_birthdayArray objectAtIndex:(rowIndex-(getupAlarmNumber+customAlarmNumber+remindNumber))];
        if (nil != birthday) {
            [cell.imageViewType setImage:[UIImage imageNamed:@"birthdayalart_pre.png"]];

            NSString *dateType;
            NSString *dateValue;
            if (DATETYPE_LUNAR == birthday.date_type) {
                /* 农历 */
                dateValue = [BirthdayViewController tileLunarFromLarkLunar:birthday.date_value];
                dateType = DATE_TYPE_LUNAR;
            } else if (DATETYPE_SOLAR == birthday.date_type) {
                /* 阳历 */
                NSArray *arr = [birthday.date_value componentsSeparatedByString:@"-"];
                if (nil != arr && arr.count >=3) {
                    dateValue = [NSString stringWithFormat:@"%@月%@日", arr[1], arr[2]];
                } else {
                    dateValue = birthday.date_value;
                }
                dateType = DATE_TYPE_SOLAR;
            }
        
            [cell.labelDate setText:dateValue];
            [cell.dateType setText:dateType];
            [cell.dateType setHidden:YES];
            [cell.longevity setText:birthday.who];

            [cell setBackgroundColor:[UIColor whiteColor]];
        }

        return cell;
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger rowIndex = indexPath.row;
    
    if (rowIndex < getupAlarmNumber) {
        /* 起床闹铃 */
        AlarmDetailViewController *alarmDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AlarmDetailViewController"];
        alarmDetailVC.deviceManager = self.deviceManager;
        alarmDetailVC.isAddAlarm = NO;
        alarmDetailVC.alarm = [_getupAlarmArray objectAtIndex:rowIndex];
        alarmDetailVC.isGetupAlarm = YES; // 起床闹铃

        if (nil != alarmDetailVC) {
            [self.navigationController pushViewController:alarmDetailVC animated:YES];
        }
    } else if (rowIndex < (getupAlarmNumber+customAlarmNumber)) {
        /* 自定义闹铃 */
        AlarmDetailViewController *alarmDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AlarmDetailViewController"];
        alarmDetailVC.deviceManager = self.deviceManager;
        alarmDetailVC.isAddAlarm = NO;
        alarmDetailVC.alarm = [_customAlarmArray objectAtIndex:rowIndex-getupAlarmNumber];
        alarmDetailVC.isGetupAlarm = NO; // 自定义闹铃

        if (nil != alarmDetailVC) {
            [self.navigationController pushViewController:alarmDetailVC animated:YES];
        }
    } else if (rowIndex < (getupAlarmNumber+customAlarmNumber+remindNumber)) {
        /* 备忘信息 */
        RemindViewController *remindVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RemindViewController"];
        remindVC.deviceManager = self.deviceManager;
        remindVC.isAddAlarm = NO;
        remindVC.remind = [_remindArray objectAtIndex:rowIndex-(getupAlarmNumber+customAlarmNumber)];
        if (nil != remindVC) {
            [self.navigationController pushViewController:remindVC animated:YES];
        }
        
    } else if (rowIndex < (getupAlarmNumber+customAlarmNumber+remindNumber+birthdayNumber)) {
        /* 生日闹铃 */
        BirthdayViewController *birthdayVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BirthdayViewController"];
        birthdayVC.deviceManager = self.deviceManager;
        birthdayVC.isAddAlarm = NO;
        birthdayVC.birthday = [_birthdayArray objectAtIndex:rowIndex-((getupAlarmNumber+customAlarmNumber+remindNumber))];
        if (nil != birthdayVC) {
            [self.navigationController pushViewController:birthdayVC animated:YES];
        }
    }
}

- (void)enableBarButtonAdd {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_barButtonAdd setEnabled:YES];
    });
}

#pragma 添加闹铃

/** 添加闹铃 */
- (void)addAlarm {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_barButtonAdd setEnabled:NO];
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(enableBarButtonAdd) userInfo:nil repeats:NO]; // 1秒后再enable闹铃添加按钮
    });
    
    AddingAlarmViewController *addingAlarmVC = [[AddingAlarmViewController alloc] init];
    addingAlarmVC.deviceManager = self.deviceManager;
    if (nil != addingAlarmVC) {
        [self.navigationController pushViewController:addingAlarmVC animated:YES];
    }
}

#pragma 闹铃数据源

- (void)clearAlarms {
    @synchronized(self) {
        [self.deviceManager.device.userData.alarmList removeAllObjects];
        [self.deviceManager.device.userData.remindList removeAllObjects];
        [self.deviceManager.device.userData.birthdayList removeAllObjects];
    }
}

- (void)enableButtonRefresh {
    [buttonRefresh setEnabled:YES];
}

/** 从设备端获取闹铃 */
- (void)getAlarms {
    dispatch_async(dispatch_get_main_queue(), ^{
        [buttonRefresh setEnabled:NO];
        [self showActiviting];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(enableButtonRefresh) userInfo:nil repeats:NO];
    });
    
    [self clearAlarms]; // 先清除已获取的闹铃列表

    [self.deviceManager.device getAlarm:^(YYTXDeviceReturnCode code) { // 获取起床闹铃和自定义闹铃
        if (YYTXOperationSuccessful == code) {
            [self.deviceManager.device getRemind:^(YYTXDeviceReturnCode code) { // 获取备忘信息
                if (YYTXOperationSuccessful == code) {
                    [self.deviceManager.device getBirthday:^(YYTXDeviceReturnCode code) { // 获取生日闹铃
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (YYTXOperationSuccessful == code) {
                                /* 所有的闹铃都获取成功 */
                                [self removeEffectView];

                                [_getupAlarmArray removeAllObjects];
                                [_customAlarmArray removeAllObjects];
                                for (AlarmClass *alarm in self.deviceManager.device.userData.alarmList) {
                                    if ([alarm.title isEqualToString:NSLocalizedStringFromTable(@"getup", @"hint", nil)]) {
                                        [_getupAlarmArray addObject:alarm]; // 更新起床闹铃列表
                                    } else {
                                        [_customAlarmArray addObject:alarm]; // 更新自定义闹铃
                                    }
                                }
                                _remindArray = [self.deviceManager.device.userData.remindList mutableCopy]; // 更新备忘信息
                                _birthdayArray = [self.deviceManager.device.userData.birthdayList mutableCopy]; // 更新生日闹铃
                                
                                [self.tableView reloadData]; // 刷新闹铃列表视图
                            } else {
                                /* 获取生日闹铃失败 */
                                if (YYTXTransferFailed == code) {
                                    [self showTitle:NSLocalizedStringFromTable(@"gettingAlarmFailed", @"hint", nil) hint:NSLocalizedStringFromTable(@"hintForTransferFailed", @"hint", nil)];
                                } else if (YYTXDeviceIsAbsent == code) {
                                    [self showTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
                                } else if (YYTXOperationIsTooFrequent == code) {
                                    [self removeEffectView];
                                } else {
                                    [self removeEffectView];
                                    [QXToast showMessage:NSLocalizedStringFromTable(@"gettingAlarmFailed", @"hint", nil)];
                                }
                                
                                [_getupAlarmArray removeAllObjects];
                                [_customAlarmArray removeAllObjects];
                                [_remindArray removeAllObjects];
                                [_birthdayArray removeAllObjects];
                                [self.tableView reloadData];
                            }
                        });
                    }];
                } else {
                    /* 获取备忘信息失败 */
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (YYTXTransferFailed == code) {
                            [self showTitle:NSLocalizedStringFromTable(@"gettingAlarmFailed", @"hint", nil) hint:NSLocalizedStringFromTable(@"hintForTransferFailed", @"hint", nil)];
                        } else if (YYTXDeviceIsAbsent == code) {
                            [self showTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
                        } else {
                            [self removeEffectView];
                            [QXToast showMessage:NSLocalizedStringFromTable(@"gettingAlarmFailed", @"hint", nil)];
                        }

                        [_getupAlarmArray removeAllObjects];
                        [_customAlarmArray removeAllObjects];
                        [_remindArray removeAllObjects];
                        [_birthdayArray removeAllObjects];
                        [self.tableView reloadData];
                    });
                }
            }];
        } else {
            /* 获取起床闹铃和自定义闹铃不成功 */
            dispatch_async(dispatch_get_main_queue(), ^{
                if (YYTXTransferFailed == code) {
                    [self showTitle:NSLocalizedStringFromTable(@"gettingAlarmFailed", @"hint", nil) hint:NSLocalizedStringFromTable(@"hintForTransferFailed", @"hint", nil)];
                } else if (YYTXDeviceIsAbsent == code) {
                    [self showTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
                } else {
                    [self removeEffectView];
                    [QXToast showMessage:NSLocalizedStringFromTable(@"gettingAlarmFailed", @"hint", nil)];
                }

                [_getupAlarmArray removeAllObjects];
                [_customAlarmArray removeAllObjects];
                [_remindArray removeAllObjects];
                [_birthdayArray removeAllObjects];
                [self.tableView reloadData];
            });
        }
    }];
}

@end
