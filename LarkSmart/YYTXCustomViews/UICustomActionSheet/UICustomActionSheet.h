//
//  UICustomActionSheet.h
//  CloudBox
//
//  Created by TTS on 15/9/11.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ActionSheetCompleteBlock) (UIActionSheet *actionSheet, NSInteger buttonIndex);

@interface UICustomActionSheet : UIActionSheet <UIActionSheetDelegate>

// 用Block的方式回调，这时候会默认用self作为Delegate
- (void)showActionSheetFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated withCompleteBlock:(ActionSheetCompleteBlock)block;

@end
