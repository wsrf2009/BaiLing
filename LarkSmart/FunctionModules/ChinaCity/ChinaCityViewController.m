//
//  ChinaCityViewController.m
//  CloudBox
//
//  Created by TTS on 15-5-13.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "ChinaCityViewController.h"
#import "ChinaCityClass.h"

@interface ChinaCityViewController () <UIPickerViewDataSource,UIPickerViewDelegate>
{
    NSUInteger provinceIndex;
    NSUInteger cityIndex;
}

@property (nonatomic, retain) NSArray *provinceArray;
@property (nonatomic, retain) UIPickerView *dataPicker;

@end

@implementation ChinaCityViewController
//@synthesize dataPicker;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_dataPicker setFrame:CGRectMake(0, 20, self.view.bounds.size.width, 216)];
    [self.view addSubview:_dataPicker];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_dataPicker setFrame:CGRectMake(0, 20, self.view.bounds.size.width, 216)];
//    [self.view addSubview:dataPicker];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (instancetype)initWithTitle:(NSString *)title select:(void (^)(NSString *selectProvince, NSString *selectCity))select {
    self = [ChinaCityViewController alertControllerWithTitle:title message:@"\n\n\n\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleActionSheet];
    if (nil != self) {
        _dataPicker = [[UIPickerView alloc] init];
        _dataPicker.delegate=self;
        _dataPicker.dataSource=self;
        _provinceArray = [ChinaCityClass cityArray];
        
        [self addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction) {
            NSArray *cityArray = [_provinceArray objectAtIndex:[_dataPicker selectedRowInComponent:0]];
            NSString *province = cityArray[0];
            NSString *city = [cityArray objectAtIndex:[_dataPicker selectedRowInComponent:1]+1];
            
            select(province, city);
        }]];
        [self addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    }
    
    return self;
}

- (instancetype)initWithPickerView:(UIPickerView *)pickerView delegate:(id)delegate {
    
    if (nil != self) {
        _dataPicker = pickerView;
        _delegate = delegate;
        
        _dataPicker.delegate=self;
        _dataPicker.dataSource=self;
        _provinceArray = [ChinaCityClass cityArray];
    }
    
    return self;
}

- (void)displayProvince:(NSString *)province {
    
    provinceIndex = [self indexOfProvince:province];
    
    [_dataPicker reloadComponent:0];
    [_dataPicker selectRow:provinceIndex inComponent:0 animated:YES];
    [_dataPicker selectRow:0 inComponent:1 animated:YES];
}

- (void)displayProvince:(NSString *)province city:(NSString *)city {
    
    provinceIndex = [self indexOfProvince:province];
    cityIndex = [self indexOfCity:city inProvince:province];
    
    [_dataPicker reloadAllComponents];
    [_dataPicker selectRow:provinceIndex inComponent:0 animated:YES];
    [_dataPicker selectRow:cityIndex inComponent:1 animated:YES];
}

- (NSUInteger)indexOfProvince:(NSString *)province {
    
    NSLog(@"%s %@", __func__, province);
    
    for (int i=0; i<_provinceArray.count; i++) {
        NSArray *cityArray = _provinceArray[i];
        
        NSRange range = [province rangeOfString:cityArray[0]];
        if (range.length > 0) {
            provinceIndex = i;
        }
    }
    
    if (provinceIndex >= _provinceArray.count) {
        provinceIndex = 0;
    }
    
    return provinceIndex;
}

- (NSUInteger)indexOfCity:(NSString *)city inProvince:(NSString *)province {
    provinceIndex = [self indexOfProvince:province];
    
    NSArray *cityArray = _provinceArray[provinceIndex];
    
    for (int i=1; i<cityArray.count; i++) {
        NSRange range = [city rangeOfString:cityArray[i]];
        if (range.length > 0) {
            cityIndex = i;
        }
    }
    
    if (cityIndex >= cityArray.count) {
        cityIndex = 1;
    }
    
    cityIndex -= 1;
    
    return cityIndex;
}

#pragma pickerView datasource

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSLog(@"%s", __func__);
    if (0 == component ) {
        provinceIndex = row;
        
        [_dataPicker reloadComponent:1];
        [_dataPicker selectRow:0 inComponent:1 animated:YES];
     }
    
    NSArray *cityArray = [_provinceArray objectAtIndex:[_dataPicker selectedRowInComponent:0]];
    NSString *province = cityArray[0];
    
    NSString *city;
    NSInteger selectedRow = [_dataPicker selectedRowInComponent:1];
    if (cityArray.count <= selectedRow) {
        city = cityArray[1];
    } else {
        city = [cityArray objectAtIndex:selectedRow+1];
    }
    
    if ([_delegate respondsToSelector:@selector(selectedProvince:selectedCity:)]) {
        [_delegate selectedProvince:province selectedCity:city];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    NSLog(@"%s", __func__);
    
//    if (pickerView.frame.size.width < 260) {
//        return pickerView.frame.size.width/2;
//    } else {
//        return 130.0;
//    }
    
    if (0 == component) {
        return 80;
    } else if (1 == component) {
        return 160;
    }
    
    return (pickerView.frame.size.width)/2;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    
    return 32;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger number;
    
    if (0 == component) {
        number = _provinceArray.count;
    } else if (1 == component) {
        number = [_provinceArray[provinceIndex] count] -1;
    }
    
    NSLog(@"%s %lu", __func__, (unsigned long)number);
    
    return number;
}
/*
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {

    if (0 == component) {
        
        NSArray *cityArray = _provinceArray[row];
        return cityArray[0];
    } else if (1 == component) {
        
        NSArray *cityArray = _provinceArray[provinceIndex];
        return cityArray[row+1];
    }
    
    return @"";
}*/

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = [[UILabel alloc] init];
    [label setFont:[UIFont systemFontOfSize:22]];
    
    NSLog(@"%s component:%ld row:%ld width0:%f width1:%f", __func__, (long)component, (long)row, [pickerView rowSizeForComponent:0].width, [pickerView rowSizeForComponent:1].width);

    if (0 == component) {
        
        NSArray *cityArray = _provinceArray[row];
        label.text = cityArray[0];
        [label setFrame:CGRectMake(0, 0, [pickerView rowSizeForComponent:0].width, [pickerView rowSizeForComponent:0].height)];
        [label setTextAlignment:NSTextAlignmentCenter];
    } else if (1 == component) {
        
        NSArray *cityArray = _provinceArray[provinceIndex];
        label.text = cityArray[row+1];
        [label setFrame:CGRectMake(0, 0, [pickerView rowSizeForComponent:1].width, [pickerView rowSizeForComponent:1].height)];
        [label setTextAlignment:NSTextAlignmentCenter];
    }

    return label;
}

@end
