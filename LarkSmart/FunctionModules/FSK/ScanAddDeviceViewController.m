//
//  ScanAddDeviceViewController.m
//  CloudBox
//
//  Created by TTS on 15/7/8.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "ScanAddDeviceViewController.h"
#import "ScanDeviceViewController.h"
#import "DeviceConfigViewController.h"

@interface ScanAddDeviceViewController ()

@end

@implementation ScanAddDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"background.png"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"NoDeviceFound", @"hint", nil)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setToolbarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)buttonClick_AddDevice:(id)sender {
    
    if (self.isAnimating) {
        return;
    }

    DeviceConfigViewController *deviceConfigVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DeviceConfigViewController"];
    deviceConfigVC.deviceManager = self.deviceManager;
    if (nil != deviceConfigVC) {
        [self.navigationController pushViewController:deviceConfigVC animated:YES];
    }
}

- (IBAction)buttonClick_Rescan:(id)sender {
    
    if (self.isAnimating) {
        return;
    }
    
    ScanDeviceViewController *scanDeviceVC = [[UIStoryboard storyboardWithName:@"ScanDevice" bundle:nil] instantiateViewControllerWithIdentifier:@"ScanDeviceViewController"];
    scanDeviceVC.deviceManager = self.deviceManager;
    if (nil != scanDeviceVC) {
        [self presentViewController:scanDeviceVC animated:YES completion:nil];
    }
}

@end
