//
//  UICustomViewController.m
//  CloudBox
//
//  Created by TTS on 15/9/18.
//  Copyright © 2015年 宇音天下. All rights reserved.
//

#import "UICustomViewController.h"

@interface UICustomViewController ()

@end

@implementation UICustomViewController

- (void)loadView {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [super loadView];
    
    _isAnimating = YES;
    
    NSLog(@"%s viewController:%@", __func__, self);
}

- (void)viewDidLoad {
    
//    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [super viewDidLoad];
    
    _isAnimating = YES;
    
    NSLog(@"%s viewController:%@", __func__, self);
}

- (void)viewWillAppear:(BOOL)animated {
//    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [super viewWillAppear:animated];
    
    _isAnimating = YES;
    
    NSLog(@"%s viewController:%@", __func__, self);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _isAnimating = NO;
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    NSLog(@"%s viewController:%@", __func__, self);
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [super viewWillDisappear:animated];
    
    _isAnimating = YES;
    
    NSLog(@"%s viewController:%@", __func__, self);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    _isAnimating = NO;
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    NSLog(@"%s viewController:%@", __func__, self);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
