//
//  PageView.m
//  CloudBox
//
//  Created by TTS on 15-3-17.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "WelcomePageView.h"

@interface WelcomePageView ()

@end

@implementation WelcomePageView

- (id)initWithFrame:(CGRect)frame {
    if(self=[super initWithFrame:frame]) {
        /* 页模式 */
        self.pagingEnabled = YES;
        self.pageSize = frame.size;
    }
    
    NSLog(@"%s frame:%@", __func__, NSStringFromCGRect(frame));
    
    return self;
}

/* 默认的addSubview:方法会被调用， 所以为了区分所需的添加照片，重载或者定义其他方法 */
- (void)addSubview:(UIView *)view forCurrent:(BOOL)current {
    NSInteger nPage = [self.subviews count];
    
    NSLog(@"%s _pageSize:%@", __func__, NSStringFromCGSize(_pageSize));
    
    // 新添加的子页都对应content的某个区域
    view.frame = CGRectMake(nPage*_pageSize.width, 0, _pageSize.width, _pageSize.height);
    nPage++;
    self.contentSize = CGSizeMake(nPage*_pageSize.width, _pageSize.height);
    [super addSubview:view];
}

- (void)addButton:(UIButton *)button onView:(UIView *)view {
    // scrollView中使能用户交互，按钮点击事件才可用
    view.userInteractionEnabled = YES;
    [view addSubview:button];
}

@end
