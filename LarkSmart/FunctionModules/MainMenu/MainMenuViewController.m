//
//  MainMenuViewController.m
//  CloudBox
//
//  Created by TTS on 15-3-30.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "MainMenuViewController.h"
#import "AlarmsViewController.h"
#import "DeviceManagerViewController.h"
#import "AboutAppViewController.h"
#import "HimalayaViewController.h"
#import "LocalMusicViewController.h"
#import "XMLYHelpViewController.h"
#import "HighSetViewController.h"

@interface MainMenuViewController ()

@property (nonatomic, retain) UIBarButtonItem *barButtonFindDevice;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIView *view00;
@property (nonatomic, retain) UIView *view01;
@property (nonatomic, retain) UIView *view10;
@property (nonatomic, retain) UIView *view11;
@property (nonatomic, retain) UIView *view20;
@property (nonatomic, retain) UIView *view21;

@end

@implementation MainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController.toolbar setTranslucent:NO];
    [self.navigationController.toolbar setOpaque:YES];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.toolbarItems = [_toolBarPlayer toolItems];

    NSString *serverStatus;
    BOOL code = [self.deviceManager checkServerStatus:&serverStatus];
    NSString *title = NSLocalizedStringFromTable(@"mainMenu", @"hint", nil);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, {50, 30}}];
    if (code) {
        NSString *string = [title stringByAppendingFormat:@"［%@］", serverStatus];
        // 创建可变属性化字符串
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
        NSUInteger length = [string length];
        // 设置基本字体
        UIFont *baseFont = [UIFont boldSystemFontOfSize:18.0f];
        [attrString addAttribute:NSFontAttributeName value:baseFont range:NSMakeRange(0, length)];
        UIColor *baseColor = [UIColor blackColor];
        [attrString addAttribute:NSForegroundColorAttributeName value:baseColor range:NSMakeRange(0, length)];
        
        NSRange range1 = [string rangeOfString:@"［"];
        NSRange range2 = [string rangeOfString:@"］"];
        if (range1.location != NSNotFound && range2.location != NSNotFound) {
            length = range2.location - range1.location-1;
            NSRange range = NSMakeRange(range1.location+1, length);
            //将需要提示的字体增大
            UIFont *biggerFont = [UIFont boldSystemFontOfSize:18.0f];
            [attrString addAttribute:NSFontAttributeName value:biggerFont range:range];
            // 将需要提示的字体设为红色
            UIColor *color = [UIColor redColor];
            [attrString addAttribute:NSForegroundColorAttributeName value:color range:range];
        }
        
        [titleLabel setAttributedText:attrString];
        [self.navigationItem setTitleView:titleLabel];
    } else {
        [self.navigationItem  setTitle:title];
    }
    
    _scrollView = [[UIScrollView alloc] init];
    [_scrollView setShowsVerticalScrollIndicator:YES];
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.directionalLockEnabled = YES;
    [self.view addSubview:_scrollView];
    
    CGFloat borderWidth = 1/[SystemToolClass screenScale];
    CGFloat viewWidth = CGRectGetWidth(self.view.frame)/2;
    CGFloat viewHeight = 137.5;
    CGRect buttonRect = (CGRect){0, 0, 90, 90};
    
    _view00 = [[UIView alloc] initWithFrame:(CGRect){0, 0, viewWidth, viewHeight}];
    _view00.layer.borderWidth = borderWidth;
    _view00.layer.borderColor = [UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f].CGColor;
    
    _view01 = [[UIView alloc] initWithFrame:(CGRect){CGRectGetMaxX(_view00.frame)-borderWidth, 0, viewWidth+borderWidth, viewHeight}];
    _view01.layer.borderWidth = borderWidth;
    _view01.layer.borderColor = [UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f].CGColor;
    
    _view10 = [[UIView alloc] initWithFrame:(CGRect){0, CGRectGetMaxY(_view00.frame)-borderWidth, viewWidth, viewHeight+borderWidth}];
    _view10.layer.borderWidth = borderWidth;
    _view10.layer.borderColor = [UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f].CGColor;
    
    _view11 = [[UIView alloc] initWithFrame:(CGRect){CGRectGetMaxX(_view10.frame)-borderWidth, CGRectGetMaxY(_view01.frame)-borderWidth, viewWidth+borderWidth, viewHeight+borderWidth}];
    _view11.layer.borderWidth = borderWidth;
    _view11.layer.borderColor = [UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f].CGColor;
    
    _view20 = [[UIView alloc] initWithFrame:(CGRect){0, CGRectGetMaxY(_view10.frame)-borderWidth, viewWidth, viewHeight+borderWidth}];
    _view20.layer.borderWidth = borderWidth;
    _view20.layer.borderColor = [UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f].CGColor;
    
    _view21 = [[UIView alloc] initWithFrame:(CGRect){CGRectGetMaxX(_view20.frame)-borderWidth, CGRectGetMaxY(_view11.frame)-borderWidth, viewWidth+borderWidth, viewHeight+borderWidth}];
    _view21.layer.borderWidth = borderWidth;
    _view21.layer.borderColor = [UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f].CGColor;
    
    [_scrollView addSubview:_view00];
    [_scrollView addSubview:_view01];
    [_scrollView addSubview:_view10];
    [_scrollView addSubview:_view11];
    [_scrollView addSubview:_view20];
    [_scrollView addSubview:_view21];
    
    UIButton *buttonMyDevice = [[UIButton alloc] initWithFrame:buttonRect];
    [buttonMyDevice setImage:[UIImage imageNamed:@"mydevice.png"] forState:UIControlStateNormal];
    [buttonMyDevice addTarget:self action:@selector(gotoDeviceList) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonHighSet = [[UIButton alloc] initWithFrame:buttonRect];
    [buttonHighSet setImage:[UIImage imageNamed:@"highset.png"] forState:UIControlStateNormal];
    [buttonHighSet addTarget:self action:@selector(gotoHighSet) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonAlarms = [[UIButton alloc] initWithFrame:buttonRect];
    [buttonAlarms setImage:[UIImage imageNamed:@"tickler.png"] forState:UIControlStateNormal];
    [buttonAlarms addTarget:self action:@selector(gotoAlarms) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonHimalaya = [[UIButton alloc] initWithFrame:buttonRect];
    [buttonHimalaya setImage:[UIImage imageNamed:@"webmusic.png"] forState:UIControlStateNormal];
    [buttonHimalaya addTarget:self action:@selector(gotoHimalaya) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonLocalMusic = [[UIButton alloc] initWithFrame:buttonRect];
    [buttonLocalMusic setImage:[UIImage imageNamed:@"localmusic.png"] forState:UIControlStateNormal];
    [buttonLocalMusic addTarget:self action:@selector(gotoLocalMusic) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonAboutApp = [[UIButton alloc] initWithFrame:buttonRect];
    [buttonAboutApp setImage:[UIImage imageNamed:@"aboutus.png"] forState:UIControlStateNormal];
    [buttonAboutApp addTarget:self action:@selector(gotoAboutApp) forControlEvents:UIControlEventTouchUpInside];
    
    [_scrollView addSubview:buttonMyDevice];
    [_scrollView addSubview:buttonHighSet];
    [_scrollView addSubview:buttonAlarms];
    [_scrollView addSubview:buttonHimalaya];
    [_scrollView addSubview:buttonLocalMusic];
    [_scrollView addSubview:buttonAboutApp];
    
    buttonMyDevice.center = _view00.center;
    buttonHighSet.center = _view01.center;
    buttonAlarms.center = _view10.center;
    buttonHimalaya.center = _view11.center;
    buttonLocalMusic.center = _view20.center;
    buttonAboutApp.center = _view21.center;
    
    [_scrollView setContentSize:(CGSize){CGRectGetMaxX(_view21.frame), CGRectGetMaxY(_view21.frame)}];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGRect frame = self.view.frame;
    frame.origin = (CGPoint){0, 0};
    [_scrollView setFrame:frame];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    NSLog(@"%s %@ mainThread:%d", __func__, parent, [[NSThread currentThread] isMainThread]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _barButtonFindDevice = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"findDevice.png"] style:UIBarButtonItemStylePlain target:self action:@selector(findDevice)];
        self.navigationItem.rightBarButtonItem = _barButtonFindDevice;
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)gotoDeviceList {
    
    NSLog(@"%s", __func__);
    
    // 我的设备
    DeviceManagerViewController *deviceListVC = [[UIStoryboard storyboardWithName:@"DeviceList" bundle:nil] instantiateViewControllerWithIdentifier:@"DeviceManagerViewController"];
    deviceListVC.deviceManager = self.deviceManager;
    if (nil != deviceListVC) {
        [self.navigationController pushViewController:deviceListVC animated:YES];
    }
}

- (void)gotoHighSet {
    
    HighSetViewController *highSetVC = [[HighSetViewController alloc] init];
    highSetVC.deviceManager = self.deviceManager;
    if (nil != highSetVC) {
        [self.navigationController pushViewController:highSetVC animated:YES];
    }
}

- (void)gotoAlarms {
    
    NSLog(@"%s", __func__);
    
    // 百灵闹钟
    AlarmsViewController *alarmsVC = [[UIStoryboard storyboardWithName:@"Alarms" bundle:nil] instantiateViewControllerWithIdentifier:@"AlarmsViewController"];
    alarmsVC.deviceManager = self.deviceManager;
    if (nil != alarmsVC) {
        [self.navigationController pushViewController:alarmsVC animated:YES];
    }
}

- (void)gotoHimalaya {
    
    NSLog(@"%s", __func__);
    
    BOOL autoPopHelper = [BoxDatabase autoPopHimalayaHelper];
    
    if (autoPopHelper) {
        XMLYHelpViewController *xmlyHelpVC = [[UIStoryboard storyboardWithName:@"Himalaya" bundle:nil] instantiateViewControllerWithIdentifier:@"XMLYHelpViewController"];
        if (nil != xmlyHelpVC) {
            xmlyHelpVC.deviceManager = self.deviceManager;
            xmlyHelpVC.toolBarPlayer = _toolBarPlayer;
            [self.navigationController pushViewController:xmlyHelpVC animated:YES];
        }
    } else {
        // 喜马拉雅
        HimalayaViewController *himalayaVC = [[UIStoryboard storyboardWithName:@"Himalaya" bundle:nil] instantiateViewControllerWithIdentifier:@"HimalayaViewController"];
        himalayaVC.deviceManager = self.deviceManager;
        himalayaVC.toolBarPlayer = _toolBarPlayer;
        if (nil != himalayaVC) {
            [self.navigationController pushViewController:himalayaVC animated:YES];
        }
    }
}

- (void)gotoLocalMusic {
    
    NSLog(@"%s", __func__);
    
    // 手机本地音乐
    LocalMusicViewController *localMusicVC = [[UIStoryboard storyboardWithName:@"LocalMusic" bundle:nil] instantiateViewControllerWithIdentifier:@"LocalMusicViewController"];
    localMusicVC.deviceManager = self.deviceManager;
    localMusicVC.toolBarPlayer = _toolBarPlayer;
    if (nil != localMusicVC) {
        [self.navigationController pushViewController:localMusicVC animated:YES];
    }
}

- (void)gotoAboutApp {
    AboutAPPViewController *aboutAppVC = [[UIStoryboard storyboardWithName:@"AboutAPP" bundle:nil] instantiateViewControllerWithIdentifier:@"AboutAPPViewController"];
    
    NSLog(@"%s", __func__);
    
    aboutAppVC.deviceManager = self.deviceManager;
    if (nil != aboutAppVC) {
        [self.navigationController pushViewController:aboutAppVC animated:YES];
    }
}

- (void)enableBarButtonFindDevice {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_barButtonFindDevice setEnabled:YES];
    });
}

- (void)findDevice {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_barButtonFindDevice setEnabled:NO];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(enableBarButtonFindDevice) userInfo:nil repeats:NO];
    });

    [self.deviceManager.device playFileId:devicePromptFileIdIMHere completionBlock:nil];
}

@end
