//
//  HighSettViewController.m
//  CloudBox
//
//  Created by TTS on 15/9/21.
//  Copyright © 2015年 宇音天下. All rights reserved.
//

#import "HighSetViewController.h"
#import "WakeupNameViewController.h"
#import "SleepMusicViewController.h"
#import "LocalCityViewController.h"
#import "UndisturbedControlViewController.h"
#import "OtherSetViewController.h"

@interface HighSetViewController ()

@end

@implementation HighSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"highSet", @"hint", nil)];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [scrollView setContentSize:self.view.frame.size];
    scrollView.alwaysBounceVertical = YES;
    scrollView.directionalLockEnabled = YES;
    [self.view addSubview:scrollView];

    CGFloat borderWidth = 1/[SystemToolClass screenScale];
    CGFloat viewWidth = CGRectGetWidth(self.view.frame)/2;
    CGFloat viewHeight = 137.5;
    CGRect buttonRect = (CGRect){0, 0, 90, 90};
    
    UIView *view00 = [[UIView alloc] initWithFrame:(CGRect){0, 0, viewWidth, viewHeight}];
    view00.layer.borderWidth = borderWidth;
    view00.layer.borderColor = [UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f].CGColor;
    
    UIView *view01 = [[UIView alloc] initWithFrame:(CGRect){CGRectGetMaxX(view00.frame)-borderWidth, 0, viewWidth+borderWidth, viewHeight}];
    view01.layer.borderWidth = borderWidth;
    view01.layer.borderColor = [UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f].CGColor;
    
    UIView *view10 = [[UIView alloc] initWithFrame:(CGRect){0, CGRectGetMaxY(view00.frame)-borderWidth, viewWidth, viewHeight+borderWidth}];
    view10.layer.borderWidth = borderWidth;
    view10.layer.borderColor = [UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f].CGColor;
    
    UIView *view11 = [[UIView alloc] initWithFrame:(CGRect){CGRectGetMaxX(view10.frame)-borderWidth, CGRectGetMaxY(view01.frame)-borderWidth, viewWidth+borderWidth, viewHeight+borderWidth}];
    view11.layer.borderWidth = borderWidth;
    view11.layer.borderColor = [UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f].CGColor;
    
    UIView *view20 = [[UIView alloc] initWithFrame:(CGRect){0, CGRectGetMaxY(view10.frame)-borderWidth, viewWidth, viewHeight+borderWidth}];
    view20.layer.borderWidth = borderWidth;
    view20.layer.borderColor = [UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f].CGColor;
    
    [scrollView addSubview:view00];
    [scrollView addSubview:view01];
    [scrollView addSubview:view10];
    [scrollView addSubview:view11];
    [scrollView addSubview:view20];
    
    UIButton *buttonWakeup = [[UIButton alloc] initWithFrame:buttonRect];
    [buttonWakeup setImage:[UIImage imageNamed:@"wakeupset.png"] forState:UIControlStateNormal];
    [buttonWakeup addTarget:self action:@selector(gotoWakeup) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonSleepMusic = [[UIButton alloc] initWithFrame:buttonRect];
    [buttonSleepMusic setImage:[UIImage imageNamed:@"sleepmusic.png"] forState:UIControlStateNormal];
    [buttonSleepMusic addTarget:self action:@selector(gotoSleepMusic) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonLocalCity = [[UIButton alloc] initWithFrame:buttonRect];
    [buttonLocalCity setImage:[UIImage imageNamed:@"localcity.png"] forState:UIControlStateNormal];
    [buttonLocalCity addTarget:self action:@selector(gotoLocalCity) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonUndisturbed = [[UIButton alloc] initWithFrame:buttonRect];
    [buttonUndisturbed setImage:[UIImage imageNamed:@"undisturbed.png"] forState:UIControlStateNormal];
    [buttonUndisturbed addTarget:self action:@selector(gotoUndisturbedControl) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonOtherSet = [[UIButton alloc] initWithFrame:buttonRect];
    [buttonOtherSet setImage:[UIImage imageNamed:@"otherset.png"] forState:UIControlStateNormal];
    [buttonOtherSet addTarget:self action:@selector(gotoOtherSet) forControlEvents:UIControlEventTouchUpInside];
    
    [scrollView addSubview:buttonWakeup];
    [scrollView addSubview:buttonSleepMusic];
    [scrollView addSubview:buttonLocalCity];
    [scrollView addSubview:buttonUndisturbed];
    [scrollView addSubview:buttonOtherSet];

    buttonWakeup.center = view00.center;
    buttonSleepMusic.center = view01.center;
    buttonLocalCity.center = view10.center;
    buttonUndisturbed.center = view11.center;
    buttonOtherSet.center = view20.center;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)gotoWakeup {
    // 唤醒控制
    WakeupNameViewController *wakeupNameVC = [[UIStoryboard storyboardWithName:@"WakeupControl" bundle:nil] instantiateViewControllerWithIdentifier:@"WakeupNameViewController"];
    wakeupNameVC.deviceManager = self.deviceManager;
    if (nil != wakeupNameVC) {
        [self.navigationController pushViewController:wakeupNameVC animated:YES];
    }
}

- (void)gotoSleepMusic {
    // 睡前音乐
    SleepMusicViewController *sleepMusicVC = [[UIStoryboard storyboardWithName:@"SleepMusic" bundle:nil] instantiateViewControllerWithIdentifier:@"SleepMusicViewController"];
    sleepMusicVC.deviceManager = self.deviceManager;
    if (nil != sleepMusicVC) {
        [self.navigationController pushViewController:sleepMusicVC animated:YES];
    }
}

- (void)gotoLocalCity {
    // 本地城市
    LocalCityViewController *localCityVC = [[UIStoryboard storyboardWithName:@"LocalCity" bundle:nil] instantiateViewControllerWithIdentifier:@"LocalCityViewController"];
    localCityVC.deviceManager = self.deviceManager;
    if (nil != localCityVC) {
        [self.navigationController pushViewController:localCityVC animated:YES];
    }
}

- (void)gotoUndisturbedControl {
    // 夜间控制
    UndisturbedControlViewController *undisturbedControlVC = [[UIStoryboard storyboardWithName:@"UndisturbedControl" bundle:nil] instantiateViewControllerWithIdentifier:@"UndisturbedControlViewController"];
    undisturbedControlVC.deviceManager = self.deviceManager;
    if (nil != undisturbedControlVC) {
        [self.navigationController pushViewController:undisturbedControlVC animated:YES];
    }
}

- (void)gotoOtherSet {
    // 其他设置
    OtherSetViewController *otherSetVC = [[UIStoryboard storyboardWithName:@"OtherSet" bundle:nil] instantiateViewControllerWithIdentifier:@"OtherSetViewController"];
    otherSetVC.deviceManager = self.deviceManager;
    if (nil != otherSetVC) {
        [self.navigationController pushViewController:otherSetVC animated:YES];
    }
}

@end
