//
//  JVFloatingDrawerView.m
//  JVFloatingDrawer
//
//  Created by Julian Villella on 2015-01-11.
//  Copyright (c) 2015 JVillella. All rights reserved.
//

#import "JVFloatingDrawerView.h"

static const CGFloat kJVCenterViewContainerCornerRadius = 5.0;
static const CGFloat kJVDefaultViewContainerWidth = 240.0;

@interface JVFloatingDrawerView ()

@property (nonatomic, strong) NSLayoutConstraint *leftViewContainerWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *rightViewContainerWidthConstraint;

@end

@implementation JVFloatingDrawerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setup];
    }
    return self;
}

#pragma mark - View Setup

- (void)setup {
    [self setupBackgroundImageView];
    [self setupCenterViewContainer];
    [self setupLeftViewContainer];
    [self setupRightViewContainer];
    
    [self bringSubviewToFront:self.centerViewContainer];
}

- (void)setupBackgroundImageView {
    _backgroundImageView = [[UIImageView alloc] init];
    
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.backgroundImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.backgroundImageView];
    
    NSArray *constraints = @[
        [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeLeading  relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0],
        [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0],
        [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeTop      relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
        [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeBottom   relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
    ];
    
    [self addConstraints:constraints];
}

- (void)setupLeftViewContainer {
    
    _leftViewContainer = [[UIView alloc] init];
    [_leftViewContainer setFrame:(CGRect){-kJVDefaultViewContainerWidth, 0, kJVDefaultViewContainerWidth, CGRectGetHeight(self.frame)}];
    _leftViewContainer.alpha = 0.0f;
    [self addSubview:self.leftViewContainer];
}

- (void)setupRightViewContainer {

    _rightViewContainer = [[UIView alloc] init];
    [_rightViewContainer setFrame:(CGRect){CGRectGetWidth(self.frame), 0, kJVDefaultViewContainerWidth, CGRectGetHeight(self.frame)}];
    _rightViewContainer.alpha = 0.0f;
    [self addSubview:self.rightViewContainer];
}

- (void)setupCenterViewContainer {

    _centerViewContainer = [[UIView alloc] init];
    [_centerViewContainer setFrame:self.frame];
    [self addSubview:self.centerViewContainer];
}

#pragma mark - Reveal Widths

- (void)setLeftViewContainerWidth:(CGFloat)leftViewContainerWidth {
    self.leftViewContainerWidthConstraint.constant = leftViewContainerWidth;
}

- (void)setRightViewContainerWidth:(CGFloat)rightViewContainerWidth {
    self.rightViewContainerWidthConstraint.constant = rightViewContainerWidth;
}

- (CGFloat)leftViewContainerWidth {
    return self.leftViewContainerWidthConstraint.constant;
}

- (CGFloat)rightViewContainerWidth {
    return self.rightViewContainerWidthConstraint.constant;
}

#pragma mark - Helpers

- (UIView *)viewContainerForDrawerSide:(JVFloatingDrawerSide)drawerSide {
    UIView *viewContainer = nil;
    switch (drawerSide) {
        case JVFloatingDrawerSideLeft:
            viewContainer = self.leftViewContainer;
            break;
        case JVFloatingDrawerSideNone:
            viewContainer = nil;
            break;
        case JVFloatingDrawerSideRight:
            viewContainer = self.rightViewContainer;
            break;
    }
    return viewContainer;
}

#pragma mark - Open/Close Events

- (void)willOpenFloatingDrawerViewController:(JVFloatingDrawerViewController *)viewController {
    [self applyBorderRadiusToCenterViewController];
    [self applyShadowToCenterViewContainer];
}

- (void)willCloseFloatingDrawerViewController:(JVFloatingDrawerViewController *)viewController {
    [self removeBorderRadiusFromCenterViewController];
    [self removeShadowFromCenterViewContainer];
}

#pragma mark - View Related

// Notice, border is applied to centerViewController.view whereas shadow is applied to
// drawerView.centerViewContainer. This is because cornerRadius requires masksToBounds = YES
// but for shadows to render outside the view, masksToBounds must be NO. So we apply them on
// different views.
- (void)applyBorderRadiusToCenterViewController {
    // FIXME: Safe? Maybe move this into a property
    UIView *containerCenterView = [self.centerViewContainer.subviews firstObject];
    
    CALayer *centerLayer = containerCenterView.layer;
    centerLayer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.15].CGColor;
    centerLayer.borderWidth = 1.0;
    centerLayer.cornerRadius = kJVCenterViewContainerCornerRadius;
    centerLayer.masksToBounds = YES;
}

- (void)removeBorderRadiusFromCenterViewController {
    // FIXME: Safe? Maybe move this into a property
    UIView *containerCenterView = [self.centerViewContainer.subviews firstObject];
    
    CALayer *centerLayer = containerCenterView.layer;
    centerLayer.borderColor = [UIColor clearColor].CGColor;
    centerLayer.borderWidth = 0.0;
    centerLayer.cornerRadius = 0.0;
    centerLayer.masksToBounds = NO;
}

- (void)applyShadowToCenterViewContainer {
    CALayer *layer = self.centerViewContainer.layer;
    layer.shadowRadius  = 20.0;
    layer.shadowColor   = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.4;
    layer.shadowOffset  = CGSizeMake(0.0, 0.0);
    layer.masksToBounds = NO;
    
    [self updateShadowPath];
}

- (void)removeShadowFromCenterViewContainer {
    CALayer *layer = self.centerViewContainer.layer;
    layer.shadowRadius  = 0.0;
    layer.shadowOpacity = 0.0;
}

- (void)updateShadowPath {
    CALayer *layer = self.centerViewContainer.layer;
    
    CGFloat increase = layer.shadowRadius;
    CGRect centerViewContainerRect = self.centerViewContainer.bounds;
    centerViewContainerRect.origin.x -= increase;
    centerViewContainerRect.origin.y -= increase;
    centerViewContainerRect.size.width  += 2.0 * increase;
    centerViewContainerRect.size.height += 2.0 * increase;
    
    layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:centerViewContainerRect cornerRadius:kJVCenterViewContainerCornerRadius] CGPath];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self updateShadowPath];
}

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com