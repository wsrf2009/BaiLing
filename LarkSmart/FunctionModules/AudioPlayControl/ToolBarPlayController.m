//
//  ToolBarPlayController.m
//  CloudBox
//
//  Created by TTS on 15-5-12.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "ToolBarPlayController.h"
#import "AudioClass.h"
#import "BDRecognizerViewController.h"
#import "BDRecognizerViewDelegate.h"
#import "BDTheme.h"
#import "TSLibraryImport.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIImageView+WebCache.h"
#import "FPPopoverController.h"

#define BUTTON_WIDTH    40
#define BUTTON_HEIGHT   40

#define VerticalSpaceImageViewIconTopToSuperViewTop 10.0f
#define VerticalSpaceLabelTitleTopToImageViewIconBottom     5.0f
//#define VerticalSpaceButtonPlayPauseTopToLabelTitleBottom   50.0f
#define VerticalSpaceButtonVoiceSearchTopToButtonPlayPauseBottom 15.0f
#define VerticalSpaceSuperViewBottomToButtonVoiceSearchBottom   30.0f
#define HeightImageViewIcon 120.0f
#define HeightLabelTitle 45.0f
#define HeightButtonPlayPause 35.0f
#define HeightButtonVolumeUp  50.0f
#define HeightButtonVoiceSearch 60.0f

#define API_KEY     @"YCmsACnSkY5MF26W0Ey6hyVR"
#define SECRET_KEY  @"PzKgxxmtUE83TSsw8Dw4a3Hm4ERhGNST"

enum {
    DevicePlayingModeOnDemand = 0, // 点播模式
    DevicePlayingModeSingleCycle, // 单曲循环
    DevicePlayingModeRandomPlay, // 随机播放
    DevicePlayingModeLoopPlay // 循环播放
} DevicePlayingMode;

typedef enum {
    DevicePlayerPlaying = 1,    // 正在播放
    DevicePlayerPaused,     // 播放暂停
    DevicePlayerStoped      // 播放停止
} DevicePlayerState;

NSString const *MusicRelativeDir = @"songs";

@interface ToolBarPlayController () <BDRecognizerViewDelegate, FPPopoverControllerDelegate>
{
    UIButton *button1;
    UIButton *button2;
    UIButton *button3;
    UIButton *button4;
    
    UIBarButtonItem *item1;
    UIBarButtonItem *item2;
    UIBarButtonItem *item3;
    UIBarButtonItem *item4;
    
    NSInteger playIndex;
    
    AudioClass *readyToPlay;
    AudioClass *playingAudio;
    
    BDRecognizerViewController *recognizerVC;
}

@property (nonatomic, retain) UINavigationController *NC;
@property (nonatomic, retain) UIScrollView *scrollView;

@property (nonatomic, retain) NSString *musicDirAbsolute;

@property (nonatomic, retain) UIImageView *imageViewIcon;
@property (nonatomic, retain) UILabel *labelInImage;
@property (nonatomic, retain) UILabel *labelTitle;
@property (nonatomic, retain) UIButton *buttonVolumeDown;
@property (nonatomic, retain) UIButton *buttonVolumeUp;
@property (nonatomic, retain) UIButton *buttonPrevious;
@property (nonatomic, retain) UIButton *buttonPlayPause;
@property (nonatomic, retain) UIButton *buttonNext;
@property (nonatomic, retain) UIButton *buttonVoiceSearch;

//@property (nonatomic, retain) PlayListTableViewController *playListTVC;

@property (nonatomic, assign) DevicePlayerState playerState;

@end

@implementation ToolBarPlayController

- (void)viewDidLoad {

    [super viewDidLoad];

    _NC = [[UINavigationController alloc] initWithRootViewController:self];
    [_NC.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"background.png"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    UIButton *buttonHide = [[UIButton alloc] initWithFrame:(CGRect){0, 0, 25, 30}];
    [buttonHide setImage:[UIImage imageNamed:@"arrowDown"] forState:UIControlStateNormal];
    [buttonHide addTarget:self action:@selector(navigationBackButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:buttonHide]];
    
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"audioPlayControl", @"hint", nil)];
    
    UIImageView *backgroundImage = [[UIImageView alloc] init];
    [backgroundImage setImage:[UIImage imageNamed:@"menubackground.png"]];
    [backgroundImage setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    _scrollView = [[UIScrollView alloc] init];
    [_scrollView setBackgroundColor:[UIColor whiteColor]];
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.directionalLockEnabled = YES;
    [_scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view addSubview:backgroundImage];
    [self.view addSubview:_scrollView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundImage]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(backgroundImage)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundImage]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(backgroundImage)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_scrollView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_scrollView)]];

    _imageViewIcon = [[UIImageView alloc] init];
    [_imageViewIcon setBackgroundColor:[UIColor clearColor]];
    [_imageViewIcon setImage:[UIImage imageNamed:@"playerdefault.png"]];
    _imageViewIcon.translatesAutoresizingMaskIntoConstraints = NO;
    
    _labelInImage = [[UILabel alloc] init];
    [_labelInImage setNumberOfLines:0];
    [_labelInImage setFont:[UIFont systemFontOfSize:15.0f]];
    [_labelInImage setTextAlignment:NSTextAlignmentCenter];
    _labelInImage.translatesAutoresizingMaskIntoConstraints = NO;
    
    _labelTitle = [[UILabel alloc] init];
    [_labelTitle setFont:[UIFont systemFontOfSize:17.0f]];
    [_labelTitle setNumberOfLines:2];
    [_labelTitle setTextAlignment:NSTextAlignmentLeft];
    _labelTitle.translatesAutoresizingMaskIntoConstraints = NO;
    
    _buttonPrevious = [[UIButton alloc] init];
    [_buttonPrevious setBackgroundImage:[UIImage imageNamed:@"playerPrevious.png"] forState:UIControlStateNormal];
    [_buttonPrevious addTarget:self action:@selector(buttonPreviousClick) forControlEvents:UIControlEventTouchUpInside];
    _buttonPrevious.translatesAutoresizingMaskIntoConstraints = NO;
    
    _buttonPlayPause = [[UIButton alloc] init];
    [_buttonPlayPause addTarget:self action:@selector(button3Click) forControlEvents:UIControlEventTouchUpInside];
    [_buttonPlayPause setBackgroundImage:[UIImage imageNamed:@"playerPlay.png"] forState:UIControlStateNormal];
    _buttonPlayPause.translatesAutoresizingMaskIntoConstraints = NO;
    
    _buttonNext = [[UIButton alloc] init];
    [_buttonNext setBackgroundImage:[UIImage imageNamed:@"playerNext.png"] forState:UIControlStateNormal];
    [_buttonNext addTarget:self action:@selector(button4Click) forControlEvents:UIControlEventTouchUpInside];
    _buttonNext.translatesAutoresizingMaskIntoConstraints = NO;
    
    _buttonVolumeDown = [[UIButton alloc] init];
    [_buttonVolumeDown setTitleColor:[UIColor colorWithRed:0.0f green:122.0f/255.0f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
    [_buttonVolumeDown setTitleColor:[UIColor colorWithRed:0.0f green:122.0f/255.0f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
    [_buttonVolumeDown setImage:[UIImage imageNamed:@"vol_des_pre.png"] forState:UIControlStateNormal];
    [_buttonVolumeDown addTarget:self action:@selector(buttonVolumeDownClick) forControlEvents:UIControlEventTouchUpInside];
    _buttonVolumeDown.translatesAutoresizingMaskIntoConstraints = NO;
    
    _buttonVoiceSearch = [[UIButton alloc] init];
    [_buttonVoiceSearch setBackgroundImage:[UIImage imageNamed:@"voiceSearch.png"] forState:UIControlStateNormal];
    [_buttonVoiceSearch addTarget:self action:@selector(button1Click) forControlEvents:UIControlEventTouchUpInside];
    _buttonVoiceSearch.translatesAutoresizingMaskIntoConstraints = NO;
    
    _buttonVolumeUp = [[UIButton alloc] init];
    [_buttonVolumeUp setTitleColor:[UIColor colorWithRed:0.0f green:122.0f/255.0f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
    [_buttonVolumeUp setTitleColor:[UIColor colorWithRed:0.0f green:122.0f/255.0f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
    [_buttonVolumeUp setImage:[UIImage imageNamed:@"vol_add_pre.png"] forState:UIControlStateNormal];
    [_buttonVolumeUp addTarget:self action:@selector(buttonVolumeUpClick) forControlEvents:UIControlEventTouchUpInside];
    _buttonVolumeUp.translatesAutoresizingMaskIntoConstraints = NO;

    [_scrollView addSubview:_imageViewIcon];
    [_scrollView addSubview:_labelTitle];
    [_scrollView addSubview:_buttonPrevious];
    [_scrollView addSubview:_buttonPlayPause];
    [_scrollView addSubview:_buttonNext];
    [_scrollView addSubview:_buttonVolumeDown];
    [_scrollView addSubview:_buttonVoiceSearch];
    [_scrollView addSubview:_buttonVolumeUp];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [_scrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];

    CGFloat verticalSpace = CGRectGetHeight(_scrollView.frame)-HeightImageViewIcon-VerticalSpaceLabelTitleTopToImageViewIconBottom-HeightLabelTitle-HeightButtonPlayPause-VerticalSpaceButtonVoiceSearchTopToButtonPlayPauseBottom-HeightButtonVoiceSearch-VerticalSpaceSuperViewBottomToButtonVoiceSearchBottom;
    CGFloat distanceImageToSuperTop = 3*verticalSpace/5;
    CGFloat distanceButtonPlayPauseToLabelTitle = 2*verticalSpace/5;
    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==distanceImageToSuperTop)-[_imageViewIcon(==HeightImageViewIcon)]-(==VerticalSpaceLabelTitleTopToImageViewIconBottom)-[_labelTitle(==HeightLabelTitle)]-(==distanceButtonPlayPauseToLabelTitle)-[_buttonPlayPause(==HeightButtonPlayPause)]-(==VerticalSpaceButtonVoiceSearchTopToButtonPlayPauseBottom)-[_buttonVoiceSearch(==HeightButtonVoiceSearch)]-(==VerticalSpaceSuperViewBottomToButtonVoiceSearchBottom)-|" options:0 metrics:@{@"distanceImageToSuperTop":[NSNumber numberWithFloat:distanceImageToSuperTop], @"HeightImageViewIcon":@HeightImageViewIcon,  @"VerticalSpaceLabelTitleTopToImageViewIconBottom":@VerticalSpaceLabelTitleTopToImageViewIconBottom, @"HeightLabelTitle":@HeightLabelTitle, @"distanceButtonPlayPauseToLabelTitle":[NSNumber numberWithFloat:distanceButtonPlayPauseToLabelTitle], @"HeightButtonPlayPause":@HeightButtonPlayPause, @"VerticalSpaceButtonVoiceSearchTopToButtonPlayPauseBottom": @VerticalSpaceButtonVoiceSearchTopToButtonPlayPauseBottom, @"HeightButtonVoiceSearch":@HeightButtonVoiceSearch, @"VerticalSpaceSuperViewBottomToButtonVoiceSearchBottom":@VerticalSpaceSuperViewBottomToButtonVoiceSearchBottom} views:NSDictionaryOfVariableBindings(_imageViewIcon, _labelTitle, _buttonPlayPause, _buttonVoiceSearch)]];
    
    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=15)-[_imageViewIcon(==HeightImageViewIcon)]-(>=15)-|" options:0 metrics:@{@"HeightImageViewIcon":@HeightImageViewIcon} views:NSDictionaryOfVariableBindings(_imageViewIcon)]];
    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_imageViewIcon attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=15)-[_labelTitle]-(>=15)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_labelTitle)]];
    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_labelTitle attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];

    CGFloat space = ([SystemToolClass screenWidth]-HeightButtonPlayPause*3)/4;
    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-space-[_buttonPrevious(==HeightButtonPlayPause)]-space-[_buttonPlayPause(==HeightButtonPlayPause)]-space-[_buttonNext(==HeightButtonPlayPause)]-space-|" options:0 metrics:@{@"space":[NSNumber numberWithFloat:space], @"HeightButtonPlayPause":@HeightButtonPlayPause} views:NSDictionaryOfVariableBindings(_buttonPrevious, _buttonPlayPause, _buttonNext)]];
    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_buttonPrevious attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_buttonPrevious attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_buttonNext attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_buttonNext attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_buttonPlayPause attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_buttonPlayPause attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_buttonPrevious attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_buttonNext attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_buttonPlayPause attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    space = ([SystemToolClass screenWidth]-HeightButtonVolumeUp*2-HeightButtonVoiceSearch)/4;
    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-space-[_buttonVolumeDown(==HeightButtonVolumeUp)]-space-[_buttonVoiceSearch(==HeightButtonVoiceSearch)]-space-[_buttonVolumeUp(==HeightButtonVolumeUp)]-space-|" options:0 metrics:@{@"space":[NSNumber numberWithFloat:space], @"HeightButtonVolumeUp":@HeightButtonVolumeUp, @"HeightButtonVoiceSearch":@HeightButtonVoiceSearch} views:NSDictionaryOfVariableBindings(_buttonVolumeDown, _buttonVoiceSearch, _buttonVolumeUp)]];
    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_buttonVolumeDown attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_buttonVolumeDown attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_buttonVolumeUp attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_buttonVolumeUp attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_buttonVoiceSearch attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_buttonVoiceSearch attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_buttonVolumeDown attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_buttonVolumeUp attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_buttonVoiceSearch attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];

    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)navigationBackButtonClick {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (instancetype)initWithManager:(YYTXDeviceManager *)manager {
    
    NSLog(@"%s isMainThread:%@", __func__, [NSThread isMainThread]?@"YES":@"NO");
    
    self = [super init];
    if (nil != self) {
        _deviceManager = manager;
        _playerState = DevicePlayerStoped;
        _playList = [[NSMutableArray alloc] init];
        playIndex = -1;
        NSLog(@"%s DeviceEventPlayerStart:%@", __func__, DeviceEventPlayerStart);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationForDeviceStartToPlay:) name:DeviceEventPlayerStart object:_deviceManager.device];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationForDeviceStopToPlay:) name:DeviceEventPlayerStop object:_deviceManager.device];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationForDevicePauseToPlay:) name:DeviceEventPlayerPause object:_deviceManager.device];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationForDeviceResumeToPlay:) name:DeviceEventPlayerResume object:_deviceManager.device];
        
        button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)];
        [button1 setBackgroundImage:[UIImage imageNamed:@"voice_search.png"] forState:UIControlStateNormal];
        [button1 addTarget:self action:@selector(button1Click) forControlEvents:UIControlEventTouchUpInside];
        item1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
        
        button2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-3*BUTTON_WIDTH-5*12, BUTTON_HEIGHT)];
        [button2.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [button2.titleLabel setNumberOfLines:2];
        [button2 setTitleColor:[UIColor colorWithRed:.0f green:128.0f/255.0f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
        [button2 addTarget:self action:@selector(button2Click) forControlEvents:UIControlEventTouchUpInside];
        item2 = [[UIBarButtonItem alloc] initWithCustomView:button2];
        
        button3 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)];
        [button3 setBackgroundImage:[UIImage imageNamed:@"playerPlay.png"] forState:UIControlStateNormal];
        [button3 addTarget:self action:@selector(button3Click) forControlEvents:UIControlEventTouchUpInside];
        item3 = [[UIBarButtonItem alloc] initWithCustomView:button3];
        
        button4 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)];
        [button4 setBackgroundImage:[UIImage imageNamed:@"playerNext.png"] forState:UIControlStateNormal];
        [button4 addTarget:self action:@selector(button4Click) forControlEvents:UIControlEventTouchUpInside];
        item4 = [[UIBarButtonItem alloc] initWithCustomView:button4];
        
        [self showStatusPlayListIsEmpty];

    }
    
    NSLog(@"%s isMainThread:%@", __func__, [NSThread isMainThread]?@"YES":@"NO");
    
    return self;
}

- (NSArray *)toolItems {
    
    NSLog(@"%s isMainThread:%@", __func__, [NSThread isMainThread]?@"YES":@"NO");

    return @[item1, item2, item3, item4];
}

#pragma button click methods

- (void)button1Click {
    
    [button1 setEnabled:NO];
    [_buttonVoiceSearch setEnabled:NO];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [button1 setEnabled:YES];
        [_buttonVoiceSearch setEnabled:YES];
    });
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    // 创建识别控件
    BDRecognizerViewController *tmpRecognizerViewController = [[BDRecognizerViewController alloc] initWithOrigin:CGPointMake((width-300)/2, (height-230)/2) withTheme:[BDTheme defaultTheme]];
    
    tmpRecognizerViewController.delegate = self;
    self->recognizerVC = tmpRecognizerViewController;
    
    // 设置识别参数
    BDRecognizerViewParamsObject *paramsObject = [[BDRecognizerViewParamsObject alloc] init];
    
    // 开发者信息，必须修改API_KEY和SECRET_KEY为在百度开发者平台申请得到的值，否则示例不能工作
    paramsObject.apiKey = API_KEY;
    paramsObject.secretKey = SECRET_KEY;
    
    // 是否传回语义理解结果
    paramsObject.isNeedNLU = YES;
    
    // 设置城市ID，当识别属性包含EVoiceRecognitionPropertyMap时有效
    paramsObject.cityID = 1;
    
    // 设置提示音开关，是否打开，默认打开
    paramsObject.recordPlayTones = EBDRecognizerPlayTonesRecordForbidden;
    
    // 设置识别模式，分为搜索和输入
    paramsObject.recogPropList = @[[NSNumber numberWithInt:EVoiceRecognitionPropertySearch]];
    
//    paramsObject.isShowTipAfter3sSilence = NO;
    paramsObject.isShowHelpButtonWhenSilence = NO;
    paramsObject.tipsTitle = @"可以使用如下指令记账";
    paramsObject.tipsList = [NSArray arrayWithObjects:@"我要记账", @"买苹果花了十块钱", @"买牛奶五块钱", @"第四行滚动后可见", @"第五行是最后一行", nil];
    
    [recognizerVC startWithParams:paramsObject];
}

- (void)button2Click {
    
    [button2 setEnabled:NO];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [button2 setEnabled:YES];
    });
    
    UIViewController *VC = [SystemToolClass appRootViewController];

    if (nil != _NC) {
        [VC presentViewController:_NC animated:YES completion:nil];
    }
}

- (void)button3Click {

    [button3 setEnabled:NO];
    [_buttonPlayPause setEnabled:NO];
        
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [button3 setEnabled:YES];
        [_buttonPlayPause setEnabled:YES];
    });
    
    if (nil == _playList || _playList.count <= 0) {
        
        if (DevicePlayerPlaying == _playerState) {
            [self playerPause];
        } else if (DevicePlayerPaused == _playerState) {
            [self playerResume];
        } else {
            [self showStatusPlayListIsEmpty];
        }
        
        return;
    }
    
    if (DevicePlayerPlaying == _playerState) {
        [self playerPause];
    } else if (DevicePlayerPaused == _playerState) {
        [self playerResume];
    } else if (DevicePlayerStoped == _playerState) {
        if (_playList.count > 0) {
            if (playIndex < 0 || playIndex > _playList.count-1) {
                playIndex = 0;
            }
            
            [self playAudioAtIndex:playIndex];
        }
    }
}

- (void)buttonPreviousClick {
    
    [_buttonPrevious setEnabled:NO];
        
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_buttonPrevious setEnabled:YES];
    });
    
    if (nil == _playList || _playList.count <= 0) {
        
        if (DevicePlayerPlaying == _playerState) {
            [self playerPause];
        } else if (DevicePlayerPaused == _playerState) {
            [self playerResume];
        } else {
            [self showStatusPlayListIsEmpty];
        }
        
        return;
    }
    
    playIndex--;

    if (playIndex < 0 || playIndex > _playList.count-1) {
        playIndex = _playList.count-1;
    }
    
    [self playAudioAtIndex:playIndex];
}

- (void)button4Click {
    
    NSLog(@"%s", __func__);

    [button4 setEnabled:NO];
    [_buttonNext setEnabled:NO];
        
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [button4 setEnabled:YES];
        [_buttonNext setEnabled:YES];
    });
    
    if (nil == _playList || _playList.count <= 0) {
        
        if (DevicePlayerPlaying == _playerState) {
            [self playerPause];
        } else if (DevicePlayerPaused == _playerState) {
            [self playerResume];
        } else {
            [self showStatusPlayListIsEmpty];
        }
        
        return;
    }
    
    [self playNextAudio];
}

- (void)playNextAudio {
    
    playIndex++;
    if (playIndex >= _playList.count) {
        playIndex = 0;
    }
    
    [self playAudioAtIndex:playIndex];
}

#pragma device player methods

- (void)playerPause {
    
    [_deviceManager.device pausePlay:^(YYTXDeviceReturnCode code) {
        
        if (YYTXDeviceIsAbsent == code) {
            
            [self showStatusNotConnected];
        } else if (YYTXOperationSuccessful == code) {
            
            if (DevicePlayerPlaying == _playerState) {
                
                _playerState = DevicePlayerPaused;
                [self showStatusIsNotPlaying];
            }
        } else if (YYTXOperationIsTooFrequent == code) {

        } else {
            
            [self showStatusPlayingFailed];
        }
    }];
}

- (void)playerResume {

    [_deviceManager.device resumePlay:^(YYTXDeviceReturnCode code) {
        
        if (YYTXDeviceIsAbsent == code) {
            
            [self showStatusNotConnected];
        } else if (YYTXOperationSuccessful == code) {
            
            if (DevicePlayerPaused == _playerState) {
                
                _playerState = DevicePlayerPlaying;
                [self showStatusIsPlaying];
            }
        } else if (YYTXOperationIsTooFrequent == code) {

        } else {
            
            [self showStatusPlayingFailed];
        }
    }];
}

- (void)playPrevious {
    
    [_deviceManager.device playPrevious:^(YYTXDeviceReturnCode code) {
        
        if (YYTXDeviceIsAbsent == code) {
            
            [self showStatusNotConnected];
        } else if (YYTXOperationSuccessful == code) {
            
            _playerState = DevicePlayerPlaying;
            
            [self showStatusIsPlaying];
        } else if (YYTXOperationIsTooFrequent == code) {

        } else {
            
            [self showStatusPlayingFailed];
        }
    }];
}

- (void)playNext {
    
    NSLog(@"%s", __func__);
    
    [_deviceManager.device playNext:^(YYTXDeviceReturnCode code) {
        
        if (YYTXDeviceIsAbsent == code) {
            
            [self showStatusNotConnected];
        } else if (YYTXOperationSuccessful == code) {
            
            _playerState = DevicePlayerPlaying;
            
            [self showStatusIsPlaying];
        } else if (YYTXOperationIsTooFrequent == code) {

        } else {
            
            [self showStatusPlayingFailed];
        }
    }];
}

- (void)playAudio:(NSString *)name netAddress:(NSString *)url {
        
    [_deviceManager.device playFileTitle:name phoneID:[SystemToolClass IPAddress] url:url completionBlock:^(YYTXDeviceReturnCode code) {
            
        if (YYTXDeviceIsAbsent == code) {
                
            [self showStatusNotConnected];
        } else if (YYTXOperationSuccessful == code) {

            playingAudio = readyToPlay;
                
            [self showStatusIsPlaying];
                
            _playerState = DevicePlayerPlaying;
        } else if (YYTXOperationIsTooFrequent == code) {

        } else {

        }
            
    }];
}

- (void)stopPlaying {

    [_deviceManager.device stopPlay:nil];
}

- (void)playAudioAtIndex:(NSUInteger)index {
    
    NSLog(@"%s", __func__);
    
    playIndex = index;
    
    readyToPlay = [_playList objectAtIndex:index];
    
    if ([_delegate respondsToSelector:@selector(indexOfPlaying:programTitle:)]) {
        [_delegate indexOfPlaying:playIndex programTitle:readyToPlay.title];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [button2 setTitle:readyToPlay.title forState:UIControlStateNormal];
        [_labelTitle setText:readyToPlay.title];
    });

    [self playAudio:readyToPlay.title netAddress:readyToPlay.url];
}

- (void)buttonVolumeDownClick {

    [_buttonVolumeDown setEnabled:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_buttonVolumeDown setEnabled:YES];
    });
    
    [_deviceManager.device setVolumeDown:nil];
}

- (void)buttonVolumeUpClick {
    
    [_buttonVolumeUp setEnabled:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_buttonVolumeUp setEnabled:YES];
    });
    
    [_deviceManager.device setVolumeUp:nil];
}

#pragma mark - BDRecognizerViewDelegate

- (void)onEndWithViews:(BDRecognizerViewController *)aBDRecognizerViewController withResults:(NSArray *)aResults; {

    if ([[[[BDVoiceRecognitionClient sharedInstance] getRecognitionPropertyList] objectAtIndex:0] integerValue] != EVoiceRecognitionPropertyInput) {
        
        if (nil == aResults) {
            
            [self showRecognitionServerAbnormal];
            
            return;
        }
        
        // 搜索模式下的结果为数组，示例为
        // ["公园", "公元"]
        NSMutableArray *audioResultData = (NSMutableArray *)aResults;
        NSMutableString *tmpString = [[NSMutableString alloc] initWithString:@""];
        
        for (int i=0; i < [audioResultData count]; i++) {
            [tmpString appendFormat:@"%@\r\n",[audioResultData objectAtIndex:i]];
        }
        
        NSString *deviceOpenId = _deviceManager.device.userData.generalData.openid;
        
        NSLog(@"%s tmpString:%@, deviceOpenId:%@", __func__, tmpString, deviceOpenId);
        
        if ((nil == deviceOpenId) || (deviceOpenId.length < 1)) {
            
            NSString *message = NSLocalizedStringFromTable(@"getDeviceOpenIdFailed", @"hint", nil);
            
            if ([SystemToolClass systemVersionIsNotLessThan:@"8.0"]) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[SystemToolClass appName] message:message preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"ok", @"hint", nil) style:UIAlertActionStyleDefault handler:nil]];
                if (nil != alertController) {
                    UIViewController *vc = [SystemToolClass appRootViewController];
                    [vc presentViewController:alertController animated:YES completion:nil];
                }
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[SystemToolClass appName] message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"ok", @"hint", nil), nil];
                [alertView show];
            }
            
            return;
        }
        
        [_deviceManager.serverService requestAnalysis:[tmpString dataUsingEncoding:NSUTF8StringEncoding]  deviceOpenId:_deviceManager.device.userData.generalData.openid requestFinish:^(NSDictionary *root) {

            if (nil == root) {
                [self showAnalysisServerAbnormal];
                return;
            }
            
            YYTXJsonObject *jsonRequest = [[YYTXJsonObject alloc] init];
            NSDictionary *result = [jsonRequest getResultValueFromRootObject:root];
            NSDictionary *params;
            if (nil == result) {
                [self showAnalysisServerAbnormal];
                return;
            } else {
                params = [jsonRequest getParamsValueFromRootObject:result];
                if (nil == params) {
                    [self showAnalysisServerAbnormal];
                    return;
                }
            }

            EventIndClass *mediaInfo = [EventIndClass parseEventIndJsonItem:params];
            if (nil != mediaInfo.query) {
                
                [button2 setTitle:mediaInfo.query forState:UIControlStateNormal];
                [_labelTitle setText:mediaInfo.query];
            } else {
                NSString *content = [_deviceManager.device.audioPlay getPlayContent:params];
                if (nil != content) {
                    
                    [button2 setTitle:content forState:UIControlStateNormal];
                    [_labelTitle setText:content];
                }
            }
            [_deviceManager.device sendAnalysisData:result completionBlock:^(YYTXDeviceReturnCode code) {
                    
                    if (YYTXDeviceIsAbsent == code) {

                        [self showStatusNotConnected];
                    } else if (YYTXOperationSuccessful == code) {
                        
                        _playerState = DevicePlayerPlaying;
                        
                        [self showStatusIsPlaying];
                        
                    } else if (YYTXOperationIsTooFrequent == code) {

                    } else {

                    }
            }];
        }];
    } else {

        NSMutableString *tmpString = [[NSMutableString alloc] initWithString:@""];
        for (NSArray *result in aResults) {
            NSDictionary *dic = [result objectAtIndex:0];
            NSString *candidateWord = [[dic allKeys] objectAtIndex:0];
            [tmpString appendString:candidateWord];
        }
    }
}

- (void)showStatusNotConnected {
    
    NSLog(@"%s", __func__);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [Toast showWithText:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), _deviceManager.device.userData.generalData.nickName]];
    });
}

- (void)showStatusPlayingFailed {
    
    NSLog(@"%s", __func__);

    dispatch_async(dispatch_get_main_queue(), ^{
        [Toast showWithText:NSLocalizedStringFromTable(@"playingProgramFailed", @"hint", nil)];
    });
}

- (void)showStatusUrlIsEmpty {
    
    NSLog(@"%s", __func__);

    dispatch_async(dispatch_get_main_queue(), ^{
        [Toast showWithText:NSLocalizedStringFromTable(@"urlIsEmpty", @"hint", nil)];
    });
}

- (void)showStatusPlayListIsEmpty {
    
    NSLog(@"%s", __func__);

    dispatch_async(dispatch_get_main_queue(), ^{

        [button2 setTitle:NSLocalizedStringFromTable(@"playListEmpty", @"hint", nil) forState:UIControlStateNormal];
        [_labelTitle setText:NSLocalizedStringFromTable(@"playListEmpty", @"hint", nil)];
    });
}

- (void)showStatusIsPlaying {
    
    NSLog(@"%s", __func__);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_buttonPlayPause setBackgroundImage:[UIImage imageNamed:@"playerPause.png"] forState:UIControlStateNormal];
        [button3 setBackgroundImage:[UIImage imageNamed:@"playerPause.png"] forState:UIControlStateNormal];
    });
}

- (void)showStatusIsNotPlaying {
    
    NSLog(@"%s", __func__);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_buttonPlayPause setBackgroundImage:[UIImage imageNamed:@"playerPlay.png"] forState:UIControlStateNormal];
        [button3 setBackgroundImage:[UIImage imageNamed:@"playerPlay.png"] forState:UIControlStateNormal];
    });
}

- (void)showStatusPlayerStopped {
    dispatch_async(dispatch_get_main_queue(), ^{
        [button2 setTitle:NSLocalizedStringFromTable(@"playerStopped", @"hint", nil) forState:UIControlStateNormal];
        [_labelTitle setText:NSLocalizedStringFromTable(@"playerStopped", @"hint", nil)];
    });
}

- (void)showRecognitionServerAbnormal {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [button2 setTitle:NSLocalizedStringFromTable(@"recognitionServerAbnormal", @"hint", nil) forState:UIControlStateNormal];
        [_labelTitle setText:NSLocalizedStringFromTable(@"recognitionServerAbnormal", @"hint", nil)];
    });
}

- (void)showAnalysisServerAbnormal {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [button2 setTitle:NSLocalizedStringFromTable(@"analysisServerAbnormal", @"hint", nil) forState:UIControlStateNormal];
        [_labelTitle setText:NSLocalizedStringFromTable(@"analysisServerAbnormal", @"hint", nil)];
    });
}

- (void)notificationForDeviceStartToPlay:(NSNotification *)sender {
    NSDictionary *userInfo = [sender userInfo];
    NSString *query = [userInfo objectForKey:JSONITEM_EVENTIND_QUERY];
    
    NSLog(@"%s +++++++++++++++++++++++++++++++ query:%@", __func__, query);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [button2 setTitle:query forState:UIControlStateNormal];
        [_labelTitle setText:query];
    });

    _playerState = DevicePlayerPlaying;
    [self showStatusIsPlaying];
}

- (void)notificationForDeviceStopToPlay:(NSNotification *)sender {
    NSDictionary *userInfo = [sender userInfo];
    NSString *query = [userInfo objectForKey:JSONITEM_EVENTIND_QUERY];
    
    NSLog(@"%s +++++++++++++++++++++++++++++++ query:%@", __func__, query);

    dispatch_async(dispatch_get_main_queue(), ^{
        
        [button2 setTitle:query forState:UIControlStateNormal];
        [_labelTitle setText:query];
    });

    _playerState = DevicePlayerStoped;
    [self showStatusIsNotPlaying];
    [self showStatusPlayerStopped];
}

- (void)notificationForDevicePauseToPlay:(NSNotification *)sender {
    NSDictionary *userInfo = [sender userInfo];
    NSString *query = [userInfo objectForKey:JSONITEM_EVENTIND_QUERY];
    
    NSLog(@"%s +++++++++++++++++++++++++++++++ query:%@", __func__, query);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [button2 setTitle:query forState:UIControlStateNormal];
        [_labelTitle setText:query];
    });
    
    _playerState = DevicePlayerPaused;
    [self showStatusIsNotPlaying];
}

- (void)notificationForDeviceResumeToPlay:(NSNotification *)sender {
    NSDictionary *userInfo = [sender userInfo];
    NSString *query = [userInfo objectForKey:JSONITEM_EVENTIND_QUERY];
    
    NSLog(@"%s +++++++++++++++++++++++++++++++ query:%@", __func__, query);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [button2 setTitle:query forState:UIControlStateNormal];
        [_labelTitle setText:query];
    });
    
    _playerState = DevicePlayerPlaying;
    [self showStatusIsPlaying];
}

- (void)selectedIndex:(NSInteger)index {

    [self playAudioAtIndex:index];
}

- (void)playListChange:(NSInteger)index {
    playIndex = index;
}

@end
