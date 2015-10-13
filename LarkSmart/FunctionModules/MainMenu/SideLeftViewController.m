//
//  DeviceFunctionTableViewController.m
//  CloudBox
//
//  Created by TTS on 15/8/5.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "SideLeftViewController.h"
#import "UIImageView+WebCache.h"

#define dispalyRate     0.8f
#define overlayRate     0.0f

@interface SideLeftViewController ()

@property (nonatomic, retain) IBOutlet UIImageView *imageViewDeviceIcon;
@property (nonatomic, retain) IBOutlet UILabel *labelDeviceNickName;

@end

@implementation SideLeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"%s nav:%@", __func__, self.navigationController);
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    if (nil == self.deviceManager.device.deviceIconUrl) {
        NSMutableArray *productsInfo = [BoxDatabase getItemsFromProducsInfo];
        for (NSDictionary *product in productsInfo) {
            
            if ([self.deviceManager.device.userData.deviceInfo.productId isEqualToString:[product objectForKey:PRODUCTINFO_PRODUCTID]]) {
                self.deviceManager.device.deviceIconUrl = [product objectForKey:PRODUCTINFO_ICON];
            }
        }
    }
    
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    [self hideEmptySeparators:self.tableView];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ([SystemToolClass systemVersionIsNotLessThan:@"7.0"]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 30, 0, 10)];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    if ([SystemToolClass systemVersionIsNotLessThan:@"7.0"]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, CGRectGetWidth(self.tableView.frame), 0, 0)];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    if ([SystemToolClass systemVersionIsNotLessThan:@"7.0"]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, CGRectGetWidth(self.tableView.frame), 0, 0)];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    
    [_imageViewDeviceIcon sd_setImageWithURL:[NSURL URLWithString:self.deviceManager.device.deviceIconUrl] placeholderImage:[UIImage imageNamed:@"default_small.png"]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%s nav:%@", __func__, self.navigationController);
    
    [_labelDeviceNickName setText:self.deviceManager.device.userData.generalData.nickName];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    
    NSLog(@"%s", __func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SideLeftVCToDeviceFunctionsVC"]) {
        DeviceFunctionsViewController *destinationVC = [segue destinationViewController];
        destinationVC.delegate = _delegate;
        destinationVC.deviceManager = self.deviceManager;
        destinationVC.toolBarPlayer = _toolBarPlayer;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (0 == indexPath.row) {
        return 150.0f;
    } else if (1 == indexPath.row) {
        return [SystemToolClass screenHeigth]-150.0f-50.0f;
    } else {
        return 50.0f;
    }
}

@end
