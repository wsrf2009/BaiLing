//
//  HelperViewController.h
//  CloudBox
//
//  Created by TTS on 15-4-24.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYTXDeviceManager.h"

@interface HelperViewController : UIViewController<YYTXDeviceManagerDelegate>
@property (nonatomic, retain) YYTXDeviceManager *deviceManager;

@end
