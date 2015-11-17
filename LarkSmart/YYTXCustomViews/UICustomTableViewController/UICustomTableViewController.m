//
//  UICustomTableViewController.m
//  CloudBox
//
//  Created by TTS on 15/7/13.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "UICustomTableViewController.h"

@interface UICustomTableViewController ()
@property (nonatomic, retain) UIView *effectview;
@property (nonatomic, retain) UIActivityIndicatorView *activityInd;
#if 1
@property (nonatomic, retain) UIView *maskView;
#endif

@end

@implementation UICustomTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isAnimating = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _isAnimating = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    _isAnimating = YES;
    
    NSLog(@"%s self:%@ nav:%@", __func__, self, self.navigationController);
    
    /* 当前视图消失前，要移除其上的所有添加的用于提示状态的视图 */
    if (nil != _effectview) {
        [self removeEffectView];
    }
    if (nil != _maskView) {
        [_maskView removeFromSuperview];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    _isAnimating = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)hideEmptySeparators:(UITableView *)tableView {

    [tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

/** 状态条高度 */
- (CGFloat)heightForStatustBar {
    
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}

/** 导航条高度 */
- (CGFloat)heightForNavigationBarHeight {
    
    return self.navigationController.navigationBar.frame.size.height;
}

/** 初始化effectview */
- (void)initEffectView {
    
    if (nil != _effectview) {
        [self removeEffectView];
    }

    if ([SystemToolClass systemVersionIsNotLessThan:@"8.0"]) {
        _effectview = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    } else {
        _effectview = [[UIView alloc] init];
        [_effectview setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:0.9f]];
    }

    _effectview.frame = CGRectMake(0, [self heightForStatustBar]+[self heightForNavigationBarHeight], self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height);
    
    [self.navigationController.view addSubview:_effectview];
}

/** 移除effectview */
- (void)removeEffectView {

    if ([_activityInd isAnimating]) {
        [_activityInd stopAnimating];
        _activityInd = nil;
    }
    if (nil != _effectview) {
        [_effectview removeFromSuperview];
        _effectview = nil;
    }
    
    [_maskView removeFromSuperview];
}

- (void)showTitle:(NSString *)title hint:(NSString *)hint {
    
    NSLog(@"%s %@ %@", __func__, title, hint);
    
    [self initEffectView];
    
    UILabel *labelTitle = [[UILabel alloc] init];
    [labelTitle setTextColor:[UIColor colorWithRed:160.0f/255.0f green:160.0f/255.0f blue:160.0f/255.0f alpha:1.0f]];
    [labelTitle setFont:[UIFont systemFontOfSize:28]];
    labelTitle.numberOfLines = 0;
    labelTitle.translatesAutoresizingMaskIntoConstraints = NO;
    UILabel *labelHint = [[UILabel alloc] init];
    [labelHint setTextColor:[UIColor colorWithRed:160.0f/255.0f green:160.0f/255.0f blue:160.0f/255.0f alpha:1.0f]];
    [labelHint setFont:[UIFont systemFontOfSize:17]];
    [labelHint setNumberOfLines:0];
    [labelHint setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [labelTitle setText:title];
    [labelHint setText:hint];
    
    [_effectview addSubview:labelTitle];
    [_effectview addSubview:labelHint];

    if (nil == labelTitle.superview || nil == labelHint.superview) {
        [self removeEffectView];
    } else {
        [_effectview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=15)-[labelTitle]-(>=15)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(labelTitle)]];
        [_effectview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=15)-[labelHint]-(>=15)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(labelHint)]];
        [_effectview addConstraint:[NSLayoutConstraint constraintWithItem:labelTitle attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_effectview attribute:NSLayoutAttributeTop multiplier:1.0 constant:_effectview.bounds.size.height/3-_effectview.frame.origin.y]];
        [_effectview addConstraint:[NSLayoutConstraint constraintWithItem:labelTitle attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_effectview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [_effectview addConstraint:[NSLayoutConstraint constraintWithItem:labelHint attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:labelTitle attribute:NSLayoutAttributeBottom multiplier:1.0 constant:20.0]];
        [_effectview addConstraint:[NSLayoutConstraint constraintWithItem:labelHint attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_effectview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    }
}

- (void)initEffectViewWithTitle:(NSString *)title hint:(NSString *)hint {

    NSLog(@"%s self:%@ nav:%@", __func__, self, self.navigationController);
    
    [self initEffectView];
    [self showTitle:title hint:hint];
    
    [self.navigationController.view addSubview:_effectview];
}

- (void)showActiviting {
    
    [self initEffectView];
    
    _activityInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_activityInd setColor:[UIColor grayColor]];
    _activityInd.center = CGPointMake(_effectview.center.x, _effectview.bounds.size.height/2-_effectview.frame.origin.y);
    
    [_activityInd startAnimating];
    [_effectview addSubview:_activityInd];
}

- (void)showBusying:(NSString *)message {
    
    NSLog(@"%s message:%@", __func__, message);
    
    [self removeEffectView];
    
    _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, [self heightForStatustBar]+[self heightForNavigationBarHeight], self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height)];
    [_maskView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat minContentViewWidth = 130.0f;
    CGFloat minContentViewHeight = 100.0f;
    
    UIView *contentView = [[UIView alloc] init];
    [contentView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.7f]];
    contentView.layer.cornerRadius = 10.0f;
    
    UIActivityIndicatorView *activityInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityInd setOpaque:YES];
    [activityInd startAnimating];
    activityInd.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (nil != message) {
        
        CGFloat maxWidth = self.navigationController.view.frame.size.width/2-20;
        CGFloat maxHeight = 45.0f;
        CGSize maxSize = (CGSize){maxWidth, maxHeight};
        UIFont *messageFont = [UIFont systemFontOfSize:16.0f];
        UIColor *messageColor = [UIColor whiteColor];
        
        CGRect messageRect;
        if ([SystemToolClass systemVersionIsNotLessThan:@"7.0"]) {
            messageRect = [message boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:messageFont} context:nil];
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            messageRect.size = [message sizeWithFont:messageFont constrainedToSize:maxSize];
#pragma clang diagnostic pop
        }
        
        messageRect.origin = (CGPoint){0, 0};
        
        CGRect contentViewRect = messageRect;
        contentViewRect.size.height += (20+50+10+10);
        contentViewRect.size.width += 20;
        if (contentViewRect.size.width < minContentViewWidth) {
            contentViewRect.size.width = minContentViewWidth;
        }
        
        [contentView setFrame:contentViewRect];
        contentView.center = CGPointMake(_maskView.center.x, _maskView.bounds.size.height/2-_maskView.frame.origin.y);

        [contentView addSubview:activityInd];
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:activityInd attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:activityInd attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:20.0f]];
        
        UILabel *labelMessage = [[UILabel alloc] init];
        [labelMessage setFrame:messageRect];
        [labelMessage setFont:messageFont];
        [labelMessage setTextColor:messageColor];
        [labelMessage setNumberOfLines:0];
        [labelMessage setLineBreakMode:NSLineBreakByTruncatingTail];
        [labelMessage setText:message];
        labelMessage.translatesAutoresizingMaskIntoConstraints = NO;
        
        [contentView addSubview:labelMessage];
        
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:labelMessage attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:labelMessage attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10.0f]];
        
    } else {
    
        [contentView setFrame:(CGRect){0, 0, minContentViewWidth, minContentViewHeight}];
        contentView.center = CGPointMake(_maskView.center.x, _maskView.bounds.size.height/2-_maskView.frame.origin.y);
        [contentView addSubview:activityInd];
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:activityInd attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:activityInd attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    }

    [_maskView addSubview:contentView];
    
    [self.navigationController.view addSubview:_maskView];
}

@end
