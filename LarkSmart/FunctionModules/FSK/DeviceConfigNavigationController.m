//
//  DeviceConfigNavigationController.m
//  CloudBox
//
//  Created by TTS on 15-4-21.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "DeviceConfigNavigationController.h"

@interface DeviceConfigNavigationController () <UINavigationBarDelegate, UINavigationControllerDelegate>

@end

@implementation DeviceConfigNavigationController

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
