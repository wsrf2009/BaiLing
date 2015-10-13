//
//  UICustomAlertView.h
//  CloudBox
//
//  Created by TTS on 15/9/11.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^AlertViewCompleteBlock) (UIAlertView *alertView, NSInteger buttonIndex);

@interface UICustomAlertView : UIAlertView

// 用Block的方式回调，这时候会默认用self作为Delegate
- (void)showAlertViewWithCompleteBlock:(AlertViewCompleteBlock)block;

@end
