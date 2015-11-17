//
//  DeviceInfoTableViewController.m
//  CloudBox
//
//  Created by TTS on 15-3-27.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "DeviceInfoTableViewController.h"
#import "Battery.h"
#import "RSSIIndicator.h"
#import "UIImageView+WebCache.h"

@interface DeviceInfoTableViewController ()

@property (nonatomic, retain) IBOutlet UILabel *labelBattery;
@property (nonatomic, retain) IBOutlet UILabel *labelIP;
@property (nonatomic, retain) IBOutlet UILabel *labelMAC;
@property (nonatomic, retain) IBOutlet UILabel *labelHardwareVersion;
@property (nonatomic, retain) IBOutlet UILabel *labelSoftwareVersion;
@property (nonatomic, retain) IBOutlet UILabel *labelProductID;
@property (nonatomic, retain) IBOutlet Battery *battery;
@property (nonatomic, retain) IBOutlet UIImageView *wifiRssi;
@property (nonatomic, retain) IBOutlet RSSIIndicator *rssi;
@property (nonatomic, retain) IBOutlet UIImageView *deviceIcon;
@property (nonatomic, retain) IBOutlet UILabel *labelNickName;
@property (nonatomic, retain) IBOutlet UILabel *labelServerStatus;
@property (nonatomic, retain) IBOutlet UILabel *labelConfigVersion;

@end

@implementation DeviceInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%s isValid:%d", __func__, _device.userData.deviceInfo.isValid);

    [self hideEmptySeparators:self.tableView];
    
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"deviceInfo", @"hint", nil)];
    
    if (nil == _device.deviceIconUrl) {
        /* 如果设备的icon url为空，则从数据库中获取出对应产品ID的icon url */
        NSMutableArray *productsInfo = [BoxDatabase getItemsFromProducsInfo];
        for (NSDictionary *product in productsInfo) {
            
            if ([_device.userData.deviceInfo.productId isEqualToString:[product objectForKey:PRODUCTINFO_PRODUCTID]]) {
                _device.deviceIconUrl = [product objectForKey:PRODUCTINFO_ICON];
            }
        }
    }
    
    if (!_device.userData.deviceInfo.isValid) {
        /* 如果还没有有效的设备信息，则须从设备获取 */
        [self getDeviceInfo];
    } else {
        [self updateUI];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma 设备信息数据源

- (void)getDeviceInfo {
    
    NSLog(@"%s", __func__);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self showActiviting];
    });
    
    /* 获取设备信息 */
    [_device heartBeat:^(YYTXDeviceReturnCode code) {

        dispatch_async(dispatch_get_main_queue(), ^{

            if (YYTXOperationSuccessful == code) {
                
                [self removeEffectView];
                [self updateUI];
            } else if (YYTXTransferFailed == code) {
                
                [self showTitle:NSLocalizedStringFromTable(@"gettingDeviceInfoFailed", @"hint", nil) hint:NSLocalizedStringFromTable(@"hintForTransferFailed", @"hint", nil)];
            } else if (YYTXDeviceIsAbsent == code) {
                
                [self showTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
            } else if (YYTXOperationIsTooFrequent == code) {
                [self removeEffectView];
            } else {
                [self showTitle:NSLocalizedStringFromTable(@"gettingDeviceInfoFailed", @"hint", nil) hint:@""];
            }
        });
    }];
}

- (void)updateUI {
    
    if (nil != _device.deviceIconUrl) {
        [_deviceIcon sd_setImageWithURL:[NSURL URLWithString:_device.deviceIconUrl] placeholderImage:[UIImage imageNamed:@"default_small.png"]];
    }
    
    [_labelNickName setText:_device.userData.generalData.nickName];
    [_battery setPower:(CGFloat)_device.userData.deviceInfo.power/100];
    [_labelBattery setText:[NSString stringWithFormat:@"%lu%c", (unsigned long)_device.userData.deviceInfo.power, '%']];
    [_labelIP setText:_device.userData.deviceInfo.ip];
    [_labelMAC setText:_device.userData.deviceInfo.mac];
    [_labelHardwareVersion setText:_device.userData.deviceInfo.HWVersion];
    [_labelSoftwareVersion setText:_device.userData.deviceInfo.SWVersion];
    [_labelProductID setText:_device.userData.deviceInfo.goodsId];
    [_labelConfigVersion setText:_device.userData.deviceInfo.config];

    [_rssi setRssi:_device.userData.deviceInfo.rssi];
    
    NSString *serverStatus;
    [self.deviceManager checkServerStatus:&serverStatus];
    _labelServerStatus.text = serverStatus;

}

@end
