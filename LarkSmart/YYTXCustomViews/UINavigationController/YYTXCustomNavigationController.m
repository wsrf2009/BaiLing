//
//  YYTXCustomNavigationController.m
//  CloudBox
//
//  Created by TTS on 15/9/28.
//  Copyright © 2015年 宇音天下. All rights reserved.
//

#import "YYTXCustomNavigationController.h"

@interface YYTXCustomNavigationController ()

@end

@implementation YYTXCustomNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#if 0
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    
    NSLog(@"%s navigationBar:%@ item:%@", __func__, navigationBar, item);
    
    UIViewController *vc = self.topViewController;
    if (vc.navigationItem == item) {
        if ([vc conformsToProtocol:@protocol(YYTXNavigationBarDelegate)]) {
            return [(id<YYTXNavigationBarDelegate>)vc shouldPopItem];
        } else {
            return YES;
        }
    } else {
        return YES;
    }
    
    return YES;
}
#endif
@end
