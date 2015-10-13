//
//  DeviceManagerViewController.m
//  CloudBox
//
//  Created by TTS on 15-3-20.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "DeviceManagerViewController.h"
#import "DeviceCellView.h"
#import "DeviceInfoTableViewController.h"
#import "UIImageView+WebCache.h"
#import "BoxDatabase.h"
#import "DeviceConfigViewController.h"
#import "MJRefresh.h"
#import "JVFloatingDrawerViewController.h"
#import "JVFloatingDrawerSpringAnimator.h"
#import "UICustomAlertView.h"

#define EXPAND          30589
#define NOTEXPAND       30245

@interface DeviceManagerViewController ()
{

    NSMutableArray *productsInfo;

    MJRefreshAutoNormalFooter *footer;
    
    UIBarButtonItem *buttonRefresh;

    dispatch_semaphore_t semaphoreForInsertOrDeleteRow;
    
    NSLock *refreshLock;
}

@end

@implementation DeviceManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    semaphoreForInsertOrDeleteRow = dispatch_semaphore_create(1);
    refreshLock = [[NSLock alloc] init];

    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"background.png"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];

    buttonRefresh = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"refresh", @"hint", nil) style:UIBarButtonItemStylePlain target:self action:@selector(refreshDeviceList)];
    self.navigationItem.rightBarButtonItem = buttonRefresh;

    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *button_AddDevice = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"addDevice", @"hint", nil) style:UIBarButtonItemStyleDone target:self action:@selector(buttonClick_AddDevice:)];
    self.toolbarItems = @[space, button_AddDevice, space];

    [self hideEmptySeparators:self.tableView];

    productsInfo = [BoxDatabase getItemsFromProducsInfo];

    footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:nil refreshingAction:nil];
    [footer setTitle:NSLocalizedStringFromTable(@"noDeviceFound", @"hint", nil) forState:MJRefreshStateNoMoreData];
    [footer setTitle:NSLocalizedStringFromTable(@"refreshingDeviceList", @"hint", nil) forState:MJRefreshStateRefreshing];
    self.tableView.footer = footer;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"%s", __func__);
    
    self.deviceManager.delegate = self;
    [self.deviceManager searchDeviceInHighFreq];
    
    [self refreshDeviceList];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    NSLog(@"%s", __func__);
    
    [self.deviceManager searchDeviceInLowFreq];
//    [self.deviceManager pauseSearchDevice];
    self.deviceManager.delegate = nil;
}

#pragma UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%s", __func__);
    
    NSUInteger count = [self.deviceManager deviceCount];
    
    if (count <= 0) {
        
        [footer setState:MJRefreshStateNoMoreData];
        [self.tableView.footer setHidden:NO];
    } else {
        
        [self.tableView.footer setHidden:YES];
    }
    
    [self.navigationItem setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"deviceCount", @"hint", nil), (unsigned long)count]];
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = indexPath.row;
    DeviceCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceCellView"];
    DeviceDataClass *device = [self.deviceManager deviceAtIndex:row];
    
    if (nil == device) {
        return cell;
    }
        
    if (nil == device.deviceIconUrl) {
        for (NSDictionary *product in productsInfo) {
                
            if ([device.userData.deviceInfo.productId isEqualToString:[product objectForKey:PRODUCTINFO_PRODUCTID]]) {
                device.deviceIconUrl = [product objectForKey:PRODUCTINFO_ICON];
                [cell.imageViewPicture sd_setImageWithURL:[NSURL URLWithString:device.deviceIconUrl] placeholderImage:[UIImage imageNamed:@"default_small.png"]];
            }
        }
    } else {
        [cell.imageViewPicture sd_setImageWithURL:[NSURL URLWithString:device.deviceIconUrl] placeholderImage:[UIImage imageNamed:@"default_small.png"]];
    }
        
    [cell.labelDeviceName setText:device.userData.generalData.nickName];

    [cell.viewBattery setPower:(CGFloat)device.userData.deviceInfo.power/100];

    [cell.rssi setRssi:device.userData.deviceInfo.rssi];
        
    [cell.buttonFindDevice setTag:row];
    [cell.buttonChangeNickName setTag:row];
        
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.isAnimating) {
        return;
    }

    DeviceDataClass *device = [self.deviceManager deviceAtIndex:indexPath.row];

    [self showBusying:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [self removeEffectView];
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });
    
    [device playFileId:devicePromptFileIdConnected completionBlock:^(YYTXDeviceReturnCode code) {
        
        if (YYTXOperationSuccessful == code) {
            if (nil != self.deviceManager.device) {
                self.deviceManager.device.isSelect = NO;
            }
            device.isSelect = YES;
            self.deviceManager.device = device;

            JVFloatingDrawerViewController *drawerViewController = [[JVFloatingDrawerViewController alloc] init];
            NSLog(@"%s isMainThread:%@", __func__, [NSThread isMainThread]?@"YES":@"NO");
            drawerViewController.deviceManager = self.deviceManager;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (nil != drawerViewController) {
                    [self presentViewController:drawerViewController animated:YES completion:nil];
                }
            });
        } else {
            [self showMessage:NSLocalizedStringFromTable(@"connectionFailed", @"hint", nil) messageType:0];
        }
    }];
}

- (void)enableButtonChangeNickName:(NSTimer *)timer {
    UIButton *button = timer.userInfo;
    
    [button setEnabled:YES];
}

- (IBAction)buttonClick_ChangeNickName:(UIButton *)button {

    NSLog(@"%s row index:%ld", __func__, (long)button.tag);
    
    [button setEnabled:NO];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(enableButtonChangeNickName:) userInfo:button repeats:NO];
    
    DeviceDataClass *device = [self.deviceManager deviceAtIndex:button.tag];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    
    NSString *title = NSLocalizedStringFromTable(@"changeNickname", @"hint", nil);
    NSString *message = [NSString stringWithFormat: NSLocalizedStringFromTable(@"maxNicknameLenth%d", @"hint", nil), MAXNICKNAMELENGTH];
    NSString *buttonCancelTitle = NSLocalizedStringFromTable(@"cancel", @"hint", nil);
    NSString *buttonModifyTitle = NSLocalizedStringFromTable(@"modify", @"hint", nil);
    
    if ([SystemToolClass systemVersionIsNotLessThan:@"8.0"]) {
        
        /* IOS8.0及以后的系统 */
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            
            NSLog(@"%s" , __func__);
            textField.text = device.userData.generalData.nickName;
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:buttonCancelTitle style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:buttonModifyTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
            UITextField *newNickName = alertController.textFields[0];
            [self device:device changeNickName:newNickName.text indexPath:indexPath];
            
        }]];
        
        if (nil != alertController) {
            [self presentViewController:alertController animated:YES completion:nil];
        }
    } else {
        /* IOS8.0以前的系统 */
        UICustomAlertView *alertView = [[UICustomAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:buttonCancelTitle otherButtonTitles:buttonModifyTitle, nil];
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField *textField = [alertView textFieldAtIndex:0];
        [textField setText:device.userData.generalData.nickName];
        [alertView showAlertViewWithCompleteBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
            if ([buttonTitle isEqualToString:buttonModifyTitle]) {
                UITextField *textField = [alertView textFieldAtIndex:0];
                [self device:device changeNickName:textField.text indexPath:indexPath];
            }
        }];
    }
}

- (void)device:(DeviceDataClass *)device changeNickName:(NSString *)newName indexPath:(NSIndexPath *)indexPath {
    
    if (newName.length > MAXNICKNAMELENGTH) {
        NSString *message1 = NSLocalizedStringFromTable(@"changeNickNameFailed", @"hint", nil);
        NSString *message2 = [NSString stringWithFormat: NSLocalizedStringFromTable(@"maxNicknameLenth%d", @"hint", nil), MAXNICKNAMELENGTH];
        NSString *message = [NSString stringWithFormat:@"%@，%@", message1, message2];
        [self showMessage:message messageType:0];
        
        return;
    }
    
    device.userData.generalData.nickName = newName;
    
    [device modifyGeneral:@{DevicePlayFileWhenOperationSuccessful:devicePromptFileIdModifySuccessful, DevicePlayFileWhenOperationFailed:devicePromptFileIdModifyFailed} completionBlock:^(YYTXDeviceReturnCode code) {
        
        if (YYTXOperationSuccessful == code) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                DeviceCellView *cell = (DeviceCellView *)[self.tableView cellForRowAtIndexPath:indexPath];
                [cell.labelDeviceName setText:device.userData.generalData.nickName];
            });
        }
    }];
}

- (void)enableButtonSoundTest:(NSTimer *)timer {
    UIButton *button = timer.userInfo;
    
    [button setEnabled:YES];
}

- (IBAction)buttonclick_SoundTest:(UIButton *)button {

    NSLog(@"%s row index:%ld", __func__, (long)button.tag);
    
    [button setEnabled:NO];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(enableButtonSoundTest:) userInfo:button repeats:NO];
    
    DeviceDataClass *device = [self.deviceManager deviceAtIndex:button.tag];

    [device playFileId:devicePromptFileIdIMHere completionBlock:nil];
}

- (void)buttonClick_AddDevice:(id)sender {
    
    if (self.isAnimating) {
        return;
    }
    
    NSLog(@"%s", __func__);
    
    DeviceConfigViewController *deviceConfigVC = [[UIStoryboard storyboardWithName:@"DeviceConfig" bundle:nil] instantiateViewControllerWithIdentifier:@"DeviceConfigViewController"];
    deviceConfigVC.deviceManager = self.deviceManager;
    if (nil != deviceConfigVC) {
        [self.navigationController pushViewController:deviceConfigVC animated:YES];
    }
    
}

- (void)enableRefreshList {
    
    dispatch_async(dispatch_get_main_queue(), ^{

        [buttonRefresh setEnabled:YES];
    });
}

- (void)refreshDeviceList {

    if (![refreshLock tryLock]) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [buttonRefresh setEnabled:NO];
        [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(enableRefreshList) userInfo:nil repeats:NO];
        [footer setState:MJRefreshStateRefreshing];
    });

    [self.deviceManager clearDevices];
        
    [self.tableView reloadData];
        
    [self.deviceManager refreshDevices];
    
    [refreshLock unlock];
}

- (void)deviceListUpdate {
    
    NSLog(@"%s 1", __func__);

    dispatch_semaphore_wait(semaphoreForInsertOrDeleteRow, DISPATCH_TIME_FOREVER);
    
    NSLog(@"%s 2", __func__);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"%s 3", __func__);
        [self.tableView reloadData];
        dispatch_semaphore_signal(semaphoreForInsertOrDeleteRow);
        
        NSLog(@"%s 4", __func__);
    });
}


@end
