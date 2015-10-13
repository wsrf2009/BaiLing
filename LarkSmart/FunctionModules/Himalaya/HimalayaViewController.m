//
//  HimalayaViewController.m
//  CloudBox
//
//  Created by TTS on 15/6/11.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "HimalayaViewController.h"
#import "ListViewController.h"
#import "XMLYHelpViewController.h"
#import "MainMenuViewController.h"

@interface HimalayaViewController ()

@end

@implementation HimalayaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.toolbarItems = [_toolBarPlayer toolItems];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"back", @"hint", nil) style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClick)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"help", @"hint", nil) style:UIBarButtonItemStylePlain target:self action:@selector(gotoXMLYHelp)];
    
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"himalaya", @"hint", nil)];
    
    [self hideEmptySeparators:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)backButtonClick {
    
    NSLog(@"%s", __func__);
    
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[MainMenuViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

- (void)hideEmptySeparators:(UITableView *)tableView {
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [tableView setTableFooterView:v];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    ListViewController *listVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ListViewController"];
    
    listVC.parentCategoryID = [NSString stringWithFormat:@"%03d", row+1];
    listVC.deviceManager = _deviceManager;
    listVC.toolBarPlayer = _toolBarPlayer;
    if (nil != listVC) {
        [self.navigationController pushViewController:listVC animated:YES];
    }
}

- (void)gotoXMLYHelp {

    XMLYHelpViewController *xmlyHelpVC = [[UIStoryboard storyboardWithName:@"Himalaya" bundle:nil] instantiateViewControllerWithIdentifier:@"XMLYHelpViewController"];
    if (nil != xmlyHelpVC) {
        xmlyHelpVC.deviceManager = _deviceManager;
        xmlyHelpVC.toolBarPlayer = _toolBarPlayer;
        [self.navigationController pushViewController:xmlyHelpVC animated:YES];
//        UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:xmlyHelpVC];
//        [self presentViewController:nv animated:YES completion:nil];
    }
    
}

@end
