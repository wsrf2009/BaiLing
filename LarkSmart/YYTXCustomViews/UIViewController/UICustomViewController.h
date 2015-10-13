//
//  UICustomViewController.h
//  CloudBox
//
//  Created by TTS on 15/9/18.
//  Copyright © 2015年 宇音天下. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYTXDeviceManager.h"

@interface UICustomViewController : UIViewController
@property (nonatomic, retain) YYTXDeviceManager *deviceManager;
@property (nonatomic, assign) BOOL isAnimating;

@end
