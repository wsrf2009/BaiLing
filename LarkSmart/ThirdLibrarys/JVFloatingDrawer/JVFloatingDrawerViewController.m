//
//  JVFloatingDrawerViewController.m
//  JVFloatingDrawer
//
//  Created by Julian Villella on 2015-01-11.
//  Copyright (c) 2015 JVillella. All rights reserved.
//

#import "JVFloatingDrawerViewController.h"
#import "JVFloatingDrawerView.h"
#import "JVFloatingDrawerSpringAnimator.h"
#import "SideLeftViewController.h"
#import "DeviceControlNavigationController.h"
#import "MainMenuViewController.h"
#import "ToolBarPlayController.h"

NSString *JVFloatingDrawerSideString(JVFloatingDrawerSide side) {
    const char* c_str = 0;
#define PROCESS_VAL(p) case(p): c_str = #p; break;
    switch(side) {
        PROCESS_VAL(JVFloatingDrawerSideNone);
        PROCESS_VAL(JVFloatingDrawerSideLeft);
        PROCESS_VAL(JVFloatingDrawerSideRight);
    }
#undef PROCESS_VAL
    
    return [NSString stringWithCString:c_str encoding:NSASCIIStringEncoding];
}

@interface JVFloatingDrawerViewController () <DeviceFunctionsDelegate>

@property (nonatomic, strong, readonly) JVFloatingDrawerView *drawerView;
@property (nonatomic, assign) JVFloatingDrawerSide currentlyOpenedSide;
@property (nonatomic, strong) UITapGestureRecognizer *toggleDrawerTapGestureRecognizer;

@property (nonatomic, retain) ToolBarPlayController *toolBarPlayer;

@end

@implementation JVFloatingDrawerViewController

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if(self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.currentlyOpenedSide = JVFloatingDrawerSideNone;
}

- (void)configureDrawerViewController {
    
    NSLog(@"%s isMainThread:%@", __func__, [NSThread isMainThread]?@"YES":@"NO");
    
    _toolBarPlayer = [[ToolBarPlayController alloc] initWithManager:_deviceManager];

    SideLeftViewController *deviceFunctionTVC = [[UIStoryboard storyboardWithName:@"DeviceControl" bundle:nil] instantiateViewControllerWithIdentifier:@"SideLeftViewController"];
    deviceFunctionTVC.deviceManager = _deviceManager;
    deviceFunctionTVC.toolBarPlayer = _toolBarPlayer;
    deviceFunctionTVC.delegate = self;
    self.leftViewController = deviceFunctionTVC;
    
    DeviceControlNavigationController *deviceControlNC = [[UIStoryboard storyboardWithName:@"DeviceControl" bundle:nil] instantiateViewControllerWithIdentifier:@"DeviceControlNavigationController"];
    MainMenuViewController *mainMenuVC = [[deviceControlNC childViewControllers] firstObject];
    mainMenuVC.deviceManager = _deviceManager;
    mainMenuVC.toolBarPlayer = _toolBarPlayer;

    self.centerViewController = deviceControlNC;
    self.backgroundImage = [UIImage imageNamed:@"menubackground.png"];

    _animator = [[JVFloatingDrawerSpringAnimator alloc] init];
}

- (void)toggleLeftDrawer:(id)sender {
    [self toggleDrawerWithSide:JVFloatingDrawerSideLeft animated:YES completion:nil];
}

- (void)selectedViewController:(UIViewController *)newVC {
    
    NSLog(@"%s isMainThread:%@", __func__, [NSThread isMainThread]?@"YES":@"NO");

    [self toggleLeftDrawer:nil];
    self.centerViewController = newVC;
}

#pragma mark - View Related

- (void)viewDidLoad {
    NSLog(@"%s isMainThread:%@", __func__, [NSThread isMainThread]?@"YES":@"NO");
    [super viewDidLoad];
    
    [self configureDrawerViewController];
}

- (void)loadView {
    NSLog(@"%s isMainThread:%@", __func__, [NSThread isMainThread]?@"YES":@"NO");
    
    [super loadView];

    self.drawerView = [[JVFloatingDrawerView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}

// Convenience type-wrapper around self.view. Maybe not the best idea?
- (void)setDrawerView:(JVFloatingDrawerView *)drawerView {
    self.view = drawerView;
}

- (JVFloatingDrawerView *)drawerView {
    return (JVFloatingDrawerView *)self.view;
}

#pragma mark - Interaction

- (void)openDrawerWithSide:(JVFloatingDrawerSide)drawerSide animated:(BOOL)animated completion:(void(^)(BOOL finished))completion {
    if(self.currentlyOpenedSide != drawerSide) {
        UIView *sideView = [self.drawerView viewContainerForDrawerSide:drawerSide];
        UIView *centerView = self.drawerView.centerViewContainer;
        
        // First close opened drawer and then open new drawer
        if(self.currentlyOpenedSide != JVFloatingDrawerSideNone) {
            [self closeDrawerWithSide:self.currentlyOpenedSide animated:animated completion:^(BOOL finished) {
                [self.animator presentationWithSide:drawerSide sideView:sideView centerView:centerView animated:animated completion:completion];
            }];
        } else {
            [self.animator presentationWithSide:drawerSide sideView:sideView centerView:centerView animated:animated completion:completion];
        }
        
        [self addDrawerGestures];
        [self.drawerView willOpenFloatingDrawerViewController:self];
    }
    
    self.currentlyOpenedSide = drawerSide;
}

- (void)closeDrawerWithSide:(JVFloatingDrawerSide)drawerSide animated:(BOOL)animated completion:(void(^)(BOOL finished))completion {
    if(self.currentlyOpenedSide == drawerSide && self.currentlyOpenedSide != JVFloatingDrawerSideNone) {
        UIView *sideView   = [self.drawerView viewContainerForDrawerSide:drawerSide];
        UIView *centerView = self.drawerView.centerViewContainer;
        
        [self.animator dismissWithSide:drawerSide sideView:sideView centerView:centerView animated:animated completion:completion];
        
        self.currentlyOpenedSide = JVFloatingDrawerSideNone;
        
        [self restoreGestures];
        
        [self.drawerView willCloseFloatingDrawerViewController:self];
    }
}

- (void)toggleDrawerWithSide:(JVFloatingDrawerSide)drawerSide animated:(BOOL)animated completion:(void(^)(BOOL finished))completion {
    if(drawerSide != JVFloatingDrawerSideNone) {
        if(drawerSide == self.currentlyOpenedSide) {
            [self closeDrawerWithSide:drawerSide animated:animated completion:completion];
        } else {
            [self openDrawerWithSide:drawerSide animated:animated completion:completion];
        }
    }
}

#pragma mark - Gestures

- (void)addDrawerGestures {
    self.centerViewController.view.userInteractionEnabled = NO;
    self.toggleDrawerTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionCenterViewContainerTapped:)];
    [self.drawerView.centerViewContainer addGestureRecognizer:self.toggleDrawerTapGestureRecognizer];
}

- (void)restoreGestures {
    [self.drawerView.centerViewContainer removeGestureRecognizer:self.toggleDrawerTapGestureRecognizer];
    self.toggleDrawerTapGestureRecognizer = nil;
    self.centerViewController.view.userInteractionEnabled = YES;    
}

- (void)actionCenterViewContainerTapped:(id)sender {
    NSLog(@"%s", __func__);
    [self closeDrawerWithSide:self.currentlyOpenedSide animated:YES completion:nil];
}

#pragma mark - Managed View Controllers

- (void)setLeftViewController:(UIViewController *)leftViewController {
    [self replaceViewController:self.leftViewController
             withViewController:leftViewController container:self.drawerView.leftViewContainer];
    
    _leftViewController = leftViewController;
}

- (void)setRightViewController:(UIViewController *)rightViewController {
    [self replaceViewController:self.rightViewController withViewController:rightViewController
                      container:self.drawerView.rightViewContainer];
    
    _rightViewController = rightViewController;
}

- (void)setCenterViewController:(UIViewController *)centerViewController {

    [self replaceViewController:self.centerViewController withViewController:centerViewController
                      container:self.drawerView.centerViewContainer];
    
    _centerViewController = centerViewController;
    
    [self resetNavButtons];
}

- (void)replaceViewController:(UIViewController *)sourceViewController withViewController:(UIViewController *)destinationViewController container:(UIView *)container {

    [sourceViewController willMoveToParentViewController:nil];
    [sourceViewController.view removeFromSuperview];
    [sourceViewController removeFromParentViewController];
    
    [self addChildViewController:destinationViewController];
    [container addSubview:destinationViewController.view];
   
    UIView *destinationView = destinationViewController.view;

    destinationView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLog(@"%s containerFrame:%@", __func__, NSStringFromCGRect(container.frame));
    
    NSDictionary *views = NSDictionaryOfVariableBindings(destinationView);
    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[destinationView]|" options:0 metrics:nil views:views]];
    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[destinationView]|" options:0 metrics:nil views:views]];
    
    [destinationViewController didMoveToParentViewController:self];
}

#pragma mark - Reveal Widths

- (void)setLeftDrawerWidth:(CGFloat)leftDrawerWidth {
    self.drawerView.leftViewContainerWidth = leftDrawerWidth;
}

- (void)setRightDrawerWidth:(CGFloat)rightDrawerWidth {
    self.drawerView.rightViewContainerWidth = rightDrawerWidth;
}

- (CGFloat)leftDrawerRevealWidth {
    return self.drawerView.leftViewContainerWidth;
}

- (CGFloat)rightDrawerRevealWidth {
    return self.drawerView.rightViewContainerWidth;
}

#pragma mark - Background Image

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    self.drawerView.backgroundImageView.image = backgroundImage;
}

- (UIImage *)backgroundImage {
    return self.drawerView.backgroundImageView.image;
}

#pragma mark - Helpers

- (UIViewController *)viewControllerForDrawerSide:(JVFloatingDrawerSide)drawerSide {
    UIViewController *sideViewController = nil;
    switch (drawerSide) {
        case JVFloatingDrawerSideLeft: sideViewController = self.leftViewController; break;
        case JVFloatingDrawerSideRight: sideViewController = self.rightViewController; break;
        case JVFloatingDrawerSideNone: sideViewController = nil; break;
    }
    return sideViewController;
}

#pragma mark - Orientation
#if 0
- (BOOL)shouldAutorotate {
    return [self.centerViewController shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations {
    return [self.centerViewController supportedInterfaceOrientations];;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.centerViewController preferredInterfaceOrientationForPresentation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if(self.currentlyOpenedSide != JVFloatingDrawerSideNone) {
        UIView *sideView   = [self.drawerView viewContainerForDrawerSide:self.currentlyOpenedSide];
        UIView *centerView = self.drawerView.centerViewContainer;
        
        [self.animator willRotateOpenDrawerWithOpenSide:self.currentlyOpenedSide sideView:sideView centerView:centerView];
    }
    
    [self.centerViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if(self.currentlyOpenedSide != JVFloatingDrawerSideNone) {
        UIView *sideView   = [self.drawerView viewContainerForDrawerSide:self.currentlyOpenedSide];
        UIView *centerView = self.drawerView.centerViewContainer;
        
        [self.animator didRotateOpenDrawerWithOpenSide:self.currentlyOpenedSide sideView:sideView centerView:centerView];
    }
    
    [self.centerViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}
#endif
#pragma mark - Status Bar

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.centerViewController;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.centerViewController;
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetNavButtons {
    
    if (!_centerViewController) {
       return;
    }
    
    UIViewController *topController = nil;
    if ([_centerViewController isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController *navController = (UINavigationController *)_centerViewController;
        if ([[navController viewControllers] count] > 0) {
            topController = [[navController viewControllers] objectAtIndex:0];
        }
    } else {
        topController = _centerViewController;
    }
    
    [topController.navigationController.navigationBar setTranslucent:NO];
    [topController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"background.png"] forBarMetrics:UIBarMetricsDefault];
    [topController.navigationController.navigationBar setTintColor:[UIColor whiteColor]];

    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sideMenu.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleLeftDrawer:)];
            
    topController.navigationItem.leftBarButtonItem = button;
}

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com