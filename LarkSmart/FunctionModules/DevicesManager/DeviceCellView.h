//
//  DeviceListTabelCell.h
//  CloudBox
//
//  Created by TTS on 15-3-25.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Battery.h"
#import "RSSIIndicator.h"

@interface DeviceCellView : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *imageViewPicture;
@property (nonatomic, retain) IBOutlet UILabel *labelDeviceName;
@property (nonatomic, retain) IBOutlet UIButton *buttonExpand;
@property (nonatomic, retain) IBOutlet Battery *viewBattery;
@property (nonatomic, retain) IBOutlet UIImageView *wifiRssi;
@property (nonatomic, retain) IBOutlet RSSIIndicator *rssi;
@property (nonatomic, retain) IBOutlet UIButton *buttonFindDevice;
@property (nonatomic, retain) IBOutlet UIButton *buttonChangeNickName;

@end
