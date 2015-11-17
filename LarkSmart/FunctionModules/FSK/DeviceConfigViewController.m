//
//  DeviceConfig.m
//  CloudBox
//
//  Created by TTS on 15-3-20.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "DeviceConfigViewController.h"
#import "WifiConfigClass.h"
#import "ConfigViewController.h"
#import "BoxDatabase.h"
#import "NetworkMonitor.h"

@interface DeviceConfigViewController ()
{
    NSData *dat;
    UIImage *imageChecked;
    UIImage *imageUnchecked;
    BOOL rememberPassword;
    BOOL displayPassword;
}

@property (retain, nonatomic) IBOutlet UITextField *textfieldSSID;
@property (retain, nonatomic) IBOutlet UITextField *textfieldPassword;
@property (nonatomic, retain) IBOutlet UIButton *buttonRememberPassword;
@property (nonatomic, retain) IBOutlet UIButton *buttonDisplayPassword;
@property (nonatomic, retain) UIBarButtonItem *barButtonItemRefresh;

@end

@implementation DeviceConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _barButtonItemRefresh = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"refresh", @"hint", nil) style:UIBarButtonItemStylePlain target:self action:@selector(getConnectedWiFi)];
    self.navigationItem.rightBarButtonItem = _barButtonItemRefresh;
    
    UIBarButtonItem *nextStep = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"nextStep", @"hint", nil) style:UIBarButtonItemStyleDone target:self action:@selector(nextStep)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [self setToolbarItems:@[space, nextStep, space] animated:YES];
    
    _textfieldSSID.placeholder = NSLocalizedStringFromTable(@"pleaseInputWIFIName", @"hint", nil);
    _textfieldPassword.placeholder = NSLocalizedStringFromTable(@"pleaseGiveNothingIfThereIsNoPassword", @"hint", nil);
    
    imageChecked = [UIImage imageNamed:@"checkbox_checked.png"];
    imageUnchecked = [UIImage imageNamed:@"checkbox_unchecked.png"];
    
    [_buttonRememberPassword setImage:imageChecked forState:UIControlStateNormal];
    [_buttonDisplayPassword setImage:imageUnchecked forState:UIControlStateNormal];
    rememberPassword = YES;
    displayPassword = NO;
    
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"WIFINameAndPassword", @"hint", nil)];
    
    /* 接收来自DevicesManager手机网络连接状态更改的通知 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WifiConnected:) name:YYTXDeviceManagerWIFIConnected object:self.deviceManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifiDisconnected:) name:YYTXDeviceManagerWIFIDisconnected object:self.deviceManager];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self getConnectedWiFi];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/** 获取手机当前连接到的WIFI信息 */
- (void)getConnectedWiFi {

    [_barButtonItemRefresh setEnabled:NO];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_barButtonItemRefresh setEnabled:YES];
    });
    
    NSString *ssid = [NetworkMonitor currentWifiSSID];
    if (nil != ssid && ![ssid isEqualToString:@""]) {
        /* 手机当前已连到WIFI网络，则使用手机当前的网络 */
        [_textfieldSSID setText:ssid];
        [_textfieldSSID setUserInteractionEnabled:NO];
        
        [_textfieldPassword setText:[BoxDatabase getPasswordWithSSID:ssid]];
    } else {
        /* 需要用户手动输入SSID */
        [_textfieldSSID setText:@""];
        [_textfieldSSID setUserInteractionEnabled:YES];
            
        [_textfieldPassword setText:@""];
    }
}

/** 手机网络已连接 */
- (void)WifiConnected:(NSNotification *)sender {
    
    [self getConnectedWiFi];
}

/** 手机网络连接已断开 */
- (void)wifiDisconnected:(NSNotification *)sender {
    [self getConnectedWiFi];
}

- (void)nextStep {
    
    if (self.isAnimating) {
        return;
    }
    
    if ([_textfieldSSID.text isEqualToString:@""]) {
        /* SSID无效 */
        [QXToast showMessage:NSLocalizedStringFromTable(@"pleaseInputWIFIName", @"hint", nil)];
        [_textfieldSSID becomeFirstResponder];
        
        return;
    }
    
    if (rememberPassword) {
        /* 将密码保存进数据库 */
        [BoxDatabase addSSID:_textfieldSSID.text withPassword:_textfieldPassword.text];
    }
    
    dat = [WifiConfigClass generateFSKDataWithSSID:_textfieldSSID.text password:_textfieldPassword.text]; // 将SSID和password加密生成有效的FSK数据

    ConfigViewController *configVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ConfigViewController"];
    configVC.deviceManager = self.deviceManager;
    configVC.data = dat;
    if (nil != configVC) {
        [self.navigationController pushViewController:configVC animated:YES];
    }
    
}

- (IBAction)buttonClick_RememberPassword:(UIButton *)button {
    /* 更改记住密码按钮的状态 */
    if (rememberPassword) {
        [button setImage:imageUnchecked forState:UIControlStateNormal];
        rememberPassword = NO;
    } else {
        [button setImage:imageChecked forState:UIControlStateNormal];
        rememberPassword = YES;
    }
}

- (IBAction)buttonClick_DisplayPassword:(UIButton *)button {
    /* 显示密码 */
    if (displayPassword) {
        [button setImage:imageUnchecked forState:UIControlStateNormal];
        displayPassword = NO;
        [_textfieldPassword setSecureTextEntry:YES];
    } else {
        [button setImage:imageChecked forState:UIControlStateNormal];
        displayPassword = YES;
        [_textfieldPassword setSecureTextEntry:NO];
    }
}

@end
