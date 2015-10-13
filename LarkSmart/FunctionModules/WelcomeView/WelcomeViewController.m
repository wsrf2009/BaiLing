//
//  ViewController.m
//  CloudBox
//
//  Created by TTS on 15-3-13.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "WelcomeViewController.h"
#import "WelcomePageView.h"
#import "ScanDeviceViewController.h"

#define BUTTON_WIDTH    182.5f
#define BUTTON_HEIGHT   45.0f

@interface WelcomeViewController () <UIScrollViewDelegate>

@property (nonatomic, retain) WelcomePageView *pageView;
@property (nonatomic, retain) UIPageControl *pageController;

@end

@implementation WelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect frame = self.view.frame;
    frame.origin = (CGPoint){0, 0};
    WelcomePageView *scrollView = [[WelcomePageView alloc] initWithFrame:frame];
    self.pageView = scrollView;
    scrollView.delegate = self; //设置代理，使得视图滚动时更新其他控件
    [self.view addSubview:scrollView];
    
    NSLog(@"%s %@", __func__, NSStringFromCGRect(frame));
    
    frame.origin.y += frame.size.height-8.0f;
    frame.size.height = 5.0f;
    
    NSLog(@"%s pageCtrlFrame:%@", __func__, NSStringFromCGRect(frame));
    
    UIPageControl *pageCtrl = [[UIPageControl alloc] initWithFrame:frame];
    self.pageController = pageCtrl;
    pageCtrl.currentPageIndicatorTintColor = [UIColor greenColor]; // 当前页的指示器颜色
    [self.view insertSubview:pageCtrl aboveSubview:self.pageView];

    [self.pageView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"welcome_01.png"]] forCurrent:NO];
    
    UIView *lastView = [[UIView alloc] init];
    [self.pageView addSubview:lastView forCurrent:NO];
    
    // 最后一个页面
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-BUTTON_HEIGHT)];
    [imageView setImage:[UIImage imageNamed:@"welcome_02.png"]];
    [lastView addSubview:imageView];
    
    /** 设置页指示器总个数 */
    self.pageController.numberOfPages = [self.pageView.subviews count];

    // 生成一个按钮
    CGSize s = self.view.frame.size;
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(s.width/2-BUTTON_WIDTH/2, self.pageController.frame.origin.y-BUTTON_HEIGHT-3.0f, BUTTON_WIDTH, BUTTON_HEIGHT);
    [button setImage:[UIImage imageNamed:@"start.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClickEvent) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 8;
    
    // 在最后一个页面添加开始使用按钮
    [lastView addSubview:button];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setToolbarHidden:YES];
}

- (void)buttonClickEvent {
    NSLog(@"%s", __func__);
    // 进入设备搜索界面
    ScanDeviceViewController *scanDeviceVC = [[UIStoryboard storyboardWithName:@"ScanDevice" bundle:nil] instantiateViewControllerWithIdentifier:@"ScanDeviceViewController"];

    scanDeviceVC.deviceManager = _deviceManger;
    
    if (nil != scanDeviceVC) {
        [self presentViewController:scanDeviceVC animated:YES completion:nil];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma 实现协议UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = scrollView.contentOffset.x / _pageView.pageSize.width;
    
    if(page != _pageController.currentPage) {
        _pageController.currentPage = page;
    }
}

@end

