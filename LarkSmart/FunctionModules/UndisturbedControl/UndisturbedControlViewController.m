//
//  WakeupTimeViewController.m
//  CloudBox
//
//  Created by TTS on 15-4-16.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "UndisturbedControlViewController.h"
#import "NSDateNSStringConvert.h"
#import "NightVolumeViewController.h"
#import "DatePickerCell.h"
#import "JGActionSheet.h"

#define LeadingSpaceToSuperView         15.0f
#define TrailingSpaceToSuperView         15.0f
#define TopSpaceToSuperView         5.0f
#define BottomSpaceToSuperView      10.0f

@interface UndisturbedControlViewController () <YYTXDeviceManagerDelegate, JGActionSheetDelegate>

@property (nonatomic, retain) IBOutlet UISwitch *switchForPrompt;
@property (nonatomic, retain) IBOutlet UISwitch *switchForNightControl;
@property (nonatomic, retain) IBOutlet UILabel *labelForNightVolume;

@property (nonatomic, retain) IBOutlet UILabel *labelPromptControlHint;
@property (nonatomic, retain) IBOutlet UILabel *labelNightControlHint;
@property (nonatomic, retain) IBOutlet UILabel *labelNightStart;
@property (nonatomic, retain) IBOutlet UILabel *labelNightEnd;

@property (nonatomic, retain) UIFont *fontForHint;

@property (nonatomic, assign) BOOL displayNightControl;

@property (nonatomic, retain) NightVolumeViewController *nightVolumeVC;

@end

@implementation UndisturbedControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.deviceManager.delegate = self;
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *buttonSave = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"save", @"hint", nil) style:UIBarButtonItemStyleDone target:self action:@selector(modifyUndisturbedControl)];
    self.toolbarItems = @[space, buttonSave, space];
    
//    [self getUndisturbedControl];
    [self performSelectorInBackground:@selector(getUndisturbedControl) withObject:nil];
    
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"undisturbedControl", @"hint", nil)];
    
    _fontForHint = [UIFont systemFontOfSize:15.0f];
    
    NSString *promptControlHint = NSLocalizedStringFromTable(@"promptControlHint", @"hint", nil);
    // 创建可变属性化字符串
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:promptControlHint];
    NSUInteger length = [promptControlHint length];
    // 设置基本字体
    UIFont *baseFont = [UIFont systemFontOfSize:14.0f];
    [attrString addAttribute:NSFontAttributeName value:baseFont range:NSMakeRange(0, length)];
    UIColor *baseColor = [UIColor grayColor];
    [attrString addAttribute:NSForegroundColorAttributeName value:baseColor range:NSMakeRange(0, length)];
    [_labelPromptControlHint setAttributedText:attrString];
    
    NSString *nightControlHint = NSLocalizedStringFromTable(@"nightControlHint", @"hint", nil);
    // 创建可变属性化字符串
    attrString = [[NSMutableAttributedString alloc] initWithString:nightControlHint];
    length = [nightControlHint length];
    // 设置基本字体
    baseFont = [UIFont systemFontOfSize:14.0f];
    [attrString addAttribute:NSFontAttributeName value:baseFont range:NSMakeRange(0, length)];
    baseColor = [UIColor grayColor];
    [attrString addAttribute:NSForegroundColorAttributeName value:baseColor range:NSMakeRange(0, length)];
    [_labelNightControlHint setAttributedText:attrString];
    
    [self hideEmptySeparators:self.tableView];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [cell setSeparatorInset:UIEdgeInsetsMake(0, self.tableView.frame.size.width, 0, 0)];
    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    [cell setSeparatorInset:UIEdgeInsetsMake(0, self.tableView.frame.size.width, 0, 0)];
    
    _displayNightControl = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.deviceManager.delegate = self;
    
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    if (nil != _nightVolumeVC) {
        [self updateUI];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.deviceManager.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (0 == section) {
        return 2;
    } else if (1 == section) {
        if (_displayNightControl) {
            return 4;
        } else {
            return 1;
        }
    } else if (2 == section) {
        return 1;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"%s (%ld, %ld)", __func__, (long)indexPath.section, (long)indexPath.row);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (1 == indexPath.section) {
        if (1 == indexPath.row) {
            UIDatePicker *datePicker = [[UIDatePicker alloc] init];
            datePicker.frame = CGRectMake(0, 0, 200.0f, 170.0f);
            [datePicker setDatePickerMode:UIDatePickerModeTime];
            NSDate *date = [self.deviceManager.device.userData.undisturbedControl.undisturbedTimeStart convertToNSDateFromTimeString];
            if (nil != date) {
                [datePicker setDate:date animated:YES];
            }
            
            JGActionSheetSection *s0 = [JGActionSheetSection sectionWithTitle:NSLocalizedStringFromTable(@"nightStart", @"hint", nil) message:nil contentView:datePicker];
            JGActionSheetSection *s1 = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[NSLocalizedStringFromTable(@"ok", @"hint", nil)] buttonStyle:JGActionSheetButtonStyleDefault];
            
            JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:@[s0, s1]];
            sheet.delegate = self;
            sheet.insets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                
                CGPoint p = (CGPoint){-5.0f, CGRectGetMidY(_labelNightStart.bounds)};
                
                p = [self.navigationController.view convertPoint:p fromView:_labelNightStart];
                
                [sheet showFromPoint:p inView:self.navigationController.view arrowDirection:JGActionSheetArrowDirectionRight animated:YES];
            }
            else {
                [sheet showInView:self.navigationController.view animated:YES];
            }
            
            [sheet setOutsidePressBlock:^(JGActionSheet *sheet) {
                [sheet dismissAnimated:YES];
            }];
            
            [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
                
                [sheet dismissAnimated:YES];
                
                if (1 == indexPath.section) {

                    self.deviceManager.device.userData.undisturbedControl.undisturbedTimeStart = [datePicker.date getTimeString];
                    [self updateUI];
                }
            }];
        } else if (2 == indexPath.row) {
            UIDatePicker *datePicker = [[UIDatePicker alloc] init];
            datePicker.frame = CGRectMake(0, 0, 200.0f, 170.0f);
            [datePicker setDatePickerMode:UIDatePickerModeTime];
            NSDate *date = [self.deviceManager.device.userData.undisturbedControl.undisturbedTimeEnd convertToNSDateFromTimeString];
            if (nil != date) {
                [datePicker setDate:date animated:YES];
            }
            
            JGActionSheetSection *s0 = [JGActionSheetSection sectionWithTitle:NSLocalizedStringFromTable(@"nightEnd", @"hint", nil) message:nil contentView:datePicker];
            JGActionSheetSection *s1 = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[NSLocalizedStringFromTable(@"ok", @"hint", nil)] buttonStyle:JGActionSheetButtonStyleDefault];
            
            JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:@[s0, s1]];
            sheet.delegate = self;
            sheet.insets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                
                CGPoint p = (CGPoint){-5.0f, CGRectGetMidY(_labelNightEnd.bounds)};
                
                p = [self.navigationController.view convertPoint:p fromView:_labelNightEnd];
                
                [sheet showFromPoint:p inView:self.navigationController.view arrowDirection:JGActionSheetArrowDirectionRight animated:YES];
            }
            else {
                [sheet showInView:self.navigationController.view animated:YES];
            }
            
            [sheet setOutsidePressBlock:^(JGActionSheet *sheet) {
                [sheet dismissAnimated:YES];
            }];
            
            [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
                
                [sheet dismissAnimated:YES];
                
                if (1 == indexPath.section) {
                    if (0 == indexPath.row) {
                        self.deviceManager.device.userData.undisturbedControl.undisturbedTimeEnd = [datePicker.date getTimeString];
                        [self updateUI];
                    }
                }
            }];
        } else if (3 == indexPath.row) {
            _nightVolumeVC = [[UIStoryboard storyboardWithName:@"UndisturbedControl" bundle:nil] instantiateViewControllerWithIdentifier:@"NightVolumeViewController"];
            _nightVolumeVC.deviceManager = self.deviceManager;
            [self.navigationController pushViewController:_nightVolumeVC animated:YES];
        }
    }
}

- (void)updateUI {
    
    NSLog(@"%s", __func__);

    [_switchForPrompt setOn:self.deviceManager.device.userData.undisturbedControl.undisturbedOpenPrompt animated:YES];
    [_switchForNightControl setOn:self.deviceManager.device.userData.undisturbedControl.undisturbedOpen animated:YES];
    [_labelForNightVolume setText:[self.deviceManager.device.userData.undisturbedControl getVolumeTitleAccrodingToIndex:self.deviceManager.device.userData.undisturbedControl.undisturbedInitVolume]];
        
    [_labelNightStart setText:[self.deviceManager.device.userData.undisturbedControl.undisturbedTimeStart substringToIndex:5]];
    [_labelNightEnd setText:[self.deviceManager.device.userData.undisturbedControl.undisturbedTimeEnd substringToIndex:5]];
        
    [self nightControlSwitchChange:_switchForNightControl];
}

#pragma mark

- (IBAction)nightControlSwitchChange:(UISwitch *)sender {
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:1 inSection:1], [NSIndexPath indexPathForRow:2 inSection:1], [NSIndexPath indexPathForRow:3 inSection:1]];
    
    NSLog(@"%s %@ isOn:%d", __func__, sender, sender.isOn);
    
    if ([sender isOn]) {
        self.deviceManager.device.userData.undisturbedControl.undisturbedOpen = NIGHTCONTROL_ISOPEN;
        
        if (!_displayNightControl) {
            _displayNightControl = YES;
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } else {
        self.deviceManager.device.userData.undisturbedControl.undisturbedOpen = NIGHTCONTROL_ISCLOSE;
            
        if (_displayNightControl){
            _displayNightControl = NO;
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (IBAction)openPromptSwitchChange:(UISwitch *)sender {
    
    if ([sender isOn]) {
        self.deviceManager.device.userData.undisturbedControl.undisturbedOpenPrompt = PROMPT_ISOPEN;
    } else {
        self.deviceManager.device.userData.undisturbedControl.undisturbedOpenPrompt = PROMPT_ISCLOSE;
    }
}

#pragma 夜间控制数据源

- (void)getUndisturbedControl {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self showActiviting];
    });
    
    [self.deviceManager.device getUndisturbedControl:^(YYTXDeviceReturnCode code) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"%s code=%d", __func__, code);
            
            if (YYTXOperationSuccessful == code) {
                
                [self removeEffectView];
                [self updateUI];
            } else if (YYTXTransferFailed == code) {
                
                [self showTitle:NSLocalizedStringFromTable(@"getNightControlFailed", @"hint", nil) hint:NSLocalizedStringFromTable(@"hintForTransferFailed", @"hint", nil)];
            } else if (YYTXDeviceIsAbsent == code) {
                
                [self showTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
            } else if (YYTXOperationIsTooFrequent == code) {
                [self removeEffectView];
//                [Toast showWithText:NSLocalizedStringFromTable(@"operationIsTooFrequenct", @"hint", nil)];
            } else {
                [self showTitle:NSLocalizedStringFromTable(@"getNightControlFailed", @"hint", nil) hint:@""];
            }
        });
    }];
}

- (void)modifyUndisturbedControl {
    
    [self showBusying:NSLocalizedStringFromTable(@"saving", @"hint", nil)];
    
    [self.deviceManager.device modifyUndisturbedControl:@{DevicePlayFileWhenOperationSuccessful:devicePromptFileIdModifySuccessful, DevicePlayFileWhenOperationFailed:devicePromptFileIdModifyFailed} completionBlock:^(YYTXDeviceReturnCode code) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (YYTXOperationSuccessful == code) {
                
                [self.navigationController popViewControllerAnimated:YES];
            } else if (YYTXTransferFailed == code) {
                
                [self showTitle:NSLocalizedStringFromTable(@"savingFailed", @"hint", nil) hint:NSLocalizedStringFromTable(@"hintForTransferFailed", @"hint", nil)];
            } else if (YYTXDeviceIsAbsent == code) {
                
                [self showTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
            } else if (YYTXOperationIsTooFrequent == code) {
                [self removeEffectView];

            } else {
                [self removeEffectView];
                [Toast showWithText:NSLocalizedStringFromTable(@"savingFailed", @"hint", nil)];
            }
        });
    }];
}

@end
