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

- (void)getConnectedWiFi {

    [_barButtonItemRefresh setEnabled:NO];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_barButtonItemRefresh setEnabled:YES];
    });
    
    NSString *ssid = [NetworkMonitor currentWifiSSID];
    if (nil != ssid && ![ssid isEqualToString:@""]) {

        [_textfieldSSID setText:ssid];
        [_textfieldSSID setUserInteractionEnabled:NO];
        
        [_textfieldPassword setText:[BoxDatabase getPasswordWithSSID:ssid]];
    } else {
        [_textfieldSSID setText:@""];
        [_textfieldSSID setUserInteractionEnabled:YES];
            
        [_textfieldPassword setText:@""];
    }
}

- (void)WifiConnected:(NSNotification *)sender {
    
    [self getConnectedWiFi];
}

- (void)wifiDisconnected:(NSNotification *)sender {
    [self getConnectedWiFi];
}

- (void)nextStep {
    
    if (self.isAnimating) {
        return;
    }
    
    if ([_textfieldSSID.text isEqualToString:@""]) {
        [QXToast showMessage:NSLocalizedStringFromTable(@"pleaseInputWIFIName", @"hint", nil)];
        [_textfieldSSID becomeFirstResponder];
        
        return;
    }
    
    if (rememberPassword) {
        [BoxDatabase addSSID:_textfieldSSID.text withPassword:_textfieldPassword.text];
    }
    
    dat = [WifiConfigClass generateFSKDataWithSSID:_textfieldSSID.text password:_textfieldPassword.text];

    ConfigViewController *configVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ConfigViewController"];
    configVC.deviceManager = self.deviceManager;
    configVC.data = dat;
    if (nil != configVC) {
        [self.navigationController pushViewController:configVC animated:YES];
    }
    
}

- (IBAction)buttonClick_RememberPassword:(UIButton *)button {
    
    if (rememberPassword) {
        [button setImage:imageUnchecked forState:UIControlStateNormal];
        rememberPassword = NO;
    } else {
        [button setImage:imageChecked forState:UIControlStateNormal];
        rememberPassword = YES;
    }
}

- (IBAction)buttonClick_DisplayPassword:(UIButton *)button {
    
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
