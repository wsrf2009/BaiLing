//
//  ViewController.m
//  CloudBox
//
//  Created by TTS on 15-3-17.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "ViewController.h"
#import "WelcomeViewController.h"
#import "ScanDeviceViewController.h"
#import "YYTXDeviceManager.h"

@interface ViewController ()
{
    YYTXDeviceManager *deviceManger;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    deviceManger = [[YYTXDeviceManager alloc] init];

    [self worksStart];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)worksStart {
    BOOL firstOpen = [BoxDatabase isFirstOpenTheApp]; // 判断是否是首次打开APP
    
    [deviceManger updateDataFromServer];
    
    /* 下面的页面跳转语句不能放在 viewDidLoad 中，会导致页面加载混乱 */
    if (firstOpen) {
        /* 如果是首次打开APP，则记录当前打开APP的时间 */
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        [BoxDatabase insertOpenAppRecord:[dateFormatter stringFromDate:[NSDate date]]];
        
        // 首次打开APP则进入欢迎界面
        WelcomeViewController *welcomeVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
        welcomeVC.deviceManger = deviceManger;
        if (nil != welcomeVC) {
            [self presentViewController:welcomeVC animated:YES completion:nil];
        }
        
    } else {
        /* 如果不是则直接进入APP工作界面 */
        ScanDeviceViewController *scanDeviceVC = [[UIStoryboard storyboardWithName:@"ScanDevice" bundle:nil] instantiateViewControllerWithIdentifier:@"ScanDeviceViewController"];
        scanDeviceVC.deviceManager = deviceManger;
        if (nil != scanDeviceVC) {
            [self presentViewController:scanDeviceVC animated:YES completion:nil];
        }
    }
}

@end
