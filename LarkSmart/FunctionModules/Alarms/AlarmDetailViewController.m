//
//  AlarmDetailViewController.m
//  CloudBox
//
//  Created by TTS on 15-4-8.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "AlarmDetailViewController.h"
#import "NSDateNSStringConvert.h"
#import "AlarmSetViewController.h"
#import "JGActionSheet.h"
#import "IQTextView.h"

#define LeadingSpaceToSuperView     10.0f
#define TrailingSpaceToSuperView    10.0f
#define TopSpaceToSuperView         20.0f
#define BottomSpaceToSuperView      20.0f
#define buttonWidth                 60.0f
#define buttonHeight                35.0f
#define buttonOneOffWidth           100.0f

@interface UIButton (AlarmCycleSelected)

@end

@implementation UIButton (AlarmCycleSelected) // UIButton扩展

/** 自定义的改变按钮的状态 */
- (void)changeStatus:(BOOL)isSelected {
    
    if (isSelected) {
        [self setBackgroundColor:[UIColor colorWithRed:.0f green:188.0f/255.0f blue:212.0f/255.0f alpha:1.0f]];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

@end

@interface AlarmClycleView : UIView
@property (nonatomic, retain) UIButton *btnOneOff;
@property (nonatomic, retain) UIButton *btnEverday;
@property (nonatomic, retain) UIButton *btnMonday;
@property (nonatomic, retain) UIButton *btnTuesday;
@property (nonatomic, retain) UIButton *btnWednesday;
@property (nonatomic, retain) UIButton *btnThursday;
@property (nonatomic, retain) UIButton *btnFriday;
@property (nonatomic, retain) UIButton *btnSaturday;
@property (nonatomic, retain) UIButton *btnSunday;

@property (nonatomic, assign) NSInteger fre_mode; // 周期模式
@property (nonatomic, assign) NSInteger frequency; // 每周重复日期fre_mode＝2时有效

@end

@implementation AlarmClycleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (nil != self) {
        /* 一次性闹铃 */
        _btnOneOff = [[UIButton alloc] init];
        [_btnOneOff setTitle:NSLocalizedStringFromTable(@"oneOff", @"hint", nil) forState:UIControlStateNormal];
        [_btnOneOff.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_btnOneOff setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _btnOneOff.layer.cornerRadius = 15.0f;
        _btnOneOff.layer.borderWidth = 0.6f;
        _btnOneOff.layer.borderColor = [UIColor grayColor].CGColor;
        [_btnOneOff addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        _btnOneOff.translatesAutoresizingMaskIntoConstraints = NO;
        
        /* 每天 */
        _btnEverday = [[UIButton alloc] init];
        [_btnEverday setTitle:NSLocalizedStringFromTable(@"everyday", @"hint", nil) forState:UIControlStateNormal];
        [_btnEverday.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_btnEverday setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _btnEverday.layer.cornerRadius = 15.0f;
        _btnEverday.layer.borderWidth = 0.6f;
        _btnEverday.layer.borderColor = [UIColor grayColor].CGColor;
        [_btnEverday addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        _btnEverday.translatesAutoresizingMaskIntoConstraints = NO;
        
        /* 周一 */
        _btnMonday = [[UIButton alloc] init];
        [_btnMonday setTitle:NSLocalizedStringFromTable(@"monday", @"hint", nil) forState:UIControlStateNormal];
        [_btnMonday.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_btnMonday setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _btnMonday.layer.cornerRadius = 15.0f;
        _btnMonday.layer.borderWidth = 0.6f;
        _btnMonday.layer.borderColor = [UIColor grayColor].CGColor;
        [_btnMonday addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        _btnMonday.translatesAutoresizingMaskIntoConstraints = NO;
        
        /* 周二 */
        _btnTuesday = [[UIButton alloc] init];
        [_btnTuesday setTitle:NSLocalizedStringFromTable(@"tuesday", @"hint", nil) forState:UIControlStateNormal];
        [_btnTuesday.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_btnTuesday setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _btnTuesday.layer.cornerRadius = 15.0f;
        _btnTuesday.layer.borderWidth = 0.6f;
        _btnTuesday.layer.borderColor = [UIColor grayColor].CGColor;
        [_btnTuesday addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        _btnTuesday.translatesAutoresizingMaskIntoConstraints = NO;
        
        /* 周三 */
        _btnWednesday = [[UIButton alloc] init];
        [_btnWednesday setTitle:NSLocalizedStringFromTable(@"wednesday", @"hint", nil) forState:UIControlStateNormal];
        [_btnWednesday.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_btnWednesday setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _btnWednesday.layer.cornerRadius = 15.0f;
        _btnWednesday.layer.borderWidth = 0.6f;
        _btnWednesday.layer.borderColor = [UIColor grayColor].CGColor;
        [_btnWednesday addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        _btnWednesday.translatesAutoresizingMaskIntoConstraints = NO;
        
        /* 周四 */
        _btnThursday = [[UIButton alloc] init];
        [_btnThursday setTitle:NSLocalizedStringFromTable(@"thursday", @"hint", nil) forState:UIControlStateNormal];
        [_btnThursday.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_btnThursday setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _btnThursday.layer.cornerRadius = 15.0f;
        _btnThursday.layer.borderWidth = 0.6f;
        _btnThursday.layer.borderColor = [UIColor grayColor].CGColor;
        [_btnThursday addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        _btnThursday.translatesAutoresizingMaskIntoConstraints = NO;
        
        /* 周五 */
        _btnFriday = [[UIButton alloc] init];
        [_btnFriday setTitle:NSLocalizedStringFromTable(@"friday", @"hint", nil) forState:UIControlStateNormal];
        [_btnFriday.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_btnFriday setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _btnFriday.layer.cornerRadius = 15.0f;
        _btnFriday.layer.borderWidth = 0.6f;
        _btnFriday.layer.borderColor = [UIColor grayColor].CGColor;
        [_btnFriday addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        _btnFriday.translatesAutoresizingMaskIntoConstraints = NO;
        
        /* 周六 */
        _btnSaturday = [[UIButton alloc] init];
        [_btnSaturday setTitle:NSLocalizedStringFromTable(@"saturday", @"hint", nil) forState:UIControlStateNormal];
        [_btnSaturday.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_btnSaturday setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _btnSaturday.layer.cornerRadius = 15.0f;
        _btnSaturday.layer.borderWidth = 0.6f;
        _btnSaturday.layer.borderColor = [UIColor grayColor].CGColor;
        [_btnSaturday addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        _btnSaturday.translatesAutoresizingMaskIntoConstraints = NO;
        
        /* 周日 */
        _btnSunday = [[UIButton alloc] init];
        [_btnSunday setTitle:NSLocalizedStringFromTable(@"sunday", @"hint", nil) forState:UIControlStateNormal];
        [_btnSunday.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_btnSunday setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _btnSunday.layer.cornerRadius = 15.0f;
        _btnSunday.layer.borderWidth = 0.6f;
        _btnSunday.layer.borderColor = [UIColor grayColor].CGColor;
        [_btnSunday addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        _btnSunday.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_btnMonday];
        [self addSubview:_btnTuesday];
        [self addSubview:_btnWednesday];
        [self addSubview:_btnThursday];
        [self addSubview:_btnFriday];
        [self addSubview:_btnSaturday];
        [self addSubview:_btnSunday];
        [self addSubview:_btnOneOff];
        [self addSubview:_btnEverday];

        CGFloat verticalSpace = (frame.size.height-TopSpaceToSuperView-BottomSpaceToSuperView-buttonHeight*3)/2;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-TopSpaceToSuperView-[_btnMonday(==buttonHeight)]-verticalSpace-[_btnThursday(==buttonHeight)]-verticalSpace-[_btnSunday(==buttonHeight)]-BottomSpaceToSuperView-|" options:0 metrics:@{@"TopSpaceToSuperView":@TopSpaceToSuperView, @"buttonHeight":@buttonHeight, @"verticalSpace":[NSNumber numberWithFloat:verticalSpace], @"BottomSpaceToSuperView":@BottomSpaceToSuperView} views:NSDictionaryOfVariableBindings(_btnMonday, _btnThursday, _btnSunday)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-TopSpaceToSuperView-[_btnTuesday(==buttonHeight)]-verticalSpace-[_btnFriday(==buttonHeight)]-verticalSpace-[_btnOneOff(==buttonHeight)]-BottomSpaceToSuperView-|" options:0 metrics:@{@"TopSpaceToSuperView":@TopSpaceToSuperView, @"buttonHeight":@buttonHeight, @"verticalSpace":[NSNumber numberWithFloat:verticalSpace], @"BottomSpaceToSuperView":@BottomSpaceToSuperView} views:NSDictionaryOfVariableBindings(_btnTuesday, _btnFriday, _btnOneOff)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-TopSpaceToSuperView-[_btnWednesday(==buttonHeight)]-verticalSpace-[_btnSaturday(==buttonHeight)]-verticalSpace-[_btnEverday(==buttonHeight)]-BottomSpaceToSuperView-|" options:0 metrics:@{@"TopSpaceToSuperView":@TopSpaceToSuperView, @"buttonHeight":@buttonHeight, @"verticalSpace":[NSNumber numberWithFloat:verticalSpace], @"BottomSpaceToSuperView":@BottomSpaceToSuperView} views:NSDictionaryOfVariableBindings(_btnWednesday, _btnSaturday, _btnEverday)]];
        
        CGFloat horizontalSpace = (frame.size.width-LeadingSpaceToSuperView-TrailingSpaceToSuperView-buttonWidth*3)/2;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-LeadingSpaceToSuperView-[_btnMonday(==buttonWidth)]-(>=horizontalSpace)-[_btnTuesday(==buttonWidth)]-(>=horizontalSpace)-[_btnWednesday(==buttonWidth)]-TrailingSpaceToSuperView-|" options:0 metrics:@{@"LeadingSpaceToSuperView":@LeadingSpaceToSuperView, @"horizontalSpace":[NSNumber numberWithFloat:horizontalSpace], @"buttonWidth":@buttonWidth, @"TrailingSpaceToSuperView":@TrailingSpaceToSuperView} views:NSDictionaryOfVariableBindings(_btnMonday, _btnTuesday, _btnWednesday)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-LeadingSpaceToSuperView-[_btnThursday(==buttonWidth)]-(>=horizontalSpace)-[_btnFriday(==buttonWidth)]-(>=horizontalSpace)-[_btnSaturday(==buttonWidth)]-TrailingSpaceToSuperView-|" options:0 metrics:@{@"LeadingSpaceToSuperView":@LeadingSpaceToSuperView, @"horizontalSpace":[NSNumber numberWithFloat:horizontalSpace], @"buttonWidth":@buttonWidth, @"TrailingSpaceToSuperView":@TrailingSpaceToSuperView} views:NSDictionaryOfVariableBindings(_btnThursday, _btnFriday, _btnSaturday)]];
        horizontalSpace = (frame.size.width-LeadingSpaceToSuperView-TrailingSpaceToSuperView-buttonWidth*2-buttonOneOffWidth)/2;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-LeadingSpaceToSuperView-[_btnSunday(==buttonWidth)]-(>=horizontalSpace)-[_btnOneOff(==buttonOneOffWidth)]-(>=horizontalSpace)-[_btnEverday(==buttonWidth)]-TrailingSpaceToSuperView-|" options:0 metrics:@{@"LeadingSpaceToSuperView":@LeadingSpaceToSuperView, @"buttonOneOffWidth":@buttonOneOffWidth, @"horizontalSpace":[NSNumber numberWithFloat:horizontalSpace], @"buttonWidth":@buttonWidth, @"TrailingSpaceToSuperView":@TrailingSpaceToSuperView} views:NSDictionaryOfVariableBindings(_btnSunday, _btnOneOff, _btnEverday)]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_btnTuesday attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_btnFriday attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_btnOneOff attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    }
    
    return self;
}

- (void)updateUI {

    if (FRE_MODE_ONEOFF == _fre_mode) {
        
        // 一次性闹铃
        _frequency &= ~(FREQUENCY_MONDAY|FREQUENCY_TUESDAY|FREQUENCY_WEDNESDAY|FREQUENCY_THURSDAY|FREQUENCY_FRIDAY|FREQUENCY_SATURDAY|FREQUENCY_SUNDAY);
        
        [_btnOneOff changeStatus:YES];
        
        [_btnEverday changeStatus:NO];
        
        [_btnMonday changeStatus:NO];
        [_btnTuesday changeStatus:NO];
        [_btnWednesday changeStatus:NO];
        [_btnThursday changeStatus:NO];
        [_btnFriday changeStatus:NO];
        [_btnSaturday changeStatus:NO];
        [_btnSunday changeStatus:NO];
        
    } else if (FRE_MODE_EVERYDAY == _fre_mode) {
        // 每天都响的闹铃
        [_btnOneOff changeStatus:NO];
        
        [_btnEverday changeStatus:YES];
        
        [_btnMonday changeStatus:YES];
        [_btnTuesday changeStatus:YES];
        [_btnWednesday changeStatus:YES];
        [_btnThursday changeStatus:YES];
        [_btnFriday changeStatus:YES];
        [_btnSaturday changeStatus:YES];
        [_btnSunday changeStatus:YES];
            
        _frequency = FREQUENCY_MONDAY|FREQUENCY_TUESDAY|FREQUENCY_WEDNESDAY|FREQUENCY_THURSDAY|FREQUENCY_FRIDAY|FREQUENCY_SATURDAY|FREQUENCY_SUNDAY;
        
    } else if (FRE_MODE_WEEKLY == _fre_mode) {
        
        // 自定义一周中那些天响的闹铃
        [_btnOneOff changeStatus:NO];
        
        if (_frequency & FREQUENCY_MONDAY) {
            [_btnMonday changeStatus:YES];
        } else {
            [_btnMonday changeStatus:NO];
        }
        
        if (_frequency & FREQUENCY_TUESDAY) {
            [_btnTuesday changeStatus:YES];
        } else {
            [_btnTuesday changeStatus:NO];
        }
        
        if (_frequency & FREQUENCY_WEDNESDAY) {
            [_btnWednesday changeStatus:YES];
        } else {
            [_btnWednesday changeStatus:NO];
        }
        
        if (_frequency & FREQUENCY_THURSDAY) {
            [_btnThursday changeStatus:YES];
        } else {
            [_btnThursday changeStatus:NO];
        }
        
        if (_frequency & FREQUENCY_FRIDAY) {
            [_btnFriday changeStatus:YES];
        } else {
            [_btnFriday changeStatus:NO];
        }
        
        if (_frequency & FREQUENCY_SATURDAY) {
            [_btnSaturday changeStatus:YES];
        } else {
            [_btnSaturday changeStatus:NO];
        }
        
        if (_frequency & FREQUENCY_SUNDAY) {
            [_btnSunday changeStatus:YES];
        } else {
            [_btnSunday changeStatus:NO];
        }
        
        NSInteger value = _frequency & (FREQUENCY_MONDAY|FREQUENCY_TUESDAY|FREQUENCY_WEDNESDAY|FREQUENCY_THURSDAY|FREQUENCY_FRIDAY|FREQUENCY_SATURDAY|FREQUENCY_SUNDAY);
        if (value == (FREQUENCY_MONDAY|FREQUENCY_TUESDAY|FREQUENCY_WEDNESDAY|FREQUENCY_THURSDAY|FREQUENCY_FRIDAY|FREQUENCY_SATURDAY|FREQUENCY_SUNDAY)) {
                
            _fre_mode = FRE_MODE_EVERYDAY;
            [_btnEverday changeStatus:YES];
        } else if (0 == value) {
            _fre_mode = FRE_MODE_ONEOFF;
            [_btnOneOff changeStatus:YES];
        } else {
            [_btnEverday changeStatus:NO];
        }
    }
}

- (void)buttonClick:(UIButton *)button {
    if (button == _btnOneOff) {
        /* 一次性 */
        if (FRE_MODE_ONEOFF != _fre_mode) {
            
            _fre_mode = FRE_MODE_ONEOFF;
        } else {
            _fre_mode = FRE_MODE_EVERYDAY;
        }
    } else if (button == _btnEverday) {
        /* 每天 */
        if (FRE_MODE_EVERYDAY != _fre_mode) {
            _fre_mode = FRE_MODE_EVERYDAY;
            _frequency &= ~(FREQUENCY_MONDAY|FREQUENCY_TUESDAY|FREQUENCY_WEDNESDAY|FREQUENCY_THURSDAY|FREQUENCY_FRIDAY|FREQUENCY_SATURDAY|FREQUENCY_SUNDAY);
            _frequency |= FREQUENCY_MONDAY|FREQUENCY_TUESDAY|FREQUENCY_WEDNESDAY|FREQUENCY_THURSDAY|FREQUENCY_FRIDAY|FREQUENCY_SATURDAY|FREQUENCY_SUNDAY;
        } else {
            _fre_mode = FRE_MODE_ONEOFF;
            _frequency &= ~(FREQUENCY_MONDAY|FREQUENCY_TUESDAY|FREQUENCY_WEDNESDAY|FREQUENCY_THURSDAY|FREQUENCY_FRIDAY|FREQUENCY_SATURDAY|FREQUENCY_SUNDAY);
            _frequency |= FREQUENCY_MONDAY|FREQUENCY_TUESDAY|FREQUENCY_WEDNESDAY|FREQUENCY_THURSDAY|FREQUENCY_FRIDAY;
        }
    } else {
        /* 一周中某天 */
        _fre_mode = FRE_MODE_WEEKLY;
        if (button == _btnMonday) {
            if (_frequency & FREQUENCY_MONDAY) {
                _frequency &= ~FREQUENCY_MONDAY;
            } else {
                _frequency |= FREQUENCY_MONDAY;
            }
        }
        
        if (button == _btnTuesday) {
            if (_frequency & FREQUENCY_TUESDAY) {
                _frequency &= ~FREQUENCY_TUESDAY;
            } else {
                _frequency |= FREQUENCY_TUESDAY;
            }
        }
        
        if (button == _btnWednesday) {
            if (_frequency & FREQUENCY_WEDNESDAY) {
                _frequency &= ~FREQUENCY_WEDNESDAY;
            } else {
                _frequency |= FREQUENCY_WEDNESDAY;
            }
        }
        
        if (button == _btnThursday) {
            if (_frequency & FREQUENCY_THURSDAY) {
                _frequency &= ~FREQUENCY_THURSDAY;
            } else {
                _frequency |= FREQUENCY_THURSDAY;
            }
        }
        
        if (button == _btnFriday) {
            if (_frequency & FREQUENCY_FRIDAY) {
                _frequency &= ~FREQUENCY_FRIDAY;
            } else {
                _frequency |= FREQUENCY_FRIDAY;
            }
        }
        
        if (button == _btnSaturday) {
            if (_frequency & FREQUENCY_SATURDAY) {
                _frequency &= ~FREQUENCY_SATURDAY;
            } else {
                _frequency |= FREQUENCY_SATURDAY;
            }
        }
        
        if (button == _btnSunday) {
            if (_frequency & FREQUENCY_SUNDAY) {
                _frequency &= ~FREQUENCY_SUNDAY;
            } else {
                _frequency |= FREQUENCY_SUNDAY;
            }
        }
    }
    
    [self updateUI];
}

@end

@interface AlarmDetailViewController () <YYTXDeviceManagerDelegate, JGActionSheetDelegate, UITextViewDelegate>
{

}

@property (nonatomic, retain) IBOutlet UIButton *buttonOpenAlarm;
@property (nonatomic, retain) IBOutlet UIButton *buttonDeleteAlarm;
@property (nonatomic, retain) IBOutlet IQTextView *textViewAlarmTitle;
@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, retain) IBOutlet UILabel *labelTitleLength;
//@property (nonatomic, retain) IBOutlet UILabel *labelTitleMaxLength;
@property (nonatomic, retain) IBOutlet UILabel *labelAlarmCycle;
@property (nonatomic, retain) IBOutlet UILabel *labelFireDate;
@property (nonatomic, retain) IBOutlet UILabel *labelDate;
@property (nonatomic, retain) IBOutlet UIButton *btnAlarmSet;
@property (nonatomic, assign) BOOL displayAlarmDate;
@end

@implementation AlarmDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%s", __func__);
    
    [_textViewAlarmTitle setPlaceholder:NSLocalizedStringFromTable(@"pleaseInputAlarmTitle", @"hint", nil)];

    UIBarButtonItem *buttonSave;
    if (_isAddAlarm) {
        /* 添加闹铃 */
    } else {
        /* 修改闹铃 */
        buttonSave = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"save", @"hint", nil) style:UIBarButtonItemStyleDone target:self action:@selector(modifyAlarm)];
    }
    /* 设置工具条 */
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = [[NSArray alloc] initWithObjects:space, buttonSave, space, nil];
    
    if (_isGetupAlarm) {
        /* 起床闹铃 */
        [self.navigationItem setTitle:NSLocalizedStringFromTable(@"getupAlarm", @"hint", nil)];
        
//        [_labelTitleMaxLength setHidden:YES];
        [_labelTitleLength setHidden:YES];
    } else {
        /* 自定义闹铃 */
        [self.navigationItem setTitle:NSLocalizedStringFromTable(@"customAlarm", @"hint", nil)];
        
        [_labelTitleLength setHidden:NO];
//        [_labelTitleMaxLength setHidden:NO];
//        [_labelTitleMaxLength setText:[NSString stringWithFormat:@"/%d", MAXCUSTOMIZEALARMTITLELENGTH]];
//        [_labelTitleMaxLength setTextColor:[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f]];
    }
    
    [self hideEmptySeparators:self.tableView];
    
    /* 隐藏separator */
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4]];
    [cell setSeparatorInset:UIEdgeInsetsMake(0, self.tableView.frame.size.width, 0, 0)];
    
    /* 起床闹铃通用设置按钮的边框 */
    _btnAlarmSet.layer.cornerRadius = 10.0f;
    _btnAlarmSet.layer.borderColor = [UIColor grayColor].CGColor;
    _btnAlarmSet.layer.borderWidth = 0.8f;
    
    _displayAlarmDate= NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%s", __func__);
    
    self.deviceManager.delegate = self;
    
    if (self.deviceManager.device.isAbsent) {
        /* 与设备的连接已断开 */
        [self initEffectViewWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
    } else {

        if (_isAddAlarm) {
            
        } else {
            [self.navigationController setToolbarHidden:NO animated:YES];
        }
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_isGetupAlarm) {
        return 5; // 起床闹铃(有通用设置)
    } else {
        return 4; // 自定义闹铃(无通用设置)
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (0 == section) {
        if (_isAddAlarm) {
            return 0;
        } else {
            return 1;
        }
    } else if (1 == section) {
        return 1;
    } else if (2 == section) {
        return 1;
    } else if (3 == section) {
        if (_displayAlarmDate) {
            return 2;
        } else {
            return 1;
        }
    } else if (4 == section) {
        return 1;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (3 == indexPath.section) {
        
        if (0 == indexPath.row) {
            /* 闹铃的周期性 */
            AlarmClycleView *alarmCycleView = [[AlarmClycleView alloc] initWithFrame:CGRectMake(0, 0, 290.0f, 170.0f)];

            alarmCycleView.fre_mode = _alarm.fre_mode;
            alarmCycleView.frequency = _alarm.frequency;
            [alarmCycleView updateUI];
            
            JGActionSheetSection *s0 = [JGActionSheetSection sectionWithTitle:NSLocalizedStringFromTable(@"alarmCycle", @"hint", nil) message:nil contentView:alarmCycleView]; // 初始化section
            JGActionSheetSection *s1 = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[NSLocalizedStringFromTable(@"ok", @"hint", nil)] buttonStyle:JGActionSheetButtonStyleDefault]; // 初始化sheet
            [s1 setButtonStyle:JGActionSheetButtonStyleDefault forButtonAtIndex:0];
            
            JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:@[s0, s1]];
            sheet.delegate = self;
            sheet.insets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                /* iPad设备中显示的位置 */
                CGPoint p = (CGPoint){-5.0f, CGRectGetMidY(_labelAlarmCycle.bounds)};
                p = [self.navigationController.view convertPoint:p fromView:_labelAlarmCycle];
                [sheet showFromPoint:p inView:self.navigationController.view arrowDirection:JGActionSheetArrowDirectionRight animated:YES];
            }
            else {
                /* iPhone */
                [sheet showInView:self.navigationController.view animated:YES];
            }
            
            [sheet setOutsidePressBlock:^(JGActionSheet *sheet) { // 点击了sheet之外的区域
                [sheet dismissAnimated:YES];
            }];
            
            [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) { // 点击了sheet中的某个section

                [sheet dismissAnimated:YES];
                
                if (1 == indexPath.section) {
                    if (0 == indexPath.row) {

                        _alarm.fre_mode = alarmCycleView.fre_mode;
                        _alarm.frequency = alarmCycleView.frequency;
                        [self updateUI];
                    }
                }
            }];
        } else if (1 == indexPath.row) {
            /* 闹铃的响铃日期 */
            UIDatePicker *datePicker = [[UIDatePicker alloc] init];
            datePicker.frame = CGRectMake(0, 0, 290.0f, 170.0f);
            [datePicker setDatePickerMode:UIDatePickerModeDate];
            NSDate *date = [_labelDate.text convertToNSDateFromDateString];
            if (nil != date) {
                [datePicker setDate:date];
            }
            
            JGActionSheetSection *s0 = [JGActionSheetSection sectionWithTitle:NSLocalizedStringFromTable(@"fireDate", @"hint", nil) message:nil contentView:datePicker]; // 初始化section
            JGActionSheetSection *s1 = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[NSLocalizedStringFromTable(@"ok", @"hint", nil)] buttonStyle:JGActionSheetButtonStyleDefault]; // 初始化sheet
            
            JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:@[s0, s1]];
            sheet.delegate = self;
            sheet.insets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                /* iPad中的现实位置 */
                CGPoint p = (CGPoint){-5.0f, CGRectGetMidY(_labelDate.bounds)};
                p = [self.navigationController.view convertPoint:p fromView:_labelDate];
                [sheet showFromPoint:p inView:self.navigationController.view arrowDirection:JGActionSheetArrowDirectionRight animated:YES];
            }
            else {
                /* iPhone */
                [sheet showInView:self.navigationController.view animated:YES];
            }
            
            [sheet setOutsidePressBlock:^(JGActionSheet *sheet) { // 点击了sheet之外的区域
                [sheet dismissAnimated:YES];
            }];
            
            [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) { // 点击了sheet中的某个section
                
                NSLog(@"%s sec:%ld row:%ld", __func__, (long)indexPath.section, (long)indexPath.row);
                
                [sheet dismissAnimated:YES];
                
                if (1 == indexPath.section) {
                    if (0 == indexPath.row) {
                        _alarm.date = [datePicker.date getDateString];
                        [self updateUI];
                    }
                }
            }];
        }
    }
}

/** 闹铃标题长度检查 */
- (BOOL)titleLengthCheck {
    NSInteger length = _textViewAlarmTitle.text.length;
    NSString *str = [NSString stringWithFormat:@"%@/%@", @(length), @MAXCUSTOMIZEALARMTITLELENGTH];
    NSRange range = [str rangeOfString:@"/"];
    NSLog(@"%s range:%@", __func__, NSStringFromRange(range));
    NSRange range1 = NSMakeRange(0, range.location);
    NSLog(@"%s range1:%@", __func__, NSStringFromRange(range1));
    BOOL statusCode;
    // 创建可变属性化字符串
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:str];
    // 设置基本字体
    UIFont *baseFont = [UIFont systemFontOfSize:15.0f];
    UIColor *baseColor = [UIColor grayColor];
    [attrString addAttributes:@{NSFontAttributeName:baseFont, NSForegroundColorAttributeName:baseColor} range:NSMakeRange(0, str.length)];
    
    if ((0 < length) && (length <= MAXCUSTOMIZEALARMTITLELENGTH)) {
        statusCode = YES;
    } else {
        [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range1];
        
        statusCode = NO;
    }
    
    _labelTitleLength.attributedText = attrString;
    
    return statusCode;
}

/** 检查用户提供的各种参数是否有效 */
- (BOOL)inputParametersIsValid {
    _alarm.title = _textViewAlarmTitle.text;
    
    /* 检查字数是否符合要求 */
    if (![self titleLengthCheck]) {
        
        if (_alarm.title.length <= 0) {
            [QXToast showMessage:NSLocalizedStringFromTable(@"theAlarmTitleIsEmpty", @"hint", nil)];
        } else {
            [QXToast showMessage:NSLocalizedStringFromTable(@"alarmTitleIsTooLong", @"hint", nil)];
        }
        
        [_textViewAlarmTitle becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        
        return NO;
    }
    
    /* 去掉其中的空格和换行 */
    NSString *str = [_alarm.title stringByReplacingOccurrencesOfString:@" " withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    [_textViewAlarmTitle setText:str];
    if (str.length <= 0) {
        
        [_textViewAlarmTitle becomeFirstResponder];
        [QXToast showMessage:NSLocalizedStringFromTable(@"theAlarmTitleInvalid", @"hint", nil)];
        return NO;
    } else {
        
        _alarm.title = str;
    }
    
    /* 选择的为一次性闹铃 */
    if (FRE_MODE_ONEOFF == _alarm.fre_mode) {
        /* 用户选择的时间 */
        NSString *alarmDate = _alarm.date;
        NSString *alarmTime = [_alarm.clock substringToIndex:5];
        /* 当前的时间 */
        NSString *curDate = [[NSDate date] getDateString];
        NSString *curTime = [[[NSDate date] getTimeString] substringToIndex:5];
        
        NSComparisonResult resultDateCompare = [alarmDate compare:curDate];
        if (NSOrderedAscending == resultDateCompare) { // 选择的日期已过期
            [QXToast showMessage:NSLocalizedStringFromTable(@"invalidAlarmTime", @"hint", nil)];
            return NO;
        } else if (NSOrderedSame == resultDateCompare) {
            /* 选择的日期为今天 */
            NSComparisonResult resultTimeCompare = [alarmTime compare:curTime];
            if (NSOrderedDescending != resultTimeCompare) { // 选择的时间已过去
                [QXToast showMessage:NSLocalizedStringFromTable(@"invalidAlarmTime", @"hint", nil)];
                return NO;
            }
        }
    }
    
    return YES;
}

/** 闹铃开关按钮被点击 */
- (IBAction)buttonOpenAlarmClick:(id)sender {
    NSString *open = NSLocalizedStringFromTable(@"open", @"hint", nil);
    NSString *close = NSLocalizedStringFromTable(@"close", @"hint", nil);
    NSString *buttonCancelTitle = NSLocalizedStringFromTable(@"cancel", @"hint", nil);
    NSString *message;
    NSString *buttonOkTitle;
    
    if ([_alarm is_valid]) {
        /* 闹铃已被开启 */
        message = NSLocalizedStringFromTable(@"closeThisAlarm?", @"hint", nil);
        buttonOkTitle = close;
    } else {
        /* 闹铃已被关闭 */
        message = NSLocalizedStringFromTable(@"openThisAlarm?", @"hint", nil);
        buttonOkTitle = open;
    }
    
    /* 弹出对话窗 */
    if ([SystemToolClass systemVersionIsNotLessThan:@"8.0"]) {
        /* IOS8.0及以后 */
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[SystemToolClass appName] message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:buttonCancelTitle style:UIAlertActionStyleDefault handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:buttonOkTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            if ([action.title isEqualToString:open]) {
                [self openAlarm:YES];
            } else if ([action.title isEqualToString:close]) {
                [self openAlarm:NO];
            }
        }]];
        
        if (nil != alertController) {
            [self presentViewController:alertController animated:YES completion:nil];
        }
    } else {
        /* IOS6.0 及以后，但是低于IOS8.0 */
        UICustomAlertView *alertView = [[UICustomAlertView alloc] initWithTitle:[SystemToolClass appName] message:message delegate:self cancelButtonTitle:buttonCancelTitle otherButtonTitles:buttonOkTitle, nil];
        
        [alertView showAlertViewWithCompleteBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
            if ([buttonTitle isEqualToString:open]) {
                [self openAlarm:YES];
            } else if ([buttonTitle isEqualToString:close]) {
                [self openAlarm:NO];
            }
        }];
    }
}

/** 删除闹铃按钮被点击 */
- (IBAction)buttonDeleteAlarmClick:(id)sender {
    NSString *message = NSLocalizedStringFromTable(@"deleteThisAlarm?", @"hint", nil);
    NSString *buttonCancelTitle = NSLocalizedStringFromTable(@"cancel", @"hint", nil);
    NSString *buttonDeleteTitle = NSLocalizedStringFromTable(@"delete", @"hint", nil);
    
    if ([SystemToolClass systemVersionIsNotLessThan:@"8.0"]) {
        /* IOS8.0及以后 */
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[SystemToolClass appName] message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:buttonCancelTitle style:UIAlertActionStyleDefault handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:buttonDeleteTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
            [self deleteAlarm];
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
                [self deleteAlarm];
            }
        }];
    }
}

- (IBAction)datePickerValueChange:(id)sender {
    
    _alarm.clock = [_datePicker.date getTimeString];
}

- (IBAction)buttonAlarmSetClick:(id)sender {
    [self gotoSetView];
}

- (void)updateUI {
    
    if (!_isAddAlarm) {
        if (_alarm.is_valid) {
            [_buttonOpenAlarm setSelected:YES];
        } else {
            [_buttonOpenAlarm setSelected:NO];
        }
    }
    
    // 根据是不是起床闹铃设置textfeild的状态
    if (_isGetupAlarm) {
        // 如果是起床闹铃
        [_textViewAlarmTitle setUserInteractionEnabled:NO];
    } else {
        // 如果是自定义闹铃
        [_textViewAlarmTitle setUserInteractionEnabled:YES];
        [_textViewAlarmTitle setTextColor:[UIColor colorWithRed:.0f green:128.0f/255.0f blue:1.0f alpha:1.0f]];
        [self titleLengthCheck];
    }
    
    [_textViewAlarmTitle setText:_alarm.title];

    /* 闹铃日期 */
    NSDate *date = [_alarm.clock convertToNSDateFromTimeString];
    [_datePicker setDatePickerMode:UIDatePickerModeTime];
    if (nil != date) {
        [_datePicker setDate:date animated:YES];
    }
    
    if (FRE_MODE_ONEOFF == _alarm.fre_mode && !_displayAlarmDate) {
        /* 一次性闹铃，需要显示日期选择选项 */
        _displayAlarmDate = YES;
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:3]] withRowAnimation:UITableViewRowAnimationTop];
    } else if (FRE_MODE_ONEOFF != _alarm.fre_mode && _displayAlarmDate) {
        /* 非一次性闹铃，隐藏日期选择选项 */
        _displayAlarmDate = NO;
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:3]] withRowAnimation:UITableViewRowAnimationTop];
    }
    
    [_labelAlarmCycle setText:[AlarmClass getAlarmCycle:_alarm]];
    [_labelDate setText:_alarm.date];
    
    NSLog(@"%s %@", __func__, [AlarmClass getAlarmCycle:_alarm]);
}

/** 跳转到闹铃通用设置界面 */
- (void)gotoSetView {
    
    AlarmSetViewController *alarmSetVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AlarmSetViewController"];
    alarmSetVC.deviceManager = self.deviceManager;
    if (nil != alarmSetVC) {
        [self.navigationController pushViewController:alarmSetVC animated:YES];
    }
}

#pragma UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {

    if (textView.text.length >= 1) {
        /* 检查是否以包含空格 */
        NSRange range1 = [textView.text rangeOfString:@" "];
        if (NSNotFound != range1.location) {
            [QXToast showMessage:NSLocalizedStringFromTable(@"invalidCharacterOrFormatForAlarmTitle", @"hint", nil)];
            textView.text = [textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            [self titleLengthCheck];
            return;
        }
#if 0
        if (0 == range1.location) {
            [self showMessage:NSLocalizedStringFromTable(@"invalidCharacterOrFormatForAlarmTitle", @"hint", nil) messageType:0];
            textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [self titleLengthCheck];
            return;
        }
        
        /* 检查是否以空格结束 */
        NSString *sub = [textView.text substringFromIndex:textView.text.length-1];
        if ([sub isEqualToString:@" "]) {
            [self showMessage:NSLocalizedStringFromTable(@"invalidCharacterOrFormatForAlarmTitle", @"hint", nil) messageType:0];
            textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [self titleLengthCheck];
            return;
        }
#endif
        /* 检查是否包含回车符 */
        NSRange range2 = [textView.text rangeOfString:@"\n"];
        if (NSNotFound != range2.location) {
            [QXToast showMessage:NSLocalizedStringFromTable(@"invalidCharacterOrFormatForAlarmTitle", @"hint", nil)];
            textView.text = [textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            [self titleLengthCheck];
            return;
        }
    }
    
    _alarm.title = textView.text;
    [self titleLengthCheck];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    [self titleLengthCheck];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    [self titleLengthCheck];
}

#pragma 闹铃数据源

/** 闹铃开关 */
- (void)openAlarm:(BOOL)open {
    NSString *successful;
    NSString *failed;
    
    if (![self inputParametersIsValid]) { // 检查用户选择的参数是否有效
        return;
    }
    
    if (_isGetupAlarm) {
        /* 起床闹铃 */
        if (open) { // 打开闹铃？
            successful = NSLocalizedStringFromTable(@"openGetupAlarmSuccessful", @"hint", nil);
            failed = NSLocalizedStringFromTable(@"openGetupAlarmFailed", @"hint", nil);
            _alarm.is_valid = YES;
        } else {
            successful = NSLocalizedStringFromTable(@"closeGetupAlarmSuccessful", @"hint", nil);
            failed = NSLocalizedStringFromTable(@"closeGetupAlarmFailed", @"hint", nil);
            _alarm.is_valid = NO;
        }
    } else {
        /* 自定义闹铃 */
        if (open) { // 打开闹铃？
            successful = NSLocalizedStringFromTable(@"openCustomAlarmSuccessful", @"hint", nil);
            failed = NSLocalizedStringFromTable(@"openCustomAlarmFailed", @"hint", nil);
            _alarm.is_valid = YES;
        } else {
            successful = NSLocalizedStringFromTable(@"closeCustomAlarmSuccessful", @"hint", nil);
            failed = NSLocalizedStringFromTable(@"closeCustomAlarmFailed", @"hint", nil);
            _alarm.is_valid = NO;
        }
    }
    
    /* 生成操作成功时终端设备的TTS提示 */
    NSArray *arr = [_alarm.clock componentsSeparatedByString:@":"];
    if (arr.count >= 2) {
        NSString *hour = arr[0];
        NSString *minute = arr[1];
        successful = [NSString stringWithFormat:successful, hour, minute];
    }
    
    [self showActiviting];
    
    /* 向设备发送数据修改闹铃 */
    [self.deviceManager.device modifyAlarm:_alarm parameter:@{DevicePlayTTSWhenOperationSuccessful:successful, DevicePlayTTSWhenOperationFailed:failed} completionBlock:^(YYTXDeviceReturnCode code) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self removeEffectView];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
}

/** 修改闹铃 */
- (void)modifyAlarm {
    
    NSLog(@"%s alarm:%@", __func__, _alarm);

    if (![self inputParametersIsValid]) {
        return;
    }

    [self showBusying:NSLocalizedStringFromTable(@"saving", @"hint", nil)];
    
    /* 生成操作成功和失败时设备端播放的TTS提示 */
    NSString *successfulHint;
    NSString *failedHint;
    NSString *successful;
    NSString *year;
    NSString *month;
    NSString *day;
    NSString *hour;
    NSString *minute;
    NSArray *arr1 = [_alarm.clock componentsSeparatedByString:@":"];
    if (arr1.count >= 2) {
        hour = arr1[0];
        minute = arr1[1];
    }
    
    NSArray *arr2 = [_alarm.date componentsSeparatedByString:@"-"];
    if (arr2.count >= 3) {
        year = arr2[0];
        month = arr2[1];
        day = arr2[2];
    }
    
    if ([_alarm.title isEqualToString:@ALARMTYPE_GETUP]) {
        /* 起床闹铃 */
        if (FRE_MODE_ONEOFF == _alarm.fre_mode) {
            /* 一次性闹铃 */
            successfulHint = NSLocalizedStringFromTable(@"modifyOneOffGetupAlarmSuccessful", @"hint", nil);
            successful = [NSString stringWithFormat:successfulHint, year, month, day, hour, minute];
        } else {
            /* 非一次性闹铃 */
            successfulHint = NSLocalizedStringFromTable(@"modifyGetupAlarmSuccessful", @"hint", nil);
            successful = [NSString stringWithFormat:successfulHint, hour, minute];
        }
        failedHint = NSLocalizedStringFromTable(@"modifyGetupAlarmFailed", @"hint", nil);
    } else {
        /* 自定义闹铃 */
        if (FRE_MODE_ONEOFF == _alarm.fre_mode) {
            /* 一次性闹铃 */
            successfulHint = NSLocalizedStringFromTable(@"modifyOneOffCustomAlarmSuccessful", @"hint", nil);
            
            successful = [NSString stringWithFormat:successfulHint, year, month, day, hour, minute];
        } else {
            /* 非一次性闹铃 */
            successfulHint = NSLocalizedStringFromTable(@"modifyCustomAlarmSuccessful", @"hint", nil);
            successful = [NSString stringWithFormat:successfulHint, hour, minute];
        }
        failedHint = NSLocalizedStringFromTable(@"modifyCustomAlarmFailed", @"hint", nil);
    }
    
    /* 将新的闹铃数据发送到设备 */
    [self.deviceManager.device modifyAlarm:_alarm parameter:@{DevicePlayTTSWhenOperationSuccessful:successful, DevicePlayTTSWhenOperationFailed:failedHint}  completionBlock:^(YYTXDeviceReturnCode code) {

        dispatch_async(dispatch_get_main_queue(), ^{

            [self removeEffectView];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
}

/** 删除闹铃 */
- (void)deleteAlarm {
    NSString *successful = NSLocalizedStringFromTable(@"deleteSuccessful", @"hint", nil);
    NSString *failed = NSLocalizedStringFromTable(@"deleteFailed", @"hint", nil);
    
    [self showActiviting];
    
    [self.deviceManager.device deleteAlarm:_alarm.ID params:@{DevicePlayTTSWhenOperationSuccessful:successful, DevicePlayTTSWhenOperationFailed:failed} completionBlock:^(YYTXDeviceReturnCode code) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self removeEffectView];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
}

/** 添加到闹铃 */
- (void)addAlarm:(void (^)(void))popVC {
    
    NSLog(@"%s alarm:%@", __func__, _alarm);
    
    if (![self inputParametersIsValid]) {
        return;
    }

    [self showBusying:NSLocalizedStringFromTable(@"saving", @"hint", nil)];
    
    /* 生成操作成功和失败时设备端播放的TTS提示 */
    NSString *successfulHint;
    NSString *failedHint;
    NSString *successful;
    NSString *year;
    NSString *month;
    NSString *day;
    NSString *hour;
    NSString *minute;
    NSArray *arr1 = [_alarm.clock componentsSeparatedByString:@":"];
    if (arr1.count >= 2) {
        hour = arr1[0];
        minute = arr1[1];
    }
    
    NSArray *arr2 = [_alarm.date componentsSeparatedByString:@"-"];
    if (arr2.count >= 3) {
        year = arr2[0];
        month = arr2[1];
        day = arr2[2];
    }
    
    if ([_alarm.title isEqualToString:@ALARMTYPE_GETUP]) {
        /* 起床闹铃 */
        if (FRE_MODE_ONEOFF == _alarm.fre_mode) {
            /* 一次性 */
            successfulHint = NSLocalizedStringFromTable(@"insertOneOffGetupAlarmSuccessful", @"hint", nil);
            successful = [NSString stringWithFormat:successfulHint, year, month, day, hour, minute];
            
        } else {
            /* 非一次性 */
            successfulHint = NSLocalizedStringFromTable(@"insertGetupAlarmSuccessful", @"hint", nil);
            
            successful = [NSString stringWithFormat:successfulHint, hour, minute];
        }
       failedHint = NSLocalizedStringFromTable(@"insertGetupAlarmFailed", @"hint", nil);
    } else {
        /* 自定义闹铃 */
        if (FRE_MODE_ONEOFF == _alarm.fre_mode) {
            /* 一次性 */
            successfulHint = NSLocalizedStringFromTable(@"insertOneOffCustomAlarmSuccessful", @"hint", nil);
            successful = [NSString stringWithFormat:successfulHint, year, month, day, hour, minute];
        } else {
            /* 非一次性 */
            successfulHint = NSLocalizedStringFromTable(@"insertCustomAlarmSuccessful", @"hint", nil);
            
            successful = [NSString stringWithFormat:successfulHint, hour, minute];
        }
        failedHint = NSLocalizedStringFromTable(@"insertCustomAlarmFailed", @"hint", nil);
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (nil != successful) {
        [dic addEntriesFromDictionary: @{DevicePlayTTSWhenOperationSuccessful:successful}];
    }
    
    [dic addEntriesFromDictionary:@{DevicePlayTTSWhenOperationFailed:failedHint}];
    
    __block AlarmDetailViewController *alarmDetailVC = self;
    [self.deviceManager.device addAlarm:_alarm params:dic completionBlock:^(YYTXDeviceReturnCode code) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [alarmDetailVC removeEffectView];
            [alarmDetailVC.navigationController popViewControllerAnimated:YES];
        });
    }];
}

@end
