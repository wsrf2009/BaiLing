//
//  ChinaCityViewController.h
//  CloudBox
//
//  Created by TTS on 15-5-13.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChinaCityViewControllerDelegate <NSObject>

- (void)selectedProvince:(NSString *)province selectedCity:(NSString *)city;

@end

@interface ChinaCityViewController : UIAlertController

@property (nonatomic, retain) id <ChinaCityViewControllerDelegate> delegate;

- (instancetype)initWithPickerView:(UIPickerView *)pickerView delegate:(id)delegate;
- (instancetype)initWithTitle:(NSString *)title select:(void (^)(NSString *selectProvince, NSString *selectCity))select;
- (void)displayProvince:(NSString *)province;
- (void)displayProvince:(NSString *)province city:(NSString *)city;

@end
