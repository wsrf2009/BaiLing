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
#import "MJRefresh.h"
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
    
    NSUInteger getupAlarmNumber;
    NSUInteger customAlarmNumber;
    NSUInteger remindNumber;
    NSUInteger birthdayNumber;

    NSInteger totalNumber;
    
    MJRefreshAutoNormalFooter *footer;
    UIBarButtonItem *buttonRefresh;
}

@property (nonatomic, retain) UIBarButtonItem *barButtonAdd;
@property (nonatomic, retain) NSMutableArray *getupAlarmArray;
@property (nonatomic, retain) NSMutableArray *customAlarmArray;
@property (nonatomic, retain) NSMutableArray *remindArray;
@property (nonatomic, retain) NSMutableArray *birthdayArray;

@end

@implementation AlarmsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%s", __func__);
    
    self.deviceManager.delegate = self;

    buttonRefresh = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"refresh", @"hint", nil) style:UIBarButtonItemStylePlain target:self action:@selector(getAlarms)];
    self.navigationItem.rightBarButtonItem = buttonRefresh;

    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _barButtonAdd = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"insertAlarm", @"hint", nil) style:UIBarButtonItemStyleDone target:self action:@selector(addAlarm)];
    self.toolbarItems = [NSArray arrayWithObjects:space, _barButtonAdd, space, nil];
    
    _getupAlarmArray = [NSMutableArray array];
    _customAlarmArray = [NSMutableArray array];
    _remindArray = [NSMutableArray array];
    _birthdayArray = [NSMutableArray array];
    getupAlarmNumber = 0;
    customAlarmNumber = 0;
    remindNumber = 0;
    birthdayNumber = 0;

    footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:nil refreshingAction:nil];
    [footer setTitle:NSLocalizedStringFromTable(@"noAlarmFound", @"hint", nil) forState:MJRefreshStateNoMoreData];
    [footer setTitle:NSLocalizedStringFromTable(@"gettingAlarmList", @"hint", nil) forState:MJRefreshStateRefreshing];
    self.tableView.footer = footer;
    
    [self hideEmptySeparators:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"%s", __func__);
    
    [self getAlarms];
    
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    [_barButtonAdd setEnabled:NO];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(enableBarButtonAdd) userInfo:nil repeats:NO];
    
    self.deviceManager.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSLog(@"%s nav:%@", __func__, self.navigationController);
    
    
    self.deviceManager.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    getupAlarmNumber = _getupAlarmArray.count;
    customAlarmNumber = _customAlarmArray.count;
    remindNumber = _remindArray.count;
    birthdayNumber = _birthdayArray.count;
    
    totalNumber = getupAlarmNumber+customAlarmNumber+remindNumber+birthdayNumber;
    
    NSLog(@"%s %ld", __func__, (long)totalNumber);
    
    if (totalNumber <= 0) {
        [footer setState:MJRefreshStateNoMoreData];
        [self.tableView.footer setHidden:NO];
    } else {
        [self.tableView.footer setHidden:YES];
    }
    
    [self.navigationItem setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"alarmCount", @"hint", nil), (long)totalNumber]];
    
    return totalNumber;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"%s (%ld, %ld)", __func__, (long)indexPath.section, (long)indexPath.row);
    NSInteger rowIndex = indexPath.row;
    
    if (rowIndex < getupAlarmNumber) {
        AlarmTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmTableViewCell" forIndexPath:indexPath];
        
        AlarmClass *alarm = [_getupAlarmArray objectAtIndex:rowIndex];
        if (nil != alarm) {

            [cell.lableTime setText:[alarm.clock substringToIndex:5]];
            if (FRE_MODE_ONEOFF == alarm.fre_mode) {
                [cell.lableDetail setText:alarm.date];
            } else {
                [cell.lableDetail setText:[AlarmClass getAlarmCycle:alarm]];
            }
        
            if ([alarm is_valid]) {

                [cell.imageViewType setImage:[UIImage imageNamed:@"awakealart_pre.png"]];
                
                [cell.lableTitle setText:alarm.title];
                
                [cell setBackgroundColor:[UIColor whiteColor]];
                [cell.lableTime setTextColor:[UIColor blackColor]];
                [cell.lableTitle setTextColor:[UIColor blackColor]];
            } else {
                [cell.imageViewType setImage:[UIImage imageNamed:@"awakealart_nor.png"]];
                
                [cell.lableTitle setText:[alarm.title stringByAppendingFormat:@"(%@)", NSLocalizedStringFromTable(@"closed", @"hint", nil)]];
                
                [cell setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f]];
                [cell.lableTime setTextColor:[UIColor grayColor]];
                [cell.lableTitle setTextColor:[UIColor grayColor]];
            }
        }
#if 0
        if (![SystemToolClass systemVersionIsNotLessThan:@"8.0"]) {
            NSMutableArray *rightUtilityButtons = [NSMutableArray array];
            NSString *deleteTitle = NSLocalizedStringFromTable(@"delete", @"hint", nil);
            [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] title:deleteTitle];
            
            NSString *openTitle;
            if ([alarm is_valid]) {
                openTitle = NSLocalizedStringFromTable(@"close", @"hint", nil);
            } else {
                openTitle = NSLocalizedStringFromTable(@"open", @"hint", nil);
            }
            [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor blueColor] title:openTitle];
            cell.rightUtilityButtons = rightUtilityButtons;
            cell.delegate = self;
        }
#endif
        return cell;
    } else if (rowIndex < (getupAlarmNumber+customAlarmNumber)) {
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
                [cell.imageViewType setImage:[UIImage imageNamed:@"definedalart_pre.png"]];
                
                [cell.lableTitle setText:alarm.title];
                
                [cell setBackgroundColor:[UIColor whiteColor]];
                [cell.lableTime setTextColor:[UIColor blackColor]];
                [cell.lableTitle setTextColor:[UIColor blackColor]];
            } else {
                [cell.imageViewType setImage:[UIImage imageNamed:@"definedalart_nor.png"]];
                
                [cell.lableTitle setText:[alarm.title stringByAppendingFormat:@"(%@)", NSLocalizedStringFromTable(@"closed", @"hint", nil)]];
                
                [cell setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f]];
                [cell.lableTime setTextColor:[UIColor grayColor]];
                [cell.lableTitle setTextColor:[UIColor grayColor]];
            }
        }
#if 0
        if (![SystemToolClass systemVersionIsNotLessThan:@"8.0"]) {
            NSMutableArray *rightUtilityButtons = [NSMutableArray array];
            NSString *deleteTitle = NSLocalizedStringFromTable(@"delete", @"hint", nil);
            [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] title:deleteTitle];
            
            NSString *openTitle;
            if ([alarm is_valid]) {
                openTitle = NSLocalizedStringFromTable(@"close", @"hint", nil);
            } else {
                openTitle = NSLocalizedStringFromTable(@"open", @"hint", nil);
            }
            [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor blueColor] title:openTitle];
            cell.rightUtilityButtons = rightUtilityButtons;
            cell.delegate = self;
        }
#endif
        return cell;
    } else if (rowIndex < (getupAlarmNumber+customAlarmNumber+remindNumber)) {
        
        RemindTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RemindTableViewCell" forIndexPath:indexPath];
        
        RemindClass *remind = [_remindArray objectAtIndex:(rowIndex-(getupAlarmNumber+customAlarmNumber))];
        if (nil != remind) {

            [cell.labelDate setText:remind.date];
        
            if ([remind is_valid]) {
                
                [cell.imageViewType setImage:[UIImage imageNamed:@"remind_pre.png"]];
                
                [cell.remind setText:remind.content];
                
                [cell setBackgroundColor:[UIColor whiteColor]];
                [cell.labelDate setTextColor:[UIColor blackColor]];
                [cell.remind setTextColor:[UIColor blackColor]];
            } else {
                [cell.imageViewType setImage:[UIImage imageNamed:@"remind_nor.png"]];
                
                [cell.remind setText:[remind.content stringByAppendingFormat:@"(%@)", NSLocalizedStringFromTable(@"closed", @"hint", nil)]];
                
                [cell setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f]];
                [cell.labelDate setTextColor:[UIColor grayColor]];
                [cell.remind setTextColor:[UIColor grayColor]];
            }
        }
#if 0
        if (![SystemToolClass systemVersionIsNotLessThan:@"8.0"]) {
            NSMutableArray *rightUtilityButtons = [NSMutableArray array];
            NSString *deleteTitle = NSLocalizedStringFromTable(@"delete", @"hint", nil);
            [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] title:deleteTitle];
            
            NSString *openTitle;
            if ([remind is_valid]) {
                openTitle = NSLocalizedStringFromTable(@"close", @"hint", nil);
            } else {
                openTitle = NSLocalizedStringFromTable(@"open", @"hint", nil);
            }
            [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor blueColor] title:openTitle];
            cell.rightUtilityButtons = rightUtilityButtons;
            cell.delegate = self;
        }
#endif
        return cell;
    } else if (rowIndex < (getupAlarmNumber+customAlarmNumber+remindNumber+birthdayNumber)) {
        
        BirthdayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BirthdayTableViewCell" forIndexPath:indexPath];
        
        BirthdayClass *birthday = [_birthdayArray objectAtIndex:(rowIndex-(getupAlarmNumber+customAlarmNumber+remindNumber))];
        if (nil != birthday) {
        
            [cell.imageViewType setImage:[UIImage imageNamed:@"birthdayalart_pre.png"]];

            NSString *dateType;
            NSString *dateValue;
            if (DATETYPE_LUNAR == birthday.date_type) {
                dateValue = [BirthdayViewController tileLunarFromLarkLunar:birthday.date_value];
                dateType = DATE_TYPE_LUNAR;
            } else if (DATETYPE_SOLAR == birthday.date_type) {
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
#if 0
        if (![SystemToolClass systemVersionIsNotLessThan:@"8.0"]) {
            NSMutableArray *rightUtilityButtons = [NSMutableArray array];
            NSString *deleteTitle = NSLocalizedStringFromTable(@"delete", @"hint", nil);
            [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] title:deleteTitle];
            cell.rightUtilityButtons = rightUtilityButtons;
            cell.delegate = self;
        }
#endif
        return cell;
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger rowIndex = indexPath.row;
    
    if (rowIndex < getupAlarmNumber) {
        /* alarm */
        AlarmDetailViewController *alarmDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AlarmDetailViewController"];
        alarmDetailVC.deviceManager = self.deviceManager;
        alarmDetailVC.isAddAlarm = NO;
        alarmDetailVC.alarm = [_getupAlarmArray objectAtIndex:rowIndex];
        alarmDetailVC.isGetupAlarm = YES; // 起床闹铃

        if (nil != alarmDetailVC) {
            [self.navigationController pushViewController:alarmDetailVC animated:YES];
        }
    } else if (rowIndex < (getupAlarmNumber+customAlarmNumber)) {
        AlarmDetailViewController *alarmDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AlarmDetailViewController"];
        alarmDetailVC.deviceManager = self.deviceManager;
        alarmDetailVC.isAddAlarm = NO;
        alarmDetailVC.alarm = [_customAlarmArray objectAtIndex:rowIndex-getupAlarmNumber];
        alarmDetailVC.isGetupAlarm = NO; // 自定义闹铃

        if (nil != alarmDetailVC) {
            [self.navigationController pushViewController:alarmDetailVC animated:YES];
        }
    } else if (rowIndex < (getupAlarmNumber+customAlarmNumber+remindNumber)) {
        /* remind */
        RemindViewController *remindVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RemindViewController"];
        remindVC.deviceManager = self.deviceManager;
        remindVC.isAddAlarm = NO;
        remindVC.remind = [_remindArray objectAtIndex:rowIndex-(getupAlarmNumber+customAlarmNumber)];
        if (nil != remindVC) {
            [self.navigationController pushViewController:remindVC animated:YES];
        }
        
    } else if (rowIndex < (getupAlarmNumber+customAlarmNumber+remindNumber+birthdayNumber)) {
        /* birthday */
        BirthdayViewController *birthdayVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BirthdayViewController"];
        birthdayVC.deviceManager = self.deviceManager;
        birthdayVC.isAddAlarm = NO;
        birthdayVC.birthday = [_birthdayArray objectAtIndex:rowIndex-((getupAlarmNumber+customAlarmNumber+remindNumber))];
        if (nil != birthdayVC) {
            [self.navigationController pushViewController:birthdayVC animated:YES];
        }
    }
}
#if 0
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    UIButton *button = [cell.rightUtilityButtons objectAtIndex:index];
    NSString *title = [button titleForState:UIControlStateNormal];
    
    if ([title isEqualToString:NSLocalizedStringFromTable(@"delete", @"hint", nil)]) {
        [self beSureToDelete:indexPath];
    } else if ([title isEqualToString:NSLocalizedStringFromTable(@"open", @"hint", nil)]) {
        [self beSureToOpen:YES indexPath:indexPath];
    } else if ([title isEqualToString:NSLocalizedStringFromTable(@"close", @"hint", nil)]) {
        [self beSureToOpen:NO indexPath:indexPath];
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 设置删除按钮
    UITableViewRowAction *actionDeleteAlarm = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedStringFromTable(@"delete", @"hint", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        [self beSureToDelete:indexPath];
    }];

    // 设置开启或关闭闹铃按钮，只有起床闹铃、自定义闹铃和备忘提醒有效
    if (indexPath.row < (getupAlarmNumber+customAlarmNumber+remindNumber)) {
        
        /* 根据闹铃的状态设置按钮的标题：打开或关闭 */
        NSString *title;
        if (indexPath.row < getupAlarmNumber) {
            AlarmClass *alarm = [_getupAlarmArray objectAtIndex:indexPath.row];
            if ([alarm is_valid]) {
                title = NSLocalizedStringFromTable(@"close", @"hint", nil);
            } else {
                title = NSLocalizedStringFromTable(@"open", @"hint", nil);
            }
        } else if (indexPath.row < (getupAlarmNumber+customAlarmNumber)) {
            AlarmClass *alarm = [_customAlarmArray objectAtIndex:indexPath.row-getupAlarmNumber];
            if ([alarm is_valid]) {
                title = NSLocalizedStringFromTable(@"close", @"hint", nil);
            } else {
                title = NSLocalizedStringFromTable(@"open", @"hint", nil);
            }
        } else if (indexPath.row < (getupAlarmNumber+customAlarmNumber+remindNumber)) {
            RemindClass *remind = [_remindArray objectAtIndex:(indexPath.row-(getupAlarmNumber+customAlarmNumber))];
            if ([remind is_valid]) {
                title = NSLocalizedStringFromTable(@"close", @"hint", nil);
            } else {
                title = NSLocalizedStringFromTable(@"open", @"hint", nil);
            }
        }
        
        UITableViewRowAction *actionSwitchAlarm = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:title handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            
            if ([action.title isEqualToString:NSLocalizedStringFromTable(@"open", @"hint", nil)]) {
                [self beSureToOpen:YES indexPath:indexPath];
            } else {
                [self beSureToOpen:NO indexPath:indexPath];
            }

        }];
        actionSwitchAlarm.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        actionSwitchAlarm.backgroundColor = [UIColor greenColor];
        
        return @[actionSwitchAlarm, actionDeleteAlarm];
        
    } else {
        return @[actionDeleteAlarm];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)beSureToDelete:(NSIndexPath *)indexPath {
    NSString *message;
    NSInteger rowIndex = indexPath.row;
    if (rowIndex < getupAlarmNumber) {
        
        /* alarm */
        message = NSLocalizedStringFromTable(@"deleteThisAlarm?", @"hint", nil);
    } else if (rowIndex < (getupAlarmNumber+customAlarmNumber)) {
        
        message = NSLocalizedStringFromTable(@"deleteThisAlarm?", @"hint", nil);
    } else if (rowIndex < (getupAlarmNumber+customAlarmNumber + remindNumber)) {
        
        /* remind */
        message = NSLocalizedStringFromTable(@"deleteThisRemind?", @"hint", nil);
    } else if (rowIndex < (getupAlarmNumber+customAlarmNumber + remindNumber + birthdayNumber)) {
        
        /* birthday */
        message = NSLocalizedStringFromTable(@"deleteThisBirthday?", @"hint", nil);
    }
    
    NSString *buttonCancelTitle = NSLocalizedStringFromTable(@"cancel", @"hint", nil);
    NSString *buttonDeleteTitle = NSLocalizedStringFromTable(@"delete", @"hint", nil);
    if ([SystemToolClass systemVersionIsNotLessThan:@"8.0"]) {
        /* IOS8.0及以后 */
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[SystemToolClass appName] message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:buttonCancelTitle style:UIAlertActionStyleDefault handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:buttonDeleteTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
            [self deleteAlarmAtIndexPath:indexPath];
        }]];
        
        if (nil != alertController) {
            NSLog(@"%s +++++++++++++", __func__);
            [self presentViewController:alertController animated:YES completion:nil];
        }
    } else {
        /* IOS6.0 及以后，但是低于IOS8.0 */
        UICustomAlertView *alertView = [[UICustomAlertView alloc] initWithTitle:[SystemToolClass appName] message:message delegate:self cancelButtonTitle:buttonCancelTitle otherButtonTitles:buttonDeleteTitle, nil];
        NSLog(@"%s ----------------", __func__);
        [alertView showAlertViewWithCompleteBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
            if ([title isEqualToString:buttonDeleteTitle]) {
                [self deleteAlarmAtIndexPath:indexPath];
            }
        }];
    }
}

- (void)beSureToOpen:(BOOL)open indexPath:(NSIndexPath *)indexPath {
    NSString *message;
    NSString *title;
    if (indexPath.row < getupAlarmNumber) {
        if (open) {
            message = NSLocalizedStringFromTable(@"openThisAlarm?", @"hint", nil);
            title = NSLocalizedStringFromTable(@"open", @"hint", nil);
            
        } else {
            message = NSLocalizedStringFromTable(@"closeThisAlarm?", @"hint", nil);
            title = NSLocalizedStringFromTable(@"close", @"hint", nil);
        }
    } else if (indexPath.row < (getupAlarmNumber+customAlarmNumber)) {
        if (open) {
            message = NSLocalizedStringFromTable(@"openThisAlarm?", @"hint", nil);
            title = NSLocalizedStringFromTable(@"open", @"hint", nil);
            
        } else {
            message = NSLocalizedStringFromTable(@"closeThisAlarm?", @"hint", nil);
            title = NSLocalizedStringFromTable(@"close", @"hint", nil);
        }
    } else if (indexPath.row < (getupAlarmNumber+customAlarmNumber+remindNumber)) {
        if (open) {
            message = NSLocalizedStringFromTable(@"openThisRemind?", @"hint", nil);
            title = NSLocalizedStringFromTable(@"open", @"hint", nil);
        } else {
            message = NSLocalizedStringFromTable(@"closeThisRemind?", @"hint", nil);
            title = NSLocalizedStringFromTable(@"close", @"hint", nil);
        }
    }
    
    NSString *buttonCancelTitle = NSLocalizedStringFromTable(@"cancel", @"hint", nil);
    if ([SystemToolClass systemVersionIsNotLessThan:@"8.0"]) {
        /* IOS8.0及以后 */
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[SystemToolClass appName] message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:buttonCancelTitle style:UIAlertActionStyleDefault handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self switchAlarm:open indexPath:indexPath];
            
        }]];
        
        if (nil != alertController) {
            [self presentViewController:alertController animated:YES completion:nil];
        }
    } else {
        /* IOS6.0 及以后，但是低于IOS8.0 */
        UICustomAlertView *alertView = [[UICustomAlertView alloc] initWithTitle:[SystemToolClass appName] message:message delegate:self cancelButtonTitle:buttonCancelTitle otherButtonTitles:title, nil];
        
        NSLog(@"%s ----------------", __func__);
        
        [alertView showAlertViewWithCompleteBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
            if ([buttonTitle isEqualToString:title]) {
                [self switchAlarm:open indexPath:indexPath];
            }
        }];
    }
}

- (void)deleteAlarmAtIndexPath:(NSIndexPath *)indexPath {
    NSString *successful = NSLocalizedStringFromTable(@"deleteSuccessful", @"hint", nil);
    NSString *failed = NSLocalizedStringFromTable(@"deleteFailed", @"hint", nil);
    NSInteger rowIndex = indexPath.row;
    if (rowIndex < getupAlarmNumber) {
        /* alarm */
        AlarmClass *alarm = [_getupAlarmArray objectAtIndex:rowIndex];
            
        [buttonRefresh setEnabled:NO];
        [self showActiviting];
            
        [self.deviceManager.device deleteAlarm:alarm.ID params:@{DevicePlayTTSWhenOperationSuccessful:successful, DevicePlayTTSWhenOperationFailed:failed} completionBlock:^(YYTXDeviceReturnCode code) {
                
            dispatch_async(dispatch_get_main_queue(), ^{
                    
                if (YYTXOperationSuccessful == code) {
                    [self removeEffectView];
                    [_getupAlarmArray removeObject:alarm];
                    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                } else if (YYTXTransferFailed == code) {
                        
                    [self showTitle:NSLocalizedStringFromTable(@"deletingAlarmFailed", @"hint", nil) hint:NSLocalizedStringFromTable(@"hintForTransferFailed", @"hint", nil)];
                } else if (YYTXDeviceIsAbsent == code) {
                        
                    [self showTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
                } else if (YYTXOperationIsTooFrequent == code) {
                        [self removeEffectView];
                        
                } else {
                    [self removeEffectView];
                    [Toast showWithText:NSLocalizedStringFromTable(@"deletingAlarmFailed", @"hint", nil)];
                }
                    
                [buttonRefresh setEnabled:YES];
            });
        }];
    } else if (rowIndex < (getupAlarmNumber+customAlarmNumber)) {
        AlarmClass *alarm = [_customAlarmArray objectAtIndex:rowIndex-getupAlarmNumber];
        
        [buttonRefresh setEnabled:NO];
        [self showActiviting];
        
        [self.deviceManager.device deleteAlarm:alarm.ID params:@{DevicePlayTTSWhenOperationSuccessful:successful, DevicePlayTTSWhenOperationFailed:failed} completionBlock:^(YYTXDeviceReturnCode code) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (YYTXOperationSuccessful == code) {
                    [self removeEffectView];
                    [_customAlarmArray removeObject:alarm];
                    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                } else if (YYTXTransferFailed == code) {
                    
                    [self showTitle:NSLocalizedStringFromTable(@"deletingAlarmFailed", @"hint", nil) hint:NSLocalizedStringFromTable(@"hintForTransferFailed", @"hint", nil)];
                } else if (YYTXDeviceIsAbsent == code) {
                    
                    [self showTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
                } else if (YYTXOperationIsTooFrequent == code) {
                    [self removeEffectView];
                    
                } else {
                    [self removeEffectView];
                    [Toast showWithText:NSLocalizedStringFromTable(@"deletingAlarmFailed", @"hint", nil)];
                }
                
                [buttonRefresh setEnabled:YES];
            });
        }];
    } else if (rowIndex < (getupAlarmNumber+customAlarmNumber+remindNumber)) {
        /* remind */
        RemindClass *remind = [_remindArray objectAtIndex:rowIndex-(getupAlarmNumber+customAlarmNumber)];
            
        [buttonRefresh setEnabled:NO];
        [self showActiviting];
            
        [self.deviceManager.device deleteRemind:remind.ID params:@{DevicePlayTTSWhenOperationSuccessful:successful, DevicePlayTTSWhenOperationFailed:failed} completionBlock:^(YYTXDeviceReturnCode code) {
                
            dispatch_async(dispatch_get_main_queue(), ^{

                if (YYTXOperationSuccessful == code) {

                    [self removeEffectView];
                    [_remindArray removeObject:remind];
                    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                } else if (YYTXTransferFailed == code) {
                            
                    [self showTitle:NSLocalizedStringFromTable(@"deletingAlarmFailed", @"hint", nil) hint:NSLocalizedStringFromTable(@"hintForTransferFailed", @"hint", nil)];
                } else if (YYTXDeviceIsAbsent == code) {
                            
                    [self showTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
                } else if (YYTXOperationIsTooFrequent == code) {
                        [self removeEffectView];
                } else {
                    [self removeEffectView];
                    [Toast showWithText:NSLocalizedStringFromTable(@"deletingAlarmFailed", @"hint", nil)];
                }
                    
                [buttonRefresh setEnabled:YES];
            });
        }];
    } else if (rowIndex < (getupAlarmNumber+customAlarmNumber+remindNumber+birthdayNumber)) {
        /* birthday */
        BirthdayClass *birthday = [_birthdayArray objectAtIndex:rowIndex-((getupAlarmNumber+customAlarmNumber+remindNumber))];

        [buttonRefresh setEnabled:NO];
        [self showActiviting];

        [self.deviceManager.device deleteBirthday:birthday.ID params:@{DevicePlayTTSWhenOperationSuccessful:successful, DevicePlayTTSWhenOperationFailed:failed} completionBlock:^(YYTXDeviceReturnCode code) {
                
            dispatch_async(dispatch_get_main_queue(), ^{

                if (YYTXOperationSuccessful == code) {

                    [self removeEffectView];
                    [_birthdayArray removeObject:birthday];
                    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                } else if (YYTXTransferFailed == code) {
                            
                    [self showTitle:NSLocalizedStringFromTable(@"deletingAlarmFailed", @"hint", nil) hint:NSLocalizedStringFromTable(@"hintForTransferFailed", @"hint", nil)];
                } else if (YYTXDeviceIsAbsent == code) {
                        
                    [self showTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
                } else if (YYTXOperationIsTooFrequent == code) {
                    [self removeEffectView];

                } else {
                    [self removeEffectView];
                    [Toast showWithText:NSLocalizedStringFromTable(@"deletingAlarmFailed", @"hint", nil)];
                }
                    
                [buttonRefresh setEnabled:YES];
            });
        }];
    }
}

- (void)switchAlarm:(BOOL)open indexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < getupAlarmNumber) {
        AlarmClass *alarm = [_getupAlarmArray objectAtIndex:indexPath.row];
        NSString *successful;
        NSString *failed;
        if (open) {
            alarm.is_valid = 1;
            successful = NSLocalizedStringFromTable(@"openGetupAlarmSuccessful", @"hint", nil);
            failed = NSLocalizedStringFromTable(@"openGetupAlarmFailed", @"hint", nil);
        } else {
            alarm.is_valid = 0;
            successful = NSLocalizedStringFromTable(@"closeGetupAlarmSuccessful", @"hint", nil);
            failed = NSLocalizedStringFromTable(@"closeGetupAlarmFailed", @"hint", nil);
        }
        
        NSArray *arr = [alarm.clock componentsSeparatedByString:@":"];
        if (arr.count >= 2) {
            NSString *hour = arr[0];
            NSString *minute = arr[1];
            successful = [NSString stringWithFormat:successful, hour, minute];
        }

        [buttonRefresh setEnabled:NO];
        [self showActiviting];
        
        [self.deviceManager.device modifyAlarm:alarm parameter:@{DevicePlayTTSWhenOperationSuccessful:successful, DevicePlayTTSWhenOperationFailed:failed} completionBlock:^(YYTXDeviceReturnCode code) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (YYTXOperationSuccessful == code) {
                    [self removeEffectView];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                } else if (YYTXTransferFailed == code) {
                    [self removeEffectView];
                    [Toast showWithText:failed];
                } else if (YYTXDeviceIsAbsent == code) {
                    
                    [self showTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
                } else if (YYTXOperationIsTooFrequent == code) {
                    [self removeEffectView];
                    
                } else if (YYTXOperationFailed == code) {
                    [self removeEffectView];
                    [self performSelector:@selector(getAlarms) withObject:nil];
                } else {
                    
                    [self removeEffectView];
                    [Toast showWithText:failed];
                }
                
                [buttonRefresh setEnabled:YES];
            });
        }];
    } else if (indexPath.row < (getupAlarmNumber+customAlarmNumber)) {
        AlarmClass *alarm = [_customAlarmArray objectAtIndex:indexPath.row-getupAlarmNumber];
        NSString *successful;
        NSString *failed;
        if (open) {
            alarm.is_valid = 1;

            successful = NSLocalizedStringFromTable(@"openCustomAlarmSuccessful", @"hint", nil);
            failed = NSLocalizedStringFromTable(@"openCustomAlarmFailed", @"hint", nil);
        } else {
            alarm.is_valid = 0;
            successful = NSLocalizedStringFromTable(@"closeCustomAlarmSuccessful", @"hint", nil);
            failed = NSLocalizedStringFromTable(@"closeCustomAlarmFailed", @"hint", nil);
        }
        
        NSArray *arr = [alarm.clock componentsSeparatedByString:@":"];
        if (arr.count >= 2) {
            NSString *hour = arr[0];
            NSString *minute = arr[1];
            successful = [NSString stringWithFormat:successful, hour, minute];
        }
        
        [buttonRefresh setEnabled:NO];
        [self showActiviting];
        
        [self.deviceManager.device modifyAlarm:alarm parameter:@{DevicePlayTTSWhenOperationSuccessful:successful, DevicePlayTTSWhenOperationFailed:failed} completionBlock:^(YYTXDeviceReturnCode code) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (YYTXOperationSuccessful == code) {
                    [self removeEffectView];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                } else if (YYTXTransferFailed == code) {
                    [self removeEffectView];
                    [Toast showWithText:failed];
                } else if (YYTXDeviceIsAbsent == code) {
                    
                    [self showTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
                } else if (YYTXOperationIsTooFrequent == code) {
                    [self removeEffectView];
                    
                } else if (YYTXOperationFailed == code) {
                    [self removeEffectView];
                    [self performSelector:@selector(getAlarms) withObject:nil];
                } else {
                    
                    [self removeEffectView];
                    [Toast showWithText:failed];
                }
                
                [buttonRefresh setEnabled:YES];
            });
        }];
    } else if (indexPath.row < (getupAlarmNumber+customAlarmNumber+remindNumber)) {
        RemindClass *remind = [_remindArray objectAtIndex:(indexPath.row-(getupAlarmNumber+customAlarmNumber))];
        NSString *successful;
        NSString *failed;
        if (open) {
            remind.is_valid = 1;
            successful = NSLocalizedStringFromTable(@"openRemindSuccessful", @"hint", nil);
            failed = NSLocalizedStringFromTable(@"openRemindFailed", @"hint", nil);
        } else {
            remind.is_valid = 0;
            successful = NSLocalizedStringFromTable(@"closeRemindSuccessful", @"hint", nil);
            failed = NSLocalizedStringFromTable(@"closeRemindFailed", @"hint", nil);
        }

        [buttonRefresh setEnabled:NO];
        [self showActiviting];
        
        [self.deviceManager.device modifyRemind:remind parameter:@{DevicePlayTTSWhenOperationSuccessful:successful, DevicePlayTTSWhenOperationFailed:failed} completionBlock:^(YYTXDeviceReturnCode code) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (YYTXOperationSuccessful == code) {
                    [self removeEffectView];
                    
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                } else if (YYTXTransferFailed == code) {
                    [self removeEffectView];
                    [Toast showWithText:failed];
                } else if (YYTXDeviceIsAbsent == code) {
                    
                    [self showTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
                } else if (YYTXOperationIsTooFrequent == code) {
                    [self removeEffectView];
                    
                } else if (YYTXOperationFailed == code) {
                    [self removeEffectView];
                    [self performSelector:@selector(getAlarms) withObject:nil];
                } else {
                    [self removeEffectView];
                    [Toast showWithText:failed];
                }
                
                [buttonRefresh setEnabled:YES];
            });
        }];
    }
}
#endif
- (void)enableBarButtonAdd {

    dispatch_async(dispatch_get_main_queue(), ^{
        [_barButtonAdd setEnabled:YES];
    });
}

#pragma 添加闹铃

- (void)addAlarm {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_barButtonAdd setEnabled:NO];
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(enableBarButtonAdd) userInfo:nil repeats:NO];
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

- (void)getAlarms {
    
    NSLog(@"%s 1", __func__);

    dispatch_async(dispatch_get_main_queue(), ^{
        [buttonRefresh setEnabled:NO];
        [self showActiviting];
        [footer setState:MJRefreshStateRefreshing];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(enableButtonRefresh) userInfo:nil repeats:NO];
    });
    
    [self clearAlarms];

    [self.deviceManager.device getAlarm:^(YYTXDeviceReturnCode code) {

        if (YYTXOperationSuccessful == code) {
            
            [self.deviceManager.device getRemind:^(YYTXDeviceReturnCode code) {
                
                if (YYTXOperationSuccessful == code) {
                    
                    [self.deviceManager.device getBirthday:^(YYTXDeviceReturnCode code) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            NSLog(@"%s 5 %d", __func__, code);
                            
                            if (YYTXOperationSuccessful == code) {

                                [self removeEffectView];
                                [self.tableView.header setState:MJRefreshStateIdle];
                                
                                [_getupAlarmArray removeAllObjects];
                                [_customAlarmArray removeAllObjects];
                                for (AlarmClass *alarm in self.deviceManager.device.userData.alarmList) {
                                    if ([alarm.title isEqualToString:NSLocalizedStringFromTable(@"getup", @"hint", nil)]) {
                                        [_getupAlarmArray addObject:alarm];
                                    } else {
                                        [_customAlarmArray addObject:alarm];
                                    }
                                }
                                _remindArray = [self.deviceManager.device.userData.remindList mutableCopy];
                                _birthdayArray = [self.deviceManager.device.userData.birthdayList mutableCopy];
                                
                                [self.tableView reloadData];
                            } else {
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
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.tableView.header setState:MJRefreshStateIdle];
                        
                        NSLog(@"%s 4 %d", __func__, code);
                        
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
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView.header setState:MJRefreshStateIdle];
            
                NSLog(@"%s 3 %d", __func__, code);

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
