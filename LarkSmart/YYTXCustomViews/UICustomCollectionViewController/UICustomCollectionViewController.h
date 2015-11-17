//
//  UICustomCollectionViewController.h
//  CloudBox
//
//  Created by TTS on 15/9/18.
//  Copyright © 2015年 宇音天下. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYTXDeviceManager.h"

@interface UICustomCollectionViewController : UICollectionViewController
@property (nonatomic, retain) YYTXDeviceManager *deviceManager;
@property (nonatomic, assign) BOOL isAnimating; // 视图正在切换的标志

@end
