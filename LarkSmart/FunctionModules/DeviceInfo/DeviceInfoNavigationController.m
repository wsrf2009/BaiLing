//
//  DeviceInfoNavigationController.m
//  CloudBox
//
//  Created by TTS on 15/9/15.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "DeviceInfoNavigationController.h"

@interface DeviceInfoNavigationController ()

@end

@implementation DeviceInfoNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#if 0
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    NSLog(@"%s", __func__);
    
    if (self.topViewController.isBeingPresented || self.topViewController.isBeingDismissed) {
        
        NSLog(@"%s %@ isBeingPresented Or isBeingDismissed", __func__, self.topViewController);
        
        return;
    }
    
    [super pushViewController:viewController animated:animated];
}
#endif
@end
