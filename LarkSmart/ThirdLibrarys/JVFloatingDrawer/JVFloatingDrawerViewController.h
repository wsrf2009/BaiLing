//
//  JVFloatingDrawerViewController.h
//  JVFloatingDrawer
//
//  Created by Julian Villella on 2015-01-11.
//  Copyright (c) 2015 JVillella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYTXDeviceManager.h"

@protocol JVFloatingDrawerAnimation;

typedef NS_ENUM(NSInteger, JVFloatingDrawerSide) {
    JVFloatingDrawerSideNone = 0,
    JVFloatingDrawerSideLeft,
    JVFloatingDrawerSideRight
};

@interface JVFloatingDrawerViewController : UIViewController

#pragma mark - Managed View Controllers

@property (nonatomic, strong) UIViewController *centerViewController;
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) UIViewController *rightViewController;

#pragma mark - Reveal Widths

@property (nonatomic, assign) CGFloat leftDrawerWidth;
@property (nonatomic, assign) CGFloat rightDrawerWidth;

#pragma mark - Interaction

@property (nonatomic, assign, getter=isDragToRevealEnabled) BOOL dragToRevealEnabled;

- (void)openDrawerWithSide:(JVFloatingDrawerSide)drawerSide animated:(BOOL)animated
                completion:(void(^)(BOOL finished))completion;

- (void)closeDrawerWithSide:(JVFloatingDrawerSide)drawerSide animated:(BOOL)animated
                 completion:(void(^)(BOOL finished))completion;

- (void)toggleDrawerWithSide:(JVFloatingDrawerSide)drawerSide animated:(BOOL)animated
                  completion:(void(^)(BOOL finished))completion;

#pragma mark - Animation

@property (nonatomic, strong) id<JVFloatingDrawerAnimation> animator;

#pragma mark - Background

@property (nonatomic, strong) UIImage *backgroundImage;

@property (nonatomic, retain) YYTXDeviceManager *deviceManager;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com