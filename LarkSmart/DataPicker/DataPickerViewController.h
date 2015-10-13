//
//  DataPickerAlertController.h
//  CloudBox
//
//  Created by TTS on 15-4-28.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataPickerViewController : UIAlertController<UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, retain) NSMutableArray *dataSource;


- (id)initWithTitle:(NSString *)title selectFinish:(void (^)(NSMutableArray *selectedIndexArray))finish;
- (void)displayArray:(NSMutableArray *)sourceArray atIndexArray:(NSMutableArray *)indexArray;
- (id)initWithTitle:(NSString *)title selectArrays:(void (^)(NSMutableArray *selectedIndexArray, NSMutableArray *selectTextArray))selectArrays;

@end
