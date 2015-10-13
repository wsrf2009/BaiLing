//
//  DataPickerAlertController.m
//  CloudBox
//
//  Created by TTS on 15-4-28.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "DataPickerViewController.h"

@interface DataPickerViewController ()
@property (nonatomic, retain) UIPickerView *dataPicker;

@end

@implementation DataPickerViewController

- (id)initWithTitle:(NSString *)title selectFinish:(void (^)(NSMutableArray *selectedIndexArray))finish {
    
    self = [DataPickerViewController alertControllerWithTitle:title message:@"\n\n\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleActionSheet];
    if (nil != self) {
        _dataPicker =[[UIPickerView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width-20, 200)];
        _dataPicker.delegate=self;
        _dataPicker.dataSource=self;
        [self.view addSubview:_dataPicker];
        
        [self addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:_dataSource.count];
            
            for (int i=0; i<_dataSource.count; i++) {
                [arr addObject:[NSNumber numberWithUnsignedInteger:[_dataPicker selectedRowInComponent:i]]];
            }
            
            finish(arr);
            
        }]];
        [self addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title selectArrays:(void (^)(NSMutableArray *selectedIndexArray, NSMutableArray *selectTextArray))selectArrays {
    
    self = [DataPickerViewController alertControllerWithTitle:title message:@"\n\n\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleActionSheet];
    if (nil != self) {
        _dataPicker =[[UIPickerView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width-20, 200)];
        _dataPicker.delegate=self;
//        _dataPicker.dataSource=self;
        [self.view addSubview:_dataPicker];
        
        [self addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSMutableArray *arrIndex = [[NSMutableArray alloc] initWithCapacity:_dataSource.count];
            NSMutableArray *arrText = [[NSMutableArray alloc] initWithCapacity:_dataSource.count];
            
            for (int i=0; i<_dataSource.count; i++) {
                [arrIndex addObject:[NSNumber numberWithUnsignedInteger:[_dataPicker selectedRowInComponent:i]]];
                [arrText addObject:[_dataSource[i] objectAtIndex:[_dataPicker selectedRowInComponent:i]]];
            }
            
            selectArrays(arrIndex, arrText);
            
        }]];
        [self addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    }
    return self;
}

- (void) displayArray:(NSMutableArray *)sourceArray atIndexArray:(NSMutableArray *)indexArray {
    
    NSLog(@"%s", __func__);
    
    if (indexArray.count != sourceArray.count) {
        return;
    }
    
    _dataSource = sourceArray;
    
    for (int i=0; i<indexArray.count; i++) {
        [_dataPicker selectRow:[[indexArray objectAtIndex:i] unsignedIntegerValue] inComponent:i animated:YES];
    }
    
    [_dataPicker reloadAllComponents];
}

#pragma pickerView datasource

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSLog(@"%s", __func__);
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    NSLog(@"%s", __func__);
    
    return (self.view.frame.size.width-50)/_dataSource.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    
    NSLog(@"%s", __func__);
    
    return 35;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    NSLog(@"%s %lu", __func__, (unsigned long)_dataSource.count);
    
    return _dataSource.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    NSLog(@"%s %lu", __func__, (unsigned long)[[_dataSource objectAtIndex:component] count]);
    
    return [[_dataSource objectAtIndex:component] count];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UIView *v = [[UIView alloc]
                 initWithFrame:CGRectMake(0,0, [self pickerView:pickerView widthForComponent:component], [self pickerView:pickerView rowHeightForComponent:component])];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [self pickerView:pickerView widthForComponent:component], [self pickerView:pickerView rowHeightForComponent:component])];
    
    NSLog(@"%s component:%ld row:%ld", __func__, (long)component, (long)row);
    
    [label setFont:[UIFont systemFontOfSize:16]];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    label.text = [NSString stringWithFormat:@"%@", [[_dataSource objectAtIndex:component] objectAtIndex:row]];
    
    [v addSubview:label];
    
    return v;
}



@end
