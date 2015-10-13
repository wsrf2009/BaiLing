//
//  BirthdayTableViewController.m
//  CloudBox
//
//  Created by TTS on 15-4-27.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "BirthdayViewController.h"
#import "solarActionView.h"
#import "NSDateNSStringConvert.h"
//#import "M2DHudView.h"

#define INDEX_SOLAR     0 // 阳历
#define INDEX_LUNAR     1 // 农历

#define LeadingSpaceToSuperView         15.0f
#define TrailingSpaceToSuperView         15.0f
#define TopSpaceToSuperView         5.0f
#define BottomSpaceToSuperView      10.0f

@interface BirthdayViewController () <SolarActionDelegate, YYTXDeviceManagerDelegate>
{
    NSInteger selectedIndex;
    solarActionView *solarController;
}

@property (nonatomic, retain) IBOutlet UIButton *buttonDeleteBirthday;
@property (nonatomic, retain) IBOutlet UITextField *textFeildName;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControlDateType;
@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;
@property (nonatomic, retain) IBOutlet UILabel *labelNameLength;
//@property (nonatomic, retain) IBOutlet UILabel *labelNameMaxLength;
@property (nonatomic, retain) IBOutlet UILabel *labelBirthdayHint;

@property (nonatomic, retain) UIFont *fontForHint;

@end

@implementation BirthdayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%s", __func__);
    
    self.deviceManager.delegate = self;
    
    if (_isAddAlarm) {

    } else {
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
    
    solarController = nil;
    
    [_textFeildName setPlaceholder:NSLocalizedStringFromTable(@"pleaseInputLongevity", @"hint", nil)];
    
    [self updateUI];
    
    UIBarButtonItem *buttonSave;
    if (_isAddAlarm) {
        /* 添加生日闹铃 */
    } else {
        /* 修改闹铃 */
        buttonSave = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"save", @"hint", nil) style:UIBarButtonItemStyleDone target:self action:@selector(modifyBirthday)];
    }
    /* 设置工具条 */
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = [NSArray arrayWithObjects:space, buttonSave, space, nil];
    
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"birthdayAlarm", @"hint", nil)];
    
//    [_labelNameMaxLength setText:[NSString stringWithFormat:@"/%d", MAXNAMELENGTH]];
//    [_labelNameMaxLength setTextColor:[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f]];
    
    _fontForHint = [UIFont systemFontOfSize:15.0f];
    
    [_segmentedControlDateType setHidden:YES];
    
    NSString *hint = NSLocalizedStringFromTable(@"birthdayHint", @"hint", nil);
    // 创建可变属性化字符串
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:hint];
    NSUInteger length = [hint length];
    // 设置基本字体
    UIFont *baseFont = [UIFont systemFontOfSize:14.0f];
    [attrString addAttribute:NSFontAttributeName value:baseFont range:NSMakeRange(0, length)];
    UIColor *baseColor = [UIColor grayColor];
    [attrString addAttribute:NSForegroundColorAttributeName value:baseColor range:NSMakeRange(0, length)];
    
    NSRange range1 = [hint rangeOfString:@"“"];
    NSRange range2 = [hint rangeOfString:@"”"];
    if (range1.location != NSNotFound && range2.location != NSNotFound) {
        length = range2.location - range1.location-1;
        NSRange range = NSMakeRange(range1.location+1, length);
        //将需要提示的字体增大
        UIFont *biggerFont = [UIFont systemFontOfSize:15.0f];
        [attrString addAttribute:NSFontAttributeName value:biggerFont range:range];
        // 将需要提示的字体设为红色
        UIColor *color = [UIColor redColor];
        [attrString addAttribute:NSForegroundColorAttributeName value:color range:range];
    }
    [_labelBirthdayHint setAttributedText:attrString];
    
    [self hideEmptySeparators:self.tableView];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    [cell setSeparatorInset:UIEdgeInsetsMake(0, self.tableView.frame.size.width, 0, 0)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.deviceManager.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (0 == section) {
        if (_isAddAlarm) {
            return 0;
        } else {
            return 1;
        }
    } else if (1 == section) {
        return 1;
    } else if (2 == section) {
        return 1;
    } else if (3 == section) {
        return 1;
    }
    
    return 0;
}

- (BOOL)nameLengthCheck {
    NSInteger length = _textFeildName.text.length;
    NSString *str = [NSString stringWithFormat:@"%d/%d", length, MAXNAMELENGTH];
    NSRange range = [str rangeOfString:@"/"];
    NSLog(@"%s range:%@", __func__, NSStringFromRange(range));
    NSRange range1 = NSMakeRange(0, range.location);
    NSLog(@"%s range1:%@", __func__, NSStringFromRange(range1));
    BOOL statusCode;
    // 创建可变属性化字符串
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:str];
    // 设置基本字体
    UIFont *baseFont = [UIFont systemFontOfSize:15.0f];
    UIColor *baseColor = [UIColor grayColor];
    [attrString addAttributes:@{NSFontAttributeName:baseFont, NSForegroundColorAttributeName:baseColor} range:NSMakeRange(0, str.length)];
    
    if ((0 < length) && (length <= MAXNAMELENGTH)) {
        statusCode = YES;
    } else {
        [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range1];
        
        statusCode = NO;
    }
    
    _labelNameLength.attributedText = attrString;
    
    return statusCode;
}

- (void)updateUI {
    
    [_textFeildName setText:_birthday.who];
    
    [self nameLengthCheck];
    
    if (DATETYPE_SOLAR == _birthday.date_type) {
        /* 生日为阳历 */
        NSDate *date = [_birthday.date_value convertToNSDateFromDateString];
        
        [_datePicker setDatePickerMode:UIDatePickerModeDate];
        if (nil != date) {
            [_datePicker setDate:date animated:YES];
        }
        
        [_datePicker setHidden:NO];
        [_pickerView setHidden:YES];
            
        _segmentedControlDateType.selectedSegmentIndex = INDEX_SOLAR;
        selectedIndex = INDEX_SOLAR;

    } else if (DATETYPE_LUNAR == _birthday.date_type) {
        /* 生日为农历 */
        NSArray *arr = [_birthday.date_value componentsSeparatedByString:@"-"];
        if (arr.count >= 3) {
            NSInteger y = [arr[0] integerValue];
            NSInteger m = [arr[1] integerValue];
            NSInteger d = [arr[2] integerValue];
            
            if ((m>=1 && m<=12) || (m>=21 && m<= 32)) {
                BOOL isLeap = NO;
                
                if (m >= 21) {
                    m -= 20;
                    isLeap = YES;
                }
                
                if (nil == solarController) {
                    solarController = [[solarActionView alloc] initWithPicker:_pickerView delegate:self];
                }
                [solarController setLunarYear:y lunarMonth:m isLeapMonth:isLeap lunarDay:d];
            }
        }

        [_datePicker setHidden:YES];
        [_pickerView setHidden:NO];
            
        _segmentedControlDateType.selectedSegmentIndex = INDEX_LUNAR;
        selectedIndex = INDEX_LUNAR;
    }
}

- (IBAction)buttonDeleteBirthdayClick:(id)sender {
    NSString *message = NSLocalizedStringFromTable(@"deleteThisBirthday?", @"hint", nil);
    NSString *buttonCancelTitle = NSLocalizedStringFromTable(@"cancel", @"hint", nil);
    NSString *buttonDeleteTitle = NSLocalizedStringFromTable(@"delete", @"hint", nil);
    
    if ([SystemToolClass systemVersionIsNotLessThan:@"8.0"]) {
        /* IOS8.0及以后 */
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[SystemToolClass appName] message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:buttonCancelTitle style:UIAlertActionStyleDefault handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:buttonDeleteTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
            [self deleteBirthday];
        }]];
        
        if (nil != alertController) {
            NSLog(@"%s +++++++++++++", __func__);
            [self presentViewController:alertController animated:YES completion:nil];
        }
    } else {
        /* IOS6.0 及以后，但是低于IOS8.0 */
        UICustomAlertView *alertView = [[UICustomAlertView alloc] initWithTitle:[SystemToolClass appName] message:message delegate:self cancelButtonTitle:buttonCancelTitle otherButtonTitles:buttonDeleteTitle, nil];
        NSLog(@"%s ----------------", __func__);
        [alertView showAlertViewWithCompleteBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
            if ([title isEqualToString:buttonDeleteTitle]) {
                [self deleteBirthday];
            }
        }];
    }
}

- (IBAction)textFieldNameChange:(UITextField *)textField {
    
    if (textField.text.length >= 1) {
        /* 检查是否以空格开始 */
        NSRange range1 = [textField.text rangeOfString:@" "];
        if (0 == range1.location) {
            [self showMessage:NSLocalizedStringFromTable(@"invalidCharacterOrFormatForLongevityName", @"hint", nil) messageType:0];
            textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [self nameLengthCheck];
            return;
        }
        
        /* 检查是否以空格结束 */
        NSString *sub = [textField.text substringFromIndex:textField.text.length-1];
        if ([sub isEqualToString:@" "]) {
            [self showMessage:NSLocalizedStringFromTable(@"invalidCharacterOrFormatForLongevityName", @"hint", nil) messageType:0];
            textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [self nameLengthCheck];
            return;
        }
        
        /* 检查是否包含回车符 */
        NSRange range2 = [textField.text rangeOfString:@"\n"];
        if (NSNotFound != range2.location) {
            [self showMessage:NSLocalizedStringFromTable(@"invalidCharacterOrFormatForLongevityName", @"hint", nil) messageType:0];
            textField.text = [textField.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            [self nameLengthCheck];
            return;
        }
    }
    
    _birthday.who = textField.text;
    [self nameLengthCheck];
}

- (IBAction)datePickerValueChange:(id)sender {
    NSString *date = [_datePicker.date getDateString];

    _birthday.date_value = date;
    _birthday.date_type = DATETYPE_SOLAR;
}

- (IBAction)segmentedControlClick_DateType:(UISegmentedControl *)segmented {
    NSInteger index = segmented.selectedSegmentIndex;
    
    NSLog(@"%s %ld", __func__, (long)index);
    
    if (index == selectedIndex) {
        // 点击相同的标签则退出，如连续两次点击农历
        return;
    }
    
    selectedIndex = index;
    
    if (INDEX_SOLAR == selectedIndex) {
        
        /*
         * 农历转阳历 
         */
        if (DATETYPE_LUNAR == _birthday.date_type) {
            
            /* 将农历生日改为阳历生日 */
            _birthday.date_value = [self solarFromLarkLunar:_birthday.date_value];
            _birthday.date_type = DATETYPE_SOLAR;
        }
        
        [self updateUI];
    } else if (INDEX_LUNAR == selectedIndex) {
        /*
         * 阳历转农历
         */

        /* 将阳历转为小写农历 */
        NSDate *date = [_birthday.date_value convertToNSDateFromDateString];
        NSDictionary *dic1 = [solarActionView lunarArrayFromSolarDate:date];
        NSString *sYear = [dic1 objectForKey:SolarDicKeyForYear];
        NSString *sMonth = [dic1 objectForKey:SolarDicKeyForMonth];
        NSString *sDay = [dic1 objectForKey:SolarDicKeyForDay];
        NSString *sLeap = [dic1 objectForKey:SolarDicKeyForLeap];
        
        NSInteger year = [sYear integerValue];
        NSInteger month = [sMonth integerValue];
        NSInteger day = [sDay integerValue];
        
        BOOL isLeap = NO;
        if ([sLeap isEqualToString:SolarLeapMonth]) {
            isLeap = YES;
        }
        
        if (isLeap) {
            month += 20;
        }
        
        _birthday.date_value = [NSString stringWithFormat:@"%ld-%ld-%ld", (long)year, (long)month, (long)day];
        _birthday.date_type = DATETYPE_LUNAR;
        
        [self updateUI];
    }
}

- (void)actionSheetSolarDate:(NSString *)year Month:(NSString *)month Day:(NSString *)day isLeapMonth:(BOOL)yesOrNo {
    NSInteger m = [month integerValue];
    
    if (yesOrNo) {
        m += 20;
    }
    
    _birthday.date_value = [NSString stringWithFormat:@"%@-%ld-%@", year, (long)m, day];
    _birthday.date_type = DATETYPE_LUNAR;
    
    NSLog(@"%s %@", __func__, _birthday.date_value);
    
    if (INDEX_SOLAR == selectedIndex) {
        _birthday.date_value = [self solarFromLarkLunar:_birthday.date_value];
        _birthday.date_type = DATETYPE_SOLAR;
    }
}

/* 将小写的农历转为阳历 2014-29-01 ==> 2014-10-24 */
- (NSString *)solarFromLarkLunar:(NSString *)lunarDate {
    
    if (nil != lunarDate) {
    
        /* 将百灵的小写农历转为阳历 */
        NSArray *arr = [lunarDate componentsSeparatedByString:@"-"];
    
        if (arr.count >= 3) {
            /* 区分是否闰月 */
            NSInteger y = [arr[0] integerValue];
            NSInteger m = [arr[1] integerValue];
            NSInteger d = [arr[2] integerValue];
        
            if ((m>=1 && m<=12) || (m>=21 && m<= 32)) {
                BOOL isLeap = NO;
            
                if (m >= 21) {
                    m -= 20;
                    isLeap = YES;
                }
            
                NSDictionary *dic = [solarActionView solarFromLunar:y lunarMonth:m isLeapMonth:isLeap lunarDay:d]; // 将小写农历转为阳历
                if (nil != dic) {
                    NSString *stringYear = [dic objectForKey:SolarDicKeyForYear];
                    NSString *stringMonth = [dic objectForKey:SolarDicKeyForMonth];
                    NSString *stringDay = [dic objectForKey:SolarDicKeyForDay];
                
                    NSLog(@"%s stringYear:%@, stringMonth:%@ sDay:%@", __func__, stringYear, stringMonth, stringDay);
                
                    return [NSString stringWithFormat:@"%@-%@-%@", stringYear, stringMonth, stringDay];
                }
            }
        }
    }
    
    return [[NSDate date] getDateString];
}

/* 将小写的农历转为大写的农历 2014-29-01 ==> 二零一四年润九月初一 */
+ (NSString *)tileLunarFromLarkLunar:(NSString *)lunarDate {
    NSArray *arr = [lunarDate componentsSeparatedByString:@"-"];
    if (arr.count >= 3) {
        /* 区分是否闰月 */
        NSInteger intYear = [arr[0] integerValue];
        NSInteger intMonth = [arr[1] integerValue];
        NSInteger intDay = [arr[2] integerValue];
        
        if ((intMonth>=1 && intMonth<=12) || (intMonth>=21 && intMonth<= 32)) {
            BOOL isLeap = NO;
            
            if (intMonth >= 21) {
                intMonth -= 20;
                isLeap = YES;
            }
            
            NSDictionary *dic1 = [solarActionView formatConversionLunar:intYear lunarMonth:intMonth lunarRunYue:isLeap lunarDay:intDay];
            NSString *strYear = [dic1 objectForKey:SolarDicKeyForYear];
            NSString *strMonth = [dic1 objectForKey:SolarDicKeyForMonth];
            NSString *strDay = [dic1 objectForKey:SolarDicKeyForDay];
            NSString *strIsLeap = [dic1 objectForKey:SolarDicKeyForLeap];
            
            NSDictionary *dic = [solarActionView titleLunarFromLunarYear:strYear lunarMonth:strMonth lunarRunYue:strIsLeap lunarDay:strDay];
            
            NSString *strTitleYear = [dic objectForKey:SolarDicKeyForYear];
            NSString *strTitleMonth = [dic objectForKey:SolarDicKeyForMonth];
            NSString *strTitleDay = [dic objectForKey:SolarDicKeyForDay];
            
            return [NSString stringWithFormat:@"%@年%@月%@", strTitleYear, strTitleMonth, strTitleDay];
        }
    }
    
    return @"";
}

#pragma Mark:生日信息数据源

- (BOOL)inputParametersIsValid {

    _birthday.who = [_textFeildName text];
    
    /* 检查字数是否符合要求 */
    if (![self nameLengthCheck]) {
        
        if (_birthday.who.length <= 0) {
            [self showMessage:NSLocalizedStringFromTable(@"theLongevityNameIsEmpty", @"hint", nil) messageType:0];
        } else {
            [self showMessage:NSLocalizedStringFromTable(@"longevityNameIsTooLong", @"hint", nil) messageType:0];
        }
        
        [_textFeildName becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        
        return NO;
    }
    
    /* 删除其中的空格和回车 */
    NSString *str = [_birthday.who stringByReplacingOccurrencesOfString:@" " withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    [_textFeildName setText:str];
    if (str.length <= 0) {
        [_textFeildName setText:@""];
        [_textFeildName becomeFirstResponder];
        [self showMessage:NSLocalizedStringFromTable(@"theLongevityInvalid", @"hint", nil) messageType:0];
        return NO;
    } else {
        _birthday.who = str;
    }

    return YES;
}

- (void)modifyBirthday {
    
    // 保存生日修改
    _birthday.who = [_textFeildName text];
    
    if (![self nameLengthCheck]) {
        
        if (_birthday.who.length <= 0) {
            [self showMessage:NSLocalizedStringFromTable(@"pleaseInputLongevity", @"hint", nil) messageType:0];
        } else {
            [self showMessage:NSLocalizedStringFromTable(@"longevityNameIsTooLong", @"hint", nil) messageType:0];
        }
        
        [_textFeildName becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        
        return;
    }
    
    [self showBusying:NSLocalizedStringFromTable(@"saving", @"hint", nil)];

    NSString *successfulHint = NSLocalizedStringFromTable(@"modifyBirthdaySuccessful", @"hint", nil);
    NSString *failedHint = NSLocalizedStringFromTable(@"modifyBirthdayFailed", @"hint", nil);
    NSString *successful = [NSString stringWithFormat:successfulHint, _birthday.who];
    
    [self.deviceManager.device modifyBirthday:_birthday parameter:@{DevicePlayTTSWhenOperationSuccessful:successful, DevicePlayTTSWhenOperationFailed:failedHint} completionBlock:^(YYTXDeviceReturnCode code) {
        
        dispatch_async(dispatch_get_main_queue(), ^{

            [self removeEffectView];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
}

- (void)deleteBirthday {
    NSString *successful = NSLocalizedStringFromTable(@"deleteSuccessful", @"hint", nil);
    NSString *failed = NSLocalizedStringFromTable(@"deleteFailed", @"hint", nil);
    
    [self showActiviting];
    
    [self.deviceManager.device deleteBirthday:_birthday.ID params:@{DevicePlayTTSWhenOperationSuccessful:successful, DevicePlayTTSWhenOperationFailed:failed} completionBlock:^(YYTXDeviceReturnCode code) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self removeEffectView];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
}

- (void)addBirthday:(void (^)(void))popVC {
    
    NSLog(@"%s", __func__);
    
    // 添加生日
    if (![self inputParametersIsValid]) {
        return;
    }

    [self showBusying:NSLocalizedStringFromTable(@"saving", @"hint", nil)];
    
    NSString *successfulHint = NSLocalizedStringFromTable(@"insertBirthdayAlarmSuccessful", @"hint", nil);
    NSString *failedHint = NSLocalizedStringFromTable(@"insertBirthdayAlarmFailed", @"hint", nil);
    NSString *successful = [NSString stringWithFormat:successfulHint, _birthday.who];
    __block BirthdayViewController *birthdayVC = self;
    [self.deviceManager.device addBirthday:_birthday parameter:@{DevicePlayTTSWhenOperationSuccessful:successful, DevicePlayTTSWhenOperationFailed:failedHint}  completionBlock:^(YYTXDeviceReturnCode code) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [birthdayVC removeEffectView];
            [birthdayVC.navigationController popViewControllerAnimated:YES];
        });
    }];
}

@end
