//
//  DeviceFunctionsViewController.m
//  CloudBox
//
//  Created by TTS on 15/9/6.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "DeviceFunctionsViewController.h"
#import "DeviceControlNavigationController.h"
#import "MainMenuViewController.h"
#import "DeviceInfoNavigationController.h"
#import "DeviceInfoTableViewController.h"

#define dispalyRate     0.8f
#define overlayRate     0.0f

@interface DeviceFunctionsViewController ()

@end

@implementation DeviceFunctionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    [self hideEmptySeparators:self.tableView];
    
    NSLog(@"%s isMainThread:%@", __func__, [NSThread isMainThread]?@"YES":@"NO");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    
//    NSLog(@"%s", __func__);
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
//    NSLog(@"%s isMainThread:%@", __func__, [NSThread isMainThread]?@"YES":@"NO");
    
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSLog(@"%s isMainThread:%@", __func__, [NSThread isMainThread]?@"YES":@"NO");

    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"%s isMainThread:%@", __func__, [NSThread isMainThread]?@"YES":@"NO");

    UITableViewCell *cell = [[UITableViewCell alloc] init];
        
    UILabel *labelTitle = [[UILabel alloc] init];
    if (0 == indexPath.row) {
        [labelTitle setText:NSLocalizedStringFromTable(@"mainMenu", @"hint", nil)];
    }  else if (1 == indexPath.row) {
        [labelTitle setText:NSLocalizedStringFromTable(@"deviceInfo", @"hint", nil)];
    }
    [labelTitle setTextColor:[UIColor whiteColor]];
    [labelTitle setFont:[UIFont systemFontOfSize:18]];
    labelTitle.translatesAutoresizingMaskIntoConstraints = NO;
        
    [cell addSubview:labelTitle];
        
    CGFloat space = CGRectGetWidth(tableView.frame)*overlayRate;
    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==30)-[labelTitle]-(>=space)-|" options:0 metrics:@{@"space":[NSNumber numberWithFloat:space]} views:NSDictionaryOfVariableBindings(labelTitle)]];
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:labelTitle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if ([SystemToolClass systemVersionIsNotLessThan:@"7.0"]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, CGRectGetWidth(tableView.frame), 0, 0)];
    }
        
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        
    NSLog(@"%s", __func__);
        
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    if (0 == indexPath.row) {
        DeviceControlNavigationController *deviceControlNC = [[UIStoryboard storyboardWithName:@"DeviceControl" bundle:nil] instantiateViewControllerWithIdentifier:@"DeviceControlNavigationController"];
        MainMenuViewController *mainMenuVC = [[deviceControlNC childViewControllers] firstObject];
        mainMenuVC.deviceManager = self.deviceManager;
        mainMenuVC.toolBarPlayer = _toolBarPlayer;
            
        if ([_delegate respondsToSelector:@selector(selectedViewController:)]) {
            [_delegate selectedViewController:deviceControlNC];
        }
    } else if (1 == indexPath.row) {
        DeviceInfoNavigationController *deviceInfoNC = [[UIStoryboard storyboardWithName:@"DeviceInfo" bundle:nil] instantiateViewControllerWithIdentifier:@"DeviceInfoNavigationController"];
        DeviceInfoTableViewController *deviceInfoVC = [[deviceInfoNC childViewControllers] firstObject];
        deviceInfoVC.deviceManager = self.deviceManager;
        deviceInfoVC.device = self.deviceManager.device;
            
        if ([_delegate respondsToSelector:@selector(selectedViewController:)]) {
            [_delegate selectedViewController:deviceInfoNC];
        }
    }
}


@end
