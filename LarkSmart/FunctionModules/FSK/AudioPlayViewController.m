//
//  AudioPlayViewController.m
//  CloudBox
//
//  Created by TTS on 15/6/4.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "AudioPlayViewController.h"
#import "ScanDeviceViewController.h"
#import "DeviceConfigViewController.h"
#import "AudioQueuePlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AdjustVolumeTableViewController.h"
#import "NoHintTableViewController.h"

#define CONFIGURATIONTIME           10

@interface AudioPlayViewController ()
{
    AudioQueuePlayer *audioQueuePlayer;
}

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, retain) UIView *VEView;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, assign) NSInteger leftTime;
@property (nonatomic, retain) NSTimer *timer;

@property (nonatomic, retain) IBOutlet UIButton *buttonNoHint;
@property (nonatomic, retain) IBOutlet UIView *viewContainer;

@property (nonatomic, retain) UIImageView *imgvActivity;
@property (nonatomic, retain) UIButton *btnSuccess;
@property (nonatomic, retain) UIButton *btnVolumn;
@property (nonatomic, retain) UIButton *btnPassword;
@property (nonatomic, retain) UIButton *btnConfig;
@property (nonatomic, retain) UIButton *btnHint;

@property (nonatomic, retain) NoHintTableViewController *noHintTVC;
@property (nonatomic, retain) AdjustVolumeTableViewController *adjustVolumeTVC;

@end

@implementation AudioPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"configuration", @"hint", nil)];
    [self.navigationController setToolbarHidden:YES];
    
    audioQueuePlayer = [[AudioQueuePlayer alloc] initWithData:_data delegate:self];

    [self performSelectorInBackground:@selector(play) withObject:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES];

    if (_noHintTVC.needFSKConfig) {
        [self play];
    } else if (_adjustVolumeTVC.needFSKConfig) {
        [self play];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    if (nil != audioQueuePlayer) {
        [_timer invalidate];
        _leftTime = -1;
        [audioQueuePlayer stop];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIWindow *)mainWindow {
    UIApplication *app = [UIApplication sharedApplication];
    if ([app.delegate respondsToSelector:@selector(window)]) {
        return [app.delegate window];
    }
    else {
        return [app keyWindow];
    }
}

- (void)startAnimation {

    [_imageView startAnimating];
}

- (void)timerFire {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_leftTime>=0) {
            [_label setText:[NSString stringWithFormat:@"%ld", (long)_leftTime]];
        } else {
            [_timer invalidate];
            [_VEView removeFromSuperview];
        }
    });
    
    _leftTime--;
}

- (void)play {
    
    if (nil == _VEView) {
        if ([SystemToolClass systemVersionIsNotLessThan:@"8.0"]) {
            _VEView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        } else {
            _VEView = [[UIView alloc] init];
            [_VEView setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:0.9f]];
        }
        
        _VEView.frame = self.view.bounds;
        
        _imageView = [[UIImageView alloc] init];
        NSMutableArray * animateArray = [[NSMutableArray alloc] initWithCapacity:24];
        [animateArray addObject:[UIImage imageNamed:@"scaning_01.png"]];
        [animateArray addObject:[UIImage imageNamed:@"scaning_02.png"]];
        [animateArray addObject:[UIImage imageNamed:@"scaning_03.png"]];
        [animateArray addObject:[UIImage imageNamed:@"scaning_04.png"]];
        [animateArray addObject:[UIImage imageNamed:@"scaning_05.png"]];
        [animateArray addObject:[UIImage imageNamed:@"scaning_06.png"]];
        [animateArray addObject:[UIImage imageNamed:@"scaning_07.png"]];
        [animateArray addObject:[UIImage imageNamed:@"scaning_08.png"]];
        [animateArray addObject:[UIImage imageNamed:@"scaning_09.png"]];
        [animateArray addObject:[UIImage imageNamed:@"scaning_10.png"]];
        [animateArray addObject:[UIImage imageNamed:@"scaning_11.png"]];
        [animateArray addObject:[UIImage imageNamed:@"scaning_12.png"]];
        [animateArray addObject:[UIImage imageNamed:@"scaning_13.png"]];
        [animateArray addObject:[UIImage imageNamed:@"scaning_14.png"]];
        [animateArray addObject:[UIImage imageNamed:@"scaning_15.png"]];
        [animateArray addObject:[UIImage imageNamed:@"scaning_16.png"]];
        [animateArray addObject:[UIImage imageNamed:@"scaning_17.png"]];
        [animateArray addObject:[UIImage imageNamed:@"scaning_18.png"]];
        [animateArray addObject:[UIImage imageNamed:@"scaning_19.png"]];
        [animateArray addObject:[UIImage imageNamed:@"scaning_20.png"]];
        [animateArray addObject:[UIImage imageNamed:@"scaning_21.png"]];
        [animateArray addObject:[UIImage imageNamed:@"scaning_22.png"]];
        [animateArray addObject:[UIImage imageNamed:@"scaning_23.png"]];
        [animateArray addObject:[UIImage imageNamed:@"scaning_24.png"]];
        _imageView.animationImages = animateArray;
        _imageView.animationDuration = 1.0;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        _label = [[UILabel alloc] init];
        [_label setFont:[UIFont systemFontOfSize:50.0f]];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        
        [_VEView addSubview:_imageView];
        [_VEView addSubview:_label];
        
        [_VEView addConstraint:[NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:150.0f]];
        [_VEView addConstraint:[NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:150.0f]];
        [_VEView addConstraint:[NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_VEView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [_VEView addConstraint:[NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_VEView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [_VEView addConstraint:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_VEView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [_VEView addConstraint:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_VEView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    }
    
    _leftTime = CONFIGURATIONTIME;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.view addSubview:_VEView];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerFire) userInfo:nil repeats:YES];
        [_timer fire];
    });
    
    [self startAnimation];

    [audioQueuePlayer play];
}

- (IBAction)buttonClickRescan:(id)sender {
    
    if (self.isAnimating) {
        return;
    }
    
    ScanDeviceViewController *scanDeviceVC = [[UIStoryboard storyboardWithName:@"ScanDevice" bundle:nil] instantiateViewControllerWithIdentifier:@"ScanDeviceViewController"];
    scanDeviceVC.deviceManager = self.deviceManager;
    if (nil != scanDeviceVC) {
        [self presentViewController:scanDeviceVC animated:YES completion:nil];
    }
}

- (IBAction)buttonClickAdjustVolume:(id)sender {
    
    if (self.isAnimating) {
        return;
    }
    
    _adjustVolumeTVC = [[AdjustVolumeTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    if (nil != _adjustVolumeTVC) {
        [self.navigationController pushViewController:_adjustVolumeTVC animated:YES];
    }
}

- (IBAction)buttonClickWrongPassword:(id)sender {

    if (self.isAnimating) {
        return;
    }
    
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[DeviceConfigViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

- (IBAction)buttonClickConfigFailed:(id)sender {
    
    if (self.isAnimating) {
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonClickNoHint:(id)sender {
    
    if (self.isAnimating) {
        return;
    }
    
    _noHintTVC = [[NoHintTableViewController alloc] initWithStyle:UITableViewStylePlain];
    if (nil != _noHintTVC) {
        [self.navigationController pushViewController:_noHintTVC animated:YES];
    }
}

@end
