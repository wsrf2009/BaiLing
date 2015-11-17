//
//  AddingAlarmViewController.m
//  CloudBox
//
//  Created by TTS on 15/8/18.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "AddingAlarmViewController.h"
#import "AlarmDetailViewController.h"
#import "RemindViewController.h"
#import "BirthdayViewController.h"

@interface AddingAlarmViewController () <UIScrollViewDelegate>

//@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, retain) UIButton *btnGetupAlarm;
@property (nonatomic, retain) UIButton *btnCustomizeAlarm;
@property (nonatomic, retain) UIButton *btnRemindAlarm;
@property (nonatomic, retain) UIButton *btnBirthdayAlarm;

@property (nonatomic, retain) UIScrollView *container;

@property (nonatomic, retain) AlarmDetailViewController *getupAlarmVC;
@property (nonatomic, retain) AlarmDetailViewController *customizeAlarmVC;
@property (nonatomic, retain) RemindViewController *remindAlarmVC;
@property (nonatomic, retain) BirthdayViewController *birthdayAlarmVC;

@property (nonatomic, retain) UIViewController *currentVC;

@property (nonatomic, retain) UIBarButtonItem *barButtonSave;

@end

@implementation AddingAlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%s", __func__);
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"insertAlarm", @"hint", nil)];
    [self.navigationController.toolbar setTranslucent:NO];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _barButtonSave = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"save", @"hint", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveAlarm)];
    self.toolbarItems = @[space, _barButtonSave, space];
    [_barButtonSave setEnabled:NO];
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(enableBarButtonSave) userInfo:nil repeats:NO];
    
    /* 起床闹铃 */
    _btnGetupAlarm = [[UIButton alloc] init];
    [_btnGetupAlarm setImage:[UIImage imageNamed:@"awakealart_nor.png"] forState:UIControlStateNormal];
    [_btnGetupAlarm setImage:[UIImage imageNamed:@"awakealart_pre.png"] forState:UIControlStateSelected];
    [_btnGetupAlarm setSelected:YES];
    [_btnGetupAlarm addTarget:self action:@selector(getupAlarmClicked:) forControlEvents:UIControlEventTouchUpInside];
    _btnGetupAlarm.translatesAutoresizingMaskIntoConstraints = NO;
    
    /* 自定义闹铃 */
    _btnCustomizeAlarm = [[UIButton alloc] init];
    [_btnCustomizeAlarm setImage:[UIImage imageNamed:@"definedalart_nor.png"] forState:UIControlStateNormal];
    [_btnCustomizeAlarm setImage:[UIImage imageNamed:@"definedalart_pre.png"] forState:UIControlStateSelected];
    [_btnCustomizeAlarm addTarget:self action:@selector(customizeAlarmClicked:) forControlEvents:UIControlEventTouchUpInside];
    _btnCustomizeAlarm.translatesAutoresizingMaskIntoConstraints = NO;
    
    /* 备忘提醒 */
    _btnRemindAlarm = [[UIButton alloc] init];
    [_btnRemindAlarm setImage:[UIImage imageNamed:@"remind_nor.png"] forState:UIControlStateNormal];
    [_btnRemindAlarm setImage:[UIImage imageNamed:@"remind_pre.png"] forState:UIControlStateSelected];
    [_btnRemindAlarm addTarget:self action:@selector(remindAlarmClicked:) forControlEvents:UIControlEventTouchUpInside];
    _btnRemindAlarm.translatesAutoresizingMaskIntoConstraints = NO;
    
    /* 生日提醒 */
    _btnBirthdayAlarm = [[UIButton alloc] init];
    [_btnBirthdayAlarm setImage:[UIImage imageNamed:@"birthdayalart_nor.png"] forState:UIControlStateNormal];
    [_btnBirthdayAlarm setImage:[UIImage imageNamed:@"birthdayalart_pre.png"] forState:UIControlStateSelected];
    [_btnBirthdayAlarm addTarget:self action:@selector(birthdayAlarmClicked:) forControlEvents:UIControlEventTouchUpInside];
    _btnBirthdayAlarm.translatesAutoresizingMaskIntoConstraints = NO;
    
    _container = [[UIScrollView alloc] init];
    _container.delegate = self;
    [_container setPagingEnabled:YES];
    _container.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_btnGetupAlarm];
    [self.view addSubview:_btnCustomizeAlarm];
    [self.view addSubview:_btnRemindAlarm];
    [self.view addSubview:_btnBirthdayAlarm];
    [self.view addSubview:_container];
    
    _getupAlarmVC = [[UIStoryboard storyboardWithName:@"Alarms" bundle:nil] instantiateViewControllerWithIdentifier:@"AlarmDetailViewController"];
    _getupAlarmVC.isGetupAlarm = YES;
    _getupAlarmVC.deviceManager = _deviceManager;
    _getupAlarmVC.isAddAlarm = YES;
    _getupAlarmVC.alarm = [[AlarmClass alloc] initAlarmTitle:NSLocalizedStringFromTable(@"getup", @"hint", nil) alarmList:_deviceManager.device.userData.alarmList];
    
    _customizeAlarmVC = [[UIStoryboard storyboardWithName:@"Alarms" bundle:nil] instantiateViewControllerWithIdentifier:@"AlarmDetailViewController"];
    _customizeAlarmVC.isGetupAlarm = NO;
    _customizeAlarmVC.deviceManager = _deviceManager;
    _customizeAlarmVC.isAddAlarm = YES;
    _customizeAlarmVC.alarm = [[AlarmClass alloc] initAlarmTitle:nil alarmList:_deviceManager.device.userData.alarmList];
    
    _remindAlarmVC = [[UIStoryboard storyboardWithName:@"Alarms" bundle:nil]instantiateViewControllerWithIdentifier:@"RemindViewController"];
    _remindAlarmVC.deviceManager = _deviceManager;
    _remindAlarmVC.isAddAlarm = YES;
    _remindAlarmVC.remind = [[RemindClass alloc] initWithRemindList:_deviceManager.device.userData.remindList];
    
    _birthdayAlarmVC = [[UIStoryboard storyboardWithName:@"Alarms" bundle:nil] instantiateViewControllerWithIdentifier:@"BirthdayViewController"];
    _birthdayAlarmVC.deviceManager = _deviceManager;
    _birthdayAlarmVC.isAddAlarm = YES;
    _birthdayAlarmVC.birthday = [[BirthdayClass alloc] initWithBirtdayList:_deviceManager.device.userData.birthdayList];
    
    [self getupAlarmClicked:_btnGetupAlarm]; // 默认选中起床闹铃
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"%s", __func__);
    
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_btnGetupAlarm attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:10.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_btnCustomizeAlarm attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:10.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_btnRemindAlarm attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:10.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_btnBirthdayAlarm attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:10.0f]];
    
    CGFloat width = 60.0f;
    CGFloat space = (CGRectGetWidth(self.view.frame)-4*width)/5;
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==space)-[_btnGetupAlarm]-(==space)-[_btnCustomizeAlarm]-(==space)-[_btnRemindAlarm]-(==space)-[_btnBirthdayAlarm]-(==space)-|" options:0 metrics:@{@"space":[NSNumber numberWithFloat:space]} views:NSDictionaryOfVariableBindings(_btnGetupAlarm, _btnCustomizeAlarm, _btnRemindAlarm, _btnBirthdayAlarm)]];
    
    // 设置按钮的宽度
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_btnGetupAlarm attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_btnCustomizeAlarm attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_btnRemindAlarm attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_btnBirthdayAlarm attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width]];
    
    // 设置按钮的高度
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_btnGetupAlarm attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_btnGetupAlarm attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_btnCustomizeAlarm attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_btnCustomizeAlarm attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_btnRemindAlarm attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_btnRemindAlarm attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_btnBirthdayAlarm attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_btnBirthdayAlarm attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_container attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_btnGetupAlarm attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_container attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_container attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_container attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/** 起床闹铃被选中 */
- (void)getupAlarmSelected {
    [_btnGetupAlarm setSelected:YES];
    [_btnCustomizeAlarm  setSelected:NO];
    [_btnRemindAlarm setSelected:NO];
    [_btnBirthdayAlarm setSelected:NO];
}

/** 起床闹铃按钮被点击 */
- (void)getupAlarmClicked:(UIButton *)sender {

    [self getupAlarmSelected];
    
    _currentVC = _getupAlarmVC;
    
    if (nil != _currentVC) {
        [_currentVC.view removeFromSuperview];
        [_currentVC removeFromParentViewController];
        [_currentVC didMoveToParentViewController:nil];
    }
    
    [self addChildViewController:_getupAlarmVC];
    _getupAlarmVC.view.frame = _container.bounds;
    [_container addSubview:_getupAlarmVC.view];
    [_getupAlarmVC didMoveToParentViewController:self];
}

/** 自定义闹铃被选中 */
- (void)customizeAlarmSelected {
    [_btnGetupAlarm setSelected:NO];
    [_btnCustomizeAlarm setSelected:YES];
    [_btnRemindAlarm setSelected:NO];
    [_btnBirthdayAlarm setSelected:NO];
}

/** 自定义闹铃按钮被点击 */
- (void)customizeAlarmClicked:(UIButton *)sender {

    [self customizeAlarmSelected];
    
    _currentVC = _customizeAlarmVC;
    
    if (nil != _currentVC) {
        [_currentVC.view removeFromSuperview];
        [_currentVC removeFromParentViewController];
        [_currentVC didMoveToParentViewController:nil];
    }
    
    [self addChildViewController:_customizeAlarmVC];
    _customizeAlarmVC.view.frame = _container.bounds;
    [_container addSubview:_customizeAlarmVC.view];
    [_customizeAlarmVC didMoveToParentViewController:self];
}

/** 备忘信息被选中 */
- (void)remindAlarmSelected {
    [_btnGetupAlarm setSelected:NO];
    [_btnCustomizeAlarm setSelected:NO];
    [_btnRemindAlarm setSelected:YES];
    [_btnBirthdayAlarm setSelected:NO];
}

/** 备忘信息按钮被点击 */
- (void)remindAlarmClicked:(UIButton *)sender {
    
    NSLog(@"%s _currentVC:%@ _remindAlarmVC:%@", __func__, _currentVC, _remindAlarmVC);

    [self remindAlarmSelected];
    
    _currentVC = _remindAlarmVC;
    
    if (nil != _currentVC) {
        [_currentVC.view removeFromSuperview];
        [_currentVC removeFromParentViewController];
        [_currentVC didMoveToParentViewController:nil];
    }
    
    
    [self addChildViewController:_remindAlarmVC];
    _remindAlarmVC.view.frame = _container.bounds;
    [_container addSubview:_remindAlarmVC.view];
    [_remindAlarmVC didMoveToParentViewController:self];
}

/** 生日闹铃被选中 */
- (void)birthdayAlarmSelected {
    [_btnGetupAlarm setSelected:NO];
    [_btnCustomizeAlarm setSelected:NO];
    [_btnRemindAlarm setSelected:NO];
    [_btnBirthdayAlarm setSelected:YES];
}

/** 生日闹铃按钮被点击 */
- (void)birthdayAlarmClicked:(UIButton *)sender {

    [self birthdayAlarmSelected];
    
    _currentVC = _birthdayAlarmVC;
    
    if (nil != _currentVC) {
        [_currentVC.view removeFromSuperview];
        [_currentVC removeFromParentViewController];
        [_currentVC didMoveToParentViewController:nil];
    }
    
    
    [self addChildViewController:_birthdayAlarmVC];
    _birthdayAlarmVC.view.frame = _container.bounds;
    [_container addSubview:_birthdayAlarmVC.view];
    [_birthdayAlarmVC didMoveToParentViewController:self];
}

#pragma UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat index = scrollView.contentOffset.x/_container.frame.size.width;
    
    NSLog(@"%s %@", __func__, NSStringFromCGPoint(scrollView.contentOffset));
    
    if (0 == index) {
        [self getupAlarmSelected];
    } else if (1 == index) {
        [self customizeAlarmSelected];
    } else if (2 == index) {
        [self remindAlarmSelected];
    } else if (3 == index) {
        [self birthdayAlarmSelected];
    }
}

- (void)enableBarButtonSave {

    [_barButtonSave setEnabled:YES];
}

- (void)saveAlarm {
    
    NSLog(@"%s", __func__);

    [_barButtonSave setEnabled:NO]; // disable保存按钮，防止重复点击
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(enableBarButtonSave) userInfo:nil repeats:NO]; // 2秒后再enable保存按钮
    
    AddingAlarmViewController *addingAlarmVC = self;
    
    if ([_currentVC isKindOfClass:[AlarmDetailViewController class]]) {
        [((AlarmDetailViewController *)_currentVC) addAlarm:^{
            /* 当前视图为起床闹铃或自定义闹铃 */
            [addingAlarmVC.navigationController popViewControllerAnimated:YES];
        }];
    } else if ([_currentVC isKindOfClass:[RemindViewController class]]) {
        [((RemindViewController *)_currentVC) addRemind:^{
            /* 当前视图为备忘信息 */
            [addingAlarmVC.navigationController popViewControllerAnimated:YES];
        }];
    } else if ([_currentVC isKindOfClass:[BirthdayViewController class]]) {
        [((BirthdayViewController *)_currentVC) addBirthday:^{
            /* 当前视图为生日闹铃 */
            [addingAlarmVC.navigationController popViewControllerAnimated:YES];
        }];
    }
}

@end
